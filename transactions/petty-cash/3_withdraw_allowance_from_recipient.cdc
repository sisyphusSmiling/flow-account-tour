import "FungibleToken"
import "FlowToken"
import "PettyCash"

/// Withdraws from the signer's Recipient resource and deposits to signer's FlowToken Vault
/// Note that this fails if the requested amount exceeds the allowance limit
///
transaction(withdrawalAmount: UFix64) {

    let recipient: &PettyCash.Recipient
    let flowVault: &FungibleToken.Vault

    prepare(signer: AuthAccount) {
        // Borrow a reference to the Recipient resource in the signer's account
        self.recipient = signer.borrow<&PettyCash.Recipient>(from: PettyCash.RecipientStoragePath)
            ?? panic("Signer does not have Recipient configured")
        
        // Get a reference to the signer's FlowToken vault
        self.flowVault = signer.borrow<&FungibleToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Signer does not have a FlowToken Vault")
    }

    execute {
        // Withdraw from Recipient's Allowance
        let allowanceVault <- self.recipient.withdraw(amount: withdrawalAmount)
        
        // Deposit to signer's FlowToken Vault
        self.flowVault.deposit(from: <-allowanceVault)
    }
}
