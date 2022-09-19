// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EIP712.sol";

contract ERC20 is EIP712{
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address  => uint256) private _nonces;


    string internal _symbol;
    uint256 private _totalSupply;
    
    bool _paused;
    address _contract_owner;
    modifier pauseCheck(){
        require(_paused == false);
        _;
    }


    constructor(string memory name, string memory symbol) EIP712(name, "1") public {
        _symbol = symbol;
        _totalSupply = 100 ether;
        balances[msg.sender] = 100 ether;

        _paused = false;
        _contract_owner = msg.sender;
    }

    function transfer(address _to, uint256 _value) pauseCheck external returns (bool success){
        require(msg.sender != address(0), "transfer from the zero address");
        require(_to != address(0), "transfer to the zero address");
        require(balances[msg.sender] >= _value, "value exceeds balance");

        unchecked{
            balances[msg.sender] -= _value;
            balances[_to] += _value;
        }

        emit Transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) pauseCheck external returns (bool success){
        require(msg.sender != address(0), "transfer from the zero address");
        require(_from != address(0), "transfer to the zero address");
        require(_to != address(0), "transfer to the zero address");

        uint256 currentAllowance = allowance(_from, msg.sender);
        require(currentAllowance >= _value, "insufficient allowance");
        unchecked{
            allowances[_from][msg.sender] -= _value;
        }
        require(balances[_from] >= _value, "_value exceeds balance");

        unchecked{
            balances[_from] -= _value;
            balances[_to] += _value;
        }

        emit Transfer(msg.sender, _to, _value);
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining){
        return allowances[_owner][_spender];
    }

    function pause() external{
        require(msg.sender == _contract_owner);
        
        _paused = true;
    }

    function approve(address _spender, uint256 _value) public returns(bool){
        allowances[msg.sender][_spender] = _value;

        return true;
    }

    function nonces(address owner) public returns(uint256){
        return _nonces[owner];
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s)
    public {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");
        // require(_nonces[owner] == nonce);

        bytes32 structHash = keccak256(abi.encode(keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"), owner, spender, value, _nonces[owner], deadline));

        bytes32 hash = _toTypedDataHash(structHash);

        address signer = ecrecover(hash, v, r, s);
        require(signer == owner, "INVALID_SIGNER");

        allowances[owner][spender] = value;
        _nonces[owner] += 1;
    }
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}