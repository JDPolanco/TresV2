// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./SignatureVerifier.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; 
import "@openzeppelin/contracts/security/Pausable.sol";

/// @title A distributor of tokens
/// @author Juan David Polanco
/// @notice You can use this contract to distribute tokens to a maximum of 3 people per envelope
/// @custom:experimental This is an experimental contract.
contract TresV2 is SignatureVerifier, Ownable, ReentrancyGuard, Pausable {
  
  struct Envelopes {
    uint128 envelopeId;
    uint initialTokenAmount;
    uint claimedTokenAmount;
    address creator;
    address[] participants;
  }
  mapping(uint128 => Envelopes) envelope;
  
  uint128 envelopeCounter;

  event EnvelopeCreated(uint128 envelopeId, address creator, uint timeStamp, uint tokenAmount, bytes32 hashedMessage, string creatorNickName);
  event Claimed(uint128 envelopeId, address claimer, uint timeStamp, uint distributedTokens, bytes32 hashedMessage);
  event CreatorWithdrawn(uint128 envelopeId, uint timeStamp);
	constructor ()
    Ownable()
	{
	}

	/********************************************************
	*                                                       *
	*                     MAIN FUNCTIONS                    *
	*                                                       *
	********************************************************/

  /// @notice create an envelope and share money with your people
  /// @param _creatorNickName nickName of creator to display when users open the envelope
  /// @dev creates envelope and stores crypto in this contract to later on distribute with participants
	function createEnvelope(string memory _creatorNickName) external payable {
    require(msg.value > 0, "Insufficient funds");
    uint128 _envelopeId = envelopeCounter;
    envelopeCounter++;
    bytes32 _hashedMessage = getMessageHash(_envelopeId, 0);
    Envelopes memory _envelope = envelope[_envelopeId];
    _envelope.envelopeId = _envelopeId;
    _envelope.initialTokenAmount = msg.value;
    _envelope.creator = msg.sender;
    envelope[_envelopeId] = _envelope;
    emit EnvelopeCreated(_envelopeId, msg.sender,block.timestamp, msg.value, _hashedMessage, _creatorNickName);
	}

  /// @notice Open envelope before others and get crypto gift!
  /// @param _envelopeId id of envelope to be opened
  /// @dev contract distributes crypto to msg.sender
  function claim(uint128 _envelopeId, bytes memory _signature) external nonReentrant whenNotPaused {
    Envelopes memory _envelope = envelope[_envelopeId];
    uint _currentParticipant = _envelope.participants.length;
    require(verify(owner(),_envelopeId,_currentParticipant,_signature), "Incorrect Signature");
    require(3 >  _currentParticipant, "max participants exceeded");
    require(_envelope.claimedTokenAmount < _envelope.initialTokenAmount, "tokens already distributed");
    require(!_alreadyClaimed(msg.sender, _envelope.participants), "You already claimed");
    
    uint _amountToDeliver;
    // If it is the last possible participant it shares the remaining crypto. Otherwise it shares a random amount of crypto
    if(2 != _currentParticipant) {
      _amountToDeliver = _getAmountToDeliver(_currentParticipant, _envelope.initialTokenAmount - _envelope.claimedTokenAmount);
    } else {
      _amountToDeliver = _envelope.initialTokenAmount - _envelope.claimedTokenAmount;
    }
    _envelope.claimedTokenAmount += _amountToDeliver;
    envelope[_envelopeId] = _envelope;
    envelope[_envelopeId].participants.push(msg.sender);
    (bool sent, ) = payable(msg.sender).call{value: _amountToDeliver}("");
    require(sent, "Failed to send Ether");
    bytes32 _newhashedMessage = getMessageHash(_envelopeId, _envelope.participants.length);
    emit Claimed(_envelopeId,msg.sender,block.timestamp, _amountToDeliver, _newhashedMessage);
  }

  /// @notice Claim your crypto locked in contract
  /// @param _envelopeId id of envelope in bytes256
  /** @dev In case participants have not claimed all possible crypto,
           the envelope creator can claim crypto locked in this contract envelope**/
  function creatorWithdraw(uint128 _envelopeId) external {
    Envelopes memory _envelope = envelope[_envelopeId];
    require(_envelope.claimedTokenAmount < _envelope.initialTokenAmount, "tokens already distributed");
    require(_envelope.creator == msg.sender, "Not creator");
    envelope[_envelopeId].claimedTokenAmount = _envelope.initialTokenAmount;
    (bool sent, ) = payable(msg.sender).call{value: _envelope.initialTokenAmount - _envelope.claimedTokenAmount}("");
    require(sent, "Failed to send Ether");
    emit CreatorWithdrawn(_envelopeId, block.timestamp);
  }

	/********************************************************
  *                                                       *
  *                INTERNAL FUNCTIONS                     *
  *                                                       *
  ********************************************************/

  /// @dev used in claim function
  /// @param _participantsCounter current number of participants for the envelope
  /// @param _tokenAmount amount of crypto left in the envelope
  /// @return _amountToDeliver amount of crypto to be deliver to claimer. It is random number between 1 and _tokenAmount
  function _getAmountToDeliver(uint _participantsCounter, uint _tokenAmount) internal view returns (uint _amountToDeliver) {
    _amountToDeliver = (uint(keccak256(abi.encodePacked(_participantsCounter,block.timestamp))) % _tokenAmount) + 1;
  }

  /// @dev used in claim function
  /// @param user user trying to open the envelope
  /// @param _claimedUsers array with addresses of users who have claimed gifts in this envelope
  /// @return _haveClaimed amount of crypto to be deliver to claimer. It is random number between 1 and _tokenAmount
  function _alreadyClaimed(address user, address[] memory _claimedUsers) internal pure returns(bool _haveClaimed){
    for(uint8 i = 0; i < _claimedUsers.length; i = unsafe_inc(i)) {
      if(_claimedUsers[i] == user){
        _haveClaimed = true;
        break;
      }
    }
  }

  /// @dev Increments a number. Used in for loops for gas optimization
  /// @param x number to be incremented
  function unsafe_inc(uint8 x) private pure returns(uint8){
    unchecked { return x + 1; }
  }

  /********************************************************
  *                                                       *
  *                  ADMIN FUNCTIONS                      *
  *                                                       *
  ********************************************************/
  
  /// @dev to be used in case of emergency to withdraw all crypto stored in this contract
  function adminWithdraw() external onlyOwner whenPaused {
    (bool sent, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(sent, "Failed to send Ether");
  }

	/********************************************************
  *                                                       *
  *                     GET FUNCTIONS                     *
  *                                                       *
  ********************************************************/

  /// @param _envelopeId numeric envelope Id
  /// @return _envelope information related to envelope
  function getEnvelope(uint128 _envelopeId) external view returns(Envelopes memory _envelope) {
    _envelope = envelope[_envelopeId];
  }

	/********************************************************
  *                                                       *
  *                  RECEIVE FUNCTIONS                    *
  *                                                       *
  ********************************************************/

  /// @dev this function allows this contract to receive native tokens
  receive() external payable {  }
  }