import React, { createContext, useContext, useState, useEffect } from 'react';
import web3Service from '../services/web3Service';

const WalletContext = createContext();

export function useWallet() {
  const context = useContext(WalletContext);
  if (!context) {
    throw new Error('useWallet must be used within WalletProvider');
  }
  return context;
}

export function WalletProvider({ children }) {
  const [account, setAccount] = useState(null);
  const [balance, setBalance] = useState('0');
  const [chainId, setChainId] = useState(null);
  const [connecting, setConnecting] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    // Listen for account changes
    web3Service.onAccountsChanged((newAccount) => {
      setAccount(newAccount);
      if (newAccount) {
        updateBalance(newAccount);
      } else {
        setBalance('0');
      }
    });

    // Listen for network changes
    web3Service.onChainChanged((newChainId) => {
      setChainId(newChainId);
      if (newChainId !== 8453) {
        setError('Please switch to Base network');
      } else {
        setError(null);
      }
    });
  }, []);

  const updateBalance = async (address) => {
    try {
      const bal = await web3Service.getBalance(address);
      setBalance(bal);
    } catch (err) {
      console.error('Failed to fetch balance:', err);
    }
  };

  const connect = async () => {
    setConnecting(true);
    setError(null);

    try {
      const acc = await web3Service.connect();
      setAccount(acc);
      await updateBalance(acc);

      // Check if on Base network
      const network = await web3Service.provider.getNetwork();
      setChainId(Number(network.chainId));

      if (Number(network.chainId) !== 8453) {
        setError('Please switch to Base network');
      }
    } catch (err) {
      setError(err.message);
      console.error('Failed to connect wallet:', err);
    } finally {
      setConnecting(false);
    }
  };

  const disconnect = () => {
    web3Service.disconnect();
    setAccount(null);
    setBalance('0');
    setChainId(null);
    setError(null);
  };

  const switchToBase = async () => {
    try {
      await web3Service.switchToBase();
      setError(null);
    } catch (err) {
      setError('Failed to switch network');
      console.error(err);
    }
  };

  const value = {
    account,
    balance,
    chainId,
    connecting,
    error,
    isConnected: !!account,
    isBaseNetwork: chainId === 8453,
    connect,
    disconnect,
    switchToBase
  };

  return (
    <WalletContext.Provider value={value}>
      {children}
    </WalletContext.Provider>
  );
}
