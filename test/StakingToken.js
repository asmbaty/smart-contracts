const StakingToken = artifacts.require('StakingToken');
const truffleAssert = require('truffle-assertions');

contract('StakingToken', (accounts) => {
    let contract;
    
    const initialSTK = 1000;

    let alice = accounts[0];
    let bob = accounts[1];
    let carol = accounts[2];
    let trudy = accounts[3];

    beforeEach('Setup contract for each test', async () => {
        contract = await StakingToken.new(alice, initialSTK);
    });

    it('One quick test for all', async () => {

        // alice transfers bob 300 STKs
        await contract.transfer(bob, 300, {from: alice});
        
        // bob stakes 300 STKs
        await contract.createStake(300, {from: bob});
        
        // bob's balance should be 0 becuase he staked everything he has
        const bob_balance = await contract.balanceOf(bob);
        expect(bob_balance.toNumber()).to.equal(0);

        // total supply must be (initialSTK-300) because bob burned 300
        const total_supply = await contract.totalSupply();
        expect(total_supply.toNumber()).to.equal(initialSTK-300);
        
        // distribute rewards
        await contract.distributeRewards({from: alice});

        // reward of bob must be 300 / 100 = 3
        const bob_reward = await contract.rewardOf(bob);
        expect(bob_reward.toNumber()).to.equal(3);

        // bob withdraws his rewards
        await contract.withdrawReward({from: bob});

        // bob's balance is now 3 STK
        const bob_balance2 = await contract.balanceOf(bob);
        expect(bob_balance2.toNumber()).to.equal(3);

        // bob now removed his stake
        await contract.removeStake(300, {from: bob});

        // total supply is now more by 3 than initialMTK
        const total_supply2 = await contract.totalSupply();
        expect(total_supply2.toNumber()).to.equal(initialSTK + 3);
    });

})