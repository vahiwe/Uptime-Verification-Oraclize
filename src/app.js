// // Import the page's CSS. Webpack will know what to do with it, 
// // as it's been configured by truffle-webpack
import './app.css';

const Web3 = require('web3')
const web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:9545"))

var va

const abi = [{"constant":true,"inputs":[],"name":"offTimeValue","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"payable":false,"stateMutability":"nonpayable","type":"fallback"},{"anonymous":false,"inputs":[{"indexed":false,"name":"description","type":"string"}],"name":"NewOraclizeQuery","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"value","type":"string"}],"name":"NewOffTimeValue","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_owner","type":"address"},{"indexed":true,"name":"_balance","type":"uint256"}],"name":"LogUpdate","type":"event"},{"constant":false,"inputs":[{"name":"_myid","type":"bytes32"},{"name":"_result","type":"string"}],"name":"__callback","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_myid","type":"bytes32"},{"name":"_result","type":"string"},{"name":"_proof","type":"bytes"}],"name":"__callback","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"getBalance","outputs":[{"name":"_balance","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"update","outputs":[],"payable":true,"stateMutability":"payable","type":"function"}]
const address = "0x52b0c74120cd8db5e81e7ef782aff2bc8f8eb6cb"
const contract = new web3.eth.Contract(abi, address)

contract.getPastEvents('NewOffTimeValue',{fromBlock: 0,toBlock: 'latest'},(err, events) => { va = events[0].returnValues[0] ; console.log(va); document.getElementById('total').innerHTML = va; })
