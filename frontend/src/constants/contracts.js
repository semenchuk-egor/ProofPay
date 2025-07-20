export const CONTRACTS = {
  PAYMENT_PROCESSOR: {
    address: process.env.REACT_APP_PAYMENT_PROCESSOR_ADDRESS,
    abi: [
      'function createPayment(address recipient, bytes32 attestationUID) external payable returns (bytes32)',
      'function getPayment(bytes32 paymentId) external view returns (tuple(address sender, address recipient, uint256 amount, bytes32 attestationUID, uint256 timestamp, bool completed))',
      'function platformFee() external view returns (uint256)',
      'event PaymentCreated(bytes32 indexed paymentId, address indexed sender, address indexed recipient, uint256 amount)',
    ],
  },
  
  ATTESTATION_VERIFIER: {
    address: process.env.REACT_APP_ATTESTATION_VERIFIER_ADDRESS,
    abi: [
      'function verifyAttestation(bytes32 uid) external view returns (bool)',
      'function trustedAttesters(address) external view returns (bool)',
    ],
  },
  
  PROOF_TOKEN: {
    address: process.env.REACT_APP_PROOF_TOKEN_ADDRESS,
    abi: [
      'function balanceOf(address account) external view returns (uint256)',
      'function transfer(address to, uint256 amount) external returns (bool)',
      'function approve(address spender, uint256 amount) external returns (bool)',
    ],
  },
  
  PAYMENT_PROOF_NFT: {
    address: process.env.REACT_APP_PAYMENT_PROOF_NFT_ADDRESS,
    abi: [
      'function ownerOf(uint256 tokenId) external view returns (address)',
      'function tokenURI(uint256 tokenId) external view returns (string)',
      'function tokenAttestations(uint256 tokenId) external view returns (bytes32)',
    ],
  },
  
  EAS: {
    address: '0x4200000000000000000000000000000000000021',
    abi: [
      'function attest(tuple(bytes32 schema, address recipient, uint64 expirationTime, bool revocable, bytes32 refUID, bytes data, uint256 value) request) external payable returns (bytes32)',
      'function getAttestation(bytes32 uid) external view returns (tuple(bytes32 uid, bytes32 schema, uint64 time, uint64 expirationTime, address recipient, address attester, bytes data))',
    ],
  },
};

export const CHAIN_IDS = {
  BASE: 8453,
  BASE_SEPOLIA: 84532,
};

export const RPC_URLS = {
  [CHAIN_IDS.BASE]: 'https://mainnet.base.org',
  [CHAIN_IDS.BASE_SEPOLIA]: 'https://sepolia.base.org',
};

export const BLOCK_EXPLORERS = {
  [CHAIN_IDS.BASE]: 'https://basescan.org',
  [CHAIN_IDS.BASE_SEPOLIA]: 'https://sepolia.basescan.org',
};
