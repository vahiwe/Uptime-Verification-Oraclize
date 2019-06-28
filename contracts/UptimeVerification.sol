pragma solidity ^0.5.0;
import "./oraclizeAPI.sol";


contract UptimeVerification is usingOraclize{

    /** Owner of contract */
    address public owner;

    /** Caller of Update function */
    address caller;

    /** Check if update has been called */
    bool updateCalled;

    /** Registration Status of Customer */
    mapping(address => Customer) customerStatus;

    /** An Oracle call returns a query. Map to Boolean to check if it has been called earlier */
    mapping(bytes32=>bool) pendingQueries;

    /** Set returned Oracle call to offTimeValue */
    uint public offTimeValue;

    /** Create a struct named Customer.
    *   Here, add Registration Status and call status
    */
    struct Customer {
        bool registerStatus;
        bool callerStatus;
        uint256 callTime;
    }

    //
    // Events - publicize actions to external listeners
    //
    event NewOraclizeQuery(string description);
    event NewOffTimeValue(string value);
    event LogUpdate(address indexed _owner, uint indexed _balance);

    //
    // Modifiers
    //
    modifier isOwner{require(msg.sender == owner, "Message Sender should be the owner of the contract"); _;}
    modifier isRegistered(address _address){require(customerStatus[_address].registerStatus == true, "Require address to be registered"); _;}
    modifier isUpdateNotCalled{require(updateCalled == false, "Check if update has been called, False check"); _;}
    modifier isUpdateCalled{require(updateCalled == true, "Check if update has been called, True check"); _;}
    modifier isCallerNull{require(caller == address(0x0), "Check if caller address is Null"); _;}
    modifier isCallerNotNull{require(caller != address(0x0), "Check if caller address is Not Null"); _;}
    modifier allowUpdate(address _address){require(now >= (customerStatus[_address].callTime) + 5 minutes, "5 minutes has passed since last update call"); _;}

    //
    // Functions
    //

    // Counstructor
    constructor() public payable {
        owner = msg.sender;
        customerStatus[owner].registerStatus = true;
        emit LogUpdate(owner, address(this).balance);
        OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
        update(); // Update views on contract creation...
    }

    /// @notice Callback function
    // Emit the appropriate event
    function __callback(bytes32 _myid, string memory _result) public {
        require(msg.sender == oraclize_cbAddress(), "Message sender should be equal to contract address");
        require(pendingQueries[_myid] == true, "This should be an already emitted ID");
        emit NewOffTimeValue(_result);
        offTimeValue = parseInt(_result);
        delete pendingQueries[_myid];
        // Do something with offTimeValue, like debiting the ISP if offTimeValue > X?
        if(offTimeValue > 77){
            this.debitisp();
        }
        updateCalled = false;
        customerStatus[caller].callerStatus == false;
        caller = address(0x0);
    }

    /// @notice Transfer ether to Customer if contract is breached
    function debitisp() public payable isUpdateCalled isCallerNotNull {
        require(address(this).balance >= 5000000, "Check Balance of Contract");
        require(customerStatus[caller].registerStatus == true, "Check if caller is registered");
        require(customerStatus[caller].callerStatus == true, "Check if caller has called the update function");
        address(uint160(caller)).transfer(5000000);
    }

    /// @notice Get balance of contract
    function getBalance() public view isRegistered(msg.sender) returns (uint _balance) {
        return address(this).balance;
    }

    /// @notice Get balance of Customer account
    function getCustomerBalance() public view isRegistered(msg.sender) returns (uint _balance) {
        return msg.sender.balance;
    }

    /// @notice Check registration Status of Customer
    function registrationStatus() public view returns (bool _stat) {
        return customerStatus[msg.sender].registerStatus;
    }

    /// @notice Register customer
    //  Can only be carried out by owner of contract
    function registerCustomer (address _address) public isOwner {
        customerStatus[_address].registerStatus = true;
    }

    /// @notice Un-Register customer
    //  Can only be carried out by owner of contract
    function deRegisterCustomer (address _address) public isOwner {
        customerStatus[_address].registerStatus = false;
    }

    /// @notice Update the uptime value by running the Oracle service
    //  Emit the appropriate event
    //  Can only be called by a registered customer
    function update() public payable isRegistered(msg.sender) isUpdateNotCalled isCallerNull allowUpdate(msg.sender) {
        // Check if we have enough remaining funds
        if (oraclize_getPrice("URL") > address(this).balance) {
            emit NewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            updateCalled = true;
            caller = msg.sender;
            customerStatus[caller].callerStatus = true;
            customerStatus[caller].callTime = now;
            emit NewOraclizeQuery("Oraclize query was sent, standing by for the answer...");
            //oraclize_query("URL", "json(https://api.thingspeak.com/channels/800450/fields/6/last.json).field6");
            // Using XPath to to fetch the right element in the XML response
            bytes32 queryId = oraclize_query("URL", "xml(https://api.thingspeak.com/channels/800450/fields/6/last.xml).feed.field6");
            pendingQueries[queryId] = true;
        }
    }

}
