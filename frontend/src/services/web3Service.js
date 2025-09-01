/**
 * Web3 service for blockchain interactions
 */
import { ethers } from 'ethers';

class Web3Service {
  constructor() {
    this.provider = null;
    this.signer = null;
    this.account = null;
  }

  /**
   * Connect to MetaMask wallet
   */
  async connect() {
    if (!window.ethereum) {
      throw new Error('MetaMask not installed');
    }

    try {
      // Request account access
      const accounts = await window.ethereum.request({
        method: 'eth_requestAccounts'
      });

      this.provider = new ethers.BrowserProvider(window.ethereum);
      this.signer = await this.provider.getSigner();
      this.account = accounts[0];

      // Check network (Base mainnet: 8453)
      const network = await this.provider.getNetwork();
      if (network.chainId !== 8453n) {
        console.warn('Not connected to Base network');
      }

      return this.account;
    } catch (error) {
      console.error('Failed to connect wallet:', error);
      throw error;
    }
  }

  /**
   * Disconnect wallet
   */
  disconnect() {
    this.provider = null;
    this.signer = null;
    this.account = null;
  }

  /**
   * Get current account
   */
  getAccount() {
    return this.account;
  }

  /**
   * Get account balance
   */
  async getBalance(address) {
    if (!this.provider) {
      throw new Error('Provider not initialized');
    }

    const balance = await this.provider.getBalance(address || this.account);
    return ethers.formatEther(balance);
  }

  /**
   * Send native token transaction
   */
  async sendTransaction(to, amount) {
    if (!this.signer) {
      throw new Error('Wallet not connected');
    }

    const tx = await this.signer.sendTransaction({
      to,
      value: ethers.parseEther(amount)
    });

    return tx.wait();
  }

  /**
   * Get contract instance
   */
  getContract(address, abi) {
    if (!this.signer) {
      throw new Error('Wallet not connected');
    }

    return new ethers.Contract(address, abi, this.signer);
  }

  /**
   * Switch to Base network
   */
  async switchToBase() {
    try {
      await window.ethereum.request({
        method: 'wallet_switchEthereumChain',
        params: [{ chainId: '0x2105' }] // 8453 in hex
      });
    } catch (error) {
      // Network not added, try to add it
      if (error.code === 4902) {
        await window.ethereum.request({
          method: 'wallet_addEthereumChain',
          params: [{
            chainId: '0x2105',
            chainName: 'Base',
            nativeCurrency: {
              name: 'Ethereum',
              symbol: 'ETH',
              decimals: 18
            },
            rpcUrls: ['https://mainnet.base.org'],
            blockExplorerUrls: ['https://basescan.org']
          }]
        });
      } else {
        throw error;
      }
    }
  }

  /**
   * Listen for account changes
   */
  onAccountsChanged(callback) {
    if (window.ethereum) {
      window.ethereum.on('accountsChanged', (accounts) => {
        this.account = accounts[0] || null;
        callback(this.account);
      });
    }
  }

  /**
   * Listen for network changes
   */
  onChainChanged(callback) {
    if (window.ethereum) {
      window.ethereum.on('chainChanged', (chainId) => {
        callback(parseInt(chainId, 16));
      });
    }
  }
}

// Singleton instance
const web3Service = new Web3Service();
export default web3Service;
