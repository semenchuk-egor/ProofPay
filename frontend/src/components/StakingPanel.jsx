import React, { useState } from 'react';

export default function StakingPanel() {
  const [amount, setAmount] = useState('');
  const [staked, setStaked] = useState('0');
  const [rewards, setRewards] = useState('0');

  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      <h2 className="text-2xl font-bold mb-6">Stake PROOF Tokens</h2>
      
      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="bg-blue-50 p-4 rounded-lg">
          <p className="text-sm text-gray-600">Your Staked</p>
          <p className="text-2xl font-bold text-blue-600">{staked} PROOF</p>
        </div>
        
        <div className="bg-green-50 p-4 rounded-lg">
          <p className="text-sm text-gray-600">Rewards</p>
          <p className="text-2xl font-bold text-green-600">{rewards} PROOF</p>
        </div>
      </div>

      <div className="space-y-4">
        <input
          type="number"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          placeholder="Amount to stake"
          className="w-full px-4 py-2 border rounded-md"
        />
        
        <div className="flex gap-3">
          <button className="flex-1 bg-blue-600 text-white py-2 rounded-md hover:bg-blue-700">
            Stake
          </button>
          <button className="flex-1 bg-gray-600 text-white py-2 rounded-md hover:bg-gray-700">
            Unstake
          </button>
        </div>
        
        <button className="w-full bg-green-600 text-white py-2 rounded-md hover:bg-green-700">
          Claim Rewards
        </button>
      </div>
    </div>
  );
}
