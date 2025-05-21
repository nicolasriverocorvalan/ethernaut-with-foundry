# Impersonator

`SlockDotIt’s` new product, `ECLocker`, integrates IoT gate locks with Solidity smart contracts, utilizing Ethereum ECDSA for authorization. When a valid signature is sent to the lock, the system emits an `Open` event, unlocking doors for the authorized controller. `SlockDotIt` has hired you to assess the security of this product before its launch. Can you compromise the system in a way that anyone can open the door?

## Vulnerability - Signature Malleability

ECDSA signatures, particularly the s component, are inherently malleable. This means that for a given message and private key, there can be two valid signatures (r, s, v) and (r, n-s, v') where 'n' is the order of the elliptic curve (secp256k1). If the smart contract doesn't specifically enforce that s must be in the lower half of the curve's order (e.g., s <= n/2), an attacker can take a legitimate signature and create a different, but equally valid, signature.


### Attack scenario

1. Legitimate user signs: An authorized controller (let's say Alice) signs a message to open the door. This generates a valid signature (r,s,v).
2. An attacker (Bob) intercepts this valid signature.
3. Bob calculates s′=n−s (attacker mangles signature, where n is the order of the secp256k1 curve). He may also need to adjust v (the recovery ID) accordingly.
4. Bob then sends a transaction to the ECLocker smart contract with the mangled signature (replays munged signature: r,s′,v′).
5. If the smart contract only relies on ecrecover to verify the signer's address and doesn't explicitly check the s value for malleability, it will consider Bob's manipulated signature as valid, as it recovers Alice's address.
6. The system emits an Open event, and the door unlocks for Bob, even though he didn't possess Alice's private key.

### Other potential vulns

* Lack of Nonce/Replay Protection: If the signed message does not include a unique, incrementing nonce or a time-based expiration, an attacker could simply replay a valid signature multiple times. Even if the signature isn't malleable, a replayed signature would still open the door.
* Missing Chain ID: If the signed message does not include the Ethereum chain ID, a signature generated on one network (e.g., testnet) could potentially be replayed on another network (e.g., mainnet) if the contract is deployed with the same logic on both.
* Weak Message Hashing/EIP-712 Misconfiguration: If the message being signed is not properly structured and hashed (e.g., using abi.encodePacked() incorrectly with multiple parameters), it could lead to hash collisions or allow an attacker to craft a message that, when signed, results in an unexpected outcome when verified by the contract.

## Attack

### Signature malleability combined with inconsistent hashing for usedSignatures

The contract attempts to prevent replay attacks by marking signatures as used in the `usedSignatures` mapping. However, the way it calculates the hash for tracking used signatures is inconsistent with standard ECDSA malleability principles.

For any given `(r, s, v)` signature, a valid alternative `(r, N - s, v')` exists, where N is the order of the secp256k1 curve (approximately 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141). Both signatures recover the same public key/address.

`ecrecover(msgHash, v, r, s)` call will return the correct controller address for both the original `(r, s, v)` and the malleable `(r, N - s, v')` signature, assuming the msgHash is the same.

Crucial flaw lies in how usedSignatures is checked:
```bash
bytes32 signatureHash = keccak256(abi.encode([uint256(r), uint256(s), uint256(v)]));
require (!usedSignatures[signatureHash], SignatureAlreadyUsed());
usedSignatures[signatureHash] = true;
```

This signatureHash is computed directly from r, s, and v. If the original signature (r, s, v) is used, its signatureHash is marked as true. If an attacker then provides the malleable signature (r, N - s, v'), the keccak256(abi.encode([uint256(r), uint256(N - s), uint256(v')])) `will result in a different signatureHash`.

### Anyone Can Open the Door

* Legitimate flow:
1. An ECLocker instance is deployed. Let's say Alice (the controller) is set during deployment or a later changeController call.
2. Alice uses her private key to sign a message (effectively msgHash) and calls open(v, r, s).
3. `_isValidSignature` is called.
4. `ecrecover(msgHash, v, r, s)` successfully recovers Alice's address.
5. `signatureHash_A = keccak256(abi.encode([uint256(r), uint256(s), uint256(v)]))` is computed.
6. `usedSignatures[signatureHash_A]` is false (initially).
7. `usedSignatures[signatureHash_A]` is set to `true`.
8. Door open.

