// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, Vm} from "../lib/forge-std-local/src/Test.sol";
import {EntryPoint} from "../src/EntryPoint.sol";
import {BasicAccount} from "../src/BasicAccount.sol";
import {Counter} from "../src/Counter.sol";

contract ERC4337Test is Test {
    EntryPoint internal entryPoint;
    Counter internal counter;
    BasicAccount internal account;

    uint256 internal ownerKey = 0xA11CE;
    address internal owner;

    function setUp() public {
        entryPoint = new EntryPoint();
        counter = new Counter();
        owner = vm.addr(ownerKey);
        account = new BasicAccount(owner, entryPoint);
    }

    function _sign(EntryPoint.UserOperation memory op) internal returns (bytes memory) {
        bytes32 hash = entryPoint.getUserOpHash(op);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerKey, hash);
        return abi.encodePacked(r, s, v);
    }

    function testHandleOps() public {
        EntryPoint.UserOperation memory op;
        op.sender = address(account);
        op.nonce = 0;
        op.to = address(counter);
        op.value = 0;
        op.data = abi.encodeWithSignature("increment()");
        op.signature = _sign(op);

        vm.prank(owner);
        entryPoint.depositTo{value: 1 ether}(address(account));

        EntryPoint.UserOperation[] memory ops = new EntryPoint.UserOperation[](1);
        ops[0] = op;

        entryPoint.handleOps(ops);

        assertEq(counter.number(), 1);
        assertEq(account.nonce(), 1);
    }
}
