import React from 'react';
import { useWallet } from '../contexts/WalletContext';

export default function Profile() {
  const { account } = useWallet();

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 py-4">
          <h1 className="text-3xl font-bold">Profile</h1>
        </div>
      </header>

      <main className="max-w-4xl mx-auto px-4 py-8">
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center space-x-4 mb-6">
            <div className="w-20 h-20 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full"></div>
            <div>
              <h2 className="text-xl font-bold">{account || 'Not Connected'}</h2>
              <p className="text-gray-600">Member since 2025</p>
            </div>
          </div>

          <div className="border-t pt-6">
            <h3 className="font-semibold mb-4">Account Information</h3>
            <dl className="space-y-2">
              <div className="flex justify-between">
                <dt className="text-gray-600">Wallet</dt>
                <dd className="font-mono">{account}</dd>
              </div>
              <div className="flex justify-between">
                <dt className="text-gray-600">Attestation</dt>
                <dd className="text-green-600">Verified ✓</dd>
              </div>
            </dl>
          </div>
        </div>
      </main>
    </div>
  );
}
