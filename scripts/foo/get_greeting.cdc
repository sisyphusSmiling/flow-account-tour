import "Foo"

pub fun main(): String {
    return Foo.borrowBarPublic().getGreeting()
}