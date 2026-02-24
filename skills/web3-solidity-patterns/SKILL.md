---
name: web3-solidity-patterns
description: Solidity design patterns. Factory, Proxy (UUPS/Diamond), access control, pull payments, events.
---

# Solidity Design Patterns

## Contract Architecture

### Interface-First Development
Always define the interface before implementation:
```solidity
interface IVault {
    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function balanceOf(address user) external view returns (uint256);

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    error InsufficientBalance(uint256 available, uint256 requested);
}
```

### Contract Structure Order
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract MyContract {
    // 1. Type declarations (structs, enums)
    // 2. State variables
    // 3. Events
    // 4. Errors
    // 5. Modifiers
    // 6. Constructor
    // 7. External functions
    // 8. Public functions
    // 9. Internal functions
    // 10. Private functions
    // 11. View/pure functions
}
```

## Design Patterns

### Factory Pattern
Deploy new contract instances from a factory:
```solidity
contract VaultFactory {
    address[] public vaults;

    event VaultCreated(address indexed vault, address indexed owner);

    function createVault(address token) external returns (address) {
        Vault vault = new Vault(token, msg.sender);
        vaults.push(address(vault));
        emit VaultCreated(address(vault), msg.sender);
        return address(vault);
    }
}
```
Use when: deploying multiple instances of the same contract with different params.

### Minimal Proxy (EIP-1167 Clone)
Deploy cheap copies sharing the same implementation:
```solidity
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

contract VaultFactory {
    address public immutable implementation;

    constructor() {
        implementation = address(new Vault());
    }

    function createVault(address token) external returns (address) {
        address clone = Clones.clone(implementation);
        Vault(clone).initialize(token, msg.sender);
        return clone;
    }
}
```
Use when: deploying many identical contracts (saves 90%+ gas on deployment).

### Proxy Patterns

| Pattern | Upgrade Logic In | Gas Cost | Complexity |
|---------|-----------------|----------|------------|
| Transparent | Proxy contract | Higher (admin check) | Medium |
| UUPS (EIP-1822) | Implementation | Lower | Medium |
| Beacon | Beacon contract | Medium | High |
| Diamond (EIP-2535) | Diamond contract | Variable | Very High |

### Access Control

| Pattern | Use When |
|---------|----------|
| `Ownable` | Single admin |
| `Ownable2Step` | Single admin with safe transfer |
| `AccessControl` | Multiple roles |
| `AccessControlDefaultAdminRules` | Multiple roles with admin safety |
| Multi-sig (Gnosis Safe) | High-value operations |
| Timelock + Governor | DAO governance |

### Pull-Over-Push (Payments)
```solidity
// BAD: Push pattern — can fail/DoS
function distribute(address[] calldata recipients) external {
    for (uint i; i < recipients.length;) {
        payable(recipients[i]).transfer(amount);  // Can fail
        unchecked { ++i; }
    }
}

// GOOD: Pull pattern — users withdraw
mapping(address => uint256) public pendingWithdrawals;

function withdraw() external {
    uint256 amount = pendingWithdrawals[msg.sender];
    require(amount > 0, NothingToWithdraw());
    pendingWithdrawals[msg.sender] = 0;
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, TransferFailed());
}
```

### Event-Driven Architecture
Design events for off-chain indexing (The Graph, custom indexers):
```solidity
// Index-friendly events
event Transfer(address indexed from, address indexed to, uint256 value);
event Swap(
    address indexed sender,
    address indexed tokenIn,
    address indexed tokenOut,
    uint256 amountIn,
    uint256 amountOut
);
```
- Up to 3 indexed params (for filtering)
- Non-indexed params for data
- Emit events for EVERY state change

### Library Usage
```solidity
// Use libraries for reusable logic without inheritance
using SafeERC20 for IERC20;
using Math for uint256;

// Prefer libraries over inheritance when:
// - Logic is stateless
// - Multiple unrelated contracts need the same utility
// - You want to avoid the diamond inheritance problem
```

## Testing Patterns

| Type | Purpose | Tool |
|------|---------|------|
| Unit | Single function correctness | forge test |
| Integration | Multi-contract interaction | forge test (with setup) |
| Fork | Against real mainnet state | forge test --fork-url |
| Fuzz | Random inputs for properties | forge test (fuzz) |
| Invariant | Protocol-wide properties | forge test (invariant) |

## Code Examples

See [examples.md](./examples.md) for complete code examples:
- Minimal Proxy (EIP-1167)
- UUPS Proxy setup
- Diamond pattern skeleton
- Governor setup
- ERC-20 with Permit
