# Core EIPs Reference

## Token Standards

### ERC-20 — Fungible Token Standard
**Status**: Final | **EIP**: 20
Standard interface for fungible tokens: `transfer`, `approve`, `transferFrom`, `balanceOf`, `totalSupply`, `allowance`.
```solidity
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
```

### ERC-721 — Non-Fungible Token Standard
**Status**: Final | **EIP**: 721
Standard for unique tokens (NFTs): `ownerOf`, `safeTransferFrom`, `approve`, `setApprovalForAll`.
Key: `safeTransferFrom` checks receiver can handle NFTs via `onERC721Received`.

### ERC-1155 — Multi Token Standard
**Status**: Final | **EIP**: 1155
Batch operations for both fungible and non-fungible tokens in one contract.
Key: `balanceOfBatch`, `safeBatchTransferFrom`. More gas efficient than separate ERC-20/721.

### ERC-4626 — Tokenized Vault Standard
**Status**: Final | **EIP**: 4626
Standard for yield-bearing vaults: `deposit`, `withdraw`, `mint`, `redeem`, `convertToShares`, `convertToAssets`.
Used by: Yearn, Aave, Compound.

## Signatures

### EIP-191 — Signed Data Standard
**Status**: Final
Prefix for signed messages: `\x19Ethereum Signed Message:\n` + length + message.
Prevents signed messages from being valid transactions.

### EIP-712 — Typed Structured Data Signing
**Status**: Final
Human-readable signing for structured data. Domain separator prevents cross-contract replay.
Used by: Permit (EIP-2612), Seaport (OpenSea), Uniswap Permit2.
```solidity
bytes32 DOMAIN_SEPARATOR = keccak256(abi.encode(
    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
    keccak256("MyContract"), keccak256("1"), block.chainid, address(this)
));
```

## Access & Permits

### EIP-2612 — ERC-20 Permit
**Status**: Final
Gasless approvals via signatures: `permit(owner, spender, value, deadline, v, r, s)`.
Eliminates separate approve transaction. Used heavily in DeFi.

### EIP-4494 — ERC-721 Permit
**Status**: Draft
Same concept as 2612 but for NFTs. Sign approval off-chain.

## Proxy & Upgradability

### EIP-1967 — Proxy Storage Slots
**Status**: Final
Standard storage slots for proxy contracts:
- Implementation: `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
- Admin: `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
- Beacon: `0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50`

### EIP-1822 — UUPS (Universal Upgradeable Proxy Standard)
**Status**: Final
Upgrade logic lives in implementation, not proxy. Smaller proxy bytecode, cheaper to deploy.

### EIP-2535 — Diamond Standard (Multi-Facet Proxy)
**Status**: Final
Single proxy with multiple implementation contracts (facets). Each function routes to its facet.
Complex but powerful for large contracts exceeding size limit.

## Account Abstraction

### EIP-4337 — Account Abstraction via Entry Point
**Status**: Final
Smart contract wallets with `UserOperation` objects processed by bundlers.
Enables: gas sponsorship, batch txs, social recovery, session keys.
Key contracts: `EntryPoint`, `Account`, `Paymaster`.

### EIP-7702 — Set EOA Account Code
**Status**: Final
EOAs can temporarily delegate to smart contract code for a single transaction.
Bridge between EOA and smart accounts. Lighter than 4337 for simple cases.

## Gas & Protocol

### EIP-1559 — Fee Market Change
**Status**: Final
Base fee + priority fee (tip). Base fee is burned. `maxFeePerGas`, `maxPriorityFeePerGas`.

### EIP-2929 — Gas Cost Increases for State Access
**Status**: Final
Cold access: 2600 (account), 2100 (storage). Warm access: 100.

### EIP-2930 — Access Lists
**Status**: Final
Pre-declare accessed addresses/slots to reduce cold access costs.

### EIP-4844 — Blob Transactions (Proto-Danksharding)
**Status**: Final
New tx type with "blob" data for L2 data availability. Much cheaper than calldata.
Used by: Optimism, Arbitrum, Base for L1 data posting.

### EIP-155 — Replay Protection
**Status**: Final
Chain ID in transaction signature prevents cross-chain replay.

### EIP-2718 — Typed Transaction Envelope
**Status**: Final
Extensible transaction format: `TransactionType || TransactionPayload`.

## Interface Detection

### EIP-165 — Standard Interface Detection
**Status**: Final
`supportsInterface(bytes4 interfaceId)` — check if contract implements an interface.
```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool);
```

### EIP-1820 — Pseudo-introspection Registry
**Status**: Final
Global registry contract for interface implementers. Used by ERC-777.

## DeFi

### EIP-3156 — Flash Loans
**Status**: Final
Standard interface for flash loans: `flashLoan(receiver, token, amount, data)`.
Receiver must implement `onFlashLoan` and repay amount + fee in same tx.

### ERC-4626 — Tokenized Vaults
(See Token Standards above)

## Smart Accounts

### EIP-7579 — Minimal Modular Smart Accounts
**Status**: Draft
Standard for modular smart account architecture: validators, executors, hooks, fallback handlers.
Enables interoperable smart account modules across implementations.

### EIP-7710 — Smart Account Delegation
**Status**: Draft
Framework for delegating permissions from smart accounts.
Used by MegaETH for ERC-7710 delegation framework.

## Metadata

### EIP-137 — ENS (Ethereum Name Service)
**Status**: Final
Domain name resolution on Ethereum. `.eth` names resolve to addresses.

### EIP-1271 — Standard Signature Validation for Contracts
**Status**: Final
`isValidSignature(hash, signature)` — lets contracts validate signatures.
Essential for smart wallet compatibility with dApps.

### EIP-6093 — Custom Errors for Common Tokens
**Status**: Final
Standard custom error names for ERC-20, ERC-721, ERC-1155.
Used by OpenZeppelin 5.x: `ERC20InsufficientBalance`, `ERC721NonexistentToken`, etc.
