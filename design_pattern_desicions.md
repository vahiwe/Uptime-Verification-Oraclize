# Design Decisions
This document aims to give an overview of the decisions made in both the design and construction of the Uptime Verification System.

## How It works
There are three main parts to the system: Ethereum Smart contract, IoT device and the ÐApp. Each will be discussed to justify design decision and to provide a high level overview of the solution.

Starting at the user front end(ÐApp), the user accesses the website via a web3 enabled browser. The ISP balance and Uptime Value is displayed. The Uptime value are gotten from the events emitted by the contract. 

The IoT Device measures the Uptime value and logs the value to an IoT platform where the data can be retrieved in both XML and JSON formats.

The Ethereum smart contract uses the oraclize library in order to get values in XML format from the web using the API provided by the IoT platform and act on it. 

## System Maintainability and Design Decision
The system has been designed to be as maintainable as possible, employing separation of concerns in every aspect of the design. The smart contracts employ an oraclize library that gets information from the web into the contract. 

## Other Design Considerations
An **Emergency stop** Paradigm was used enabling core functionality to be stopped if it might occur that a callback function of a sent query gets called more than once. A mapping is initiated that manages the query ids and their states. When the callback function of a query gets called, the require statement checks if the current query id needs to be processed. After one successful iteration the id gets deleted to prevent further callbacks for that particular id.
Also if your contract is not covered with enough ETH, the query will fail. From the contract logic the price of the next query is checked before it gets send. This is done by calling oraclize_getPrice and checking if it is higher than your current contract balance. If that's the case the oraclize_query will fail and it is handled gracefully.