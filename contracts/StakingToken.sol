// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

/**
 * @title Staking Token (STK)
 * @author Aharon Smbatyan
 * @notice Implements a basic ERC20 staking token with incentive distribution
 */
contract StakingToken is ERC20, Ownable {
    
    /// @notice We usually require to know who are all the stakeholders
    address[] internal stakeholders;

    /// @notice The stakes for each stakeholder.
    mapping (address => uint256) internal stakes;

    /// @notice The accumulated rewards for each stakeholder.
    mapping (address => uint256) internal rewards;

    /**
     * @notice The constructor for the Staking Token.
     * @param _owner The address to receive all tokens on construction.
     * @param _supply The amount of tokens to mint on construction.
     */
    constructor(address _owner, uint256 _supply) ERC20('Staking token', 'STK') {
        _mint(_owner, _supply);
    }

    /**
     * @notice A method to check if an address is a stakeholder.
     * @param _address The address to verify.
     * @return bool, uint256 Whether the address is a stakeholder, and if so its position
     *         in the stakeholder array
     */
    function isStakeholder(address _address) public view returns(bool, uint256)
    {
        for(uint256 s = 0; s < stakeholders.length; s += 1) {
            if(_address == stakeholders[s]) {
                return (true, s);
            }
        }
        return (false, 0);
    }

    /**
     * @notice A method to add a stakeholder.
     * @param _stakeholder The stakeholder to add.
     */
    function addStakeholder(address _stakeholder) public
    {
        (bool is_stakeholder,) = isStakeholder(_stakeholder);
        if(!is_stakeholder) {
            stakeholders.push(_stakeholder);
        }
    }

    /**
     * @notice A method to remove a stakeholder.
     * @param _stakeholder The stakeholder to remove.
     */
    function removeStakeholder(address _stakeholder) public
    {
        (bool is_stakeholder, uint256 idx) = isStakeholder(_stakeholder);
        if(is_stakeholder) {
            stakeholders[idx] = stakeholders[stakeholders.length-1];
            stakeholders.pop();
        }
    }

    /**
     * @notice A method to retrieve the stake for a stakeholder
     * @param _stakeholder The stakeholder to retrieve the stake for.
     * @return uint256 The amount of wei staked.
     */
    function stakeOf(address _stakeholder) public view returns (uint256)
    {
        return stakes[_stakeholder];
    }

    /**
     * @notice Return the total of aggregated stakes from all stakeholders.
     * @return uint256 The aggregated stakes from all stakeholders.
     */
    function totalStakes() public view returns (uint256)
    {
        uint256 total = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
           total += stakes[stakeholders[s]];
        }
        return total;
    }

    /**
     * @notice A method for a stakeholder to create a stake.
     * @param _stake The size of the stake to be created.
     */
    function createStake(uint256 _stake) public
    {
        _burn(msg.sender, _stake);
        if(stakes[msg.sender] == 0) {
            addStakeholder(msg.sender);
        }
        stakes[msg.sender] += _stake;
    }

    /**
     * @notice A method for a stakeholder to remove a stake.
     * @param _stake The size of the stake to be removed.
     */
    function removeStake(uint256 _stake) public
    {
        stakes[msg.sender] -= _stake; // will revert if negative
        if(stakes[msg.sender] == 0) {
            removeStakeholder(msg.sender);
        }
        _mint(msg.sender, _stake);
    }

    /**
     * @notice A method to allow a stakeholder to check his rewards.
     * @param _stakeholder The stakeholder to check rewards for.
     */
    function rewardOf(address _stakeholder) public view returns(uint256)
    {
        return rewards[_stakeholder];
    }

    /**
    * @notice Return the total of aggregated rewards from all stakeholders.
    * @return uint256 The aggregated rewards from all stakeholders.
    */
    function totalRewards() public view returns(uint256)
    {
        uint256 total = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            total += rewards[stakeholders[s]];
        }
        return total;
    }

    /**
     * @notice A simple method that calculates the rewards for each stakeholder.
     * @param _stakeholder The stakeholder to calculate rewards for.
     */
    function calculateReward(address _stakeholder) public view returns (uint256)
    {
        return stakes[_stakeholder] / 100;
    }

    /**
     * A method to distribute rewards to all stakeholders.
     */
    function distributeRewards() public onlyOwner
    {
        for(uint256 i = 0; i < stakeholders.length; i += 1) {
            address stakeholder = stakeholders[i];
            uint256 reward = calculateReward(stakeholder);
            rewards[stakeholder] += reward;
        }
    }

    /**
     * @notice A method to allow a stakeholder to withdraw his rewards.
     */
    function withdrawReward() public
    {
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        _mint(msg.sender, reward);
    }
}