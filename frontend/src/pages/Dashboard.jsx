import React, { useState, useEffect } from 'react';
import { WalletConnect } from '../components/WalletConnect';
import { PaymentForm } from '../components/PaymentForm';
import { useWeb3 } from '../hooks/useWeb3';

export const Dashboard = () => {
  const { account, signer } = useWeb3();
  const [payments, setPayments] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (account) {
      loadPayments();
    }
  }, [account]);

  const loadPayments = async () => {
    setLoading(true);
    try {
      const response = await fetch(`/api/payments?address=${account}`);
      const data = await response.json();
      setPayments(data);
    } catch (error) {
      console.error('Failed to load payments:', error);
    } finally {
      setLoading(false);
    }
  };

  const handlePaymentSuccess = (data) => {
    console.log('Payment successful:', data);
    loadPayments();
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <nav className="bg-white shadow-sm">
        <div className="container mx-auto px-4 py-4 flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-blue-600">ProofPay</h1>
            <p className="text-sm text-gray-600">Decentralized Payments</p>
          </div>
          <WalletConnect />
        </div>
      </nav>

      {/* Main Content */}
      <main className="container mx-auto px-4 py-8">
        {!account ? (
          <div className="text-center py-12">
            <h2 className="text-3xl font-bold mb-4">Welcome to ProofPay</h2>
            <p className="text-gray-600 mb-8">Connect your wallet to get started</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            {/* Payment Form */}
            <div>
              <PaymentForm signer={signer} onSuccess={handlePaymentSuccess} />
            </div>

            {/* Payment History */}
            <div className="bg-white rounded-lg shadow p-6">
              <h3 className="text-xl font-bold mb-4">Recent Payments</h3>
              
              {loading ? (
                <div className="text-center py-8">Loading...</div>
              ) : payments.length === 0 ? (
                <div className="text-center py-8 text-gray-500">
                  No payments yet
                </div>
              ) : (
                <div className="space-y-4">
                  {payments.map((payment, idx) => (
                    <div key={idx} className="border-b pb-4">
                      <div className="flex justify-between">
                        <span className="font-medium">{payment.amount} ETH</span>
                        <span className="text-sm text-gray-500">{payment.status}</span>
                      </div>
                      <div className="text-sm text-gray-600">
                        To: {payment.recipient.slice(0, 10)}...
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        )}
      </main>
    </div>
  );
};
