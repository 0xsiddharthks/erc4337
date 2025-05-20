// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;
import "./Vm.sol";

abstract contract Script {
    Vm public constant vm = Vm(address(uint160(uint256(keccak256('hevm cheat code')))));
}

library console {
    function log(string memory) internal pure {}
    function log_uint(uint256) internal pure {}
    function log_int(int256) internal pure {}
    function log_bytes(bytes memory) internal pure {}
}
