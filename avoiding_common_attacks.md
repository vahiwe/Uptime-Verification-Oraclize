# Security Tools / Common Attacks
 This has been designed to sufficiently prevent common attack vectors. Additionally, The contracts were verified through the use of a number of Security analysis tools, linters and code coverage checkers, including `Truffle-security` and `Solium`. 

### Security Considerations in Design
The simplicity in design means that most normal attack vectors do not apply, such as Race condition, Transaction-Ordering Dependence (TOD) and Front Running. There are, however, some sections of the system design that could result in potential attack vectors. Each of these possible vulnerabilities is discussed as well as how the project mitigates against them.

1. **Integer Overflow and Underflow**
The value of the uptime is stored using a uint. This *could* potentially overflow/underflow. The case of an overflow/underflow is impossible as this value corresponds to a percentage value which is between 0-100.
2. **DoS with Block gas limit**
Each block has an upper bound on the amount of gas that can be spent, and thus the amount computation that can be done. This is the Block Gas Limit. From the contract logic the gas price is pre-calculated and if it is higher than the current account balance, the query fails and is handled gracefully. Thus eliminating this vulnerability.

### Smart Contract Security Audit
Each Testing framework and their respective results will be discussed.


1. **Truffle-security**: Testing was preformed with the plugin Truffle-security. The easiest way to interact with it is by running an npm install. Use this [link](https://github.com/ConsenSys/truffle-security) to view installation instructions. To start, install in the project directory:

        npm install truffle-security

Once you have the plugin in your project directory you can use it to execute tests on contracts. From the root of the project directory you can run:

    truffle run verify

Truffle-security reported a number of warnings regarding DoS if gas limit is reached, integer overflow/underflow and a number of other interesting results. None of which are system braking nor could be considered vulnerabilities due to having adequate checks to prevent against under/overflows.  

2. **Solium**: Linting to identify and fix styling and security issues within the smart contracts was preformed using Solium. To get running with Solium, first install it on your local machine using:
    
        sudo snap install solium --edge    
If you are running this on your own project, first init the project to get started.

        solium --init


Next, we can lint the whole directory of contracts using:

        solium -d contracts/

Solium reported 1 error in the `Oraclize.sol` due to the use of inline assembly. Despite this, it is considered secure as the oraclize contract followed standard design patterns.


