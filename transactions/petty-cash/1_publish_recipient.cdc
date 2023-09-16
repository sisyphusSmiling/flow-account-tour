import "FungibleToken"
import "PettyCash"

/// Publishes a Capability on the signer's Allowance for the specified recipient
///
transaction(recipientAddress: Address) {

    prepare(signer: AuthAccount) {
        let allowanceCapability = signer.getCapability<&{PettyCash.AllowancePublic, FungibleToken.Provider}>(
                PettyCash.RecipientPrivatePath
            )

        assert(allowanceCapability.check(), message: "Invalid Allowance Capability")

        signer.inbox.publish(allowanceCapability, name: "FlowTokenAllowance", recipient: recipientAddress)
    }
}
