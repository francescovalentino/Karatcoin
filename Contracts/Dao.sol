pragma solidity ^0.4.0;

import "./Settings.sol";

contract Certificate  {  
  address public owner;
  bool public locked;
  uint256 public totalSupply;
  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;

  modifier ifOwner() {
    if (msg.sender != owner) {
      throw;
    } else {
      _;
    }
  }

  function Certificate() {
    owner = msg.sender;
  }

  function safeToAdd(uint a, uint b) returns (bool) {
    return (a + b >= a);
  }

  function safeToSubtract(uint a, uint b) returns (bool) {
    return (b <= a);
  }

  function addSafely(uint a, uint b) returns (uint result) {
    if (!safeToAdd(a, b)) {
      throw;
    } else {
      result = a + b;
      return result;
    }
  }

  function subtractSafely(uint a, uint b) returns (uint) {
    if (!safeToSubtract(a, b)) throw;
    return a - b;
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

  function setOwner(address _owner) ifOwner returns (bool success) {
    owner = _owner;
    return true;
  }

}

contract Token {

  address public owner;
  address public config;
  address public certificateLedger;
  address public dao;  
  bool public locked;
  uint256 public totalSupply;
  mapping (address => uint256) balances;
  mapping (address => bool) seller;
  mapping (address => mapping (address => uint256)) allowed;

  modifier ifOwner() {
    if (msg.sender != owner) throw;
    _;
  }  
  
  modifier ifDao() {
    if (msg.sender != dao) throw;
    _;
  }

  modifier ifSales() {
    if (!seller[msg.sender]) throw; 
    _; 
  }

  function Token(address _config) {
    config = _config;
    owner = msg.sender;
    address _initseller = Conf_Sets(_config).getConfigAddress("sale1:address");
    seller[_initseller] = true; 
    certificateLedger = new Certificate();
    locked = false;
  }

  function safeToAdd(uint a, uint b) returns (bool) {
    return (a + b >= a);
  }

  function safeToSubtract(uint a, uint b) returns (bool) {
    return (b <= a);
  }

  function addSafely(uint a, uint b) returns (uint result) {
    if (!safeToAdd(a, b)) {
      throw;
    } else {
      result = a + b;
      return result;
    }
  }

  function subtractSafely(uint a, uint b) returns (uint) {
    if (!safeToSubtract(a, b)) throw;
    return a - b;
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}
