import React, {Component} from 'react';
//import { AppBar, Toolbar, Grid, Typography } from '@material-ui/core';
import Coin from '../abis/Coin.json'
import { withAlert } from 'react-alert'


class CoinApp extends Component {

    async componentWillMount() {
        await this.loadBlockchainData()
    }

    async loadBlockchainData() {
        const web3 = window.web3
        const accounts = await web3.eth.getAccounts()
        this.setState({ account: accounts[0] })
    
        const networkId = await web3.eth.net.getId()
        const networkData = Coin.networks[networkId]
        if(networkData) {
          const abi = Coin.abi
          const address = networkData.address
          this.props.alert.info(`Loading coin contract at address ${address}`)
          var contract = new web3.eth.Contract(abi, address)
          this.setState({ contract })
    
          this.loadData()    
          this.listenEvents()
        } else {
          this.props.alert.error('Smart contract is not deployed to detected network.')
        }
    }

    loadData() {

    }

    listenEvents() {

    }

    constructor(props) {
        super(props)
        //this.handleRegister = this.handleRegister.bind(this);
        this.state = {
          account: '',
          contract: null,
          userCount: 0,
          users: []
        }
    
      }

    render() {
        return (
        <div><h2>Hello CoinApp</h2></div>
        );
    }
};

export default withAlert()(CoinApp);