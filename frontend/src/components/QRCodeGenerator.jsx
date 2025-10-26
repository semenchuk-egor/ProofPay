import React from 'react';

export default function QRCodeGenerator({ address }) {
  return (
    <div className="bg-white rounded-lg shadow p-6 text-center">
      <h3 className="font-semibold mb-4">Receive Payments</h3>
      <div className="w-48 h-48 bg-gray-200 mx-auto mb-4 flex items-center justify-center">
        <p className="text-gray-500">QR Code</p>
      </div>
      <p className="text-sm text-gray-600 font-mono break-all">{address}</p>
    </div>
  );
}
