/// Creates a new account, funding creation via the signing account
///
transaction(originatingPublicKey: String) {
    prepare(signer: AuthAccount) {
        let newAccount: AuthAccount = AuthAccount(payer: signer)

        // Create a public key for the proxy account from the passed in string
        let key: PublicKey = PublicKey(
            publicKey: originatingPublicKey.decodeHex(),
            signatureAlgorithm: SignatureAlgorithm.ECDSA_P256
        )

        // Add the key to the new account
        newAccount.keys.add(
            publicKey: key,
            hashAlgorithm: HashAlgorithm.SHA3_256,
            weight: 1000.0
        )
    }
}