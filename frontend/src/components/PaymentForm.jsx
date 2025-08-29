import React, { useState } from 'react';

/**
 * Component for creating payment transactions
 */
export default function PaymentForm() {
  const [formData, setFormData] = useState({
    recipient: '',
    amount: '',
    tokenAddress: ''
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setSuccess(false);

    try {
      // TODO: Implement payment submission
      console.log('Submitting payment:', formData);
      
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      setSuccess(true);
      setFormData({ recipient: '', amount: '', tokenAddress: '' });
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-md mx-auto bg-white rounded-lg shadow-md p-6">
      <h2 className="text-2xl font-bold mb-6">Send Payment</h2>

      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Recipient Address
          </label>
          <input
            type="text"
            value={formData.recipient}
            onChange={(e) => setFormData({ ...formData, recipient: e.target.value })}
            placeholder="0x..."
            required
            className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Amount (ETH)
          </label>
          <input
            type="number"
            step="0.000001"
            value={formData.amount}
            onChange={(e) => setFormData({ ...formData, amount: e.target.value })}
            placeholder="0.00"
            required
            className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Token Address (Optional)
          </label>
          <input
            type="text"
            value={formData.tokenAddress}
            onChange={(e) => setFormData({ ...formData, tokenAddress: e.target.value })}
            placeholder="0x... (leave empty for native ETH)"
            className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
          <p className="text-xs text-gray-500 mt-1">
            Leave empty to send native ETH, or enter ERC20 token address
          </p>
        </div>

        {error && (
          <div className="p-4 bg-red-50 border border-red-200 rounded-md">
            <p className="text-red-800 text-sm">{error}</p>
          </div>
        )}

        {success && (
          <div className="p-4 bg-green-50 border border-green-200 rounded-md">
            <p className="text-green-800 text-sm">Payment submitted successfully!</p>
          </div>
        )}

        <button
          type="submit"
          disabled={loading}
          className="w-full bg-blue-600 text-white px-6 py-3 rounded-md hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed font-medium transition"
        >
          {loading ? 'Processing...' : 'Send Payment'}
        </button>
      </form>

      <div className="mt-6 pt-6 border-t border-gray-200">
        <p className="text-xs text-gray-500 text-center">
          Both sender and recipient must have valid EAS attestations
        </p>
      </div>
    </div>
  );
}
