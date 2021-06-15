const Coin = artifacts.require('Coin');
const truffleAssert = require('truffle-assertions');


contract('Coin', (accounts) => {
    let contract;

    let alice = accounts[0];
    let bob = accounts[1];
    let carol = accounts[2];
    let trudy = accounts[3];

    beforeEach('Setup contract for each test', async () => {
        contract = await Coin.new();
    });

    it('Alice mints money for Bob', async () => {
        await contract.mint(bob, 100, {from: alice});
        const balance = await contract.balances(bob);
        expect(balance.toNumber()).to.equal(100);
    });

    it('Bob cannot mint money for himself', async () => {
        await truffleAssert.reverts(
            contract.mint(bob, 100, { from: bob})
        );
    });

    it('Bob sends received money to carol', async () => {
        await contract.mint(bob, 100, {from: alice});
        await contract.send(carol, 60, {from: bob});

        const bob_balance = await contract.balances(bob);
        const carol_balance = await contract.balances(carol);

        expect(bob_balance.toNumber()).to.equal(40);
        expect(carol_balance.toNumber()).to.equal(60);
    });

    it('Bob cannot send more money than he has', async () => {
        await contract.mint(bob, 100, {from: alice});
        await truffleAssert.reverts(
            contract.send(carol, 101, {from: bob}),
            truffleAssert.ErrorType.REVERT
        );
    });
})