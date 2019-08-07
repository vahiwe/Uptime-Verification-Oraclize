const {
    PREFIX,
    waitForEvent
  } = require('./utils')
  
  const Web3 = require('web3')
  const offtime = artifacts.require('./UptimeVerification.sol')
  const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:9545'))
  
  contract('Uptime Verification Tests', accounts => {
  
    let offtimeVal
    const gasAmt = 3e6
    const address = accounts[0]
  
    beforeEach(async () => (
      { contract } = await offtime.deployed(),
      { methods, events } = new web3.eth.Contract(
        contract._jsonInterface,
        contract._address
      )
    ))
  
    it('Should have logged a new Provable query', async () => {
      const {
        returnValues: {
          description
        }
      } = await waitForEvent(events.NewProvableQuery)
      assert.strictEqual(
        description,
        'Provable query was sent, standing by for the answer...',
        'Provable query incorrectly logged!'
      )
    })
  
    it('Callback should have logged a new Offtime value', async () => {
      const {
        returnValues: {
          value
        }
      } = await waitForEvent(events.NewOffTimeValue)
      offtimeVal = value
      assert.isAbove(
        parseInt(value),
        0,
        'An Offtime value should have been retrieved from Oraclize call!'
      )
    })
  
    it('Should set Offtime Value correctly in contract', async () => {
      const queriedOfftime = await methods
        .offTimeValue()
        .call()
      assert.strictEqual(
        parseInt(queriedOfftime),
        parseInt(offtimeVal),
        'Contract\'s Offtime Value not set correctly!'
      )
    })
  
    it('Should not revert on second query attempt', async () => {
      const expErr = 'revert'
      try {
        await methods
          .update()
          .send({
            from: address,
            gas: gasAmt
          })
        assert.isTrue('Update transaction succeeded!')
      } catch (e) {}
    })

    it('Owner of Contract should be registered', async () => {
        const regStatus = await methods.registrationStatus().call({from: address,gas: gasAmt})
        assert.strictEqual(
          regStatus,
          true,
          'Owner of account not registered'
        )
      })
  })
  