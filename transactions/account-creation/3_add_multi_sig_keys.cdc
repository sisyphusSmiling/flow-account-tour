/// Adds the given keys to the signing account at the specified weights. Assumes ECDSA_P256 keys & SHA2_256 hash algos
///
transaction(publicKeys: [String], weights: [UFix64]) {

    prepare(signer: AuthAccount) {

        assert(publicKeys.length == weights.length, message: "Mismatched number of keys and weights")

        // Iterate over given keys, adding each to the new account at their corresponding weights
        for i, key in publicKeys {
            let pubKey = PublicKey(
                    publicKey: key.decodeHex(),
                    signatureAlgorithm: SignatureAlgorithm.ECDSA_P256
                )

            signer.keys.add(
                publicKey: pubKey,
                hashAlgorithm: HashAlgorithm.SHA3_256,
                weight: weights[i]
            )
        }
    }
}