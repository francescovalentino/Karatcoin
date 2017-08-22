pragma solidity ^0.4.0;
import "./Settings.sol";

contract Certificate  {
  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;
  address public owner;
  bool public locked;
  uint256 public totalSupply;

  modifier ifOwner() {
    if (msg.sender != owner) {
      throw;
    } else {
      _;
    }
  }


  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Mint(address indexed _receiver, uint256 indexed _amount);
  event Approval(address indexed _owner, address indexed _spender, uint256  _value);

  function Certificate() {
    owner = msg.sender;
  }

  function safeToAdd(uint a, uint b) returns (bool) {
  }

  function addSafely(uint a, uint b) returns (uint result) {
  }

  function safeToSubtract(uint a, uint b) returns (bool) {
  }

  function subtractSafely(uint a, uint b) returns (uint) {
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

  function transfer(address _to, uint256 _value) returns (bool success) {
    if (balances[msg.sender] >= _value && _value > 0) {
      balances[msg.sender] = subtractSafely(balances[msg.sender], _value);
      balances[_to] = addSafely(_value, balances[_to]);
      Transfer(msg.sender, _to, _value);
      success = true;
    } else {
      success = false;
    }
    return success;
  }

  function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
  }

  function approve(address _spender, uint256 _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    success = true;
    return success;
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
  }

  function mint(address _owner, uint256 _amount) ifOwner returns (bool success) {
  }

  function setOwner(address _owner) ifOwner returns (bool success) {
    owner = _owner;
    return true;
  }

}

contract Token {

  address public owner;
  address public config;
  bool public locked;
  address public dao;
  address public certificateLedger;
  uint256 public totalSupply;

  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;
  mapping (address => bool) seller;

  modifier ifSales() {
    if (!seller[msg.sender]) throw; 
    _; 
  }

  modifier ifOwner() {
    if (msg.sender != owner) throw;
    _;
  }

  modifier ifDao() {
    if (msg.sender != dao) throw;
    _;
  }

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Mint(address indexed _receiver, uint256  _amount);
  event Approval(address indexed _owner, address indexed _spender, uint256  _value);

  function Token(address _config) {
    config = _config;
    owner = msg.sender;
    address _initseller = Conf_Sets(_config).getConfigAddress("sale1:address");
    seller[_initseller] = true; 
    certificateLedger = new Certificate();
    locked = false;
  }

  function safeToAdd(uint a, uint b) returns (bool) {
  }

  function addSafely(uint a, uint b) returns (uint result) {
  }

  function safeToSubtract(uint a, uint b) returns (bool) {
  }

  function subtractSafely(uint a, uint b) returns (uint) {
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

  function transfer(address _to, uint256 _value) returns (bool success) {
    if (balances[msg.sender] >= _value && _value > 0) {
      balances[msg.sender] = subtractSafely(balances[msg.sender], _value);
      balances[_to] = addSafely(balances[_to], _value);
      Transfer(msg.sender, _to, _value);
      success = true;
    } else {
      success = false;
    }
    return success;
  }

  function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
  }

  function approve(address _spender, uint256 _value) returns (bool success) {
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
  }
  function mint(address _owner, uint256 _amount) ifSales returns (bool success) {
  }

  function mintCertificate(address _owner, uint256 _amount) ifSales returns (bool success) {
  }

  function registerDao(address _dao) ifOwner returns (bool success) {
  }

  function setDao(address _newdao) ifDao returns (bool success) {
  }

  function isSeller(address _query) returns (bool isseller) {
    return seller[_query];
  }

  function registerSeller(address _tokensales) ifDao returns (bool success) {
    seller[_tokensales] = true;
    return true;
  }

  function unregisterSeller(address _tokensales) ifDao returns (bool success) {
    seller[_tokensales] = false;
    return true;
  }

  function setOwner(address _newowner) ifDao returns (bool success) {
    if(Certificate(certificateLedger).setOwner(_newowner)) {
      owner = _newowner;
      success = true;
    } else {
      success = false;
    }
    return success;
  }

}
