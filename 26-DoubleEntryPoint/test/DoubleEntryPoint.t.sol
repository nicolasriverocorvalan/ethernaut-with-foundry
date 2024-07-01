// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {DoubleEntryPoint,CryptoVault,LegacyToken,Forta} from "../src/DoubleEntryPoint.sol";
import {FortaBot} from "../src/FortaBot.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DoubleEntryPointTest is Test {
    LegacyToken public legacyToken;
    DoubleEntryPoint public doubleEntryPoint;
    CryptoVault public cryptoVault;
    Forta public forta;

    function setUp() public {
        legacyToken = new LegacyToken();
        legacyToken.mint(address(this), 100 ether); //my 100 ether for our wallet
        cryptoVault = new CryptoVault(address(this)); // set the sweptTokensRecipient to this contract (our wallet)
        forta = new Forta();
        doubleEntryPoint = new DoubleEntryPoint(address(legacyToken), address(cryptoVault), address(forta), address(this)); // the constructor mint 100 ether DET tokens
        cryptoVault.setUnderlying(address(doubleEntryPoint));
    }

    function testLegacyTokenInitialSupply() public view{
        uint256 totalSupply = legacyToken.totalSupply();
        require(totalSupply == 100 ether, "LET total supply does not match expected value");
    }

    function testDoubleEntryPointTokenInitialSupply() public view{
        uint256 totalSupply = doubleEntryPoint.totalSupply();
        require(totalSupply == 100 ether, "DET total supply does not match expected value");
    }

    function testSweepTokensRecipient() public view {
        address sweptTokensRecipient = cryptoVault.sweptTokensRecipient();
        require(sweptTokensRecipient == address(this), "Swept tokens recipient does not match expected value");
    }

    function testSweepAfterAttack() public {        
        cryptoVault.sweepToken(IERC20(address(legacyToken))); // Simulate the attack

        uint256 depTokenBalanceAfterSweep = IERC20(address(legacyToken)).balanceOf(address(cryptoVault));
        require(depTokenBalanceAfterSweep == 0, "DET token balance must be 0 after the attack");
    }

    function testAccountTokensAfterAttack() public view {
        uint256 detBalance = IERC20(address(doubleEntryPoint)).balanceOf(address(this));
        uint256 letBalance = IERC20(address(legacyToken)).balanceOf(address(this));

        require(detBalance == 100, "DET token balance must be 100 after the attack");
        require(letBalance == 100, "LET token balance must be 100 after the attack");
    }
}
