pragma solidity ^0.5.2;

import "../utils/Counters.sol";
/**
 * @title TimedRoles
 * @dev Library for managing addresses assigned to a Role which has a time constraint.
 */
library TimedRoles {
    using Counters for Counters.Counter;
    struct Role {
        mapping (address => uint256) bearer;
        Counters.Counter size;
    }

    /**
     * @dev give an account access to this role by setting current timestamp
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account) == 0);

        role.bearer[account] = block.timestamp;
        role.size.increment();
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account) != 0);

        role.bearer[account] = 0;
        role.size.decrement();
    }

    /**
     * @dev check if an account has this role and return the timestamp when it was added
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (uint256) {
        require(account != address(0));
        return role.bearer[account];
    }

    /**
     * @dev check how many accounts has this role
     * @return bool
     */
    function count(Role storage role) internal view returns (uint256) {
        return role.size.current();
    }
}
