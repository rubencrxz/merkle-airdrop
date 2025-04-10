// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {Vm} from "forge-std/Vm.sol";
import {ClaimAirdrop} from "../script/Interactions.s.sol";
import {BagelToken} from "../src/BagelToken.sol";

contract ClaimAirdropTest is Test {
    ClaimAirdrop public claimAirdrop;
    MerkleAirdrop public merkleAirdrop;
    BagelToken public bagelToken;

    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
   
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    bytes32 PROOF1 = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 PROOF2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [PROOF1, PROOF2];
    bytes private SIGNATURE = hex"eba11dc5bd5bd0f468007303124c13965cadb551ff6b0578aa95bead09724a7333025cf6b4e5f22d74dfb1cc1dbb5ca3a8d2636d2727f7e510b046c76b20e9eb1c";

    function setUp() public {
        // Desplegar el contrato de MerkleAirdrop
        bagelToken = new BagelToken();
        merkleAirdrop = new MerkleAirdrop(ROOT, bagelToken);
        
        // Desplegar el contrato de ClaimAirdrop
        claimAirdrop = new ClaimAirdrop();
    }

    function testClaimAirdrop() public {
        // Primero, realizar un mock de la dirección del contrato de Airdrop
        address mostRecentlyDeployed = address(merkleAirdrop);

        // Intentar hacer el claim
        try claimAirdrop.claimAirdrop(mostRecentlyDeployed) {
            // Si no revertir, entonces el test es exitoso
            console.log("Airdrop claimed successfully");
        } catch (bytes memory errorData) {
            // Si el revert se lanza, capturar el mensaje de revert
            string memory errorMessage = string(errorData);
            console.log("Error: %s", errorMessage);
            assertEq(errorMessage, "EvmError: Revert", "The claim failed with an error");
        }
    }

    function testSplitSignature() public {
        // Verificar que la función splitSignature maneje correctamente la firma
        (uint8 v, bytes32 r, bytes32 s) = claimAirdrop.splitSignature(SIGNATURE);
        assertEq(v, 28); // Valor esperado de v
        assertTrue(r != bytes32(0), "r should not be zero");
        assertTrue(s != bytes32(0), "s should not be zero");
    }
}
