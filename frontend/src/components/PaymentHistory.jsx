import React, { useState, useEffect } from 'react';
import { formatAddress, formatAmount, formatDate } from '../utils/format';

export const PaymentHistory = ({ address }) => {
  const [payments, setPayments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all'); // all, sent, received

  useEffect(() => {
    if (address) {
      loadPayments();
    }
  }, [address, filter]);

  const loadPayments = async () => {
    setLoading(true);
    try {
      const response = await fetch(`/api/payments?address=${address}&filter=${filter}`);
      const data = await response.json();
      setPayments(data);
    } catch (error) {
      console.error('Failed to load payments:', error);
    } finally {
      setLoading(false);
    }
  };

  const getStatusColor = (status) => {
    const colors = {
      completed: 'bg-green-100 text-green-800',
      pending: 'bg-yellow-100 text-yellow-800',
      failed: 'bg-red-100 text-red-800',
    };
    return colors[status] || 'bg-gray-100 text-gray-800';
  };

  return (
    <div className="bg-white rounded-lg shadow p-6">
      <div className="flex justify-between items-center mb-6">
        <h3 className="text-xl font-bold">Payment History</h3>
        
        <div className="flex gap-2">
          <button
            onClick={() => setFilter('all')}
            className={`px-3 py-1 rounded ${filter === 'all' ? 'bg-blue-600 text-white' : 'bg-gray-200'}`}
          >
            All
          </button>
          <button
            onClick={() => setFilter('sent')}
            className={`px-3 py-1 rounded ${filter === 'sent' ? 'bg-blue-600 text-white' : 'bg-gray-200'}`}
          >
            Sent
          </button>
          <button
            onClick={() => setFilter('received')}
            className={`px-3 py-1 rounded ${filter === 'received' ? 'bg-blue-600 text-white' : 'bg-gray-200'}`}
          >
            Received
          </button>
        </div>
      </div>

      {loading ? (
        <div className="text-center py-8">
          <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
          <p className="mt-2 text-gray-600">Loading payments...</p>
        </div>
      ) : payments.length === 0 ? (
        <div className="text-center py-8 text-gray-500">
          <p>No payments found</p>
        </div>
      ) : (
        <div className="space-y-4">
          {payments.map((payment, idx) => (
            <div key={idx} className="border rounded-lg p-4 hover:shadow-md transition">
              <div className="flex justify-between items-start mb-2">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="text-lg font-semibold">
                      {formatAmount(payment.amount)} ETH
                    </span>
                    <span className={`text-xs px-2 py-1 rounded ${getStatusColor(payment.status)}`}>
                      {payment.status}
                    </span>
                  </div>
                  <div className="text-sm text-gray-600 mt-1">
                    {payment.sender === address ? 'To' : 'From'}: {formatAddress(payment.sender === address ? payment.recipient : payment.sender)}
                  </div>
                </div>
                <div className="text-right text-sm text-gray-500">
                  {formatDate(payment.timestamp)}
                </div>
              </div>
              
              {payment.description && (
                <div className="text-sm text-gray-600 mt-2">
                  {payment.description}
                </div>
              )}
              
              {payment.attestation_uid && (
                <div className="mt-2 text-xs text-blue-600">
                  Attestation: {formatAddress(payment.attestation_uid)}
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
};
