
// File: contracts/interface/IZtickyStake.sol

pragma solidity ^0.5.2;

interface IZtickyStake {
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

  //ERC900
  function stake(uint256 amount, bytes calldata data) external;
  function stakeFor(address user, uint256 amount, bytes calldata data) external;
  function unstake(uint256 amount, bytes calldata data) external;
  function unstakeFor(address user, uint256 amount, bytes calldata data) external;
  function totalStakedFor(address addr) external view returns (uint256);
  function totalStaked() external view returns (uint256);
  function token() external view returns (address);
  function supportsHistory() external pure returns (bool);

  //ZtickyStake
  function totalShares() external view returns (uint256);
  function sharesOf(address _shareHolder) external view returns (uint256);
  function shareRatioOf(address _shareHolder) external view returns (uint256);
  function authorizedStake(uint256 _amount, bytes calldata _data) external returns (bool);
  function authorizedUnstake(uint256 _amount, bytes calldata _data) external returns (uint256);
  function authorizedStakeFor(address _stakeFor, uint256 _amount, bytes calldata _data) external returns (bool);
  function authorizedUnstakeFor(address _stakeFor, uint256 _amount, bytes calldata _data) external returns (uint256);
  function changeMinimumLockTime(uint256 _newMinimumLockTime) external returns (bool);



  event Staked(address indexed user, uint256 amount, uint256 total, bytes data);
  event Unstaked(address indexed user, uint256 amount, uint256 total, bytes data);
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
  //BASE
  function mint(address _to, uint256 _amount) external returns(bool);
  function burn(uint256 _value) external returns(bool);
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

// File: contracts/interface/IZtickerZ.sol

pragma solidity ^0.5.2;

interface IZtickerZ {
  /* Frontend */
  function isBackendConfigured() external view returns(bool);
  function changeZStakeContract(address _newAddress) external returns(bool);
  function changeZCZContract(address _newAddress) external returns(bool);
  function ZCZ() external view returns(IZtickyCoinZ);
  function ZStake() external view returns(IZtickyStake);

  /* ZtickerZ */
  function mint(address _to, uint256 _amount) external returns (bool);
  function stake(uint256 value) external returns (bool);
  function unstake(uint256 value) external returns (bool);
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

// File: contracts/backend/Frontend.sol

pragma solidity ^0.5.2;

/**
 * @title Frontend
 * @dev The Frontend contract is an interface to all the backend contracts.
 * This structure is useful to simplify the upgradability as it make it possible to separate logic from storage
 * while guaranteeing the correct write permissions to the storage.
 * Current implementation includes a pointer to the ZCZ and ZStake contract.
 */
contract Frontend is Ownable{
  address private _ZCZAddress = address(0);
  IZtickyCoinZ private _ZCZ = IZtickyCoinZ(_ZCZAddress);

  address private _ZStakeAddress = address(0);
  IZtickyStake private _ZStake = IZtickyStake(_ZStakeAddress);

  /**
   * @dev Make sure the entire logic contract has been correctly configured.
   */
  function isBackendConfigured()
  public
  view
  returns(bool)
  {
    require(_ZCZAddress!=address(0), "_ZCZ contract not configured.");
    require(_ZStakeAddress!=address(0), "ZStake contract not configured.");
    return true;
  }

  /**
   * @dev Change the address of the backend contract.
   * @param _newAddress The address of the newly deployed contract.
   */
  function changeZStakeContract(address _newAddress)
  public
  onlyOwner
  returns(bool)
  {
    require(_newAddress!=address(0), "Address must be specified.");
    require(IZtickyStake(_newAddress).isBackend(), "Address is not a valid backend contract.");
    _ZStakeAddress = _newAddress;
    _ZStake =IZtickyStake(_ZStakeAddress);
    return true;
  }

  /**
   * @dev Change the address of the backend contract.
   * @param _newAddress The address of the newly deployed contract.
   */
  function changeZCZContract(address _newAddress)
  public
  onlyOwner
  returns(bool)
  {
    require(_newAddress!=address(0), "Address must be specified.");
    require(IZtickyCoinZ(_newAddress).isBackend(), "Address is not a valid backend contract.");
    _ZCZAddress = _newAddress;
    _ZCZ =IZtickyCoinZ(_ZCZAddress);
    return true;
  }

  /**
   * @dev Return the Backend ZCZ contract.
   */
  function ZCZ()
  public
  view
  returns(IZtickyCoinZ)
  {
    return _ZCZ;
  }

  /**
   * @dev Return the Backend ZStake contract.
   */
  function ZStake()
  public
  view
  returns(IZtickyStake)
  {
    return _ZStake;
  }
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

// File: contracts/roles/PauserRole.sol

pragma solidity ^0.5.2;



contract PauserRole is Ownable {
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

    function addPauser(address account) public onlyOwner {
        _addPauser(account);
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
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

// File: contracts/ZtickerZv01.sol

pragma solidity ^0.5.2;

/**
 * @title ZtickerZMock
 * @dev The ZtickerZMock contract is a basic logic contract implementing basic functionalities
 * used for ZCZ distribution prior to full version release.
 */
contract ZtickerZ is IZtickerZ, Frontend, Destructible, Pausable {


    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount)
      onlyOwner
      whenNotPaused
      public
      returns (bool)
    {
      Frontend.ZCZ().mint(_to, _amount);
      return true;
    }

    /**
     * @dev This function allows the frontend contract to directly withdraw from user balance in order
     * to reduce user interactions when invoked from logic contract.
     * @param value The amount of approval.
     */
    function stake(uint256 value) public
      whenNotPaused
      returns (bool)
    {
      Frontend.ZCZ().authorizedApprove(address(this), value);
      Frontend.ZStake().authorizedStake(value, "ZtickerZv01");
      return true;
    }


    /**
     * @dev This function allows the frontend contract to directly withdraw from user balance in order
     * to reduce user interactions when invoked from logic contract.
     * @param value The amount of approval.
     */
    function unstake(uint256 value) public
      whenNotPaused
      returns (bool)
    {
      Frontend.ZCZ().authorizedApprove(address(this), value);
      Frontend.ZStake().authorizedUnstake(value, "ZtickerZv01");
      return true;
    }
}
