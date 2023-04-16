pragma solidity ^0.8.0;

library Strings {
    // via https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol
    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory result = new bytes(length);
        uint256 k = length;
        while (_i != 0) {
            k = k-1;
            uint8 d = uint8(48 + uint256(_i % 10));
            result[k] = bytes1(d);
            _i /= 10;
        }
        return string(result);
    }

    function fixed2str(int256 value, uint8 decimals) internal pure returns (string memory) {
        int256 _value = value;
        bool negative = false;
        if (_value < 0) {
            negative = true;
            _value = _value * -1;
        }

        uint256 tempValue = uint256(_value);

        uint256 i = 1;

        while (i * (10**decimals) <= tempValue) {
            i++;
        }

        if (i == 1) {
            return "0";
        }

        uint256 index = i + decimals;

        bytes memory result;

        do {
            index--;
            bytes1 digit = bytes1(uint8(48 + uint256(tempValue / (10**index)) % 10));
            result = abi.encodePacked(result, digit);

            if (index == decimals && i != 1) {
                result = abi.encodePacked(result, ".");
            }
        } while (index > 0);

        if (negative) {
            return string(abi.encodePacked("-", result));
        } else {
            return string(result);
        }
    }
}
