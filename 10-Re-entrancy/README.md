# Re-entrancy

Steal all the funds from the contract.

## Vulnerability

The contract is vulnerable to a reentrancy attack due to the way the withdraw function is implemented.

In the `withdraw` function, you send Ether to `msg.sender` and then subtract the withdrawn amount from `balances[msg.sender]`. This allows for a reentrancy attack, where the fallback function of the attacker's contract calls `withdraw` again before the first call to `withdraw` has finished. This can drain the contract's Ether.

## Attack

### Fix

The balance must be subtracted before the Ether is sent. This prevents a reentrant call from withdraw being able to withdraw more Ether than the caller is entitled to.

```bash
function withdraw(uint256 _amount) public {
    require(balances[msg.sender] >= _amount, "Insufficient balance");

    balances[msg.sender] = balances[msg.sender].sub(_amount);

    (bool result,) = msg.sender.call{value: _amount}("");
    require(result, "Transfer failed");
}
```
