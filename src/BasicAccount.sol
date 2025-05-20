// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./EntryPoint.sol";
import "./ECDSA.sol";

contract BasicAccount {
    using ECDSA for bytes32;

    address public owner;
    EntryPoint public immutable entryPoint;
    uint256 public nonce;

    constructor(address _owner, EntryPoint _entryPoint) {
        owner = _owner;
        entryPoint = _entryPoint;
    }

    function validateUserOp(bytes32 hash, bytes calldata signature, uint256 opNonce, address, uint256, bytes calldata) external returns (bool) {
        require(msg.sender == address(entryPoint), "only entryPoint");
        require(opNonce == nonce, "invalid nonce");
        address signer = hash.recover(signature);
        require(signer == owner, "bad signature");
        nonce++;
        return true;
    }

    function execute(address to, uint256 value, bytes calldata data) external {
        require(msg.sender == address(entryPoint), "only entryPoint");
        (bool success, ) = to.call{value: value}(data);
        require(success, "call failed");
    }

    receive() external payable {}
}
