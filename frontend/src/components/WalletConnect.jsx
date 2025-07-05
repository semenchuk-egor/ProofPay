import React from 'react';
import { useWeb3 } from '../hooks/useWeb3';

export const WalletConnect = () => {
  const { account, chainId, error, connect, disconnect } = useWeb3();

  const formatAddress = (address) => {
    if (!address) return '';
    return `${address.slice(0, 6)}...${address.slice(-4)}`;
  };

  const getChainName = (id) => {
    const chains = {
      '8453': 'Base',
      '84532': 'Base Sepolia',
      '1': 'Ethereum',
    };
    return chains[id?.toString()] || 'Unknown';
  };

  return (
    <div className="flex items-center gap-4">
      {error && (
        <div className="text-red-600 text-sm">{error}</div>
      )}
      
      {account ? (
        <div className="flex items-center gap-2">
          <div className="bg-green-100 px-3 py-2 rounded-md">
            <div className="text-xs text-green-600">{getChainName(chainId)}</div>
            <div className="font-mono text-sm">{formatAddress(account)}</div>
          </div>
          <button
            onClick={disconnect}
            className="px-4 py-2 bg-gray-200 rounded-md hover:bg-gray-300"
          >
            Disconnect
          </button>
        </div>
      ) : (
        <button
          onClick={connect}
          className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
        >
          Connect Wallet
        </button>
      )}
    </div>
  );
};
