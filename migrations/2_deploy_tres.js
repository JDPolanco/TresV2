const TresV2 = artifacts.require('TresV2');

let tresV2
module.exports = async function (deployer) {
   await deployer
    .deploy(TresV2)
  tresV2 = await TresV2.deployed()
  await tresV2.createEnvelope("Q Iterviewer", {value: 1000000});
};