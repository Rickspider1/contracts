// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "./interfaces/IMintableERC20.sol";

contract Staking is Ownable {
  struct StakingPosition {
    uint256 amount;
    uint32 time;
    uint32 lastWithdrawal;
    uint32 createdAt;
  }

  struct StakingPositionFrontend {
    uint256 amount;
    uint32 time;
    uint32 lastWithdrawal;
    uint32 createdAt;
    uint32 withdrawIn;
    uint256 unclaimedRewards;
    uint256 dailyRewards;
  }

  IMintableERC20 public immutable token;

  uint256 public c = 100;

  uint256 public totalStaked = 0;

  mapping(address => uint256) public stakedByAddress;

  mapping(address => StakingPosition[]) public stakingPositionsByAddress;

  constructor(address _token) {
    token = IMintableERC20(_token);
  }

  event cChanged(
    uint256 oldC,
    uint256 newC
  );

  event Staked(
    address indexed addr,
    uint256 amount,
    uint256 time,
    uint256 data
  );

  event RewardsClaimed(
    address indexed addr,
    uint256 i,
    uint256 amount
  );

  event Unstaked(
    address indexed addr,
    uint256 i,
    uint256 amount
  );

  function adjustC(uint256 newC) public onlyOwner {
    emit cChanged(c, newC);

    c = newC;
  }

  function stake(uint256 _amount, uint32 _time, uint256 _data) public {
    uint256 daysTime = _time / 1 days;

    require(daysTime >= 30 && daysTime <= 360 && daysTime % 15 == 0, "invalid staking time");

    token.transferFrom(msg.sender, address(this), _amount);

    stakingPositionsByAddress[msg.sender].push(
      StakingPosition(
        _amount,
        _time,
        uint32(block.timestamp),
        uint32(block.timestamp)
      )
    );

    totalStaked += _amount;
    stakedByAddress[msg.sender] += _amount;

    emit Staked(
      msg.sender,
      _amount,
      _time,
      _data
    );
  }

  function claimRewards(uint256 _i) public {
    require(stakingPositionsByAddress[msg.sender].length > _i, "invalid index");

    StakingPosition storage stakingPosition = stakingPositionsByAddress[msg.sender][_i];

    uint256 rewards = calculateRewards(
      stakingPosition.amount,
      stakingPosition.time,
      stakingPosition.lastWithdrawal,
      block.timestamp
    );

    require(stakingPosition.amount != 0, "invalid staking position");

    stakingPosition.lastWithdrawal = uint32(block.timestamp);
    
    token.mint(msg.sender, rewards);

    emit RewardsClaimed(msg.sender, _i, rewards);
  }

  function unstake(uint256 _i) public {
    require(stakingPositionsByAddress[msg.sender].length > _i, "invalid index");

    claimRewards(_i);

    StakingPosition storage stakingPosition = stakingPositionsByAddress[msg.sender][_i];

    require(stakingPosition.createdAt + stakingPosition.time <= block.timestamp, "time period not passed");

    emit Unstaked(msg.sender, _i, stakingPosition.amount);

    token.transferFrom(address(this), msg.sender, stakingPosition.amount);

    totalStaked -= stakingPosition.amount;
    stakedByAddress[msg.sender] -= stakingPosition.amount;

    stakingPosition.amount = 0;
    stakingPosition.time = 0;
    stakingPosition.lastWithdrawal = 0;
    stakingPosition.createdAt = 0;
  }

  function calculateRewards(uint256 _stakedAmount, uint256 _stakedTime, uint256 _startTime, uint256 _endTime) public view returns (uint256) {
    uint256 timeDelta = _endTime - _startTime;

    uint256 apy = calculateApy(_stakedTime);

    return _stakedAmount * apy / 100 * timeDelta / 360 days;
  }

  function calculateApy(uint256 _stakedTime) public view returns (uint256) {
    uint256 stakedDays = _stakedTime / 1 days;

    require(stakedDays >= 30 && stakedDays <= 360, "invalid staked time");

    if(stakedDays < 90) return ((stakedDays - 30) * (stakedDays - 30) / 12 + 38) * c / 100;
    else return ((stakedDays - 90) / 2 + 338) * c / 100;
  }

  function stakingPositions(address _addr) public view returns (StakingPositionFrontend[] memory) {
    uint256 n = stakingPositionsByAddress[_addr].length;

    StakingPositionFrontend[] memory positions = new StakingPositionFrontend[](n);

    for(uint256 i = 0; i < n; i++) {
      StakingPosition memory stakingPosition = stakingPositionsByAddress[_addr][i];

      positions[i] = StakingPositionFrontend(
        stakingPosition.amount,
        stakingPosition.time,
        stakingPosition.lastWithdrawal,
        stakingPosition.createdAt,
        uint32(stakingPosition.createdAt + stakingPosition.time > block.timestamp ? (stakingPosition.createdAt + stakingPosition.time - block.timestamp) / 1 days : 0),
        calculateRewards(
          stakingPosition.amount,
          stakingPosition.time,
          stakingPosition.lastWithdrawal,
          block.timestamp
        ),
        calculateRewards(
          stakingPosition.amount,
          stakingPosition.time,
          0,
          1 days
        )
      );
    }

    return positions;
  }
}
