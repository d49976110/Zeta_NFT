const {time} = require('@openzeppelin/test-helpers');
const {web3} = require('@openzeppelin/test-helpers/src/setup');
const Zeta = artifacts.require('Zeta');

contract('Zeta', (accounts) => {
  beforeEach(async () => {
    ZetaInstance = await Zeta.deployed();
  });

  it('check init owner balance ', async () => {
    const result = await ZetaInstance.balanceOf(accounts[0]);
    assert.equal(result, 0, 'first should be zero');
  });

  it('init mint', async () => {
    await ZetaInstance.init_mint(60, {from: accounts[0], gas: 6712388});
    await ZetaInstance.init_mint(39, {from: accounts[0], gas: 6712388});
    const result = await ZetaInstance.balanceOf(accounts[0]);
    assert.equal(result.toString(), 99, 'first should be 99');
  });

  it('rest supply', async () => {
    const result = await ZetaInstance.getRestSupply();
    assert.equal(result, 900);
  });

  it('before setTime should not mint', async () => {
    try {
      await ZetaInstance.mint(1, {from: accounts[1], value: 0.001 * 10 ** 18});
    } catch (err) {
      assert.equal(err.reason, 'Not in the mint period');
    }
  });

  it('setTime', async () => {
    const now = Math.floor(Date.now() / 1000);
    await ZetaInstance.setTime(now - 1000, now + 86400);
    const result = await ZetaInstance.getTime();
    // console.log('result', result);

    assert.equal(result._startTime.toString(), now - 1000);
    assert.equal(result._endTime.toString(), now + 86400);
  });

  it('before active should not mint', async () => {
    try {
      await ZetaInstance.mint(1, {from: accounts[1], value: 0.001 * 10 ** 18});
    } catch (err) {
      assert.equal(err.reason, 'Sale must be active to mint');
    }
  });

  it('flip active', async () => {
    await ZetaInstance.flipSaleActive();
    const result = await ZetaInstance.getSaleActive();
    assert.equal(result, true, 'flip active should be true');
  });

  it('mint', async () => {
    await ZetaInstance.mint(1, {from: accounts[1], value: 0.001 * 10 ** 18});
    const userTokenBalance = await ZetaInstance.balanceOf(accounts[1]);
    assert.equal(userTokenBalance, 1);
  });

  it('rest balance', async () => {
    const result = await ZetaInstance.getRestSupply();
    assert.equal(result, 899);
  });

  it('check contract balance', async () => {
    const balance = await web3.eth.getBalance(ZetaInstance.address);
    assert.equal(web3.utils.fromWei(balance, 'ether'), 0.001);
  });
});
