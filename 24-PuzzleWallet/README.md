# Puzzle Wallet

A group of friends discovered a way to slightly reduce the cost of performing multiple transactions by batching them into a single transaction. They developed a smart contract to implement this.

The group needed the contract to be upgradeable in case there were any bugs in the code, and they also wanted to restrict its usage to people within the group. To achieve this, they voted and assigned two special roles:

1. Admin: This role has the power to update the logic of the smart contract.
2. Owner: This role manages the whitelist of addresses allowed to use the contract.

After deploying the contracts and whitelisting the group members, everyone celebrated their achievement in reducing costs. However, they were unaware that their funds were still at risk.

Your task is to hijack this wallet and become the admin of the proxy contract.

## Notes

`Upgradeable` contracts in Solidity are a design pattern that allows the logic of a contract to be updated while preserving the contract's state and address. This is useful when you want to fix bugs, add new features, or change the contract's behavior after it has been deployed.

The upgradeable contract pattern typically involves two types of contracts:

1. `Proxy Contract`: This contract is responsible for forwarding calls to the implementation contract. It contains the state of the upgradeable contract and its address never changes. When a call is made to the proxy contract, it uses the `delegatecall` opcode to forward the call to the implementation contract. This means the call is executed in the context of the proxy contract, allowing the implementation contract to access and modify the proxy's state.

2. `Implementation Contract`: This contract contains the business logic. When an upgrade is needed, a new implementation contract is deployed and the proxy contract is updated to forward calls to the new implementation.

```javascript
contract Proxy {
    address public implementation;

    function upgrade(address newImplementation) public {
        // Add access control here
        implementation = newImplementation;
    }

    fallback() external payable {
        (bool success,) = implementation.delegatecall(msg.data);
        require(success, "Delegatecall failed");
    }
}

contract ImplementationV1 {
    uint public value;

    function setValue(uint newValue) public {
        value = newValue;
    }
}

contract ImplementationV2 {
    uint public value;

    function setValue(uint newValue) public {
        value = newValue * 2;
    }
}
```
In the context of the `Proxy` contract, `delegatecall` is used to forward function calls to the current implementation contract. This is done in the fallback function.

`delegatecall` opcode: is a low-level function that calls another contract's function in the context of the calling contract. This means that the code at the target address is executed in the storage context of the calling contract.

Here's how `msg.sender` and `msg.value` behave when performing a `delegatecall`:

### Example

```javascript
contract CalledContract { //Implementation
    address public caller;
    uint public value;

    function setCallerAndValue() public payable {
        caller = msg.sender;
        value = msg.value;
    }
}

contract CallingContract { //Proxy
    CalledContract public calledContract;

    constructor() {
        calledContract = new CalledContract();
    }

    function regularCall() public payable {
        calledContract.setCallerAndValue{value: msg.value}();
    }

    function delegateCall() public payable {
        (bool success,) = address(calledContract).delegatecall(
            abi.encodeWithSignature("setCallerAndValue()")
        );
        require(success, "Delegatecall failed");
    }
}
```

In this example, `CallingContract` has two functions: `regularCall` and `delegateCall`. Both functions call the `setCallerAndValue` function of `CalledContract`.

* In `regularCall`, `msg.sender` inside `CalledContract.setCallerAndValue` will be the address of `CallingContract`, and `msg.value` will be the amount of ether sent with the call, because it's a regular call.

* In `delegateCall`, `msg.sender` inside `CalledContract.setCallerAndValue` will be the address that originally called `CallingContract`.`delegateCall`, and `msg.value` will be the amount of ether sent with the original call to `CallingContract.delegateCall`, because `delegatecall` executes in the context of the calling contract and retains the original `msg.sender` and `msg.value`.

Let's assume that we have two addresses:

* `0xAbc...` (the address of CallingContract)
* `0xDef...` (the address that calls CallingContract)

and we're sending `5 ETH` with each call. Here's how the values of `msg.sender` and `msg.value` would look like:

1. In `regularCall`, `msg.sender` inside `CalledContract.setCallerAndValue` will be `0xAbc...` (the address of `CallingContract`), and `msg.value` will be `5 ETH`, because it's a regular call.

