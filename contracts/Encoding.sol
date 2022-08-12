// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

contract Encoding {
    struct CustomData {
        string name;
        uint[2] nums;
    }

    function encode(
        uint x,
        address addr,
        uint[] calldata arr,
        CustomData calldata data
    ) external pure returns (bytes memory) {
        return abi.encode(x, addr, arr, data);
    }
    function decode(bytes calldata data)
        external pure
        returns (
            uint x,
            address addr,
            uint[] memory arr,
            CustomData memory customData
        )
    {
        (x, addr, arr, customData) = abi.decode(data, (uint, address, uint[], CustomData));
    }
}
