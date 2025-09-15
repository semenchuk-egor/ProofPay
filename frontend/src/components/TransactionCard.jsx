import React from 'react';

/**
 * Card component for displaying transaction information
 */
export default function TransactionCard({ transaction }) {
  const {
    type,
    address,
    amount,
    status,
    timestamp,
    txHash
  } = transaction;

  const getTypeStyles = () => {
    return type === 'sent' 
      ? { bg: 'bg-red-100', text: 'text-red-600', icon: '↑' }
      : { bg: 'bg-green-100', text: 'text-green-600', icon: '↓' };
  };

  const getStatusBadge = () => {
    const styles = {
      completed: 'bg-green-100 text-green-800',
      pending: 'bg-yellow-100 text-yellow-800',
      failed: 'bg-red-100 text-red-800'
    };

    return (
      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${styles[status]}`}>
        {status === 'completed' && '✓'}
        {status === 'pending' && '⏳'}
        {status === 'failed' && '✗'}
        {' '}{status.charAt(0).toUpperCase() + status.slice(1)}
      </span>
    );
  };

  const formatAddress = (addr) => {
    return `${addr.slice(0, 8)}...${addr.slice(-6)}`;
  };

  const formatAmount = (amt) => {
    return `${parseFloat(amt).toFixed(4)} ETH`;
  };

  const formatTimestamp = (ts) => {
    const date = new Date(ts);
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
  };

  const typeStyles = getTypeStyles();

  return (
    <div className="bg-white rounded-lg shadow hover:shadow-md transition p-4 border border-gray-200">
      <div className="flex items-start justify-between">
        {/* Left side - Icon and Details */}
        <div className="flex items-start space-x-3">
          <div className={`${typeStyles.bg} rounded-full p-2 mt-1`}>
            <span className={`${typeStyles.text} text-lg font-bold`}>
              {typeStyles.icon}
            </span>
          </div>
          
          <div>
            <p className="font-medium text-gray-900">
              {type === 'sent' ? 'Sent to' : 'Received from'}
            </p>
            <p className="text-sm text-gray-600 font-mono">{formatAddress(address)}</p>
            <p className="text-xs text-gray-500 mt-1">{formatTimestamp(timestamp)}</p>
          </div>
        </div>

        {/* Right side - Amount and Status */}
        <div className="text-right">
          <p className={`text-lg font-semibold ${typeStyles.text}`}>
            {type === 'sent' ? '-' : '+'}{formatAmount(amount)}
          </p>
          <div className="mt-2">
            {getStatusBadge()}
          </div>
        </div>
      </div>

      {/* Transaction Hash Link */}
      {txHash && status === 'completed' && (
        <div className="mt-3 pt-3 border-t border-gray-100">
          <a
            href={`https://basescan.org/tx/${txHash}`}
            target="_blank"
            rel="noopener noreferrer"
            className="text-sm text-blue-600 hover:text-blue-700 flex items-center"
          >
            <span>View on Basescan</span>
            <svg className="w-4 h-4 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
            </svg>
          </a>
        </div>
      )}
    </div>
  );
}
