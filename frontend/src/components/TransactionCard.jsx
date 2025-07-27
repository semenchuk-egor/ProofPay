import React from 'react';
import { formatAddress, formatAmount, formatDate } from '../utils/format';

export const TransactionCard = ({ transaction, userAddress }) => {
  const isSent = transaction.sender === userAddress;
  
  const getStatusIcon = (status) => {
    const icons = {
      completed: '✓',
      pending: '⏳',
      failed: '✗',
    };
    return icons[status] || '?';
  };

  const getStatusColor = (status) => {
    const colors = {
      completed: 'bg-green-500',
      pending: 'bg-yellow-500',
      failed: 'bg-red-500',
    };
    return colors[status] || 'bg-gray-500';
  };

  return (
    <div className="bg-white rounded-lg border border-gray-200 p-4 hover:shadow-lg transition">
      <div className="flex items-start justify-between">
        <div className="flex-1">
          {/* Direction Badge */}
          <div className="flex items-center gap-2 mb-2">
            <span className={`text-sm font-medium ${isSent ? 'text-red-600' : 'text-green-600'}`}>
              {isSent ? '↑ Sent' : '↓ Received'}
            </span>
            <div className={`w-6 h-6 rounded-full ${getStatusColor(transaction.status)} flex items-center justify-center text-white text-xs`}>
              {getStatusIcon(transaction.status)}
            </div>
          </div>

          {/* Amount */}
          <div className="text-2xl font-bold mb-1">
            {formatAmount(transaction.amount)} ETH
          </div>

          {/* Counterparty */}
          <div className="text-sm text-gray-600 mb-2">
            <span className="font-medium">{isSent ? 'To:' : 'From:'}</span>{' '}
            <span className="font-mono">
              {formatAddress(isSent ? transaction.recipient : transaction.sender)}
            </span>
          </div>

          {/* Description */}
          {transaction.description && (
            <div className="text-sm text-gray-700 mb-2">
              {transaction.description}
            </div>
          )}

          {/* Timestamp */}
          <div className="text-xs text-gray-500">
            {formatDate(transaction.timestamp)}
          </div>
        </div>

        {/* View Details Button */}
        <button
          onClick={() => window.open(`https://basescan.org/tx/${transaction.payment_id}`, '_blank')}
          className="ml-4 px-3 py-1 text-sm bg-gray-100 hover:bg-gray-200 rounded-md"
        >
          View
        </button>
      </div>

      {/* Attestation Badge */}
      {transaction.attestation_uid && (
        <div className="mt-3 pt-3 border-t border-gray-100">
          <div className="flex items-center gap-2 text-xs text-blue-600">
            <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
            </svg>
            <span>Attestation Verified</span>
          </div>
        </div>
      )}
    </div>
  );
};