* Attacker's flow:
1. Bob observes Alice's transaction and obtains the r, s, and v values.
2. Bob calculates `s'=N−s` (where N is the secp256k1 curve order). He also determines the correct v' for the malleated signature.
3. Bob then calls `open(v', r, s')` on the same ECLocker instance.
4. `_isValidSignature` is called.
5. `ecrecover(msgHash, v', r, s')` also successfully recovers Alice's address because `(r, N - s, v')` is a valid signature for the same message signed by Alice.
6. `signatureHash_B = keccak256(abi.encode([uint256(r), uint256(s'), uint256(v')]))` is computed.
7. Since s' is different from s, `signatureHash_B` will be different from `signatureHash_A`.
8. `require (!usedSignatures[signatureHash], SignatureAlreadyUsed());` check passes.
9. `usedSignatures[signatureHash_B]` is set to `true`.
10. Door opens for Bob.

```bash
== Logs ==
  Interacting with Impersonator at: 0x6fB2f9F7aA47A5D0299B14c16E531bb426aF9923
  Interacting with ECLocker at: 0xdD1376DA1A988D9c35562C9Aa06A68d8a5fc7237
  Current ECLocker controller: 0x42069d82D9592991704e6E41BF2589a76eAd1A91
  
--- ORIGINAL SIGNATURE (extracted from event log) ---
  Original r:
  0x1932cb842d3e27f54f79f7be0289437381ba2410fdefbae36850bee9c41e3b91
  Original s:
  0x78489c64a0db16c40ef986beccc8f069ad5041e5b992d76fe76bba057d9abff2
  Original v: 27
  
--- MALLEABLE SIGNATURE FOR ATTACK ---
  Malleated r (same):
  0x1932cb842d3e27f54f79f7be0289437381ba2410fdefbae36850bee9c41e3b91
  Malleated s (N - s):
  0x87b7639b5f24e93bf106794133370f950d5e9b00f5b5c8cbd866a487529b814f
  Malleated s (N - s):
  0x87b7639b5f24e93bf106794133370f950d5e9b00f5b5c8cbd866a487529b814f
  Malleated v (adjusted): 28
  Malleated s (uint): 61386255033295324479228690463930298567438841096413154552415886062180481335631
  Targeting new controller: 0x0000000000000000000000000000000000000000
  
Calling changeController() with malleable signature to set controller to 0x0...
  changeController() call SUCCESSFUL (VULNERABILITY CONFIRMED).
  New ECLocker controller (after attack): 0x0000000000000000000000000000000000000000

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [33401] 0xdD1376DA1A988D9c35562C9Aa06A68d8a5fc7237::changeController(28, 0x1932cb842d3e27f54f79f7be0289437381ba2410fdefbae36850bee9c41e3b91, 0x87b7639b5f24e93bf106794133370f950d5e9b00f5b5c8cbd866a487529b814f, 0x0000000000000000000000000000000000000000)
    ├─ [3000] PRECOMPILES::ecrecover(0xf413212ad6f041d7bf56f97eb34b619bf39a937e1c2647ba2d306351c6d34aae, 28, 11397568185806560130291530949248708355673262872727946990834312389557386886033, 61386255033295324479228690463930298567438841096413154552415886062180481335631) [staticcall]
    │   └─ ← [Return] 0x00000000000000000000000042069d82d9592991704e6e41bf2589a76ead1a91
    ├─ emit ControllerChanged(newController: 0x0000000000000000000000000000000000000000, timestamp: 1747869768 [1.747e9])
    └─ ← [Stop]
```

## Fix

The most important fix is to ensure that only the "canonical" (low-S) form of the signature is accepted. This means adding a check within `_isValidSignature` to ensure that s is less than or equal to `N/2`.

```bash
// Add this constant (or import from a library)
uint256 private constant SECP256K1_N_DIV_2 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0;

function _isValidSignature(uint8 v, bytes32 r, bytes32 s) internal returns (address) {
    // Enforce s <= N/2 for non-malleability (critical)
    require(uint256(s) <= SECP256K1_N_DIV_2, "ECDSA: invalid signature 's' value (malleable)");

    address _address = ecrecover(msgHash, v, r, s);
    require (_address == controller, InvalidController());

    // This hash calculation is fine *after* enforcing canonical S
    // As long as s is canonical, there's only one valid (r,s,v) for the message hash.
    bytes32 signatureHash = keccak256(abi.encode([uint256(r), uint256(s), uint256(v)]));
    require (!usedSignatures[signatureHash], SignatureAlreadyUsed());

    usedSignatures[signatureHash] = true;

    return _address;
}
```

Or use OpenZeppelin's ECDSA library. Its recover function automatically includes this s <= N/2 check, making the code much safer and cleaner.

```bash
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

function _isValidSignature(uint8 v, bytes32 r, bytes32 s) internal returns (address) {
    // Use OpenZeppelin's recover, which handles s-value malleability
    address _address = ECDSA.recover(msgHash, v, r, s);
    require (_address == controller, InvalidController());

    // The remaining logic for replay protection is sound *after* malleability is addressed
    bytes32 signatureHash = keccak256(abi.encode([uint256(r), uint256(s), uint256(v)]));
    require (!usedSignatures[signatureHash], SignatureAlreadyUsed());

    usedSignatures[signatureHash] = true;

    return _address;
}
```
