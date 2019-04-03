
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

// File: contracts/roles/BackendAdmin.sol

pragma solidity ^0.5.2;



/**
 * @title BackendAdmin
 * @dev BackendAdmins are responsible for assigning and removing frontend contracts.
 */
contract BackendAdmin is Ownable {
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
 * @dev Frontend contracts have been approved by a BackendAdmin to perform restricted actions.
 * This role is special in that the only accounts that can add it are BackendAdmins (who can also remove it).
 */
contract Backend is BackendAdmin {
    using Roles for Roles.Role;

    event FrontendAdded(address indexed contractAddress);
    event FrontendRemoved(address indexed contractAddress);

    Roles.Role private _frontends;

    modifier onlyFrontend() {
        require(isFrontend(msg.sender));
        _;
    }

    function isBackend() public pure returns (bool) {
        return true;
    }

    function isFrontend(address contractAddress) public view returns (bool) {
        return _frontends.has(contractAddress);
    }

    function addFrontend(address contractAddress) public onlyBackendAdmin {
        _addFrontend(contractAddress);
    }

    function removeFrontend(address contractAddress) public onlyBackendAdmin {
        _removeFrontend(contractAddress);
    }

    function _addFrontend(address contractAddress) internal {
        _frontends.add(contractAddress);
        emit FrontendAdded(contractAddress);
    }

    function _removeFrontend(address contractAddress) internal {
        _frontends.remove(contractAddress);
        emit FrontendRemoved(contractAddress);
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

// File: contracts/ERC900/IERC900.sol

pragma solidity ^0.5.2;


/**
 * @title ERC900 Simple Staking Interface
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-900.md
 */
interface IERC900 {
  event Staked(address indexed user, uint256 amount, uint256 total, bytes data);
  event Unstaked(address indexed user, uint256 amount, uint256 total, bytes data);

  function stake(uint256 amount, bytes calldata data) external;
  function stakeFor(address user, uint256 amount, bytes calldata data) external;
  function unstake(uint256 amount, bytes calldata data) external;
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

/* solium-disable security/no-block-members */
pragma solidity ^0.5.2;


/**
 * @title ERC900 Simple Staking Interface basic implementation
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-900.md
 */
contract ERC900 is IERC900, Pausable {
  // @TODO: deploy this separately so we don't have to deploy it multiple times for each contract
  using SafeMath for uint256;

  // Token used for staking
  ERC20 public ERC20tokenContract;

  // To save on gas, rather than create a separate mapping for totalStakedFor & stakes,
  //  both data structures are stored in a single mapping for a given addresses.
  //
  // It's possible to have a non-existing stakes, but have tokens in totalStakedFor
  //  if other users are staking on behalf of a given address.
  mapping (address => StakeContract) public stakeHolders;

  // Struct for personal stakes (i.e., stakes made by this address)
  // blockNumber - block number when the stake has been created
  // amount - the amount of tokens in the stake
  // stakedFor - the address the stake was staked for
  // stakedBy - the address owner of the stake
  struct Stake {
    uint256 blockNumber;
    uint256 amount;
    uint256 unstaked;
    address stakedBy;
  }

  struct StakedForContract {
    uint256 stakeIndex;
    Stake[] stakes;
  }

  // Struct for all stake metadata at a particular address
  // total - the number of tokens staked for this address
  // fors - a mapping of StakedFor made by this address .
  // stakes - array list of stakes made for this address
  struct StakeContract {
    uint256 total;
    mapping (address => StakedForContract) fors;
    Stake[] stakes;
  }

  /**
   * @dev Constructor function
   * @param _ERC20tokenContract address The address of the token contract used for staking
   */
  constructor(ERC20 _ERC20tokenContract) public {
    require(address(_ERC20tokenContract) != address(0));
    ERC20tokenContract = _ERC20tokenContract;
  }

  /**
   * @dev Modifier that checks that this contract can transfer tokens from the
   *  balance in the ERC20tokenContract contract for the given address.
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
   * @notice MUST trigger Staked event
   * @param _amount uint256 the amount of tokens to stake
   * @param _data bytes optional data to include in the Stake event
   */
  function stake(uint256 _amount, bytes memory _data) public {
    createStake(msg.sender, msg.sender, _amount, _data);
  }

  /**
   * @notice Stakes a certain amount of tokens, this MUST transfer the given amount from the caller
   * @notice MUST trigger Staked event
   * @param _stakeFor address the address the tokens are staked for
   * @param _amount uint256 the amount of tokens to stake
   * @param _data bytes optional data to include in the Stake event
   */
  function stakeFor(address _stakeFor, uint256 _amount, bytes memory _data) public {
    createStake(msg.sender, _stakeFor, _amount,  _data);
  }

  /**
   * @notice Unstakes a certain amount of tokens, this SHOULD return the given amount of tokens to the user, if unstaking is currently not possible the function MUST revert
   * @notice MUST trigger Unstaked event
   * @dev Users can only unstake starting from their oldest active stake. Upon releasing that stake, the tokens will be
   *  transferred back to their account, and their stakeIndex will increment to the next active stake.
   * @param _amount uint256 the amount of tokens to unstake
   * @param _data bytes optional data to include in the Unstake event
   */
  function unstake(uint256 _amount, bytes memory _data) public {
    withdrawStake(msg.sender, msg.sender, _amount, _data);
  }

  /**
   * @notice Unstakes a certain amount of tokens for a given user, this SHOULD return the given amount of tokens to the owner
   * @notice MUST trigger Unstaked event
   * @dev Users can only unstake starting from the oldest active stake. Upon releasing that stake, the tokens will be
   *  transferred back to their owner, and their stakeIndex will increment to the next active stake.
   * @param _stakeFor address the user the tokens are staked for
   * @param _amount uint256 the amount of tokens to unstake
   * @param _data bytes optional data to include in the Unstake event
   */
  function unstakeFor(address _stakeFor, uint256 _amount, bytes memory _data) public {
    withdrawStake(msg.sender, _stakeFor, _amount, _data);
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
   * @dev Helper function to get specific properties of all of the personal stakes created by an address
   * @param _address address The address to query
   * @return (uint256[], uint256[], address[])
   *  timestamps array, amounts array, stakedFor array
   */
  function getPersonalStakes(address _address)
    view
    public
    returns(uint256[] memory, uint256[] memory, address[] memory)
  {
    StakeContract storage s = stakeHolders[_address];
    uint256 arraySize = s.stakes.length;
    uint256[] memory blockNumbers = new uint256[](arraySize);
    uint256[] memory amounts = new uint256[](arraySize);
    address[] memory stakedBy = new address[](arraySize);

    for (uint256 i = 0; i < s.stakes.length; i++) {
      blockNumbers[i] = s.stakes[i].blockNumber;
      amounts[i] = s.stakes[i].amount.sub(s.stakes[i].unstaked);
      stakedBy[i] = s.stakes[i].stakedBy;
    }

    return (blockNumbers, amounts, stakedBy);
  }

  /**
   * @dev Helper function to create stakes for a given address
   * @param _stakedBy address The sender requesting the stake
   * @param _stakeFor address The address the stake is being created for
   * @param _amount uint256 The number of tokens being staked
   * @param _data bytes optional data to include in the Stake event
   */
  function createStake(address _stakedBy, address _stakeFor, uint256 _amount, bytes memory _data)
    internal
    whenNotPaused
    canStake(_stakedBy, _amount)
    returns (uint256 , uint256)
  {
    stakeHolders[_stakeFor].total = stakeHolders[_stakeFor].total.add(_amount);
    Stake memory s = Stake(block.number, _amount, 0, _stakedBy);
    stakeHolders[_stakeFor].stakes.push(s);
    stakeHolders[_stakedBy].fors[_stakeFor].stakes.push(s);
    emit Staked(_stakeFor, s.amount, totalStakedFor(_stakeFor), _data);
    return (s.blockNumber, s.amount);
  }

  /**
   * @dev Helper function to withdraw stakes back to the original _stakedBy
   * @param _stakedBy address The sender that created the stake
   * @param _amount uint256 The amount to withdraw. Any exceeding amount will be mapped to the maximum available stake amount.
   * @param _data bytes optional data to include in the Unstake event
   */
  function withdrawStake(address _stakedBy, address _unstakeFor, uint256 _amount, bytes memory _data)
    internal
    whenNotPaused
    returns(uint256[] memory blockNumbers, uint256[] memory amounts)
  {
    StakedForContract storage sc = stakeHolders[_stakedBy].fors[_unstakeFor];
    uint256 _totalUnstaked = 0;
    uint256 i = 0;
    blockNumbers = new uint256[](sc.stakes.length);
    amounts = new uint256[](sc.stakes.length);
    while(_amount > 0 || sc.stakeIndex < sc.stakes.length) {
      Stake storage s = sc.stakes[sc.stakeIndex];
      uint256 _remainder = s.amount.sub(s.unstaked);
      uint256 _unstake = Math.min(_amount, _remainder);
      s.unstaked = s.unstaked.add(_unstake);
      _amount = _amount.sub(_unstake);
      _totalUnstaked = _totalUnstaked.add(_unstake);
      stakeHolders[_unstakeFor].total = stakeHolders[_unstakeFor].total.sub(_unstake);
      // Add safe check in case of contract vulnerability
      require(s.amount>=s.unstaked, "Inconsistent staking state.");
      if (s.amount == s.unstaked) sc.stakeIndex++;
      emit Unstaked(_unstakeFor, _unstake, totalStakedFor(_unstakeFor), _data);
      blockNumbers[i] = s.blockNumber;
      amounts[i] = _unstake;
      i++;
    }
    if (_totalUnstaked == 0) return (blockNumbers, amounts);
    // Transfer the staked tokens from this contract back to the sender
    // Notice that we are using transfer instead of transferFrom here.
    require(ERC20tokenContract.transfer(_stakedBy, _totalUnstaked), "Unable to withdraw stake");
  }
}

// File: contracts/backend/ZtickyStake.sol

pragma solidity ^0.5.2;

/**
 * @title ZtickyStake
 * @dev The ZtickyStake contract is a backend ERC900 contract used as storage for staking features.
 * It doesn't supports history and implements an interface callable exclusively from the logic contract
 */
contract ZtickyStake is IZtickyStake, ERC900, Destructible, HasNoEther, Backend {

  using SafeMath for uint256;

  uint256 public minimumLockTime = 0;

  struct ShareContract {
    uint256 outstandingShares;
    uint256 lastUpdated;
  }
  ShareContract public total;
  mapping (address => ShareContract) public shareHolders;

  constructor(address _zcz) ERC900(ERC20(_zcz)) public {}

  modifier emergencyUnstake(address _recipient) {
    require(ERC900.ERC20tokenContract.transfer(_recipient, ERC900.totalStaked()), "Transfer of staked locked tokens is required!");
    _;
  }

  function calculateCurrentSharesFromPreviousState(uint256 _previousShare, uint256 _previousStake, uint256 _updatedAt)
  internal
  view
  returns (uint256 _outstandingShares)
  {
    uint256 _delta = block.number.sub(_updatedAt);
    _outstandingShares = _previousShare + _delta.mul(_previousStake);
  }

  function calculateCurrentSharesFromHistory(uint256[] memory blockNumbers, uint256[] memory amounts, uint256 _minimumLockTime)
  internal
  view
  returns (uint256 _outstandingShares)
  {
    for (uint256 i = 0; i < blockNumbers.length; i++) {
      if (block.number.sub(blockNumbers[i]) < _minimumLockTime) continue;
      _outstandingShares = _outstandingShares.add(calculateCurrentSharesFromPreviousState(0, amounts[i], blockNumbers[i]));
    }
  }

  function getShareRatio(uint256 _outstandingShares, uint256 _totalShares)
  internal
  pure
  returns (uint256)
  {
    return _outstandingShares.mul(1 ether).div(_totalShares);
  }

  function updateShares()
  internal
  {
    total.outstandingShares = totalShares();
    total.lastUpdated = block.number;
  }

  function updateSharesOf(address _shareHolder)
  internal
  {
    shareHolders[_shareHolder].outstandingShares = sharesOf(_shareHolder);
    shareHolders[_shareHolder].lastUpdated = block.number;
  }

  function createStake(address _stakedBy, address _stakeFor, uint256 _amount, bytes memory _data)
  internal
  returns (uint256 , uint256)
  {
    updateShares();
    updateSharesOf(_stakeFor);
    return ERC900.createStake(_stakedBy, _stakeFor, _amount, _data);
  }

  function withdrawStake(address _stakedBy, address _stakeFor, uint256 _amount, bytes memory _data)
  internal
  returns(uint256[] memory blockNumbers, uint256[] memory amounts)
  {
    updateShares();
    updateSharesOf(_stakeFor);
    (blockNumbers, amounts) = ERC900.withdrawStake(_stakedBy, _stakeFor, _amount, _data);
    uint256 _unstakedShare = 0;
    uint256 n = block.number;
    for (uint256 i = 0; i < amounts.length; i++) {
      uint256 _delta = n.sub(blockNumbers[i]);
      _unstakedShare = _unstakedShare.add(_delta.mul(amounts[i]));
      shareHolders[_stakeFor].outstandingShares = shareHolders[_stakeFor].outstandingShares.sub(_unstakedShare);
      shareHolders[_stakeFor].lastUpdated = n;
    }
    total.outstandingShares = total.outstandingShares.sub(_unstakedShare);
  }

  function totalShares()
  public
  view
  returns (uint256)
  {
    return calculateCurrentSharesFromPreviousState(total.outstandingShares, ERC900.totalStaked(), total.lastUpdated);
  }

  function sharesOf(address _shareHolder)
  public
  view
  returns (uint256)
  {
    ShareContract storage s = shareHolders[_shareHolder];
    return calculateCurrentSharesFromPreviousState(s.outstandingShares, ERC900.totalStakedFor(_shareHolder), s.lastUpdated);
  }

  function shareRatioOf(address _shareHolder)
  public
  view
  returns (uint256)
  {
    return getShareRatio(sharesOf(_shareHolder), totalShares());
  }

  function changeMinimumLockTime(uint256 _newMinimumLockTime)
  onlyBackendAdmin
  public
  returns (bool)
  {
    minimumLockTime = _newMinimumLockTime;
    return true;
  }

  /**
   * @notice Stakes a certain amount of tokens, this MUST transfer the given amount from the user
   * @notice MUST trigger Staked event
   * @param _amount uint256 the amount of tokens to stake
   * @param _data bytes optional data to include in the Stake event
   */
  function authorizedStakeFor(address _stakeFor, uint256 _amount, bytes memory _data)
  onlyFrontend
  whenNotPaused
  public
  returns (bool)
  {
    createStake(tx.origin, _stakeFor, _amount, _data);
    return true;
  }

  /**
  * @notice Unstakes a certain amount of tokens, this SHOULD return the given amount of tokens to the user, if unstaking is currently not possible the function MUST revert
  * @notice MUST trigger Unstaked event
  * @dev Users can only unstake starting from their oldest active stake. Upon releasing that stake, the tokens will be
  *  transferred back to their account, and their stakeIndex will increment to the next active stake.
  * @param _amount uint256 the amount of tokens to unstake
  * @param _data bytes optional data to include in the Unstake event
  */
  function authorizedUnstakeFor(address _stakeFor, uint256 _amount, bytes memory _data)
  onlyFrontend
  whenNotPaused
  public
  returns (uint256)
  {
    uint256 _totalShares = totalShares();
    (uint256[] memory blockNumbers, uint256[] memory amounts) =  withdrawStake(tx.origin, _stakeFor, _amount, _data);
    return getShareRatio(calculateCurrentSharesFromHistory(blockNumbers, amounts, minimumLockTime), _totalShares);
  }

  /**
   * @notice Stakes a certain amount of tokens, this MUST transfer the given amount from the user
   * @notice MUST trigger Staked event
   * @param _amount uint256 the amount of tokens to stake
   * @param _data bytes optional data to include in the Stake event
   */
  function authorizedStake(uint256 _amount, bytes memory _data)
  public
  returns (bool)
  {
    return authorizedStakeFor(tx.origin, _amount, _data);
  }


  /**
   * @notice Stakes a certain amount of tokens, this MUST transfer the given amount from the user
   * @notice MUST trigger Staked event
   * @param _amount uint256 the amount of tokens to stake
   * @param _data bytes optional data to include in the Stake event
   */
  function authorizedUnstake(uint256 _amount, bytes memory _data)
  public
  returns (uint256)
  {
    return authorizedUnstakeFor(tx.origin, _amount, _data);
  }

  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy()
  whenPaused
  onlyBackendAdmin
  emergencyUnstake(Ownable.owner())
  public
  {
    selfdestruct(Ownable.owner());
  }

  function destroyAndSend(address payable _recipient)
  whenPaused
  onlyOwner
  emergencyUnstake(_recipient)
  public
  {
    return Destructible.destroyAndSend(_recipient);
  }
}
