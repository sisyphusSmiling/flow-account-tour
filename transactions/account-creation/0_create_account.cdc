/// Creates a new account, funding creation via the signing account
///
transaction {
    prepare(signer: AuthAccount) {
        let newAccount: AuthAccount = AuthAccount(payer: signer)
    }
}