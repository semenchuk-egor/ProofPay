import React, { createContext, useContext, useState, useEffect } from 'react';
import { authAPI } from '../services/api';

const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const savedToken = localStorage.getItem('auth_token');
    const savedAddress = localStorage.getItem('user_address');
    
    if (savedToken && savedAddress) {
      setToken(savedToken);
      setUser({ address: savedAddress });
    }
    setLoading(false);
  }, []);

  const login = async (address, signature, message) => {
    try {
      const response = await authAPI.verify(address, signature, message);
      const { access_token } = response.data;
      
      setToken(access_token);
      setUser({ address });
      
      localStorage.setItem('auth_token', access_token);
      localStorage.setItem('user_address', address);
      
      return true;
    } catch (error) {
      console.error('Login failed:', error);
      return false;
    }
  };

  const logout = () => {
    setToken(null);
    setUser(null);
    localStorage.removeItem('auth_token');
    localStorage.removeItem('user_address');
  };

  return (
    <AuthContext.Provider value={{ user, token, loading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
