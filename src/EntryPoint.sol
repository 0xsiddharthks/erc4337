// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./ECDSA.sol";

interface IAccount {
    function validateUserOp(bytes32 hash, bytes calldata signature, uint256 nonce, address to, uint256 value, bytes calldata data) external returns (bool);
}

contract EntryPoint {
    using ECDSA for bytes32;

    struct UserOperation {
        address sender;
        uint256 nonce;
        address to;
        uint256 value;
        bytes data;
        bytes signature;
    }

    mapping(address => uint256) public nonce;
    mapping(address => uint256) public deposits;

    receive() external payable {}

    function depositTo(address account) external payable {
        deposits[account] += msg.value;
    }

    function withdrawTo(address payable account, uint256 amount) external {
        require(deposits[msg.sender] >= amount, "insufficient deposit");
        deposits[msg.sender] -= amount;
        account.transfer(amount);
    }

    function handleOps(UserOperation[] calldata ops) external {
        for (uint256 i = 0; i < ops.length; i++) {
            _handleOp(ops[i]);
        }
    }

    function _handleOp(UserOperation calldata op) internal {
        require(op.nonce == nonce[op.sender], "invalid nonce");
        bytes32 hash = getUserOpHash(op);
        require(IAccount(op.sender).validateUserOp(hash, op.signature, op.nonce, op.to, op.value, op.data), "validation failed");
        nonce[op.sender]++;
        (bool success, ) = op.sender.call(abi.encodeWithSignature("execute(address,uint256,bytes)", op.to, op.value, op.data));
        require(success, "execute failed");
    }

    function getUserOpHash(UserOperation calldata op) public view returns (bytes32) {
        return keccak256(abi.encode(address(this), op.sender, op.nonce, op.to, op.value, keccak256(op.data)));
    }
}
