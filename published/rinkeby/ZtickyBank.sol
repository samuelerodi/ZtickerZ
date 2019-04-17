
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

// File: contracts/utils/ReentrancyGuard.sol

pragma solidity ^0.5.2;

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}

// File: contracts/backend/ZtickyBank.sol

pragma solidity ^0.5.2;



/**
 * @title ZtickyBank
 * @author Samuele Rodi (a.k.a. Sam Fisherman)
 * @notice The ZtickyBank contract is a backend contract whose goal is to retain all the funds redeemable
 * by ZtickerZ stakeholders in the forms of dividends. It is a backend contract since it has the only
 * purpose of storing value, while the logic is implemented in the Frontend contract.
 */
contract ZtickyBank is IZtickyBank, HasZCZ, DestructibleZCZ, ReentrancyGuard, Backend {

  using SafeMath for uint256;

  /**
   * @dev The number of outstanding shares as per standard
   */
  uint256 public totalShares = 1 ether;

  constructor(address _zcz) public {
    HasZCZ._setZCZ(_zcz);
  }

  /**
   * @notice Function that confirms that this contract implements a ZtickyBank interface
   * @return true.
   */
  function isZBank()
    public
    pure
    returns(bool)
  {
    return true;
  }

  /**
   * @notice It returns the total balance of the ZBank contract
   * @return An array with the ETH balance and ZCZ balance.
   */
  function totalBalance()
    public
    view
    returns (uint256 _eth, uint256 _zcz)
  {
    _eth = address(this).balance;
    _zcz = this.ZCZ().balanceOf(address(this));
  }

  /**
   * @notice Computes the expected dividend in both ETH and ZCZ for each single share
   * @return An array with the ETH dividend and ZCZ dividend.
   */
  function outstandingDividendsPerShare()
    public
    view
    returns (uint256, uint256)
  {
    (uint256 _totalETH, uint256 _totalZCZ) = totalBalance();
    return (_totalETH.div(totalShares), _totalZCZ.div(totalShares));
  }

  /**
   * @notice Computes the expected dividend in both ETH and ZCZ for a specified amount of shares
   * @param _shares The amount of owned shares by the users for which dividends are being requested
   * @return An array with the ETH dividend and ZCZ dividend.
   */
  function outstandingDividendsFor(uint256 _shares)
    public
    view
    returns (uint256, uint256)
  {
    require(_shares<=totalShares, "Shares must be lower than total");
    (uint256 _totalETH, uint256 _totalZCZ) = totalBalance();
    return (_totalETH.mul(_shares).div(totalShares), _totalZCZ.mul(_shares).div(totalShares));
  }

  /**
   * @notice Computes the expected dividend in both ETH and ZCZ for each single share
   * @param _account The receipient of the redeemed dividends
   * @param _shares The amount of owned shares by the account for which dividends are being sent
   * @param _payETH boolean to specify if dividends in ETH are being sent
   * @param _payZCZ boolean to specify if dividends in ZCZ are being sent
   * @return A boolean that indicates if the operation was successful.
   */
  function payout(address payable _account, uint256 _shares, bool _payETH, bool _payZCZ)
    public
    onlyFrontend
    nonReentrant
    returns (bool)
  {
    (uint256 _eth, uint256 _zcz) = outstandingDividendsFor(_shares);
    emit Withdraw(_account, _eth, _zcz);
    if (_payZCZ && _zcz>0) require(this.ZCZ().transfer(_account, _zcz));
    if (_payETH && _eth>0) _account.transfer(_eth);
    return true;
  }

  /**
   * @notice This contract accepts ether payments
   */
  function() external payable {}

}
