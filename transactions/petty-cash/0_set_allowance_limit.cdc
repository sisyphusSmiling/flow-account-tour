import "PettyCash"

/// Sets the limit of the signer's Allowance as specified
///
transaction(limit: UFix64) {

    let allowance: &PettyCash.Allowance

    prepare(signer: AuthAccount) {
        // Borrow a reference to the Allowance resource in the signer's account
        self.allowance = signer.borrow<&PettyCash.Allowance>(from: PettyCash.AllowanceStoragePath)
            ?? panic("Signer does not have Allowance configured")
    }

    execute {
        // Reset the limit
        self.allowance.resetLimit(amount: limit)
    }
}
