import React, { useState } from 'react';

export default function Governance() {
  const [proposals, setProposals] = useState([]);

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 py-4 sm:px-6 lg:px-8">
          <h1 className="text-3xl font-bold">Governance</h1>
          <p className="text-gray-600 mt-1">Participate in ProofPay DAO decisions</p>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 py-8 sm:px-6 lg:px-8">
        <div className="bg-white rounded-lg shadow p-6 mb-6">
          <button className="bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700">
            Create Proposal
          </button>
        </div>

        <div className="space-y-4">
          {proposals.length === 0 ? (
            <div className="bg-white rounded-lg shadow p-12 text-center">
              <p className="text-gray-600">No active proposals</p>
            </div>
          ) : (
            proposals.map(proposal => (
              <div key={proposal.id} className="bg-white rounded-lg shadow p-6">
                <h3 className="text-xl font-bold mb-2">{proposal.title}</h3>
                <p className="text-gray-600 mb-4">{proposal.description}</p>
                <div className="flex gap-3">
                  <button className="bg-green-600 text-white px-4 py-2 rounded">Vote For</button>
                  <button className="bg-red-600 text-white px-4 py-2 rounded">Vote Against</button>
                </div>
              </div>
            ))
          )}
        </div>
      </main>
    </div>
  );
}
