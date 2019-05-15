
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
  function sharesOfFor(address _stakedBy, address _stakeFor) external view returns(uint256);
  function vestedSharesOf(address _shareHolder) external view returns (uint256);
  function maturedTokensOf(address _stakeFor) external view  returns(uint256);
  function maturedTokensOfFor(address _stakedBy, address _stakeFor) external view returns(uint256);
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

// File: contracts/interface/IZtickyBank.sol

pragma solidity ^0.5.2;

interface IZtickyBank {

  //ZtickyBank
  function isZBank() external pure returns(bool);
  function totalBalance() external view returns (uint256, uint256);
  function outstandingDividendsPerShare() external view returns (uint256, uint256);
  function outstandingDividendsFor(uint256 shares) external view returns (uint256, uint256);
  function payout(address payable to, uint256 shares, bool payETH, bool payZCZ) external returns (bool);
  function () external payable;


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
  //Destructible
  function destroy() external;
  function destroyAndSend(address payable _recipient) external;


  event Withdraw(address indexed by, uint256 eth, uint256 zcz);
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
  /* ZtickerZ */
  function expectedDividends(address _stakeFor) external view returns (uint256, uint256);
  function expectedDividendsFor(address _stakedBy, address _stakeFor) external view returns (uint256, uint256);
  function mint(address to) external returns (bool);
  function payDividends() external returns (bool);
  function stake(uint256 value) external returns (bool);
  function unstake(uint256 value) external returns (bool);
  function stakeFor(address stakedFor, uint256 value) external returns (bool);
  function unstakeFor(address payable stakedFor, uint256 value) external returns (bool);
  function claimDividendsAndRestake() external returns (bool);
  function claimDividendsAndRestakeFor(address payable stakedFor) external returns (bool);

  /* Frontend */
  function isBackendConfigured() external view returns(bool);
  function changeZCZContract(address newAddress) external returns(bool);
  function changeZStakeContract(address newAddress) external returns(bool);
  function changeZBankContract(address payable newAddress) external returns(bool);
  function ZCZ() external view returns(IZtickyCoinZ);
  function ZStake() external view returns(IZtickyStake);
  function ZBank() external view returns(IZtickyBank);

  /* FrontendAdmin */
  function isFrontendAdmin(address account) external view returns (bool);
  function addFrontendAdmin(address account) external;
  function removeFrontendAdmin(address account) external;
  function renounceFrontendAdmin() external;

  /* Destructible */
  function destroy() external;
  function destroyAndSend(address payable _recipient) external;
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

