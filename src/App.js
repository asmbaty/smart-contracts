import React, {Component} from 'react'
import Web3 from 'web3'
import './App.css'
import CoinApp from './components/CoinApp'

class App extends Component {
  
  async componentWillMount() {
    await this.loadWeb3()
  }

  async loadWeb3() {
    if(window.ethereum) {
      window.web3 = new Web3(window.ethereum)
      await window.ethereum.enable() // browser
    }
    else if(window.web3) {
      window.web3 = new Web3(window.web3.currentProvider) // metamask
    }
    else {
      this.props.alert.error('Non-Ethereum browser detected. You should consider trying MetaMask!')
    }
  }

  render() {
    return (
      <>
        <CoinApp/>
      </>
    );
  }
}

export default App;
