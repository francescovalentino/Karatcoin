pragma solidity ^0.4.0;
import "./Token.sol";
import "./Settings.sol";

contract Collector {
  address public owner;
  address public FeesPool;
  address public DAO_Tokens;
  uint256 public payout_Time;
}

contract GoldFees {
  address public DAO_Tokens;
  address public GOLD_Tokens;
  bytes32 public environment;
  uint256 public timeLength;
  uint256 public timeCount;
  uint256 public collectDuration;
  mapping (uint256 => Time) times;
}
