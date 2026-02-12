# Solidity Gas Optimization

## Storage (Most Impactful)

### Storage Packing
```solidity
// BAD: 3 storage slots (96 bytes, 60K+ gas)
uint256 amount;    // slot 0
uint8 status;      // slot 1
address owner;     // slot 2

// GOOD: 2 storage slots (saves 20K+ gas)
uint256 amount;    // slot 0
address owner;     // slot 1 (20 bytes)
uint8 status;      // slot 1 (1 byte, packed with owner)
```

### Cache Storage Reads
```solidity
// BAD: Multiple SLOAD (2100 gas each after first)
function process() external {
    require(balances[msg.sender] > 0);
    uint256 fee = balances[msg.sender] * feeRate / 10000;
    balances[msg.sender] -= fee;
}

// GOOD: Cache in memory (3 gas per MLOAD)
function process() external {
    uint256 balance = balances[msg.sender];
    require(balance > 0);
    uint256 fee = balance * feeRate / 10000;
    balances[msg.sender] = balance - fee;
}
```

### Constants and Immutables
```solidity
// BAD: Storage read every time (2100 gas)
uint256 public maxSupply = 10000;

// GOOD: Embedded in bytecode (0 gas)
uint256 public constant MAX_SUPPLY = 10000;

// GOOD: Set once at deploy, embedded in bytecode
uint256 public immutable deployTimestamp;
constructor() { deployTimestamp = block.timestamp; }
```

## Function Parameters

### Calldata vs Memory
```solidity
// BAD: Copies array to memory
function process(uint256[] memory data) external { ... }

// GOOD: Reads directly from calldata (no copy)
function process(uint256[] calldata data) external { ... }
```

### Short-Circuit Requires
```solidity
// BAD: Evaluates both conditions
require(expensiveCheck() && cheapCheck());

// GOOD: Cheap check first, short-circuits
require(cheapCheck() && expensiveCheck());
```

## Custom Errors vs Require Strings

```solidity
// BAD: Stores string in bytecode, expensive to deploy and revert
require(balance >= amount, "Insufficient balance for withdrawal");

// GOOD: 4-byte selector, much cheaper
error InsufficientBalance(uint256 available, uint256 required);
if (balance < amount) revert InsufficientBalance(balance, amount);
```

## Loops

### Unchecked Increment
```solidity
// GOOD: Safe because i cannot overflow in practice
for (uint256 i = 0; i < length;) {
    // ... loop body
    unchecked { ++i; }
}
```

### Cache Array Length
```solidity
// BAD: Reads length from storage every iteration
for (uint256 i = 0; i < myArray.length; i++) { ... }

// GOOD: Cache length
uint256 length = myArray.length;
for (uint256 i = 0; i < length;) {
    // ...
    unchecked { ++i; }
}
```

## Data Structures

### Mappings vs Arrays
- **Mappings**: O(1) lookup, no iteration, no length, cheapest for key-value
- **Arrays**: Iteration possible, has length, more expensive for lookup
- Use mappings with a separate array/counter when you need both

### Bytes32 vs String
```solidity
// BAD: Dynamic size, expensive
string public name = "MyToken";

// GOOD: Fixed 32 bytes, single slot
bytes32 public constant NAME = "MyToken";
```

## EIP-2929 Cold/Warm Access

| Access | Gas Cost |
|--------|----------|
| Cold SLOAD (first read) | 2100 |
| Warm SLOAD (subsequent) | 100 |
| Cold account access | 2600 |
| Warm account access | 100 |

Implication: batch operations on same storage/address save gas on warm access.

## Events

- Use indexed parameters for filterable fields (up to 3)
- Non-indexed data is cheaper to emit
- Events are not accessible on-chain — use for off-chain indexing only

## Assembly Optimization (Advanced)

Only use when measurable gas savings justify complexity:
- Custom memory management
- Efficient hashing with known-length inputs
- Bitwise operations for packed data
- Always document what the assembly does and why it's safe
