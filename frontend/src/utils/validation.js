/**
 * Validation utilities
 */

export function isValidAddress(address) {
  return /^0x[a-fA-F0-9]{40}$/.test(address);
}

export function isValidAmount(amount) {
  return !isNaN(amount) && parseFloat(amount) > 0;
}

export function isValidTxHash(hash) {
  return /^0x[a-fA-F0-9]{64}$/.test(hash);
}

export function validateEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

export function validateURL(url) {
  try {
    new URL(url);
    return true;
  } catch {
    return false;
  }
}
