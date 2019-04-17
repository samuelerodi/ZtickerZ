
// File: contracts/interface/IZtickyStake.sol

pragma solidity ^0.5.2;

interface IZtickyStake {

  //ZtickyStake
  function isZStake() external pure returns(bool);
  function vestingTime() external view returns (uint256);
  function totalStakedValue() external view returns (uint256);
  function totalShares() external view returns (uint256);
  function stakedValueOf(address _shareHolder) external view returns (uint256);
  function sharesOf(address _shareHolder) external view returns (uint256);
  function sharesByFor(address _stakedBy, address _stakeFor) external view returns(uint256);
  function vestedSharesOf(address _shareHolder) external view returns (uint256);
  function maturedTokensOf(address _stakeFor) external view  returns(uint256);
  function maturedTokensByFor(address _stakedBy, address _stakeFor) external view returns(uint256);
  function authorizedStake(uint256 _amount) external returns (bool);
  function authorizedUnstake(uint256 _amount) external returns (uint256);
  function authorizedStakeFor(address _stakeFor, uint256 _amount) external returns (bool);
  function authorizedUnstakeFor(address _stakeFor, uint256 _amount) external returns (uint256);
  function changeVestingTime(uint256 _newMinimumLockTime) external returns (bool);

  //ERC900
  function stake(uint256 amount) external;
  function stakeFor(address user, uint256 amount) external;
  function unstake(uint256 amount) external;
  function unstakeFor(address user, uint256 amount) external;
  function totalStakedFor(address addr) external view returns (uint256);
  function totalStaked() external view returns (uint256);
  function token() external view returns (address);
  function supportsHistory() external pure returns (bool);

  //Backend
  function isBackend() external pure returns (bool);
  function isFrontend(address account) external view returns (bool);
  function addFrontend(address account) external;
  function removeFrontend(address account) external;
  //BackendAdmin
  function isBackendAdmin(address account) external view returns (bool);
  function addBackendAdmin(address account) external;
  function removeBackendAdmin(address account) external;
  function renounceBackendAdmin() external;
  //Pausable
  function paused() external view returns (bool);
  function pause() external;
  function unpause() external;
  //PauserRole
  function isPauser(address account) external view returns (bool);
  function addPauser(address account) external;
  function removePauser(address account) external;
  function renouncePauser() external;
  //Ownable
  function owner() external view returns (address payable);
  function isOwner() external view returns (bool);
  function transferOwnership(address payable newOwner) external;
  //HasNoEther
  function reclaimEther() external;
  function() external;
  //Destructible
  function destroy() external;
  function destroyAndSend(address payable _recipient) external;




  event Staked(address indexed user, uint256 amount, uint256 total, address indexed stakedBy);
  event Unstaked(address indexed user, uint256 amount, uint256 total, address indexed stakedBy);
  event Paused(address account);
  event Unpaused(address account);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);
  event FrontendAdded(address indexed account);
  event FrontendRemoved(address indexed account);
  event BackendAdminAdded(address indexed account);
  event BackendAdminRemoved(address indexed account);
}

// File: contracts/interface/IZtickyCoinZ.sol

pragma solidity ^0.5.2;

interface IZtickyCoinZ {

  //ZtickyCoinZ
  function isZCZ() external pure returns(bool);
  function mint(address to, uint256 amount) external returns(bool);
  function burn(uint256 value) external returns(bool);
  function authorizedApprove(address spender, uint256 value) external returns (bool);


  //ERC20
  function totalSupply() external view returns (uint256);
  function balanceOf(address owner) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  //ERC20Detailed
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
  //ERC20Pausable
  function transfer(address to, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function increaseAllowance(address spender, uint addedValue) external returns (bool success);
  function decreaseAllowance(address spender, uint subtractedValue) external returns (bool success);
  //Pausable
  function paused() external view returns (bool);
  function pause() external;
  function unpause() external;
  //PauserRole
  function isPauser(address account) external view returns (bool);
  function addPauser(address account) external;
  function removePauser(address account) external;
  function renouncePauser() external;
  //Ownable
  function owner() external view returns (address payable);
  function isOwner() external view returns (bool);
  function transferOwnership(address payable newOwner) external;
  //Backend
  function isBackend() external pure returns (bool);
  function isFrontend(address account) external view returns (bool);
  function addFrontend(address account) external;
  function removeFrontend(address account) external;
  //BackendAdmin
  function isBackendAdmin(address account) external view returns (bool);
  function addBackendAdmin(address account) external;
  function removeBackendAdmin(address account) external;
  function renounceBackendAdmin() external;
  //HasNoEther
  function reclaimEther() external;
  function() external;

  //Events
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Paused(address account);
  event Unpaused(address account);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);
  event FrontendAdded(address indexed account);
  event FrontendRemoved(address indexed account);
  event BackendAdminAdded(address indexed account);
  event BackendAdminRemoved(address indexed account);
}

// File: contracts/utils/SafeMath.sol

pragma solidity ^0.5.2;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: contracts/utils/Counters.sol

pragma solidity ^0.5.2;


/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids
 *
 * Include with `using Counters for Counters.Counter;`
 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the SafeMath
 * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never
 * directly accessed.
 */
