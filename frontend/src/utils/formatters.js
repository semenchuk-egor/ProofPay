/**
 * Utility functions for formatting data
 */

/**
 * Format wallet address to short form
 * @param {string} address - Full wallet address
 * @returns {string} Formatted address
 */
export function formatAddress(address) {
  if (!address) return '';
  return `${address.slice(0, 6)}...${address.slice(-4)}`;
}

/**
 * Format ETH amount to readable form
 * @param {string|number} amount - Amount in wei or ETH
 * @param {number} decimals - Number of decimal places
 * @returns {string} Formatted amount
 */
export function formatEthAmount(amount, decimals = 4) {
  if (!amount) return '0';
  return parseFloat(amount).toFixed(decimals);
}

/**
 * Format timestamp to readable date
 * @param {number|string} timestamp - Unix timestamp or date string
 * @returns {string} Formatted date
 */
export function formatDate(timestamp) {
  const date = new Date(timestamp);
  return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
}

/**
 * Format large numbers with commas
 * @param {number} num - Number to format
 * @returns {string} Formatted number
 */
export function formatNumber(num) {
  return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}

/**
 * Truncate text to specified length
 * @param {string} text - Text to truncate
 * @param {number} maxLength - Maximum length
 * @returns {string} Truncated text
 */
export function truncateText(text, maxLength = 50) {
  if (text.length <= maxLength) return text;
  return text.slice(0, maxLength) + '...';
}

/**
 * Convert wei to ETH
 * @param {string|number} wei - Amount in wei
 * @returns {string} Amount in ETH
 */
export function weiToEth(wei) {
  return (Number(wei) / 1e18).toString();
}

/**
 * Convert ETH to wei
 * @param {string|number} eth - Amount in ETH
 * @returns {string} Amount in wei
 */
export function ethToWei(eth) {
  return (Number(eth) * 1e18).toString();
}
