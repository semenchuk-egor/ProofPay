# Troubleshooting Guide

## Common Issues

### Smart Contracts

#### Gas Estimation Failed
**Problem:** Transaction fails with "gas estimation failed"
**Solution:**
- Check contract is not paused
- Verify caller has required permissions
- Ensure sufficient token balance

#### Transaction Reverted
**Problem:** Transaction reverts without clear error
**Solution:**
- Check attestation validity
- Verify both parties are verified
- Review contract events for specific error

### Backend

#### API Connection Failed
**Problem:** Cannot connect to backend
**Solution:**
- Verify BACKEND_URL in .env
- Check if backend is running
- Confirm CORS settings

#### Database Connection Error
**Problem:** MongoDB connection fails
**Solution:**
- Check MONGO_URL format
- Verify MongoDB is running
- Test connection with mongo shell

### Frontend

#### Wallet Not Connecting
**Problem:** MetaMask doesn't connect
**Solution:**
- Refresh page
- Check MetaMask is installed
- Try switching networks
- Clear browser cache

#### Transaction Stuck
**Problem:** Transaction pending forever
**Solution:**
- Check network congestion
- Try increasing gas price
- Speed up transaction in MetaMask

## Getting Help
- Discord: [Join our community]
- GitHub: [Open an issue]
- Email: support@proofpay.io
