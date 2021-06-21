// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
contract ReceiverPays {
    address owner = msg.sender;

    mapping(uint256 => bool) usedNonces;

    constructor() payable {}

    function claimPayment(
        uint256 amount,
        uint256 nonce,
        bytes memory signature
    ) public
    {
        require(!usedNonces[nonce]);
        usedNonces[nonce] = true;

        bytes32 message = prefixed(keccak256(abi.encodePacked(
            msg.sender, amount, nonce, this
        )));

        require(recoverSigner(message, signature) == owner);

        payable(msg.sender).transfer(amount);
    }

    function shutdown() public
    {
        require(msg.sender == owner);
        selfdestruct(payable(msg.sender));
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65);

        assembly {
            // first 32 bytes, after the length prefix.
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes).
            v := bytes(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function recoverSigner(bytes32 message, bytes memory sig)
        internal
        pure
        returns (address)
    {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("/x19Ethereum Signed Message:\n32", hash));
    }
}