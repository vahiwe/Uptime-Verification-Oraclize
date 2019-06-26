pragma solidity ^0.5.0;
import "./oraclizeAPI.sol";


contract UptimeVerification is usingOraclize{

    /** Owner of contract */
    address public owner;

    /** Registration Status of Address */
    mapping(address => bool) registerStatus;

    /** An Oracle call returns a query. Map to Boolean to check if it has been called earlier */
    mapping(bytes32=>bool) pendingQueries;

    /** Set returned Oracle call to offTimeValue */
    uint public offTimeValue;

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
    modifier isRegistered{require(registerStatus[msg.sender] == true, "Message Sender should be registered"); _;}

    //
    // Functions
    //

    // Counstructor
    constructor() public payable {
        owner = msg.sender;
        registerStatus[owner] = true;
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
    }

    /// @notice Get balance of contract
    function getBalance() public view returns (uint _balance) {
        return address(this).balance;
    }

    /// @notice Transfer ether to Customer if contract is breached
    function debitisp() public payable {
        require(msg.value > 0 && msg.value == 5000000, "Check value of debit amount to be equal to 5000000");
        msg.sender.transfer(msg.value);
    }

    /// @notice Get balance of Customer account
    function getCustomerBalance() public view returns (uint _balance) {
        return msg.sender.balance;
    }

    /// @notice Check registration Status of Customer
    function registrationStatus() public view returns (bool _stat) {
        return registerStatus[msg.sender];
    }

    /// @notice Register customer
    //  Can only be carried out by owner of contract
    function registerCustomer (address _address) public isOwner {
        registerStatus[_address] = true;
    }

    /// @notice Update the uptime value by running the Oracle service
    //  Emit the appropriate event
    //  Can only be called by a registered customer
    function update() public payable isRegistered {
        // Check if we have enough remaining funds
        if (oraclize_getPrice("URL") > address(this).balance) {
            emit NewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            emit NewOraclizeQuery("Oraclize query was sent, standing by for the answer...");
            //oraclize_query("URL", "json(https://api.thingspeak.com/channels/800450/fields/6/last.json).field6");
            // Using XPath to to fetch the right element in the XML response
            bytes32 queryId = oraclize_query("URL", "xml(https://api.thingspeak.com/channels/800450/fields/6/last.xml).feed.field6");
            pendingQueries[queryId] = true;
        }
    }

}
