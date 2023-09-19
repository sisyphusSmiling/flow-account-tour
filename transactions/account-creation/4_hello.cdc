import "Foo"

/// Simple dry run transaction to demonstrate sending a multisig transaction
///
transaction {
    prepare(signer: AuthAccount) {
        signer.borrow<&Foo.Bar>(from: Foo.StoragePath)?.sayGreeting() ?? panic("Bar resource not found!")
    }
}