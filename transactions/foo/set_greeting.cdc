import "Foo"

/// Sets the given greeting in the signer's Foo.Bar resource
///
transaction(newGreeting: String) {

    let bar: &Foo.Bar

    prepare(signer: AuthAccount) {
        self.bar = signer.borrow<&Foo.Bar>(from: Foo.StoragePath)!
    }

    execute {
        self.bar.setGreeting(newGreeting)
    }

    post {
        self.bar.getGreeting() == newGreeting: "Greeting was not set properly"
    }
}
