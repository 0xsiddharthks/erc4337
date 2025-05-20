// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;
import "./Vm.sol";

abstract contract Test {
    Vm public constant vm = Vm(address(uint160(uint256(keccak256('hevm cheat code')))));

    function assertEq(uint256 a, uint256 b) internal pure {
        require(a == b, 'assertEq(uint256) failed');
    }

    function assertEq(address a, address b) internal pure {
        require(a == b, 'assertEq(address) failed');
    }
}
