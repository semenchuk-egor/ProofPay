import React, { useState } from 'react';
import { ethers } from 'ethers';

export const PaymentForm = ({ signer, onSuccess }) => {
  const [recipient, setRecipient] = useState('');
  const [amount, setAmount] = useState('');
  const [description, setDescription] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      // Validate inputs
      if (!ethers.isAddress(recipient)) {
        throw new Error('Invalid recipient address');
      }

      const amountWei = ethers.parseEther(amount);

      // Create payment transaction
      const tx = await signer.sendTransaction({
        to: recipient,
        value: amountWei,
      });

      await tx.wait();

      // Call backend to create attestation
      const response = await fetch('/api/payments', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          sender: await signer.getAddress(),
          recipient,
          amount: parseFloat(amount),
          description,
        }),
      });

      const data = await response.json();

      if (onSuccess) {
        onSuccess(data);
      }

      // Reset form
      setRecipient('');
      setAmount('');
      setDescription('');
    } catch (err) {
      setError(err.message);
      console.error('Payment error:', err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4 max-w-md mx-auto p-6 bg-white rounded-lg shadow">
      <h2 className="text-2xl font-bold mb-4">Send Payment</h2>
      
      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          {error}
        </div>
      )}

      <div>
        <label className="block text-sm font-medium mb-2">Recipient Address</label>
        <input
          type="text"
          value={recipient}
          onChange={(e) => setRecipient(e.target.value)}
          className="w-full px-3 py-2 border rounded-md"
          placeholder="0x..."
          required
        />
      </div>

      <div>
        <label className="block text-sm font-medium mb-2">Amount (ETH)</label>
        <input
          type="number"
          step="0.001"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          className="w-full px-3 py-2 border rounded-md"
          placeholder="0.1"
          required
        />
      </div>

      <div>
        <label className="block text-sm font-medium mb-2">Description</label>
        <input
          type="text"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          className="w-full px-3 py-2 border rounded-md"
          placeholder="Payment for..."
        />
      </div>

      <button
        type="submit"
        disabled={loading}
        className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 disabled:opacity-50"
      >
        {loading ? 'Processing...' : 'Send Payment'}
      </button>
    </form>
  );
};
