// Import the page's CSS. Webpack will know what to do with it, 
// as it's been configured by truffle-webpack
import './app.css';

// Import libraries we need.
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract';

// Import our contract artifacts and turn them into usable abstractions.
// Make sure you've ran truffle compile first
import contract_build_artifacts from '../build/contracts/UptimeVerification.json'

// OraclizeContract is our usable abstraction, which we'll use through the code below.
var OraclizeContract = contract(contract_build_artifacts);

var accounts;
var account;

window.App = {
  currentBalance: 0,
  offTimeValue: 0,

  // 'Constructor'
  start: function() {
    var self = this;

    // Bootstrap the Contract abstraction for use with the current web3 instance
    OraclizeContract.setProvider(web3.currentProvider);

    // Get the initial account balance so it can be displayed.
    web3.eth.getAccounts(function(err, accs) {
      if (err != null) {
        alert("There was an error fetching your accounts.");
        return;
      }

      if (accs.length == 0) {
        alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
        return;
      }

      accounts = accs;
      account = accounts[0];

      self.refreshBalance();
    });
  },

  // Show an error
  setStatus: function(message) {
    var status = document.getElementById("status");
    status.innerHTML = message;
  },

  // Opens a socket and listens for Events defined in our contract.
  addEventListeners: function(instance){
    // var LogCreated = instance.events.LogUpdate({},{fromBlock: 0, toBlock: 'latest'});
    // var NewOffTimeValue = instance.events.NewOffTimeValue({},{fromBlock: 0, toBlock: 'latest'});
    // var NewOraclizeQuery = instance.events.NewOraclizeQuery({},{fromBlock: 0, toBlock: 'latest'});

    instance.events.NewOffTimeValue(function(err, result){
      if(!err){
        App.offTimeValue = result.args.value;
        App.showBalance(App.offTimeValue, App.currentBalance);
      }else{
        console.log(err)
      }
    })

    // Emitted when the Contract's constructor is run
    instance.events.LogUpdate(function(err, result){
      if(!err){
        console.log('Contract created!');
        console.log('Owner: ' , result.args._owner);
        console.log('Balance: ' , web3.fromWei(result.args._balance, 'ether').toString(), 'ETH');
        console.log('-----------------------------------');
      }else{
        console.log(err)
      }
    })

    // Emitted when a text message needs to be logged to the front-end from the Contract
    instance.events.NewOraclizeQuery(function(err, result){
      if(!err){
        console.info(result.args.description)
      }else{
        console.error(err)
      }
    })
  },

  refreshBalance: function() {
    var self = this;

    var meta;

    OraclizeContract.deployed().then(function(instance) {
      meta = instance;

      App.addEventListeners(instance);

      return meta.getBalance.call(account, {from: account});
    }).then(function(value) {
      App.currentBalance = web3.fromWei(value.valueOf(), 'ether');
      App.showBalance(App.offTimeValue, App.currentBalance);
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error getting balance; see console log.");
    });
  },

  showBalance: function(offTimeVal, balance){
    // Balance updated, start CSS animation
    var row = document.getElementById('row');
    row.style.animation = 'heartbeat 0.75s';
    
    // Removes CSS animation after 1100 ms
    setTimeout(function(row){
      var row = document.getElementById('row');
      row.style.animation = null;
    }, 1100)

    var balance_element = document.getElementById("balance");
    // Rounding can be more precise, this is just an example
    balance_element.innerHTML = parseFloat(balance).toFixed(6);

    var total_element = document.getElementById("total");
    total_element.innerHTML = parseInt(offTimeVal);
  }
};

// Front-end entry point
window.addEventListener('load', function() {
  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    console.warn("Using web3 detected from external source. If you find that your accounts don't appear or you have 0 MetaCoin, ensure you've configured that source properly. If using MetaMask, see the following link. Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask")
    // Use Mist/MetaMask's provider
    window.web3 = new Web3(web3.currentProvider);
  } else {
    console.warn("No web3 detected. Falling back to http://127.0.0.1:9545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:9545"));
  }

  // All systems go, start App!
  App.start();
});