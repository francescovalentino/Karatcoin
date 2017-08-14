pragma solidity ^0.4.0;
import "./Settings.sol";

contract ProxyPayment {

  address payout;
  address owner;
  address tokenSales; 

  function ProxyPayment(address _payout, address _tokenSales) {
    payout = _payout;
    owner = _payout;
    tokenSales = _tokenSales;
  }

  function () {
    if (!Token_Sales_Sets(tokenSales).call.gas(100000).value(msg.value)(bytes4(sha3("proxyPurchase(address)")),payout)) {
       throw;
    }
  }

}

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
    saleStatus.releasedTokens = 0;
    saleStatus.releasedCertificates = 0;
    saleStatus.claimers = 0;
    saleConfig.startDate = Conf_Sets(_config).getConfigUint("sale1:period1");
    saleConfig.endDate = Conf_Sets(_config).getConfigUint("sale1:end");
    saleConfig.target = Conf_Sets(_config).getConfigUint("sale1:target") * Cents;
    saleConfig.cap = Conf_Sets(_config).getConfigUint("sale1:cap") * Cents;
    saleConfig.certificateCost = Conf_Sets(_config).getConfigUint("sale1:certificatecost") * Cents;
    saleInfo.amount = Conf_Sets(_config).getConfigUint("sale1:amount") * Billion;
    saleInfo.totWei = 0;
    saleInfo.totCents = 0;
    saleInfo.realCents;
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

  function purchase(address _user, uint256 _amount) private returns (bool success) {
    uint256 _cents = weiToCents(_amount);
    if ((saleInfo.realCents + _cents) > saleConfig.cap) return false;
    uint256 _wei = _amount;
    uint256 _modifier;
    uint _period = getPeriod();
    if ((_period == 0) || (_cents == 0)) {
      return false;
    } else {
      if (_period == 3) _modifier = 100;
      if (_period == 2) _modifier = 115;
      if (_period == 1) _modifier = 130;
      uint256 _creditwei = _amount;
      uint256 _creditcents = (weiToCents(_creditwei) * _modifier * 10000) / 1000000 ;
      buyers[_user].centsTotal += _creditcents;
      buyers[_user].weiTotal += _creditwei; 
      saleInfo.totCents += _creditcents;
      saleInfo.realCents += _cents;
      saleInfo.totWei += _creditwei;
      Purchase(ethToCents, _modifier, _creditcents); 
      return true;
    }
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

  function getSaleInfo() public constant returns (uint256 weiamount, uint256 cents, uint256 realcents, uint256 amount) {
    return (saleInfo.totWei, saleInfo.totCents, saleInfo.realCents, saleInfo.amount);
  }

  function targetReached() public constant returns (bool reached) {
    reached = (saleInfo.totCents >= saleConfig.target);
    return reached;
  }

  function claim() returns (bool success) {
    return claimFor(msg.sender);
  }

  function claimFor(address _user) returns (bool success) {
    if ( (now < saleConfig.endDate) || (buyers[_user].claimed == true) ) {
      return true;
    }
  
    if (!targetReached()) {
      if (!address(_user).send(buyers[_user].weiTotal)) throw;
      buyers[_user].claimed = true;
      return true;
    }

    if (targetReached()) {
      address _tokenc = Conf_Sets(config).getConfigAddress("ledger");
      uint256 _tokens = calcShare(buyers[_user].centsTotal, saleInfo.totCents); 
      uint256 _certificates = buyers[_user].centsTotal / saleConfig.certificateCost;

      if ((Token_Sets(_tokenc).mint(msg.sender, _tokens)) && (Token_Sets(_tokenc).mintCertificate(_user, _certificates))) {
        saleStatus.releasedTokens += _tokens;
        saleStatus.releasedCertificates += _certificates;
        saleStatus.claimers += 1;
        buyers[_user].claimed = true;
        Claim(_user, _tokens, _certificates);
        return true;
      } else {
        return false;
      }
    }

  }

  function getPeriod() public constant returns (uint saleperiod) {
    
    if ((now > saleConfig.endDate) || (now < saleConfig.startDate)) {
      saleperiod = 0;
      return saleperiod;
    } else {
      return false;
    }

  }

  function userInfo(address _user) public constant returns (uint256 centstotal, uint256 weitotal, uint256 share, uint certificates, bool claimed) {
    share = calcShare(buyers[_user].centsTotal, saleInfo.totCents);
    certificates = buyers[_user].centsTotal / saleConfig.certificateCost;
    return (buyers[_user].centsTotal, buyers[_user].weiTotal, share, certificates, buyers[_user].claimed);
  }

  function ownInfo() public constant returns (uint256 centstotal, uint256 weitotal, uint256 share, uint certificates, bool claimed) {
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

  function regProxy(address _payout) ifOrigin returns (bool success) {
    address _proxy = new ProxyPayment(_payout, address(this));
    proxies[_proxy].payout = _payout;
    proxies[_proxy].isProxy = true;
    proxyPayouts[_payout] = _proxy;
    return true;
  }
  
  function getProxy(address _payout) public returns (address proxy) {
    return proxyPayouts[_payout];
  }

  function getPayout(address _proxy) public returns (address payout, bool isproxy) {
    return (proxies[_proxy].payout, proxies[_proxy].isProxy);
  }

  function unlock() ifOwner public returns (bool success) {
    locked = false;
    return true;
  }
}
