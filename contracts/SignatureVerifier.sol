// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Strings.sol";

contract SignatureVerifier {

	using Strings for uint;

    /// @dev used in createEnvelop and claim functions of TresV2 contract
    /// @param envelopeId numeric envelope id
    /// @param claimCounter current number of claims
    /// @return hashedMessage hashed message of arguments combination
    function getMessageHash(
        uint envelopeId,
		uint claimCounter
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(envelopeId.toString(),claimCounter.toString()));
    }

    /// @dev used in verify function
    /// @param _messageHash message hash obtained from getMessageHash function
    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }

    /// @dev used in claim function of TresV2 contract
    /// @param _signer for TresV2 it will always be the owner of TresV2 contract
    /// @param _envelopeId numeric envelope id
    /// @param claimCounter current number of claims
    /// @param signature signature of message from TresV2 server privateKey
    /// @return valid states if signature is valid or not
    function verify(
        address _signer,
        uint _envelopeId,
	    uint claimCounter,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(_envelopeId,claimCounter);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

     /// @dev used in verify function
    /// @param _ethSignedMessageHash for TresV2 it will always be the owner of TresV2 contract
    /// @param _signature numeric envelope id
    /// @return signer signer of message
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    /// @dev returns paramets that allow to retrieve the signer of the message. Used in recoverSigner function
    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }
}