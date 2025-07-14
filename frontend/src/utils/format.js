export const formatAddress = (address) => {
  if (!address) return '';
  return `${address.slice(0, 6)}...${address.slice(-4)}`;
};

export const formatAmount = (amount, decimals = 4) => {
  if (!amount) return '0';
  return parseFloat(amount).toFixed(decimals);
};

export const formatDate = (timestamp) => {
  const date = new Date(timestamp * 1000);
  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
};

export const formatChainId = (chainId) => {
  const chains = {
    1: 'Ethereum',
    8453: 'Base',
    84532: 'Base Sepolia',
    5: 'Goerli',
  };
  return chains[chainId] || `Chain ${chainId}`;
};

export const validateAddress = (address) => {
  return /^0x[a-fA-F0-9]{40}$/.test(address);
};

export const validateAmount = (amount) => {
  const num = parseFloat(amount);
  return !isNaN(num) && num > 0;
};

export const truncateText = (text, maxLength = 50) => {
  if (!text || text.length <= maxLength) return text;
  return text.slice(0, maxLength) + '...';
};
