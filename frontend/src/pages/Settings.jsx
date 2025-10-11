import React, { useState } from 'react';

export default function Settings() {
  const [settings, setSettings] = useState({
    notifications: true,
    autoApprove: false,
    language: 'en'
  });

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 py-4 sm:px-6 lg:px-8">
          <h1 className="text-3xl font-bold">Settings</h1>
        </div>
      </header>

      <main className="max-w-3xl mx-auto px-4 py-8">
        <div className="bg-white rounded-lg shadow">
          <div className="p-6 border-b">
            <h2 className="text-lg font-semibold">Preferences</h2>
          </div>
          
          <div className="p-6 space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="font-medium">Enable Notifications</p>
                <p className="text-sm text-gray-600">Receive payment alerts</p>
              </div>
              <input type="checkbox" checked={settings.notifications} className="h-4 w-4" />
            </div>
            
            <div className="flex items-center justify-between">
              <div>
                <p className="font-medium">Auto-approve small payments</p>
                <p className="text-sm text-gray-600">Payments under 0.01 ETH</p>
              </div>
              <input type="checkbox" checked={settings.autoApprove} className="h-4 w-4" />
            </div>
          </div>

          <div className="p-6 border-t">
            <button className="bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700">
              Save Changes
            </button>
          </div>
        </div>
      </main>
    </div>
  );
}
