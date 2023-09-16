import "FungibleToken"
import "PettyCash"

/// Claims a published Capability on an Allowance and saves it in a newly configured Recipient resource in the signer's
/// account storage.
///
transaction(issuerAddress: Address) {

    prepare(signer: AuthAccount) {
        // Claim the published Capability
        let allowanceCapability = signer.inbox.claim<&{PettyCash.AllowancePublic, FungibleToken.Provider}>("FlowTokenAllowance", provider: issuerAddress)
            ?? panic("No Allowance Capability to claim")

        // Create a new Recipient to store the claimed Capability & save in storage
        let newRecipient: @PettyCash.Recipient <- PettyCash.createNewRecipient(sourceAllowance: allowanceCapability)
        signer.save(<-newRecipient, to: PettyCash.RecipientStoragePath)
    }
}
