const RedEnvelope = artifacts.require("TresV2");
const { expectEvent, expectRevert } = require("@openzeppelin/test-helpers");

contract("TresV2", (accounts) => {
  let redEnvelope, creator, receipt, envelopeId, eventtest, signature, wrongSignature;
  before(async () => {
    redEnvelope = await RedEnvelope.new();
    creator = accounts[0];
    claimer = accounts[1];
  });

  /********************************************************
   *                                                       *
   *                     CREATE ENVELOPE FUNCTIONS         *
   *                                                       *
   ********************************************************/

  describe("Create Envelope", () => {
    it("Envelope Created succesfully", async () => {
      
      receipt = await redEnvelope.createEnvelope("This is a test message", {
        value: 100000000,
      });
      
      // 0xe3f0ae350ee09657933cd8202a4dd563c5af941f8054e6d7191e3246be378290
      account = creator.toString()
      hashedMessage = await redEnvelope.getMessageHash(0,0);
      // signature = await web3.eth.sign(hashedMessage, account)
      // signature = await web3.eth.sign(web3.utils.asciiToHex(hashedMessage), account)
      signature = await web3.eth.accounts.sign(hashedMessage, "0x3008d732b383b908b8ec72d81146d4cce2f9e9d02dffb05f2d7bfb265120d2ea");
      wrongSignature = await web3.eth.accounts.sign(hashedMessage, "0x3fd1aebf7bdd9b406a23165bdcfe732ef87dcfcf02ae9194afbd9aea08530fb3");
      signature = signature.signature
      wrongSignature = wrongSignature.signature
      getEthSigned = await redEnvelope.getEthSignedMessageHash(hashedMessage)
      signedAccount = await redEnvelope.recoverSigner(getEthSigned, signature)
      owner = await redEnvelope.owner()
      console.log("hashed message", hashedMessage)
      console.log("ethSignedMessage",getEthSigned)
      console.log("signature", signature)
      console.log("creator", creator.toString())
      console.log("Signed Account", signedAccount)      
      console.log("Owner", owner.toString())
      result = await redEnvelope.verify(account,0,0,signature)
      console.log(result)

    });
    it("EnvelopeCreated Event emited", async () => {
      envelopeId = 0;
      await expectEvent(receipt, "EnvelopeCreated", {
        envelopeId: envelopeId.toString(),
        hashedMessage: hashedMessage.toString(),
        creator: account,
        tokenAmount: "100000000",
        creatorNickName: "This is a test message"
      });
    });


  })
    

  /********************************************************
   *                                                       *
   *                     CLAIM PRICE FUNCTIONS             *
   *                                                       *
   ********************************************************/
  
   describe("User Claim", () => {
    
    it("Claim incorrect Signature", async()=> {
      await expectRevert(redEnvelope.claim(0, wrongSignature), "Incorrect Signature")
    })

    it("Claim is correct", async() => {
      await redEnvelope.claim(0,signature)
    })

   })


  /*****************************************************************
   *                                                               *
   *                     CREATOR WITHDRAW FUNCTIONS                *
   *                                                               *
   ****************************************************************/

  // describe("Creator Withdraw", () => {
  //   it("Creator withdraw", async () => {
  //     eventtest = await redEnvelope.creatorWithdraw(envelopeId);
  //     receipt = await redEnvelope.getEnvelope(envelopeId);
  //     truffleAssert.eventEmitted(eventtest, "CreatorWithdrawn", (ev) => {
  //       return ev.withdrawn === true;
  //     });
  //   });

  //   it("Testing TokenAmount post withdraw", async () => {
  //     assert.equal(receipt.tokenAmount, 0, "Token Amount does not match");
  //   });
  // });
});