library Counters {
    using SafeMath for uint256;

    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value = counter._value.add(1);
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

// File: contracts/roles/TimedRoles.sol

pragma solidity ^0.5.2;

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

// File: contracts/interface/IAdmin.sol

pragma solidity ^0.5.2;

/**
 * @title IAdmin
 * @notice Admins have special permissions and are responsible for mantaining a contract.
 */
interface IAdmin {

  /**
   * @dev It MUST implement the function that checks whether an address is an admin
   */
  function isAdmin(address account) external view returns (bool);

  /**
   * @dev This modifier checks if the caller is an admin of the contract
   */
  modifier onlyAdmin() {
    require(this.isAdmin(msg.sender));
    _;
  }

}

// File: contracts/roles/Roles.sol

pragma solidity ^0.5.2;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    using Counters for Counters.Counter;
    struct Role {
        mapping (address => bool) bearer;
        Counters.Counter size;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
        role.size.increment();
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
        role.size.decrement();
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
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

// File: contracts/utils/Ownable.sol

pragma solidity ^0.5.2;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address payable private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address payable) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    // function renounceOwnership() public onlyOwner {
    //     emit OwnershipTransferred(_owner, address(0));
    //     _owner = address(0);
    // }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address payable newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/roles/BackendAdmin.sol

pragma solidity ^0.5.2;




/**
 * @title BackendAdmin
 * @dev BackendAdmins are responsible for managing backend contracts, and among other things, assign frontend contracts
 * i.e. contracts that implement the logic.
 * BackendAdmins can only be added or removed by the owner of the contract, but they might eventually renounce to the title indipendently
 */
contract BackendAdmin is IAdmin, Ownable {
    using Roles for Roles.Role;

    event BackendAdminAdded(address indexed account);
    event BackendAdminRemoved(address indexed account);

    Roles.Role private _backendAdmins;

    constructor () internal {
        _addBackendAdmin(msg.sender);
    }

    modifier onlyBackendAdmin() {
        require(isBackendAdmin(msg.sender));
        _;
    }

    function isAdmin(address account) public view returns (bool) {
        return isBackendAdmin(account);
    }

    function isBackendAdmin(address account) public view returns (bool) {
        return _backendAdmins.has(account);
    }

    function addBackendAdmin(address account) public onlyOwner {
        _addBackendAdmin(account);
    }

    function removeBackendAdmin(address account) public onlyOwner {
        _removeBackendAdmin(account);
    }

    function renounceBackendAdmin() public {
        _removeBackendAdmin(msg.sender);
    }

    function _addBackendAdmin(address account) internal {
        _backendAdmins.add(account);
        emit BackendAdminAdded(account);
    }

    function _removeBackendAdmin(address account) internal {
        _backendAdmins.remove(account);
        emit BackendAdminRemoved(account);
    }
}

// File: contracts/backend/Backend.sol

pragma solidity ^0.5.2;




/**
 * @title Backend
 * @notice Backend contracts are storage contracts managed by a BackendAdmin entitled to perform restricted actions.
 * Backend contracts allow special interactions to frontend contracts, which are special type of logic contracts
 * that act as relay contracts. This separation between frontend and backend contracts allows for separation
 * between data and logic and it gives a good approach to contract's logic upgradability.
 * The Backend admin role is special in that it is the only accounts allowed to add (or remove) a Frontend logic contract.
 */
contract Backend is BackendAdmin {

    using TimedRoles for TimedRoles.Role;

    event FrontendAdded(address indexed contractAddress);
    event FrontendRemoved(address indexed contractAddress);

    /* @dev Use timed roles in order to control timing of frontend activation */
    TimedRoles.Role private _frontends;

    /**
     * @dev Requires a specific frontend activation time for security reasons.
     * Given that Frontends have access to special sensitive functions, and that the
     * Backend Admin is the only authority able to approve a new frontend, an elapsed time
     * of 2 days is required for every newly added frontend to become active.
     * This is a measure that mitigates the authority of the Backend Admin as a single
     * central point of failure.
     **/
    uint256 public frontendActivationTime = 172800;

    /**
     * @notice Make sure the caller is an allowed frontend.
     */
    modifier onlyFrontend() {
        require(isFrontend(msg.sender));
        _;
    }

    /**
     * @dev Internal function to add a frontend contract.
     */
    function _addFrontend(address contractAddress) internal {
      _frontends.add(contractAddress);
      emit FrontendAdded(contractAddress);
    }

    /**
     * @dev Internal function to remove a frontend contract.
     */
    function _removeFrontend(address contractAddress) internal {
      _frontends.remove(contractAddress);
      emit FrontendRemoved(contractAddress);
    }

    /**
     * @notice Implements backend methods.
     */
    function isBackend() public pure returns (bool) {
        return true;
    }

    /**
     * @notice Check if the address is an authorized frontend and if activation time has passed.
     * @param contractAddress The address of the frontend contract
     */
    function isFrontend(address contractAddress) public view returns (bool) {
        uint256 _ts = _frontends.has(contractAddress);
        return _ts!=0 && ((_ts + frontendActivationTime) < block.timestamp);
    }

    /**
     * @notice Add a frontend contract.
     * @param contractAddress The address of the frontend contract
     */
    function addFrontend(address contractAddress) public onlyBackendAdmin {
        _addFrontend(contractAddress);
    }

    /**
     * @notice Remove a frontend contract.
     * @param contractAddress The address of the frontend contract
     */
    function removeFrontend(address contractAddress) public onlyBackendAdmin {
        _removeFrontend(contractAddress);
    }

}

// File: contracts/utils/HasNoEther.sol

pragma solidity ^0.5.2;


/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <remco@2π.com>
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up
 * in the contract, it will allow the owner to reclaim this Ether.
 * @notice Ether can still be sent to this contract by:
 * calling functions labeled `payable`
 * `selfdestruct(contract_address)`
 * mining directly to the contract address
 */
contract HasNoEther is Ownable {

  /**
  * @dev Constructor that rejects incoming Ether
  * The `payable` flag is added so we can access `msg.value` without compiler warning. If we
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively
  * we could use assembly to access msg.value.
  */
  constructor() public payable {
    require(msg.value == 0);
  }

  /**
   * @dev Disallows direct send by setting a default function without the `payable` flag.
   */
  function() external {}

  /**
   * @dev Transfer all Ether held by the contract to the owner.
   */
  function reclaimEther() external onlyOwner {
    Ownable.owner().transfer(address(this).balance);
  }
}

// File: contracts/interface/IHasZCZ.sol

pragma solidity ^0.5.2;

/**
 * @title IHasZCZ
 * @notice Owns a reference to the ZCZ contract for operation like query balances or transfering tokens
 */
interface IHasZCZ {
  function ZCZ() external view returns(IZtickyCoinZ);
}

// File: contracts/utils/HasZCZ.sol

pragma solidity ^0.5.2;

/**
 * @title HasZCZ
 * @notice This represent a contract with a direct reference to the ZtickyCoinZ Backend contract.
 * It is used to perform approve or transfer operations for ZCZ.
 */
contract HasZCZ is IHasZCZ {

    IZtickyCoinZ private _ZCZ = IZtickyCoinZ(address(0));

    /**
     * @notice Internally set a contract address and check if the address is a correct ZCZ contract
     */
    function _setZCZ(address _zcz) internal {
      require(_zcz != address(0), "Address must be specified.");
      require(IZtickyCoinZ(_zcz).isZCZ(), "Must be a valid ZCZ contract address");
      _ZCZ = IZtickyCoinZ(_zcz);
    }

    /**
     * @notice Return the Backend ZCZ contract.
     */
    function ZCZ()
    public
    view
    returns(IZtickyCoinZ)
    {
      require(address(_ZCZ)!=address(0), "ZCZ contract is not configured.");
      return _ZCZ;
    }
}

// File: contracts/utils/Destructible.sol

pragma solidity ^0.5.2;


/**
 * @title Destructible
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.
 */
contract Destructible is Ownable {
  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy() public onlyOwner {
    selfdestruct(Ownable.owner());
  }

  function destroyAndSend(address payable _recipient) public onlyOwner {
    selfdestruct(_recipient);
  }
}

// File: contracts/roles/PauserRole.sol

pragma solidity ^0.5.2;



/**
 * @title PauserRole
 * @dev PauserRoles are account that are entitled to stop a contract operation in case an emergency arise.
 * That could be represented by a contract vulnerability discovery, an ongoing contract upgrade or any greater cause.
 * PauserRoles are managed by contract admins, but they also might eventually renounce to the title of Pauser indipendently.
 */
contract PauserRole is IAdmin {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyAdmin {
        _addPauser(account);
    }

    function removePauser(address account) public onlyAdmin {
        _removePauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

// File: contracts/utils/Pausable.sol

pragma solidity ^0.5.2;


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev called by the pauser to pause, triggers stopped state
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the pauser to unpause, returns to normal state
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

// File: contracts/utils/DestructibleZCZ.sol

pragma solidity ^0.5.2;

/**
 * @title DestructibleZCZ
 * @dev Base contract which holds ether as well as ZCZ and can be destroyed by owner.
 * All funds in contract will be sent to the owner specified address.
 */
contract DestructibleZCZ is IHasZCZ, Pausable, Destructible {

  /**
   * @dev Transfers the current ZCZ balance to the recipient and allow proceeding to destroying the contract.
   */
  modifier emergencyTransfer(address _recipient) {
    uint256 _balance = this.ZCZ().balanceOf(address(this));
    if (_balance!=0) require(this.ZCZ().transfer(_recipient, _balance), "Transfer of contract balance is required!");
    _;
  }

  /**
   * @dev Transfers the current ZCZ and ETH balance to the owner and terminates the contract.
   * Invokable by any contract admin
   */
  function destroy()
    whenPaused
    onlyAdmin
    emergencyTransfer(Ownable.owner())
    public
  {
    selfdestruct(Ownable.owner());
  }

  /**
   * @dev Transfers the current ZCZ and ETH balance to the specified recipient and terminates the contract.
   * Invokable by the owner of the contract only
   */
  function destroyAndSend(address payable _recipient)
    whenPaused
    onlyOwner
    emergencyTransfer(_recipient)
    public
  {
    return Destructible.destroyAndSend(_recipient);
  }
}

// File: contracts/ERC20/IERC20.sol

pragma solidity ^0.5.2;

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/ERC20/ERC20.sol

pragma solidity ^0.5.2;



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://eips.ethereum.org/EIPS/eip-20
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return A uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
     * @dev Transfer token to a specified address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when _allowed[msg.sender][spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when _allowed[msg.sender][spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Transfer token for a specified addresses
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Approve an address to spend another addresses' tokens.
     * @param owner The address that owns the tokens.
     * @param spender The address that will spend the tokens.
     * @param value The number of tokens that can be spent.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}

// File: contracts/utils/Math.sol

pragma solidity ^0.5.2;

/**
 * @title Math
 * @dev Assorted math operations
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Calculates the average of two numbers. Since these are integers,
     * averages of an even and odd number cannot be represented, and will be
     * rounded down.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// File: contracts/utils/Arrays.sol

pragma solidity ^0.5.2;

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

// File: contracts/ERC900/IERC900.sol

pragma solidity ^0.5.2;


/**
 * @title ERC900 Simple Staking Interface ZtickerZ implementation
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-900.md
 */
interface IERC900 {
  event Staked(address indexed user, uint256 amount, uint256 total, address indexed stakedBy);
  event Unstaked(address indexed user, uint256 amount, uint256 total, address indexed stakedBy);

  function stake(uint256 amount) external;
  function stakeFor(address user, uint256 amount) external;
  function unstake(uint256 amount) external;
  function totalStakedFor(address addr) external view returns (uint256);
  function totalStaked() external view returns (uint256);
  function token() external view returns (address);
  function supportsHistory() external pure returns (bool);

  // NOTE: Not implementing the optional functions
  /* function lastStakedFor(address addr) external view returns (uint256); */
  /* function totalStakedForAt(address addr, uint256 blockNumber) external view returns (uint256); */
  /* function totalStakedAt(uint256 blockNumber) external view returns (uint256); */
}

// File: contracts/ERC900/ERC900.sol

pragma solidity ^0.5.2;


/**
 * @title ERC900 Simple Staking Interface ZtickerZ implementation
 * @author Samuele Rodi (a.k.a. Sam Fisherman)
 * @dev Originally based on https://github.com/ethereum/EIPs/blob/master/EIPS/eip-900.md
 * Adapted to meet the ZtickerZ staking requirements
 * It doesn't supports history and implements an interface callable exclusively from the logic contract
 */
contract ERC900 is IERC900, Pausable {

  using SafeMath for uint256;
  using Arrays for uint256[];

  // Token used for staking
  ERC20 public ERC20tokenContract;

  // Struct for individual staking instance (i.e., atomic staking transaction made by an address)
  // blockTimestamp - block timestamp when the stake has been created
  // amount - the amount of tokens in the stake
  // unstaked - the amount of tokens that has been unstaked so far
  struct Stake {
    uint256 blockTimestamp;
    uint256 amount;
    uint256 unstaked;
  }

  // Struct for historical reference of all the stakes made for a specific recipient (i.e., stakes made for this address)
  // stakedBy - the address that issued the stake and owner of the tokens in the stake
  // idx - the index of the staking instance in the mapping of recipients of the owner of the stake
  struct HistoryRef {
    address stakedBy;
    uint256 idx;
  }

  // Struct to keep updated reference on the staking status and chronological order of the stakes made for a specific address
  // stakeIndex - the index of the latest active stake (not yet fully unstaked) in the array of stakes
  // stakes - the array of stakes made by the owner and for a specific recipient address
  struct StakingStructure {
    uint256 stakeIndex;
    Stake[] stakes;
  }

  // Struct for a full staking contract of an stakeholder (owner of the stake)
  // total - the number of tokens currently staked for the current address (as beneficiary of the stake)
  // personalStakingHistory - reference list to full staking history (active and inactive) made for the current address.
  // fors - mapping of recipient for which current address is the owner of a staking instance
  struct StakeContract {
    uint256 total;
    HistoryRef[] personalStakingHistory;
    mapping (address => StakingStructure) fors;
  }

  // The stakeHolders mapping is a list of StakeContract created by the owner of a staking contract.
  // A StakeContract consist of a total, amount of actively staked tokens for that address,
  // an history reference for all the active and inactive staking made for that address and
  // a mapping of stakes for which the address is the owner of the stake
  // It's possible to not own any active stake, but have tokens in total
  // if other users are staking on behalf of the given address.
  mapping (address => StakeContract) public stakeHolders;

  /**
   * @dev Constructor
   * @param _ERC20tokenContract address The address of the token contract used for staking
   */
  constructor(ERC20 _ERC20tokenContract) public {
    require(address(_ERC20tokenContract) != address(0));
    ERC20tokenContract = _ERC20tokenContract;
  }

  /**
   * @dev Modifier that checks that this contract can transfer tokens from the
   * balance in the ERC20tokenContract contract for the given address.
   * @dev This modifier also transfers the tokens.
   * @param _address address to transfer tokens from
   * @param _amount uint256 the number of tokens
   */
  modifier canStake(address _address, uint256 _amount) {
    require(_amount!=0, "Amount to be staked cannot be 0.");
    require(ERC20tokenContract.transferFrom(_address, address(this), _amount),"Stake required");
    _;
  }



  /**
   * @notice Stakes a certain amount of tokens, this MUST transfer the given amount from the user
   * @dev Triggers Staked event
   * @param _amount uint256 the amount of tokens to stake
   */
  function stake(uint256 _amount) public {
    createStake(msg.sender, msg.sender, _amount);
  }

  /**
   * @notice Stakes a certain amount of tokens, this MUST transfer the given amount from the caller
   * @dev Triggers Staked event
   * @param _stakeFor address the address the tokens are staked for
   * @param _amount uint256 the amount of tokens to stake
   */
  function stakeFor(address _stakeFor, uint256 _amount) public {
    createStake(msg.sender, _stakeFor, _amount);
  }

  /**
   * @notice Unstakes a certain amount of tokens, this return the given amount of tokens
   * (or the max number of staked tokens for that address) to the owner of the stake,
   * @dev Triggers Unstaked event
   * @dev Users can only unstake starting from their oldest active stake. Upon releasing that stake, the tokens will be
   * transferred back to their account, and their stakeIndex will increment to the next active stake.
   * @param _amount uint256 the amount of tokens to unstake
   */
  function unstake(uint256 _amount) public {
    withdrawStake(msg.sender, msg.sender, _amount);
  }

  /**
   * @notice Unstakes a certain amount of tokens for a given user, this return the given amount of tokens
   * (or the max number of staked tokens for that particular address) to the owner of the stakes.
   * @dev Triggers Unstaked event
   * @dev Users can only unstake starting from the oldest active stake. Upon releasing that stake, the tokens will be
   * transferred back to their owner, and their stakeIndex will increment to the next active stake.
   * @param _stakeFor address the user the tokens are staked for
   * @param _amount uint256 the amount of tokens to unstake
   */
  function unstakeFor(address _stakeFor, uint256 _amount) public {
    withdrawStake(msg.sender, _stakeFor, _amount);
  }

  /**
   * @notice Returns the current total of tokens staked for an address
   * @param _address address The address to query
   * @return uint256 The number of tokens staked for the given address
   */
  function totalStakedFor(address _address) public view returns (uint256) {
    return stakeHolders[_address].total;
  }

  /**
   * @notice Returns the current total of tokens staked
   * @return uint256 The number of tokens staked in the contract
   */
  function totalStaked() public view returns (uint256) {
    return ERC20tokenContract.balanceOf(address(this));
  }

  /**
   * @notice Address of the token being used by the staking interface
   * @return address The address of the ERC20 token used for staking
   */
  function token() public view returns (address) {
    return address(ERC20tokenContract);
  }

  /**
   * @notice MUST return true if the optional history functions are implemented, otherwise false
   * @dev Since we don't implement the optional interface, this always returns false
   * @return bool Whether or not the optional history functions are implemented
   */
  function supportsHistory() public pure returns (bool) {
    return false;
  }

  /**
   * @dev Helper function to get specific properties of active stakes created by an address for the same address
   * @param _stakeFor address The address for which it is being staked
   * @return (uint256[], uint256[]) timestamps array, amounts array
   */
  function getActiveStakesFor(address _stakeFor)
    view
    public
    returns(uint256[] memory, uint256[] memory)
  {
    return getActiveStakesBy(_stakeFor, _stakeFor);
  }

  /**
   * @dev Helper function to get specific properties of active stakes created by an address for another address
   * @param _stakedBy address The address that initiated the stake
   * @param _stakeFor address The address for which it is being staked
   * @return (uint256[], uint256[]) timestamps array, amounts array
   */
  function getActiveStakesBy(address _stakedBy, address _stakeFor)
    view
    public
    returns(uint256[] memory blockTimestamps, uint256[] memory amounts)
  {
    StakingStructure storage _ss = stakeHolders[_stakedBy].fors[_stakeFor];
    uint256 _size = _ss.stakes.length.sub(_ss.stakeIndex);
    blockTimestamps = new uint256[](_size);
    amounts = new uint256[](_size);

    for (uint256 i = 0; i < _size; i++) {
      Stake storage _s = _ss.stakes[_ss.stakeIndex.add(i)];
      blockTimestamps[i] = _s.blockTimestamp;
      amounts[i] = _s.amount.sub(_s.unstaked);
    }
    return (blockTimestamps, amounts);
  }

  /**
   * @dev Helper function to get the full history of staking instances created for this address
   * @param _stakeFor address The address to query
   * @return (uint256[], uint256[], uint256[], address[]) blockTimestamps array, amounts array, unstaked array, stakedBy array
   */
  function getStakingHistoryOf(address _stakeFor)
    view
    public
    returns(uint256[] memory blockTimestamps, uint256[] memory amounts, uint256[] memory unstaked, address[] memory stakedBy)
  {
    StakeContract storage _sc = stakeHolders[_stakeFor];
    uint256 _size = _sc.personalStakingHistory.length;
    blockTimestamps = new uint256[](_size);
    amounts = new uint256[](_size);
    unstaked = new uint256[](_size);
    stakedBy = new address[](_size);

    for (uint256 i = 0; i < _sc.personalStakingHistory.length; i++) {
      HistoryRef memory _h = _sc.personalStakingHistory[i];
      Stake memory _s = stakeHolders[_h.stakedBy].fors[_stakeFor].stakes[_h.idx];
      blockTimestamps[i] = _s.blockTimestamp;
      amounts[i] = _s.amount;
      unstaked[i] = _s.unstaked;
      stakedBy[i] = _sc.personalStakingHistory[i].stakedBy;
    }
  }

  /**
   * @dev Helper function to create a staking instance for a given address
   * @param _stakedBy address The owner of the stake
   * @param _stakeFor address The address beneficiary of the stake
   * @param _amount uint256 The number of tokens being staked
   */
  function createStake(address _stakedBy, address _stakeFor, uint256 _amount)
    internal
    whenNotPaused
    canStake(_stakedBy, _amount)
    returns (uint256 , uint256)
  {
    stakeHolders[_stakeFor].total = stakeHolders[_stakeFor].total.add(_amount);
    Stake memory s = Stake(block.timestamp, _amount, 0);
    uint256 _l = stakeHolders[_stakedBy].fors[_stakeFor].stakes.push(s);
    HistoryRef memory _h = HistoryRef(_stakedBy, _l-1);
    stakeHolders[_stakeFor].personalStakingHistory.push(_h);
    emit Staked(_stakeFor, s.amount, totalStakedFor(_stakeFor), _stakedBy);
    return (s.blockTimestamp, s.amount);
  }

  /**
   * @dev Helper function to close a staking instance or reduce the staked amount and withdraw tokens staked by the owner of the stake
   * @param _stakedBy address The owner of the stake
   * @param _stakeFor address The address beneificiary of the active stake
   * @param _amount uint256 The amount to withdraw. Any exceeding amount will be mapped to the maximum available active staked amount.
   * @dev This function does NOT revert on amounts greater than the maximum
   */
  function withdrawStake(address _stakedBy, address _stakeFor, uint256 _amount)
    internal
    whenNotPaused
    returns(uint256[] memory blockTimestamps, uint256[] memory amounts)
  {
    StakingStructure storage ss = stakeHolders[_stakedBy].fors[_stakeFor];
    uint256 _totalUnstaked = 0;
    uint256 l = 0;
    blockTimestamps = new uint256[](ss.stakes.length);
    amounts = new uint256[](ss.stakes.length);
    while(_amount > 0 && ss.stakeIndex < ss.stakes.length) {
      Stake storage s = ss.stakes[ss.stakeIndex];
      uint256 _remainder = s.amount.sub(s.unstaked);
      uint256 _unstake = Math.min(_amount, _remainder);
      _amount = _amount.sub(_unstake);
      s.unstaked = s.unstaked.add(_unstake);
      _totalUnstaked = _totalUnstaked.add(_unstake);
      stakeHolders[_stakeFor].total = stakeHolders[_stakeFor].total.sub(_unstake);
      // Add safe check in case of remote contract vulnerability
      require(s.amount>=s.unstaked, "Inconsistent staking state.");
      if (s.amount == s.unstaked) ss.stakeIndex++;
      emit Unstaked(_stakeFor, _unstake, totalStakedFor(_stakeFor), _stakedBy);
      blockTimestamps[l] = s.blockTimestamp;
      amounts[l] = _unstake;
      l++;
    }
    // Transfer the staked tokens from this contract back to the sender
    // Notice that we are using transfer instead of transferFrom here.
    if (_totalUnstaked != 0) require(ERC20tokenContract.transfer(_stakedBy, _totalUnstaked), "Unable to withdraw stake");
    return  (blockTimestamps.subarray(0,l), amounts.subarray(0,l));
  }
}

// File: contracts/backend/ZtickyStake.sol

pragma solidity ^0.5.2;

/**
 * @title ZtickyStake
 * @author Samuele Rodi (a.k.a. Sam Fisherman)
 * @notice The ZtickyStake contract is a backend ERC900 contract used as storage for staking features.
 * This contract aims to let token stakeholders to mature outstanding shares.
 * In this implementations, it does not exist any predefined structure of shareholders, instead shareholders
 * owns a ratio of the total shares in a dinamic fashion based on their staked value over the total.
 * The staked value of a user is constantly changing as it consists in the intregral of the currently active staked amount
 * over the time in which the stake has been active.
 * The total staked value is the sum of the staked value of all of its users with an ongoing stake.
 * The staked value of a user is the parameter which determines the shares ratio of a given user over the total.
 * However, shares by a user are accumulated in the form of vested shares, which means that they are not redeemable
 * as outstanding shares unless a minimum vesting time has effectively passed from the begin of the staking,
 * (i.e. a time threshold necessary to let the tokens locked into a staking contract to mature some shares).
 */
contract ZtickyStake is IZtickyStake, HasZCZ, ERC900, DestructibleZCZ, HasNoEther, Backend {

  using SafeMath for uint256;

  /**
   * @dev The vesting time is controlled by the BackendAdmin and represent the minimum
   * staking time to let staked tokens mature outstanding shares.
   */
  uint256 public vestingTime = 0;
  /**
   * @dev The number of outstanding shares as per standard
   */
  uint256 public totalShares = 1 ether;

  /**
   * @dev Given the fact that the total staked amount is a step function over time, the staked value can
   * be thus calculated in a linear fashion starting from the latest update to the total staked amount (the last staking or unstaking operation).
   * In a similar fashion also the individual staked value of users can be evaluated using a linearized form of the current staked amount and
   * a reference to the last updated staked value.
   * The ShareContract struct serves to store the latest reference to the staked value and its corresponding time of latest update
   */
  struct ShareContract {
    uint256 stakedValue;
    uint256 lastUpdated;
  }

  /**
   * @dev The data structure which stores the global staked value
   */
  ShareContract public total;

  /**
   * @dev The address mapping which stores the staked value of currently active stakeholders
   */
  mapping (address => ShareContract) public shareHolders;

  constructor(address _zcz) ERC900(ERC20(_zcz))  public {
    HasZCZ._setZCZ(_zcz);
  }

  /**
   * @dev Helper function used to calculated the current staked value starting from a previous state
   * in the hypotesis of no intermediate staking updates
   * @param _previousStakedValue The latest updated staked value
   * @param _previousStakeAmount The current token staked amount
   * @param _updatedAt The timestamp of the latest update of the staked value
   */
  function calculateCurrentStakedValueFromPreviousState(uint256 _previousStakedValue, uint256 _previousStakeAmount, uint256 _updatedAt)
    internal
    view
    returns (uint256 _stakedValue)
  {
    uint256 _delta = block.timestamp.sub(_updatedAt);
    _stakedValue = _previousStakedValue.add(_delta.mul(_previousStakeAmount));
  }

  /**
   * @dev Helper function used to calculate the accumulated staked value over an entire set of history states
   * representing active ongoing token stakes.
   * @param blockTimestamps An array of timestamps specifying the date of creation of the staking instance
   * @param amounts An array specifying the active staked amount of tokens for the corresponding specific date
   * @param _vestingTime The vesting time considered used for the evaluation of matured tokens
   * @return _stakedValue The calculated (outstanding) staked value
   * @return _maturedTokens The amount of tokens that have matured outstanding shares
   */
  function calculateCurrentStakedValueFromHistory(uint256[] memory blockTimestamps, uint256[] memory amounts, uint256 _vestingTime)
    internal
    view
    returns (uint256 _stakedValue, uint256 _maturedTokens)
  {
    for (uint256 i = 0; i < blockTimestamps.length; i++) {
      if (block.timestamp.sub(blockTimestamps[i]) < _vestingTime) continue;
      _maturedTokens = _maturedTokens.add(amounts[i]);
      _stakedValue = _stakedValue.add(calculateCurrentStakedValueFromPreviousState(0, amounts[i], blockTimestamps[i]));
    }
  }

  /**
   * @dev Helper function used to derive an address' shares ratio from the total staked value.
   * @param _stakedValue The staked value owner of the shares ratio
   * @param _totalStakedValue The global staked value
   * @return uint256 The shares ratio expressed as a number from 0 to 1 ether
   */
  function calculateShares(uint256 _stakedValue, uint256 _totalStakedValue)
    internal
    view
    returns (uint256)
  {
    return _stakedValue.mul(totalShares).div(_totalStakedValue);
  }

  /**
   * @dev Helper function used to update the global staked value reference.
   */
  function updateStakedValue()
    internal
  {
    total.stakedValue = totalStakedValue();
    total.lastUpdated = block.timestamp;
  }

  /**
   * @dev Helper function used to update the staked value reference for a specific address.
   * @param _shareHolder Address of the beneficiary of the staking and shareholder
   */
  function updateStakedValueOf(address _shareHolder)
    internal
  {
    shareHolders[_shareHolder].stakedValue = stakedValueOf(_shareHolder);
    shareHolders[_shareHolder].lastUpdated = block.timestamp;
  }

  /**
   * @dev Helper middleware responsible for creating a staking instance as per ERC900 implementation and keeps the staked value references up to date.
   * @param _stakedBy Owner of the stake
   * @param _stakeFor Beneficiary of the stake
   * @param _amount Amount of the stake
   */
  function createStake(address _stakedBy, address _stakeFor, uint256 _amount)
    internal
    returns (uint256 , uint256)
  {
    updateStakedValue();
    updateStakedValueOf(_stakeFor);
    return ERC900.createStake(_stakedBy, _stakeFor, _amount);
  }

  /**
   * @dev Helper middleware responsible for withdrawing a staking instance as per ERC900 implementation and keeps the staked value references up to date.
   * @param _stakedBy Owner of the stake
   * @param _stakeFor Beneficiary of the stake
   * @param _amount Amount to unstake
   */
  function withdrawStake(address _stakedBy, address _stakeFor, uint256 _amount)
    internal
    returns(uint256[] memory blockTimestamps, uint256[] memory amounts)
  {
    updateStakedValue();
    updateStakedValueOf(_stakeFor);
    (blockTimestamps, amounts) = ERC900.withdrawStake(_stakedBy, _stakeFor, _amount);
    uint256 _unstakedShare = 0;
    uint256 n = block.timestamp;
    for (uint256 i = 0; i < amounts.length; i++) {
      uint256 _delta = n.sub(blockTimestamps[i]);
      _unstakedShare = _unstakedShare.add(_delta.mul(amounts[i]));
    }
    shareHolders[_stakeFor].stakedValue = shareHolders[_stakeFor].stakedValue.sub(_unstakedShare);
    total.stakedValue = total.stakedValue.sub(_unstakedShare);
  }


  /**
   * @notice Function that confirms that this contract implements a ZtickyStake interface
   * @return true.
   */
  function isZStake()
    public
    pure
    returns(bool)
  {
    return true;
  }

  /**
   * @notice Returns the global current active staked value for all addresses
   * @return uint256 The staked value.
   */
  function totalStakedValue()
    public
    view
    returns (uint256)
  {
    return calculateCurrentStakedValueFromPreviousState(total.stakedValue, ERC900.totalStaked(), total.lastUpdated);
  }

  /**
   * @notice Returns the current active staked value for a given address
   * @param _shareHolder The shareholder beneficiary of the stake
   * @return uint256 The staked value.
   */
  function stakedValueOf(address _shareHolder)
    public
    view
    returns (uint256)
  {
    ShareContract storage s = shareHolders[_shareHolder];
    return calculateCurrentStakedValueFromPreviousState(s.stakedValue, ERC900.totalStakedFor(_shareHolder), s.lastUpdated);
  }

  /**
   * @notice Returns the vested shares ratio for a given address (i.e. the total amount of shares
   * ratio accumulated comprising of both maturing shares and redeemable outstanding shares)
   * @param _shareHolder The shareholder beneficiary of the stake
   * @return uint256 The vested shares ratio.
   */
  function vestedSharesOf(address _shareHolder)
    public
    view
    returns (uint256)
  {
    return calculateShares(stakedValueOf(_shareHolder), totalStakedValue());
  }

  /**
   * @notice Returns the outstanding shares ratio (i.e. only the amount of redeemable outstanding shares,
   * matured vested shares) of an active ongoing stakes made by a stake owner and for a specific beneficiary
   * @param _stakedBy The owner of the active stake
   * @param _stakeFor The beneficiary of the stake
   * @return uint256 The outstanding shares ratio.
   */
  function sharesByFor(address _stakedBy, address _stakeFor)
    public
    view
    returns(uint256)
  {
    (uint256[] memory blockTimestamps, uint256[] memory amounts) = ERC900.getActiveStakesBy(_stakedBy, _stakeFor);
    (uint256 _stakedValue, ) = calculateCurrentStakedValueFromHistory(blockTimestamps, amounts, vestingTime);
    return calculateShares(_stakedValue, totalStakedValue());
  }

  /**
   * @notice Returns the outstanding shares ratio (i.e. only the amount of redeemable outstanding shares,
   * matured vested shares) of an active ongoing stakes made by an address for itself
   * @param _stakeFor The beneficiary of the stake
   * @return uint256 The outstanding shares ratio.
   */
  function sharesOf(address _stakeFor)
    public
    view
    returns(uint256)
  {
    return sharesByFor(_stakeFor, _stakeFor);
  }

  /**
   * @notice Returns the amount of matured staked tokens (i.e. tokens that have passed the minimum vesting time threshold)
   * inside an active ongoing stake made by a stake owner for a specific beneficiary
   * @param _stakedBy The owner of the stake
   * @param _stakeFor The beneficiary of the stake
   * @return uint256 The amount of matured staked tokens.
   */
  function maturedTokensByFor(address _stakedBy, address _stakeFor)
    public
    view
    returns(uint256)
  {
    (uint256[] memory blockTimestamps, uint256[] memory amounts) = ERC900.getActiveStakesBy(_stakedBy, _stakeFor);
    (, uint256 _maturedTokens) = calculateCurrentStakedValueFromHistory(blockTimestamps, amounts, vestingTime);
    return _maturedTokens;
  }

  /**
   * @notice Returns the amount of matured staked tokens (i.e. tokens that have passed the minimum vesting time threshold)
   * inside an active ongoing stake made by a an address for itself
   * @param _stakeFor The beneficiary of the stake
   * @return uint256 The amount of matured staked tokens.
   */
  function maturedTokensOf(address _stakeFor)
    public
    view
    returns(uint256)
  {
    return maturedTokensByFor(_stakeFor, _stakeFor);
  }

  /**
   * @notice It changes the vesting time needed to mature outstanding shares.
   * This function is restricted only to backend admins.
   * @param _newVestingTime The new vesting time expressed in seconds
   * @return A boolean that indicates if the operation was successful.
   */
  function changeVestingTime(uint256 _newVestingTime)
    onlyBackendAdmin
    public
    returns (bool)
  {
    vestingTime = _newVestingTime;
    return true;
  }

  /**
   * @notice This function allows the frontend contract to perform a staking operation on behalf
   * of a specific address expressed as tx.origin for a specific beneficiary.
   * It requires of a preapproved token withdrawal.
   * @param _stakeFor the beneficiary of the stake
   * @param _amount the amount of tokens to stake
   * @return A boolean that indicates if the operation was successful.
   */
  function authorizedStakeFor(address _stakeFor, uint256 _amount)
    onlyFrontend
    whenNotPaused
    public
    returns (bool)
  {
    createStake(tx.origin, _stakeFor, _amount);
    return true;
  }

  /**
   * @notice This function allows the frontend contract to perform an unstaking operations made by a stake owner
   * assigned to a specific beneficiary. During the unstake, it is calculated the corresponding outstanding
   * shares ratio that gets freed as a consequence of the unstake, and the corresponding staked value gets subtracted
   * from the total.
   * @param _stakeFor the beneficiary of the stake
   * @param _amount the amount of tokens to unstake
   * @return uint256 the shares ratio that gets freed
   */
  function authorizedUnstakeFor(address _stakeFor, uint256 _amount)
    onlyFrontend
    whenNotPaused
    public
    returns (uint256)
  {
    uint256 _totalStakedValue = totalStakedValue();
    (uint256[] memory blockTimestamps, uint256[] memory amounts) =  withdrawStake(tx.origin, _stakeFor, _amount);
    (uint256 _stakedValue,) = calculateCurrentStakedValueFromHistory(blockTimestamps, amounts, vestingTime);
    return calculateShares(_stakedValue, _totalStakedValue);
  }

  /**
   * @notice This function allows the frontend contract to perform a staking operation on behalf
   * of a specific address for itself expressed as tx.origin.
   * It requires of a preapproved token withdrawal.
   * @param _amount the amount of tokens to stake
   * @return A boolean that indicates if the operation was successful.
   */
  function authorizedStake(uint256 _amount)
    public
    returns (bool)
  {
    return authorizedStakeFor(tx.origin, _amount);
  }


  /**
   * @notice This function allows the frontend contract to perform an unstaking operations made by an address for
   * itself. During the unstake, it is calculated the corresponding outstanding shares ratio that gets freed
   * as a consequence of the unstake, and the corresponding staked value gets subtracted from the total.
   * @param _amount the amount of tokens to unstake
   * @return uint256 the shares ratio that gets freed
   */
  function authorizedUnstake(uint256 _amount)
    public
    returns (uint256)
  {
    return authorizedUnstakeFor(tx.origin, _amount);
  }
}
