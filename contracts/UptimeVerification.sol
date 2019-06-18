pragma solidity ^0.5.0;
import "./oraclizeAPI.sol";


contract UptimeVerification is usingOraclize{

  address owner;

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
  // Functions
  //

  // Counstructor
  constructor() public {
        owner = msg.sender;
        emit LogUpdate(owner, address(this).balance);
        OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
        update(); // Update views on contract creation...
    }

  // Fallback function - Called if other functions don't match call or
  // sent ether without data
  // Typically, called when invalid data is sent
  // Added so ether sent to this contract is reverted if the contract fails
  // otherwise, the sender's money is transferred to contract
  function() external {
      revert();
  }

  function __callback(bytes32 _myid, string memory _result) public {
      require(msg.sender == oraclize_cbAddress(), "Message sender should be equal to contract address");
      require(pendingQueries[_myid] == true, "This should be an already emitted ID");
      emit NewOffTimeValue(_result);
      offTimeValue = parseInt(_result);
      delete pendingQueries[_myid];
      // Do something with viewsCount, like tipping the author if viewsCount > X?
  }

  function getBalance() public view returns (uint _balance) {
        return address(this).balance;
    }


    /// @notice Update the uptime value by running the Oracle service
    // Emit the appropriate event
  function update() public payable {
          emit NewOraclizeQuery("Oraclize query was sent, standing by for the answer...");
          //oraclize_query("URL", "json(https://api.thingspeak.com/channels/800450/fields/6/last.json).field6");
          // Using XPath to to fetch the right element in the XML response
          bytes32 queryId = oraclize_query("URL", "xml(https://api.thingspeak.com/channels/800450/fields/6/last.xml).feed.field6");
          pendingQueries[queryId] = true;
  }

}
