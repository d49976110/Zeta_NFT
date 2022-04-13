const {time} = require('@openzeppelin/test-helpers');
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
    const result = await ZetaInstance.getRest();
    assert.equal(result, 900);
  });
});
