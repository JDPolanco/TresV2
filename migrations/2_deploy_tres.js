const TresV2 = artifacts.require('TresV2');

module.exports = async function (deployer) {
   await deployer
    .deploy(TresV2)
    .then(() => setAddress(process.env.NETWORK_ID, TresV2.address));
  tresV2 = await TresV2.deployed()
  await tresV2.createEnvelope(3,"Hello Q Iterviewer", {value: 1000000});
  console.log(receipt[0].envelopeId)
};