2. In `delegateCall`, `msg.sender` inside `CalledContract.setCallerAndValue` will be `0xDef...` (the address that originally called `CallingContract.delegateCall`), and `msg.value` will be `5 ETH`, because `delegatecall` executes in the context of the calling contract and retains the original `msg.sender` and `msg.value`.

## Vulnerability

| Slot # | PuzzleProxy | PuzzleWallet |
|--------|-------------|--------------|
| 0      | pendingAdmin| owner        |
| 1      | admin       | maxBalance   |

To become the admin of the proxy, we need to overwrite the value in slot 1, either the admin or the maxBalance variable.

The function setMaxBalance() is only checking if the contract's balance is 0.

```bash
# PuzzleWallet
mapping(address => bool) public whitelisted;

modifier onlyWhitelisted() {
    require(whitelisted[msg.sender], "Not whitelisted");
    _;
}

function addToWhitelist(address addr) external {
    require(msg.sender == owner, "Not the owner");
    whitelisted[addr] = true;
}

function setMaxBalance(uint256 _maxBalance) external onlyWhitelisted {
    require(address(this).balance == 0, "Contract balance is not 0");
    maxBalance = _maxBalance;
}

# PuzzleProxy
function proposeNewAdmin(address _newAdmin) external {
    pendingAdmin = _newAdmin;
}
```

From `PuzzleProxy`, we can see that the function `proposeNewAdmin()` is external and sets the value for `pendingAdmin`. Since the slots are replicated, if we call this function, we will automatically become the owner of the `PuzzleWallet` contract because both variables are stored in `slot 0` of the contracts.

To drain the contract's balance, we need to exploit the `execute()` function, which calls an address with some value. This function checks if `msg.sender` has sufficient balance. By manipulating the contract to believe we have more balance than we actually do, we can call `execute()` with a value equal to or greater than the contract's balance, allowing us to withdraw all the funds.

```bash
# PuzzleWallet
function execute(address to, uint256 value, bytes calldata data) external payable onlyWhitelisted {
    require(balances[msg.sender] >= value, "Insufficient balance");
    balances[msg.sender] = balances[msg.sender].sub(value);
    (bool success, ) = to.call{ value: value }(data);
    require(success, "Execution failed");
}
```
To manipulate our balance, we need to exploit the `deposit()` function, which adds the deposited amount to both the contract and our balances mapping. Normally, calling `deposit()` increases the balance in both places. To exploit it, we need to send Ether once but increase our balance twice. This can be achieved using the `multicall()` function, which allows multiple function calls in a single transaction, saving gas.

```bash
# PuzzleWallet
function deposit() external payable onlyWhitelisted {
    require(address(this).balance <= maxBalance, "Max balance reached");
    balances[msg.sender] += msg.value;
}

function multicall(bytes[] calldata data) external payable onlyWhitelisted {
    bool depositCalled = false;
    for (uint256 i = 0; i < data.length; i++) {
        bytes memory _data = data[i];
        bytes4 selector;
        assembly {
            selector := mload(add(  , 32))
        }
        if (selector == this.deposit.selector) {
            require(!depositCalled, "Deposit can only be called once");
            // Protect against reusing msg.value
            depositCalled = true;
        }
        (bool success, ) = address(this).delegatecall(data[i]);
        require(success, "Error while delegating call");
    }
}
```

To exploit the `deposit()` function, we need to call it multiple times in a single transaction, sending Ether once but increasing our balance multiple times. However, the `multicall()` function prevents this by setting a `depositCalled` flag. To bypass this, we can call `multicall()` twice, each with one `deposit()` call, allowing us to double our balance without additional Ether.

With the contract's balance at 0.001 Ether, calling `deposit()` twice with 0.001 Ether will increase our balance to 0.002, but the contract will incorrectly think it has 0.003 Ether. This allows us to call `execute()` with a sufficient balance to drain the contract.

Finally, after draining the contract, we can call `setMaxBalance()` to set the value of maxBalance and become the proxy admin.

## Attack



## Fix
