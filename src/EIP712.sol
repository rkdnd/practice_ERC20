//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract EIP712 {
    string internal _name;
    string internal _version;

    bytes32 private DOMAIN_SEPARATOR = "DOMAIN";
    
    constructor(string memory name, string memory version) {
        _name = name;
        _version = version;
    }

    function _domainSeparator() public view returns (bytes32) {
        return DOMAIN_SEPARATOR;
    }
    
    function _toTypedDataHash(bytes32 structHash) public returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", _domainSeparator(), structHash));
    }

}