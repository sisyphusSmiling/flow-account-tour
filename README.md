# Tour of Flow's Account Model

> The place to get started utilizing accounts on Flow

## Accounts on Flow

## Adding Custom Account Functionality

We'll explore adding custom functionality to accounts with contracts and their defined resources.

In the [`PettyCash` contract](./contracts/PettyCash.cdc), we define an `Allowance` resource which enables withdrawals from a FungibleToken Vault up to a defined limit. The owner of the `Allowance` keeps it in their account and can reset the limit to any amount at any time.

On contract initialization, an `Allowance` is configured in the deploying account ready to set a limit and issue to a recipient.

But an allowance typically has a recipient, so we also define a `Recipient` which maintains a Capability on the `Allowance`. When the actual recipient of the allowance wants to access their funds, they can withdraw from the source account's FungibleToken Vault, but only up to the amount specified in the `Allowance` resource regardless of how many funds are actually available in the underlying FungibleToken Vault.

This is a great illustration of the power of not only composabile standards, but also of how the abstracted account model on Flow unlocks powerful customization of user accounts via Capability-based security on contract-defined resources.

## Account Linking

Capabilities enable access to a set of functionality on those objects they target. However, Capabilities are not limitted to targetting resources, but can also target account objects themselves.

This means there are two ways to access accounts in Flow. You can either custody a key for the account you're trying to access and sign transactions authorizing you to access the account object and its contents or you can access the account via a Capability.

Account access via Capabilities opens the door to all sorts of unique applications. Accounts can store Capabilities on other accounts, enabling a network of linked accounts. Or, think of a contract that creates any number of accounts and maintains access to those accounts via Capabilities. Alternatively, we can have onchain equivalents of multisig schemes, allowing us to assign role-based access or time-restricted or other conditional logic.