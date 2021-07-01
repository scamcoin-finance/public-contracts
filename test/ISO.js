const ISO = artifacts.require("ISO");
const StakingToken = artifacts.require("StakingToken");
var expect = require('chai').expect;

const Web3 = require("web3");
const web3 = new Web3();

contract("ISO", (accounts) => {
    const [alice, bob] = accounts;
    let contractInstance;
    let tokenContractInstance;
    const priceBNB = '4200000000000000000'; // 0.014BNB
    const tokenCount = '0.1';

    beforeEach(async () => {
        contractInstance = await ISO.new();
        tokenContractInstance = await StakingToken.new();

        await tokenContractInstance.transfer(contractInstance.address, web3.utils.toWei('40000', 'ether'), {from: alice});
        await contractInstance.setPriceBNB(priceBNB, {from: alice});
        await contractInstance.setTokenContract(contractInstance.address, {from: alice});
    });

    it('get token contract', async () => {
        const res = await contractInstance.tokenContract();
        expect(res).to.equal(contractInstance.address);
    });

    it('get price', async () => {
        const res = await contractInstance.priceBNB();
        expect(res.toString()).to.equal(priceBNB);
    });

    it('get cost', async () => {
        const res = await contractInstance.getCost(
            // web3.utils.toWei(tokenCount, 'ether'),
            '238095238095238082',
            priceBNB,
            '18'
        );

        console.log(res.toString());

        // expect(res.toString()).to.equal(web3.utils.toWei(tokenCount * priceBNB + '', 'wei'));
    });

    // it("Buy tokens", async () => {
    //     const res = await contractInstance.buyTokensForBNB(
    //         web3.utils.toWei(tokenCount, 'ether'), 
    //         {from: bob, value: web3.utils.toWei(tokenCount * priceBNB + '', 'wei')}
    //     );

    //     const gasUsed = res.receipt.gasUsed;
    //     console.log(web3.utils.fromWei(gasUsed.toString(), 'ether'));

    //     const tokensSold = await contractInstance.tokensSold();
    //     expect(tokensSold.toString()).to.equal(web3.utils.toWei(tokenCount, 'ether'));
    // })

    afterEach(async () => {
        await contractInstance.kill();
        await tokenContractInstance.kill();
    });
})