import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_BACKEND_URL || 'http://localhost:8000';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('auth_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('auth_token');
      window.location.href = '/';
    }
    return Promise.reject(error);
  }
);

export const paymentAPI = {
  create: (data) => apiClient.post('/api/payments', data),
  get: (id) => apiClient.get(`/api/payments/${id}`),
  list: (address) => apiClient.get(`/api/payments?address=${address}`),
};

export const attestationAPI = {
  create: (data) => apiClient.post('/api/attestations', data),
  get: (uid) => apiClient.get(`/api/attestations/${uid}`),
  verify: (uid) => apiClient.post(`/api/attestations/${uid}/verify`),
  list: (address) => apiClient.get(`/api/attestations?address=${address}`),
};

export const authAPI = {
  challenge: (address) => apiClient.post('/api/auth/challenge', { address }),
  verify: (address, signature) => apiClient.post('/api/auth/verify', { address, signature }),
};

export default apiClient;
