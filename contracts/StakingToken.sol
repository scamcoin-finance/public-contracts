// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ScamCoin.sol";

contract StakingToken is ScamCoin {
    using SafeMath for uint256;

    constructor() ScamCoin() {}

    /**
     * @dev We usually require to know who are all the stakeholders.
     */
    address[] internal stakeholders;

    /**
     * @dev The stakes for each stakeholder.
     */
    mapping(address => uint256) internal stakes;

    /**
     * @dev The accumulated rewards for each stakeholder.
     */
    mapping(address => uint256) internal rewards;

    // ---------- STAKES ----------

    /**
     * @dev A method for a stakeholder to create a stake.
     * @param _stake The size of the stake to be created.
     */
    function createStake(uint256 _stake)
        public
    {
        _burn(msg.sender, _stake);
        if(stakes[msg.sender] == 0) addStakeholder(msg.sender);
        stakes[msg.sender] = stakes[msg.sender].add(_stake);
    }

    /**
     * @dev A method for a stakeholder to remove a stake.
     * @param _stake The size of the stake to be removed.
     */
    function removeStake(uint256 _stake)
        public
    {
        stakes[msg.sender] = stakes[msg.sender].sub(_stake);
        if(stakes[msg.sender] == 0) removeStakeholder(msg.sender);
        _mint(msg.sender, _stake);
    }

    /**
     * @dev A method to retrieve the stake for a stakeholder.
     * @param _stakeholder The stakeholder to retrieve the stake for.
     * @return uint256 The amount of wei staked.
     */
    function stakeOf(address _stakeholder)
        public
        view
        returns(uint256)
    {
        return stakes[_stakeholder];
    }

    /**
     * @dev A method to the aggregated stakes from all stakeholders.
     * @return uint256 The aggregated stakes from all stakeholders.
     */
    function totalStakes()
        public
        view
        returns(uint256)
    {
        uint256 _totalStakes = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            _totalStakes = _totalStakes.add(stakes[stakeholders[s]]);
        }
        return _totalStakes;
    }

    // ---------- STAKEHOLDERS ----------

    /**
     * @dev A method to check if an address is a stakeholder.
     * @param _address The address to verify.
     * @return bool, uint256 Whether the address is a stakeholder, 
     * and if so its position in the stakeholders array.
     */
    function isStakeholder(address _address)
        public
        view
        returns(bool, uint256)
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            if (_address == stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }

    /**
     * @dev A method to add a stakeholder.
     * @param _stakeholder The stakeholder to add.
     */
    function addStakeholder(address _stakeholder)
        public
    {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if(!_isStakeholder) stakeholders.push(_stakeholder);
    }

    /**
     * @dev A method to remove a stakeholder.
     * @param _stakeholder The stakeholder to remove.
     */
    function removeStakeholder(address _stakeholder)
        public
    {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if(_isStakeholder){
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        } 
    }

    // ---------- REWARDS ----------
    
    /**
     * @dev A method to allow a stakeholder to check his rewards.
     * @param _stakeholder The stakeholder to check rewards for.
     */
    function rewardOf(address _stakeholder) 
        public
        view
        returns(uint256)
    {
        return rewards[_stakeholder];
    }

    /**
     * @dev A method to the aggregated rewards from all stakeholders.
     * @return uint256 The aggregated rewards from all stakeholders.
     */
    function totalRewards()
        public
        view
        returns(uint256)
    {
        uint256 _totalRewards = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            _totalRewards = _totalRewards.add(rewards[stakeholders[s]]);
        }
        return _totalRewards;
    }

    /** 
     * @dev A simple method that calculates the rewards for each stakeholder.
     * @param _stakeholder The stakeholder to calculate rewards for.
     */
    function calculateReward(address _stakeholder)
        public
        view
        returns(uint256)
    {
        uint256 _koefReward = koefReward();
        return _calculateReward(_stakeholder, _koefReward);
    }

    /** 
     * @dev A simple method that calculates the rewards for each stakeholder.
     * @param _stakeholder The stakeholder to calculate rewards for.
     */
    function _calculateReward(address _stakeholder, uint256 _koefReward)
        private
        view
        returns(uint256)
    {
        return (stakes[_stakeholder] / (100 * _koefReward)) * 6;
    }
    
    function koefReward() 
        public
        view
        returns(uint256)
    {
        uint256 _totalStakes = totalStakes();
        require(_totalStakes > 0, 'totalStakes is 0');

        uint256 _totalTokens = totalSupply();
        _totalTokens = _totalTokens.add(_totalStakes);
        _totalTokens = _totalTokens.add(totalRewards());

        uint256 _koef = 1;

        require(maxSupply() > _totalTokens, 'maxSupply must be greater totalTokens');

        uint256 _limitReward = maxSupply() - _totalTokens;
        require(_limitReward > 0, 'limitReward is 0');

        uint256 _targetReward = (_totalStakes / (100 * _koef)) * 6;

        if (_targetReward > _limitReward) {
            while(_targetReward > 0) {
                _koef = _koef * 2;
                _targetReward = _targetReward.div(2);

                if (_limitReward > _targetReward) {
                    break;
                }
            }
            require(_targetReward > 0, 'reward limit reached');
        }

        return _koef;
    }

    /**
     * @dev A method to distribute rewards to all stakeholders.
     */
    function distributeRewards() 
        public
        onlyOwner
    {
        uint256 _koefReward = koefReward();

        for (uint256 s = 0; s < stakeholders.length; s += 1){
            address stakeholder = stakeholders[s];
            uint256 reward = _calculateReward(stakeholder, _koefReward);
            rewards[stakeholder] = rewards[stakeholder].add(reward);
        }
    }

    /**
     * @dev A method to allow a stakeholder to withdraw his rewards.
     */
    function withdrawReward() 
        public
    {
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        _mint(msg.sender, reward);
    }

    /**
     * @dev for testing
     */
    // function kill() public onlyOwner {
	// 	address payable wallet = payable(owner());
	// 	selfdestruct(wallet);
	// }
}