    IZtickyCoinZ private _ZCZ;

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

// File: contracts/roles/FrontendAdmin.sol

pragma solidity ^0.5.2;




/**
 * @title FrontendAdmin
 * @dev FrontendAdmins are responsible for managing frontend contracts,
 * i.e. contracts that use backend contracts as data storage, thus they can specify backend contracts as storage.
 * FrontendAdmins can only be added or removed by the owner of the contract, but they might eventually renounce to the title indipendently
 */
contract FrontendAdmin is IAdmin, Ownable {
    using Roles for Roles.Role;

    event FrontendAdminAdded(address indexed account);
    event FrontendAdminRemoved(address indexed account);

    Roles.Role private _frontendAdmins;

    constructor () internal {
        _addFrontendAdmin(msg.sender);
    }

    modifier onlyFrontendAdmin() {
        require(isFrontendAdmin(msg.sender), "Not authorized. Must be a FrontendAdmin.");
        _;
    }

    function isAdmin(address account) public view returns (bool) {
        return isFrontendAdmin(account);
    }

    function isFrontendAdmin(address account) public view returns (bool) {
        return _frontendAdmins.has(account);
    }

    function addFrontendAdmin(address account) public onlyOwner {
        _addFrontendAdmin(account);
    }

    function removeFrontendAdmin(address account) public onlyOwner {
        _removeFrontendAdmin(account);
    }

    function renounceFrontendAdmin() public {
        _removeFrontendAdmin(msg.sender);
    }

    function _addFrontendAdmin(address account) internal {
        _frontendAdmins.add(account);
        emit FrontendAdminAdded(account);
    }

    function _removeFrontendAdmin(address account) internal {
        _frontendAdmins.remove(account);
        emit FrontendAdminRemoved(account);
    }
}

// File: contracts/frontend/Frontend.sol

pragma solidity ^0.5.2;

/**
 * @title Frontend
 * @notice The Frontend contract is an interface to all the backend contracts.
 * This structure is useful to simplify the upgradability as it make it possible to separate logic from storage
 * while guaranteeing the correct write permissions to the storage.
 * Current implementation includes a pointer to ZCZ, ZStake and ZBank contract.
 */
contract Frontend is HasZCZ, FrontendAdmin {

  IZtickyStake private _ZStake;
  IZtickyBank private _ZBank;

  /**
   * @dev Make sure the entire logic contract has been correctly configured.
   */
  function isBackendConfigured()
  public
  view
  returns(bool)
  {
    HasZCZ.ZCZ();
    require(address(_ZStake)!=address(0), "ZStake contract not configured.");
    require(address(_ZBank)!=address(0), "ZBank contract not configured.");
    return true;
  }

  /**
   * @dev Change the address of the backend ZStake contract.
   * @param _newAddress The address of the newly deployed contract.
   */
  function changeZStakeContract(address _newAddress)
  public
  onlyFrontendAdmin
  returns(bool)
  {
    require(_newAddress!=address(0), "Address must be specified.");
    require(IZtickyStake(_newAddress).isZStake(), "Address is not a valid backend contract.");
    _ZStake =IZtickyStake(_newAddress);
    return true;
  }

  /**
   * @dev Change the address of the backend ZCZ contract.
   * @param _newAddress The address of the newly deployed contract.
   */
  function changeZCZContract(address _newAddress)
  public
  onlyFrontendAdmin
  returns(bool)
  {
    HasZCZ._setZCZ(_newAddress);
    return true;
  }

  /**
   * @dev Change the address of the backend contract.
   * @param _newAddress The address of the newly deployed contract.
   */
  function changeZBankContract(address payable _newAddress)
  public
  onlyFrontendAdmin
  returns(bool)
  {
    require(_newAddress!=address(0), "Address must be specified.");
    require(IZtickyBank(_newAddress).isZBank(), "Address is not a valid backend contract.");
    _ZBank =IZtickyBank(_newAddress);
    return true;
  }

  /**
   * @dev Return the Backend ZStake contract.
   */
  function ZStake()
  public
  view
  returns(IZtickyStake)
  {
    require(address(_ZStake)!=address(0), "ZStake contract is not configured.");
    return _ZStake;
  }

  /**
   * @dev Return the Backend ZBank contract.
   */
  function ZBank()
  public
  view
  returns(IZtickyBank)
  {
    require(address(_ZBank)!=address(0), "ZStake contract is not configured.");
    return _ZBank;
  }

  /**
   * @dev Return the Backend ZCZ contract.
   */
  function ZCZ()
  public
  view
  returns(IZtickyCoinZ)
  {
    return HasZCZ.ZCZ();
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
        require(isPauser(msg.sender), "Not authorized. Must be a Pauser.");
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

// File: contracts/ZtickerZ.sol

pragma solidity ^0.5.2;
/**
 * @title ZtickerZ v0.1
 * @author Samuele Rodi (a.k.a. Sam Fisherman)
 * @notice This ZtickerZ contract is the first release of the ZtickerZ logic contract that implements the functionalities
 * used for inital ZCZ mining through proof-of-stake. This frontend contract is also used as an interface to the staking features
 * of ZtickerZ.
 */
contract ZtickerZ is IZtickerZ, DestructibleZCZ, Frontend {

  using SafeMath for uint256;

  /* Amount of premined ZCZ  */
  uint256 public preminedZCZ = 21000000 * 1 ether;
  /* Check if mining has occured */
  bool preminingFinished;


  /* Amount of ZCZ minted through proof-of-stake */
  uint256 public posZCZ;
  /* Counter of current payout through proof-of-stake */
  uint256 public currentPosPayoutIdx;
  /* Time when next payout through proof-of-stake will occur*/
  uint256 public nextPosPayoutTimestamp;
  /* Interval between subsequent proof-of-stake payouts: 1 month */
  /* uint256 public posPayoutInterval = 2629800; */
  uint256 public posPayoutInterval = 604800;


  /* Outstanding interest rates of proof-of-stake payouts 100k = 100% */
  uint256[] public posInterestRates = [ 5000,  /* 1 */
                                        4800,  /* 2 */
                                        4600,  /* 3 */
                                        4400,  /* 4 */
                                        4200,  /* 5 */
                                        4000,  /* 6 */
                                        3800,  /* 7 */
                                        3600,  /* 8 */
                                        3400,  /* 9 */
                                        3200,  /* 10 */
                                        3000,  /* 11 */
                                        2800,  /* 12 */
                                        2600,  /* 13 */
                                        2400,  /* 14 */
                                        2200,  /* 15 */
                                        2000,  /* 16 */
                                        1800,  /* 17 */
                                        1650,  /* 18 */
                                        1500,  /* 19 */
                                        1300,  /* 20 */
                                        1200,  /* 21 */
                                        1100,  /* 22 */
                                        1000]; /* 23 */

  /**
   * @notice This checks that the caller is strictly an externally owned account.
   * This is necessary for interacting with Backend contracts because Backends use the tx.origin
   * to identify the legit issuer of transactions. This is done especially for security reasons,
   * i.e. to avoid relying on a single point of failure, represented by the BackendAdmin,
   * for sensitive transactions, which modify the supply of ZCZ (minting and burning).
   */
  modifier onlyExternal() {
    require(tx.origin == msg.sender, "Only externally owned account can interact with the contract");
    _;
  }

  /**
   * @notice Returns the expected amount of redeemable dividends for the stakeholder.
   * @param _stakeFor The address of the stakeholder.
   * @return An array with the ETH dividend and ZCZ dividend.
   */
  function expectedDividends(address _stakeFor) public
    view
    returns (uint256, uint256)
  {
    uint256 _shares = Frontend.ZStake().sharesOf(_stakeFor);
    return Frontend.ZBank().outstandingDividendsFor(_shares);
  }

  /**
   * @notice Returns the expected amount of redeemable dividends for the stakeholder.
   * @param _stakedBy The address owner of the stake.
   * @param _stakeFor The address for which the stake is being held.
   * @return An array with the ETH dividend and ZCZ dividend.
   */
  function expectedDividendsFor(address _stakedBy, address _stakeFor) public
    view
    returns (uint256, uint256)
  {
    uint256 _shares = Frontend.ZStake().sharesOfFor(_stakedBy, _stakeFor);
    return Frontend.ZBank().outstandingDividendsFor(_shares);
  }

    /**
     * @notice Function to mint tokens, restricted to frontend admins only.
     * This function can be triggered once only and it is used for the initial premined supply of ZCZ tokens specified inside this contract.
     * @param _to The address that will receive the minted tokens.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to) public
      onlyExternal
      onlyFrontendAdmin
      whenNotPaused
      returns (bool)
    {
      require(!preminingFinished, "Premining is finished");
      preminingFinished = true;
      Frontend.ZCZ().mint(_to, preminedZCZ);
      return true;
    }

    /**
     * @notice Function to pay token dividends issued through proof-of-stake.
     * This function is invoked by admins and triggers change only when the next payout time has reached.
     * It modifies the ZCZ premined supply through the proof-of-stake using a predetermined interest rate pattern.
     * @return A boolean that indicates if the operation was successful.
     */
    function payDividends() public
      onlyExternal
      onlyFrontendAdmin
      whenNotPaused
      returns (bool)
    {
      require(preminingFinished, "Must mint coins first");
      require(currentPosPayoutIdx < posInterestRates.length, "Planned payouts have ended");
      require(block.timestamp > nextPosPayoutTimestamp, "Dividends payout time has not come yet");
      if (nextPosPayoutTimestamp == 0) nextPosPayoutTimestamp = block.timestamp;
      uint256 _currentInterest = posInterestRates[currentPosPayoutIdx];
      uint256 _totalZCZ = preminedZCZ.add(posZCZ);
      uint256 _amount = _totalZCZ.mul(_currentInterest).div(100000);
      currentPosPayoutIdx++;
      posZCZ = posZCZ.add(_amount);
      nextPosPayoutTimestamp += posPayoutInterval;
      Frontend.ZCZ().mint(address(Frontend.ZBank()), _amount);
      return true;
    }


    /**
    * @notice This function allows the user to stake his own tokens for a different account.
    * The stakeholder remains the owner of the ZCZ tokens and the only entitled to withdraw the stake at any time,
    * but the beneficiary of the staking will receive the benefit of the staking (dividends).
    * It performs the pre approval, transfer and staking in a single transaction.
    * @param _stakeFor The address beneficiary of the stake.
    * @param _value The amount of ZCZ to be staked.
    */
    function stakeFor(address _stakeFor, uint256 _value) public
    onlyExternal
    whenNotPaused
    returns (bool)
    {
      IZtickyStake _zs = Frontend.ZStake();
      require(Frontend.ZCZ().authorizedApprove(address(_zs), _value));
      require(_zs.authorizedStakeFor(_stakeFor, _value));
      return true;
    }

    /**
    * @notice This function allows to unstake an arbitrary amount of tokens for another account
    * which has a "stakeFor" ongoing and gives the benefits of all the staked tokens that have matured some shares
    * to the beneficiary of the stake, while it returns the staked tokens to the legit owner.
    * @param _stakeFor The address beneficiary of the stake.
    * @param _value The amount of tokens to be unstaked.
    */
    function unstakeFor(address payable _stakeFor, uint256 _value) public
    onlyExternal
    whenNotPaused
    returns (bool)
    {
      uint256 _unvestedShares = Frontend.ZStake().authorizedUnstakeFor(_stakeFor, _value);
      if (_unvestedShares>0) Frontend.ZBank().payout(_stakeFor, _unvestedShares, true, true);
      return true;
    }

    /**
     * @notice This function allows the user to stake tokens in the staking contract on behalf of himself without
     * needing to pre-approve a token transfer to the staking contract.
     * This is to reduce user interactions and increase user experience.
     * @param _value The amount of ZCZ to be staked.
     */
    function stake(uint256 _value) public
      returns (bool)
    {
      return stakeFor(msg.sender, _value);
    }

    /**
     * @notice This function allows to unstake an arbitrary amount of tokens and receive the
     * benefits of all the staked tokens that have matured some shares.
     * @param _value The amount of tokens to be unstaked.
     */
    function unstake(uint256 _value) public
      returns (bool)
    {
      return unstakeFor(msg.sender, _value);
    }

    /**
     * @notice This function is useful for any stakeholder to claim and receive all the outstanding dividends
     * accrued for a different account and restake all of them without performing two different operations.
     * @param _stakeFor The address beneficiary of the stake.
     */
    function claimDividendsAndRestakeFor(address payable _stakeFor) public
      returns (bool)
    {
      uint256 _maturedTokens = Frontend.ZStake().maturedTokensOfFor(msg.sender, _stakeFor);
      unstakeFor(_stakeFor, _maturedTokens);
      stakeFor(_stakeFor, _maturedTokens);
      return true;
    }

    /**
     * @notice This function is useful for any stakeholder to claim and receive all the outstanding dividends
     * and restake all of its tokens without having to perform two different operations.
     */
    function claimDividendsAndRestake() public
    returns (bool)
    {
      return claimDividendsAndRestakeFor(msg.sender);
    }

    /**
     * @notice This contract accepts ether payments
     */
    function() external payable {}
}
