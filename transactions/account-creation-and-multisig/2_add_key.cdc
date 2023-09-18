/// Adds a given key to signing account as ECDSA_P256 & SHA3_256 at 1000.0 weight
///
transaction(originatingPublicKey: String) {

    prepare(signer: AuthAccount) {
        // Create a public key for the proxy account from the passed in string
        let key: PublicKey = PublicKey(
            publicKey: originatingPublicKey.decodeHex(),
            signatureAlgorithm: SignatureAlgorithm.ECDSA_P256
        )

        // Add the key to the new account
        signer.keys.add(
            publicKey: key,
            hashAlgorithm: HashAlgorithm.SHA3_256,
            weight: 1000.0
        )
    }
}