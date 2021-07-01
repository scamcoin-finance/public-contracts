const StakingToken = artifacts.require("StakingToken");
var expect = require('chai').expect;

const Web3 = require("web3");
const web3 = new Web3();

contract("StakingToken", (accounts) => {
    let [alice, bob] = accounts;
    let contractInstance;

    let stakeCount = 40000;
    let stakeToWei = web3.utils.toWei(stakeCount.toString(), 'ether');
    let koef;

    beforeEach(async () => {
        contractInstance = await StakingToken.new();

        await contractInstance.transfer(bob, web3.utils.toWei('0.11', 'ether'), {from: alice});
        await contractInstance.createStake(web3.utils.toWei('0.11', 'ether'), {from: bob});

        await contractInstance.createStake(stakeToWei, {from: alice});
    });

    it("Staking exists", async () => {
        const stake = await contractInstance.stakeOf(alice);
        expect(stake.toString()).to.equal(stakeToWei.toString());
    });

    it('Get koefReward', async () => {
        const koefReward = await contractInstance.koefReward();
        koef = koefReward.toNumber();
        expect(koefReward.toString()).to.equal('1');
    });

    it('Get calculateReward', async () => {
        const calculateReward = await contractInstance.calculateReward(alice);
        expect(calculateReward.toString()).to.equal(web3.utils.toWei(stakeCount / (100 * koef) * 6 + '', 'ether').toString());
    });

    it('Get calculateReward for bob', async () => {
        const calculateReward = await contractInstance.calculateReward(bob);
        expect(calculateReward.toString()).to.equal(web3.utils.toWei(0.11 / (100 * koef) * 6 + '', 'ether').toString());
    });

    it('distributeRewards', async () => {
        await contractInstance.distributeRewards({from: alice});

        const rewardAlice = await contractInstance.rewardOf(alice);
        const rewardBob = await contractInstance.rewardOf(bob);

        expect(rewardAlice.toString()).to.equal(web3.utils.toWei(stakeCount / (100 * koef) * 6 + '', 'ether').toString());
        expect(rewardBob.toString()).to.equal(web3.utils.toWei(0.11 / (100 * koef) * 6 + '', 'ether').toString());
    });

    afterEach(async () => {
        await contractInstance.kill();
    });
})