import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';

function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <div className="container mx-auto px-4 py-16">
        <h1 className="text-6xl font-bold text-center mb-8">
          ProofPay
        </h1>
        <p className="text-xl text-center text-gray-600 mb-12">
          Decentralized payments without KYC using on-chain proof
        </p>
      </div>
    </div>
  );
}

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Home />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
