import React, { useState } from 'react';

/**
 * Component for verifying EAS attestations
 */
export default function AttestationVerifier() {
  const [attestationUID, setAttestationUID] = useState('');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState(null);
  const [error, setError] = useState(null);

  const verifyAttestation = async () => {
    if (!attestationUID) {
      setError('Please enter an attestation UID');
      return;
    }

    setLoading(true);
    setError(null);
    setResult(null);

    try {
      const response = await fetch(
        `${process.env.REACT_APP_BACKEND_URL}/api/attestation/verify/${attestationUID}`
      );
      
      if (!response.ok) {
        throw new Error('Failed to verify attestation');
      }

      const data = await response.json();
      setResult(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const getAttestationDetails = async () => {
    if (!attestationUID) {
      setError('Please enter an attestation UID');
      return;
    }

    setLoading(true);
    setError(null);
    setResult(null);

    try {
      const response = await fetch(
        `${process.env.REACT_APP_BACKEND_URL}/api/attestation/${attestationUID}`
      );
      
      if (!response.ok) {
        throw new Error('Attestation not found');
      }

      const data = await response.json();
      setResult(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto p-6 bg-white rounded-lg shadow-md">
      <h2 className="text-2xl font-bold mb-6">Verify Attestation</h2>
      
      <div className="mb-6">
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Attestation UID
        </label>
        <input
          type="text"
          value={attestationUID}
          onChange={(e) => setAttestationUID(e.target.value)}
          placeholder="0x..."
          className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        />
      </div>

      <div className="flex gap-4 mb-6">
        <button
          onClick={verifyAttestation}
          disabled={loading}
          className="flex-1 bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed"
        >
          {loading ? 'Verifying...' : 'Quick Verify'}
        </button>
        
        <button
          onClick={getAttestationDetails}
          disabled={loading}
          className="flex-1 bg-green-600 text-white px-6 py-2 rounded-md hover:bg-green-700 disabled:bg-gray-400 disabled:cursor-not-allowed"
        >
          {loading ? 'Loading...' : 'Get Details'}
        </button>
      </div>

      {error && (
        <div className="p-4 bg-red-50 border border-red-200 rounded-md mb-4">
          <p className="text-red-800">{error}</p>
        </div>
      )}

      {result && (
        <div className="p-4 bg-gray-50 border border-gray-200 rounded-md">
          <h3 className="font-semibold mb-3">Verification Result:</h3>
          
          {result.valid !== undefined ? (
            <div className={`p-3 rounded ${result.valid ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
              <p className="font-medium">
                {result.valid ? '✓ Valid Attestation' : '✗ Invalid or Expired Attestation'}
              </p>
            </div>
          ) : (
            <div className="space-y-2">
              <p><span className="font-medium">UID:</span> {result.uid?.substring(0, 20)}...</p>
              <p><span className="font-medium">Recipient:</span> {result.recipient}</p>
              <p><span className="font-medium">Attester:</span> {result.attester}</p>
              <p><span className="font-medium">Status:</span> 
                <span className={`ml-2 ${result.valid ? 'text-green-600' : 'text-red-600'}`}>
                  {result.valid ? 'Valid ✓' : 'Invalid ✗'}
                </span>
              </p>
              {result.data && (
                <div className="mt-3 p-3 bg-white rounded">
                  <p className="font-medium mb-2">KYC Data:</p>
                  <p>Level: {result.data.level}</p>
                  <p>Timestamp: {new Date(result.data.timestamp * 1000).toLocaleString()}</p>
                </div>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  );
}
