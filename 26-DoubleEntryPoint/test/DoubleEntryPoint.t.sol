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

    address public lgTokenAddress;
    address public randomAddress = address(uint160(uint(keccak256(abi.encodePacked(block.timestamp, block.prevrandao)))));

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

}



/*


    function testDoubleEntryPointTokenInitialSupply() public view{
        uint256 totalSupply = doubleEntryPoint.totalSupply();
        require(totalSupply == 100 ether, "DEP total supply does not match expected value");
    }

    function testSweepTokensRecipient() public view {
        address sweptTokensRecipient = cryptoVault.sweptTokensRecipient();
        require(sweptTokensRecipient == address(this), "Swept tokens recipient does not match expected value");
    }

    function testCryptoVaultAsHolderOfLegacyToken() public view {
        uint256 balance = legacyToken.balanceOf(address(cryptoVault));
        require(balance == 100 ether, "CryptoVault does not hold the expected amount of LET");
    }

    function testSweepAfterAttack() public {        
        cryptoVault.sweepToken(IERC20(lgTokenAddress)); // Simulate the attack

        uint256 depTokenBalanceAfterSweep = IERC20(lgTokenAddress).balanceOf(address(cryptoVault));
        require(depTokenBalanceAfterSweep == 0, "DEP token balance must be 0 after the attack");

        (bool ok, bytes memory data) = trySweep(cryptoVault, doubleEntryPoint);
        require(!ok, "Sweep succeeded");

        // Decode the returned data to check if the DEP token balance is 0
        // bool hasTokens = abi.decode(data, (bool));
        // require(!hasTokens, "DEP token balance must be 0 after the attack");
    }

    function trySweep(CryptoVault _cryptoVault, DoubleEntryPoint _instance) internal returns (bool, bytes memory) {
        try _cryptoVault.sweepToken(IERC20(_instance.delegatedFrom())) {
            return (true, abi.encode(false));
        } catch {
            return (false, abi.encode(_instance.balanceOf(_instance.cryptoVault()) > 0));
        }
    }


*/