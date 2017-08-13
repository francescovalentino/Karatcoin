pragma solidity ^0.4.0;
import "./Settings.sol";

contract TokenSales is Token_Sales_Sets {

  modifier ifOwner() {
    if (msg.sender != owner) throw;
    _;
  }

  modifier ifOrigin() {
    if (tx.origin != owner) throw;
    _;
  }

  mapping (address => address) proxyPayouts;
  uint256 public WEIxETH = 1000000000000000000;
  uint256 public Billion = 1000000000;
  uint256 public Cents = 100;


  function TokenSales(address _config) {
    owner = msg.sender;
    config = _config;
    saleStatus.founderClaim = false;
    saleStatus.releasedTokens = 0;
    saleStatus.releasedCertificates = 0;
    saleStatus.claimers = 0;
    saleConfig.startDate = Conf_Sets(_config).getConfigUint("sale1:period");
    saleConfig.endDate = Conf_Sets(_config).getConfigUint("sale1:end");
    saleConfig.founderAmount = Conf_Sets(_config).getConfigUint("sale1:founder_amount") * Billion;
    saleConfig.founderWallet = Conf_Sets(_config).getConfigAddress("sale1:founder_wallet");
    saleConfig.target = Conf_Sets(_config).getConfigUint("sale1:target") * Cents;
    saleConfig.cap = Conf_Sets(_config).getConfigUint("sale1:cap") * Cents;
    saleConfig.certificateCost = Conf_Sets(_config).getConfigUint("sale1:certificatecost") * Cents;
    saleInfo.amount = Conf_Sets(_config).getConfigUint("sale1:amount") * Billion;
    saleInfo.totWei = 0;
    saleInfo.totCents = 0;
    saleInfo.realCents;
    saleStatus.founderClaim = false;
    locked = true;
  }

  function () {
    if (getPeriod() == 0) throw;
    uint256 _amount = msg.value;
    address _sender;
    if (proxies[msg.sender].isProxy == true) {
      _sender = proxies[msg.sender].payout;
    } else {
      _sender = msg.sender;
    }
    if (!purchase(_sender, _amount)) throw;
  }

  function proxyPurchase(address _user) returns (bool success) {
    return purchase(_user, msg.value);
  }

  function pxbillion(uint256 _x, uint256 _z) public constant returns (uint256 y) {
    y = (Billion * _x + _z / 2) / _z;
    return y;
  }

  function calcShare(uint256 _contrib, uint256 _total) public constant returns (uint256 share) {
    uint256 _pxbillion = pxbillion(_contrib, _total);
    share = ((_pxbillion * saleInfo.amount) / Billion);
    return share;
  }

  function weiToCents(uint256 _wei) public constant returns (uint256 centsvalue) {
    centsvalue = ((_wei * 100000 / WEIxETH) * ethToCents) / 100000;
    return centsvalue;
  }

  function setEthToCents(uint256 _eth) ifOwner returns (bool success) {
    ethToCents = _eth;
    success = true;
    return success;
  }


  function getSaleStatus() public constant returns (bool founder_claim, uint256 reltokens, uint256 relcertificates, uint256 claimers) {
    return (saleStatus.founderClaim, saleStatus.releasedTokens, saleStatus.releasedCertificates, saleStatus.claimers);
  }

  function getSaleInfo() public constant returns (uint256 weiamount, uint256 cents, uint256 realcents, uint256 amount) {
    return (saleInfo.totWei, saleInfo.totCents, saleInfo.realCents, saleInfo.amount);
  }


  function getSaleConfig() public constant returns (uint256 start, uint256 second, uint256 third, uint256 end, uint256 target, uint256 cap, uint256 certificatecost, uint256 founder_amount, address founder_wallet) {
    return (saleConfig.startDate, saleConfig._2ndPeriod, saleConfig._3rdPeriod, saleConfig.endDate, saleConfig.target, saleConfig.cap, saleConfig.certificateCost, saleConfig.founderAmount, saleConfig.founderWallet);
  }

  function getPeriod() public constant returns (uint saleperiod) {
    
    if ((now > saleConfig.endDate) || (now < saleConfig.startDate)) {
      saleperiod = 0;
      return saleperiod;
    }
  }

  function userInfo(address _user) public constant returns (uint256 centstotal, uint256 weitotal, uint256 share, uint certificates) {
    share = calcShare(buyers[_user].centsTotal, saleInfo.totCents);
    certificates = buyers[_user].centsTotal / saleConfig.certificateCost;
    return (buyers[_user].centsTotal, buyers[_user].weiTotal, share, certificates, buyers[_user].claimed);
  }

  function ownInfo() public constant returns (uint256 centstotal, uint256 weitotal, uint256 share, uint certificates) {
    return userInfo(msg.sender);
  }

  function totWei() public constant returns (uint) {
    return saleInfo.totWei;
  }

  function totCents() public constant returns (uint) {
    return saleInfo.totCents;
  }

  function startDate() public constant returns (uint date) {
    return saleConfig.startDate;
  }
 
  function endDate() public constant returns (uint date) {
    return saleConfig.endDate;
  }

  function isEnded() public constant returns (bool ended) {
    return (now >= endDate());
  }
  
  function sendFunds() public returns (bool success) {
    if (locked) return false;
    if (!targetReached()) return false;
    if (!isEnded()) return false;
    address _dao = Conf_Sets(config).getConfigAddress("sale1:dao");
    if (_dao == 0x0000000000000000000000000000000000000000) return false;
    return _dao.send(totWei());
  }

}
