pragma solidity ^0.4.0;

contract Conf_Sets {
  address public owner;
  mapping (address => bool) admins;
  mapping (bytes32 => bool) boolMap;
  mapping (bytes32 => bytes32) bytesMap;
  mapping (bytes32 => uint256) uintMap;
  mapping (bytes32 => address) addressMap;

  function setConfigAddress(bytes32 _key, address _val) returns (bool success);
  function setConfigBool(bytes32 _key, bool _val) returns (bool success);
  function setConfigUint(bytes32 _key, uint256 _val) returns (bool success);
  function setConfigBytes(bytes32 _key, bytes32 _val) returns (bool success);
  function getConfigAddress(bytes32 _key) returns (address val);
  function getConfigBool(bytes32 _key) returns (bool val);
  function getConfigUint(bytes32 _key) returns (uint256 val);
  function getConfigBytes(bytes32 _key) returns (bytes32 val);
  function addAdmin(address _admin) returns (bool success);
  function removeAdmin(address _admin) returns (bool success);

}

contract Token_Sets {

  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;
  mapping (address => bool) seller;
  address config;
  address owner;
  address dao;
  address public certLedger;
  bool locked;
  uint256 public totalSupply;

  function balanceOf(address _owner) constant returns (uint256 balance);
  function transfer(address _to, uint256 _value) returns (bool success);
  function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
  function approve(address _spender, uint256 _value) returns (bool success);
  function allowance(address _owner, address _spender) constant returns (uint256 remaining);
  function registerDao(address _dao) returns (bool success);
  function registerSeller(address _tokensales) returns (bool success);
  function mint(address _owner, uint256 _amount) returns (bool success);
  function mintCertificate(address _owner, uint256 _amount) returns (bool success);

  event Transfer(address indexed _from, address indexed _to, uint256 indexed _value);
  event Mint(address indexed _receiver, uint256 indexed _amount);
  event Approval(address indexed _owner, address indexed _spender, uint256 indexed _value);
}

contract Token_Sales_Sets {

  struct SaleStatus {
    bool founderClaim;
    uint256 releasedTokens;
    uint256 releasedCertificates;
    uint256 claimers;
  }

  struct Info {
    uint256 totWei;
    uint256 totCents;
    uint256 realCents;
    uint256 amount;
  }

  struct SaleProxy {
    address payout;
    bool isProxy;
  }

  struct SaleConfig {
    uint256 startDate;
    uint256 _2ndTime;
    uint256 _3rdTime;
    uint256 endDate;
    uint256 certificateCost;
    uint256 founderAmount;
    address founderWallet;
    uint256 target;
    uint256 cap;
  }

  struct Buyer {
    uint256 centsTotal;
    uint256 weiTotal;
    bool claimed;
  }

  Info saleInfo;
  address config;
  address owner;
  SaleConfig saleConfig;
  SaleStatus saleStatus;
  uint256 public ethToCents;
  bool locked;
  mapping (address => Buyer) buyers;
  mapping (address => SaleProxy) proxies;

  function calcShare(uint256 _contrib, uint256 _total) public constant returns (uint256 share);
  function pxbillion(uint256 _x, uint256 _z) public constant returns (uint256 y);
  function weiToCents(uint256 _wei) public constant returns (uint256 centsvalue);
  function totWei() public constant returns (uint);
  function totCents() public constant returns (uint);
  function claimFor(address _user) returns (bool success); 
  function proxyPurchase(address _user) returns (bool success);
  function purchase(address _user, uint256 _amount) private returns (bool success);
  function userInfo(address _user) public constant returns (uint256 centstotal, uint256 weitotal, uint256 share, uint certificates, bool claimed); 
  function ownInfo() public constant returns (uint256 centstotal, uint256 weitotal, uint256 share, uint certificates, bool claimed); 
  function targetReached() public constant returns (bool reached);
  function getTime() public constant returns (uint saletime);
  function claim() returns (bool success);
  function claimFounders() returns (bool success);
  function startDate() public constant returns (uint date);
  function _2ndTime() public constant returns (uint date);
  function _3rdTime() public constant returns (uint date);
  function endDate() public constant returns (uint date);  
  function isEnded() public constant returns (bool ended);
  function sendFunds() public returns (bool success);
  function regProxy(address _payout) returns (bool success);
  function getProxy(address _payout) public returns (address proxy);
  function getPayout(address _proxy) public returns (address payout, bool isproxy);
  function getSaleStatus() public constant returns (bool founder_claim, uint256 reltokens, uint256 relcertificates, uint256 claimers);
  function getSaleInfo() public constant returns (uint256 weiamount, uint256 cents, uint256 realcents, uint256 amount);
  function getSaleConfig() public constant returns (uint256 start, uint256 second, uint256 third, uint256 end, uint256 target, uint256 cap, uint256 certificatecost, uint256 founder_amount, address founder_wallet);
  function unlock() public returns (bool success);
  event Claim(address indexed _user, uint256 indexed _amount, uint256 indexed _certificates);
  event Purchase(uint256 indexed _exchange, uint256 indexed _rate, uint256 indexed _cents);

}
