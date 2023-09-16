import "PettyCash"

pub fun main(address: Address): UFix64 {
    return getAccount(address).getCapability<&{PettyCash.AllowancePublic}>(PettyCash.AllowancePublicPath).borrow()?.getRemainingAllowance()
        ?? panic("Could not borrow a reference to the AllowancePublic at the given Address")
}