import "FungibleToken"

/// An example of a contract that enables a user to set an allowance for a specific token Provider
/// NOTE: This is presented for demonstration purposes and is not sufficiently robust for use in production
///
pub contract PettyCash {

    pub let AllowanceStoragePath: StoragePath
    pub let AllowancePublicPath: PublicPath
    pub let RecipientStoragePath: StoragePath
    pub let RecipientPrivatePath: PrivatePath

    pub event AllowanceSet(id: UInt64, amount: UFix64, issuer: Address?)

    /* --- Allowance --- */
    //
    /// Enables querying of the remaining allowance
    ///
    pub resource interface AllowancePublic {
        /// Queries the remaining allowance
        pub view fun getRemainingAllowance(): UFix64
    }

    /// Resource that enables withdrawal from a FungibleToken Vault up to a set allowance. The allowance limit can be
    /// reset by the owner of the resource
    ///
    pub resource Allowance : AllowancePublic, FungibleToken.Provider {
        /// The withdrawal limit available via this Allowance resource
        access(self) var limit: UFix64
        /// The amount withdrawn since limit was last reset
        access(self) var withdrawn: UFix64
        /// Capability on the underlying FungibleToken Vault enabling withdrawal of funds
        access(self) let providerCapability: Capability<&{FungibleToken.Provider}>

        init(
            limit: UFix64,
            providerCapability: Capability<&{FungibleToken.Provider}>
        ) {
            pre {
                providerCapability.check(): "Invalid Provider Capability"
            }
            self.limit = limit
            self.withdrawn = 0.0
            self.providerCapability = providerCapability
        }

        /* AllowancePublic conformance */
        //
        pub view fun getRemainingAllowance(): UFix64 {
            return self.limit - self.withdrawn
        }

        /* FungibleToken.Provider conformance */
        //
        /// Withdraws the specified amount from the underlying FungibleToken Provider
        ///
        pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
            pre {
                self.withdrawn + amount <= self.limit: "Cannot withdraw more than the allowance limit"
            }
            self.withdrawn = self.withdrawn + amount
            let provider: &{FungibleToken.Provider} = self.providerCapability.borrow()
                ?? panic("Problem with Provider Capability")
            return <- provider.withdraw(amount: amount)
        }

        /* Resource Owner funcationality */
        //
        /// Resets the allowance limit to the specified amount and resets the amount withdrawn to 0.0
        pub fun resetLimit(amount: UFix64) {
            post {
                self.withdrawn == 0.0 && self.getRemainingAllowance() == amount: 
                    "Limit was not properly reset"
            }
            self.limit = amount
            self.withdrawn = 0.0

            emit AllowanceSet(id: self.uuid, amount: amount, issuer: self.owner?.address)
        }
    }

    /// Enables an Allowance recipient to store and access their issued Allowance Capability
    ///
    pub resource Recipient : AllowancePublic, FungibleToken.Provider {
        /// Capability on the Allowance resource enabling withdrawal of funds
        access(self) var allowance: Capability<&{AllowancePublic, FungibleToken.Provider}>

        init(allowance: Capability<&{AllowancePublic, FungibleToken.Provider}>) {
            pre {
                allowance.check(): "Invalid allowance Capability"
            }
            self.allowance = allowance
        }
        
        /* AllowancePublic conformance */
        //
        pub view fun getRemainingAllowance(): UFix64 {
            return self.borrowAllowance().getRemainingAllowance()
        }

        /* FungibleToken.Provider conformance */
        //
        /// Withdraws the specified amount from the Allowance resource
        ///
        pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
            return <- self.borrowAllowance().withdraw(amount: amount)
        }

        /* Helper method */
        //
        /// Returns a reference to the Allowance resource or reverts is Capability is invalid
        ///
        access(self) fun borrowAllowance(): &{AllowancePublic, FungibleToken.Provider} {
            return self.allowance.borrow() ?? panic("Problem with Allowance Capability")
        }
    }

    /// Returns a new Allowance resource
    ///
    pub fun createNewAllowance(
        limit: UFix64,
        providerCapability: Capability<&{FungibleToken.Provider}>
    ): @Allowance {
        return <- create Allowance(limit: limit, providerCapability: providerCapability)
    }

    /// Returns a new Recipient resource
    ///
    pub fun createNewRecipient(sourceAllowance: Capability<&{AllowancePublic, FungibleToken.Provider}>): @Recipient {
        return <- create Recipient(allowance: sourceAllowance)
    }

    init() {
        self.AllowanceStoragePath = /storage/PettyCashAllowance
        self.AllowancePublicPath = /public/PettyCashAllowancePublic
        self.RecipientStoragePath = /storage/PettyCashRecipient
        self.RecipientPrivatePath = /private/PettyCashRecipient

        // Configure the deploying account with an Allowance resource using their FlowToken Vault
        if !self.account.getCapability<&{FungibleToken.Provider}>(/private/flowTokenPettyCashAllowance).check() {
            self.account.unlink(/private/flowTokenPettyCashAllowance)
            self.account.link<&{FungibleToken.Provider}>(
                /private/flowTokenPettyCashAllowance,
                target: /storage/flowTokenVault
            )
        }
        let flowProviderCapability: Capability<&AnyResource{FungibleToken.Provider}> = self.account
            .getCapability<&{FungibleToken.Provider}>(/private/flowTokenPettyCashAllowance)

        // Create, save and link an Allowance resource to the deploying account
        let newAllowance: @PettyCash.Allowance <- create Allowance(limit: 0.0, providerCapability: flowProviderCapability)
        self.account.save(<-newAllowance, to: self.AllowanceStoragePath)
        self.account.link<&{AllowancePublic}>(self.AllowancePublicPath, target: self.AllowanceStoragePath)
        self.account.link<&{AllowancePublic, FungibleToken.Provider}>(
            self.RecipientPrivatePath,
            target: self.AllowanceStoragePath
        )
    }
}
