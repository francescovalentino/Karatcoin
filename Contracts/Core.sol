pragma solidity ^0.4.0;

contract Core {

  event Withdraw(address indexed _receiver, uint256 indexed _amount, address indexed _sender);
  event PayRequest(uint256 indexed _requestId);
  event Approve(uint256 indexed _requestId);
  event Decline(uint256 indexed _requestId);
  
  enum RequestStatus { Pending, Approved, Declined }

  struct Request {
    RequestStatus status;
    address recipient;
    uint256 amount;
  } 

  mapping (address => bool) approved;
  mapping (address => bool) supervisors;
  address public owner;
  mapping (uint256 => Request) requests;
  uint256 requestCount = 0;

  modifier ifOwner() {
    if (owner != msg.sender) {
      throw;
    } else {
      _;
    }
  }

  modifier ifStatus(RequestStatus _status, uint256 _requestId) {
    if (_status != requests[_requestId].status) {
      throw;
    } else {
      _;
    }
  }

  modifier ifApproved() {
    if (!approved[msg.sender]) {
      throw;
    } else {
      _;
    }
  }

  modifier ifSupervisor() {
    if (!supervisors[msg.sender]) {
      throw;
    } else {
      _;
    }
  }

  function Core() {
    approved[msg.sender] = true;
    supervisors[msg.sender] = true;
    owner = msg.sender;
  }

  function balance() public constant returns (uint256 bal) {
    bal = address(this).balance;
    return bal;
  }

  function authorizeUser(address _user) ifSupervisor returns (bool success) {
    approved[_user] = true;
    success = true;
    return success;
  }

  function unauthorizeUser(address _user) ifSupervisor returns (bool success) {
    approved[_user] = false;
    success = true;
    return success;
  }

  function authorizeSupervisor(address _user) ifOwner returns (bool success) {
    supervisors[_user] = true;
    success = true;
    return success;
  }

  function unauthorizeSupervisor(address _user) ifOwner returns (bool success) {
    supervisors[_user] = false;
    success = true;
    return success;
  }

  function withdraw(address _receiver, uint256 _amount) ifSupervisor returns (bool success) {
    if (address(_receiver).send(_amount)) {
      Withdraw(_receiver, _amount, msg.sender);
      success = true;
    } else {
      success = false;
    }
    return success;
  }

  function request(address _receiver, uint256 _amount) ifApproved returns (bool success) {
    if (_amount < balance()) {
      success = false;
    } else {
      requestCount++;
      requests[requestCount].status = RequestStatus.Pending;
      requests[requestCount].amount = _amount;
      requests[requestCount].recipient = _receiver;
      success = true;
      PayRequest(requestCount);
    }
    return success;
  }

  function approve(uint256 _requestId) ifSupervisor ifStatus(RequestStatus.Pending, _requestId) returns (bool success) {
    if (address(requests[_requestId].recipient).send(requests[_requestId].amount)) {
      requests[_requestId].status = RequestStatus.Approved;
      success = true;
      Approve(_requestId);
    } else {
      success = false;
    }
    return success;
  }

  function decline(uint256 _requestId) ifSupervisor ifStatus(RequestStatus.Pending, _requestId) returns (bool success) {
    requests[_requestId].status = RequestStatus.Declined;
    success = true;
    Decline(_requestId);
    return success;
  }

}
