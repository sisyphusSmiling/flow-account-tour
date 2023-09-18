/// Simple contract demonstrating deployment, Capability linking & retrieval, and deployment account configuration
// on initialization.
///
pub contract Foo {
    
    /* Canonical Paths */
    //
    pub let StoragePath: StoragePath
    pub let PublicPath: PublicPath

    /* Events */
    //
    pub event Greeting(id: UInt64, greeting: String, from: Address?)
    pub event GreetingSet(id: UInt64, greeting: String, at: Address?)

    /* --- Bar --- */
    //
    /// Simple queryable public interface
    ///
    pub resource interface BarPublic {
        pub view fun getGreeting(): String
    }

    /// Simple resource containing a greeting mutable by its owner
    ///
    pub resource Bar : BarPublic {
        /// The contained greeting string
        access(self) var greeting: String

        init() {
            self.greeting = "Hello, World!"
        }

        /* BarPublic Conformance */
        //
        /// Retrieves the contained greeting, also emitting the `Greeting` event
        /// Note: You wouldn't normally emit an event in a getter method, but it's done here for demonstration purposes
        ///
        pub view fun getGreeting(): String {
            emit Greeting(id: self.uuid, greeting: self.greeting, from: self.owner?.address)
            return self.greeting
        }

        /* Resource Owner Functionality */
        //
        /// Sets the contained greeting, emitting the `GreetingSet` event
        ///
        pub fun setGreeting(_ greeting: String) {
            self.greeting = greeting
            emit GreetingSet(id: self.uuid, greeting: self.greeting, at: self.owner?.address)
        }
    }

    /* --- Contract Methods --- */
    //
    /// Creates and returns a new Bar resource
    ///
    pub fun createNewBar(): @Bar {
        return <-create Bar()
    }

    /// Allows caller to easily retrieve a reference to the stored Bar resource as a queryable BarPublic
    /// Notice that though the reference targets the underlying Bar resource configured on contract init, the reference
    /// only enables access to the methods exposed via the BarPulic interface.
    ///
    pub fun borrowBarPublic(): &{BarPublic} {
        return self.account.getCapability<&{BarPublic}>(self.PublicPath).borrow() ?? panic("Could not borrow BarPublic")
    }

    init() {
        // Set contract fields
        self.StoragePath = /storage/FooBar
        self.PublicPath = /public/FooBar

        // Configure the deployment account with a Bar resource
        self.account.save(<-create Bar(), to: self.StoragePath)
        self.account.link<&{BarPublic}>(self.PublicPath, target: self.StoragePath)
    }
}
