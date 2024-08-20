// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./DataTypes.sol";

library Utils {
    using DataTypes for *;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    function transferValues(address from, address to, uint value) internal returns (bool sufficient) {
        emit Transfer(from, to, value);    
        payable(to).transfer(value);

        return true;
    }

    function generateUUID(
        uint openBetsLength
    ) internal view returns (string memory) {
        bytes32 uuid = keccak256(
            abi.encodePacked(block.timestamp, msg.sender, openBetsLength)
        );
        return toHexString(uuid);
    }

    function toHexString(bytes32 data) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(64);
        for (uint i = 0; i < 32; i++) {
            str[i * 2] = alphabet[uint(uint8(data[i] >> 4))];
            str[1 + i * 2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

    function stringLength(string memory str) internal pure returns (uint) {
        return bytes(str).length;
    }

    function removeElementArray(
        uint index,
        DataTypes.Bet[] storage array
    ) internal {
        require(index < array.length, "Index out of bounds");

        for (uint i = index; i < array.length - 1; i++) {
            array[i] = array[i + 1];
        }

        array.pop();
    }
}
