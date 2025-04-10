// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";

import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";

import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkelAirdropTest is Test, ZkSyncChainChecker{
    MerkleAirdrop public airdrop;
    BagelToken public bagelToken;

    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint public AMOUNT_TO_CLAIM = 25 * 1e18;
    uint public AMOUNT_TO_SEND = AMOUNT_TO_CLAIM *4;

    bytes32 public proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 public proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proofOne, proofTwo];

    address public gasPayer;
    address user;
    uint256 userPrivkey;

    function setUp() public {
        /*if (!isZkSyncChain()){
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, bagelToken) = deployer.deployMerkleAirdrop();
        } else {*/
            bagelToken = new BagelToken();
            airdrop = new MerkleAirdrop(ROOT, bagelToken);
            bagelToken.mint(bagelToken.owner(), AMOUNT_TO_SEND);
            bagelToken.transfer(address(airdrop), AMOUNT_TO_SEND);     

        (user, userPrivkey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    /*function testUsersCanClaim()  public {
        uint256 startingBalance = bagelToken.balanceOf(user);

        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);

        // sign a message
        console.log(user);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivkey, digest);

        // gasPayer calls claim using the signed message
        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        uint256 endingBalance = bagelToken.balanceOf(user);
        assertEq(endingBalance, startingBalance + AMOUNT_TO_CLAIM);
    }*/
    function signMessage(uint256 privKey, address account) public view returns (uint8 v, bytes32 r, bytes32 s) {
        bytes32 hashedMessage = airdrop.getMessageHash(account, AMOUNT_TO_CLAIM);
        (v, r, s) = vm.sign(privKey, hashedMessage);
    }

     function testUsersCanClaim() public {
        uint256 startingBalance = bagelToken.balanceOf(user);

        // get the signature
        vm.startPrank(user);
        (uint8 v, bytes32 r, bytes32 s) = signMessage(userPrivkey, user);
        vm.stopPrank();

        // gasPayer claims the airdrop for the user
        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        uint256 endingBalance = bagelToken.balanceOf(user);

        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}