pragma solidity ^0.5.2;

import "../utils/Math.sol";

/**
 * @title Arrays
 * @dev Utility library of inline array functions
 */
library Arrays {

    /**
     * @dev Upper bound search function which is kind of binary search algorithm. It searches sorted
     * array to find index of the element value. If element is found then returns its index otherwise
     * it returns index of first element which is greater than searched value. If searched element is
     * bigger than any array element function then returns first index after last element (i.e. all
     * values inside the array are smaller than the target). Complexity O(log n).
     * @param array The array sorted in ascending order.
     * @param element The element's value to be found.
     * @return The calculated index value. Returns 0 for empty array.
     */
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            // Note that mid will always be strictly less than high (i.e. it will be a valid array index)
            // because Math.average rounds down (it does integer division with truncation).
            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        // At this point `low` is the exclusive upper bound. We will return the inclusive upper bound.
        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
    }

    /**
     * @dev Returns a subarray of the array element in input.
     * @param array The original array.
     * @param from The first zero-indexed element of the array to be considered in the sub-array result.
     * @param to The first zero-indexed element of the array to be excluded in the sub-array result.
     * @return The calculated subarray. If from equals to the result is an empty array.
     */
    function subarray(uint256[] memory array, uint256 from, uint256 to) internal pure returns (uint256[] memory out) {
      require(array.length >= to);
      require(to >= from);
      uint256 l = to - from;
      out = new uint256[](l);
      for (uint256 i = 0; i < l; i++) {
        out[i] = array[from + i];
      }
    }
}
