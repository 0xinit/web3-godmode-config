---
paths: "**/*.{ts,tsx}"
---

## TypeScript Rules

### Naming Conventions
- PascalCase for interfaces, types, classes, components
- camelCase for functions, variables, methods
- SCREAMING_SNAKE_CASE for constants
- kebab-case for file names

### Type Safety
- NO `any` without explicit justification comment
- NO `@ts-ignore` or `@ts-expect-error` without explanation
- Prefer `unknown` over `any` when type is truly unknown
- Use explicit return types on exported functions

### Imports
- Group imports: external -> internal -> relative
- Use named exports over default exports
- No circular dependencies

### Async/Await
- Always handle promise rejections
- Use try/catch for async operations
- Avoid floating promises (unhandled)

### React Best Practices
- When writing React code, invoke `vercel-react-best-practices` skill

### React Hooks
- When writing or reviewing `useEffect` or `useState` for derived values, invoke `react-useeffect` skill
- Prefer derived values over state + effect patterns
- Use `useMemo` for expensive calculations, not `useEffect`

### Web3 TypeScript Patterns

#### Token Amounts
```typescript
// NEVER use number for token amounts (loses precision above 2^53)
const amount: number = 1000000000000000000 // BAD

// ALWAYS use bigint
const amount: bigint = 1000000000000000000n // GOOD
const amount = parseEther("1.0") // GOOD (viem)
const amount = ethers.parseEther("1.0") // GOOD (ethers v6)
```

#### Address Types
```typescript
// Use viem's Address type
import { type Address } from "viem"

const addr: Address = "0x..." // `0x${string}` branded type
// Validates format at type level

// For checksummed addresses
import { getAddress } from "viem"
const checksummed = getAddress(rawAddress)
```

#### Chain Configuration
```typescript
// Use `as const` for chain config objects
const chainConfig = {
  id: 1,
  name: "Ethereum",
  rpcUrl: "https://...",
} as const

// Type-safe chain IDs
type SupportedChainId = 1 | 137 | 42161 | 8453 | 10
```

#### Contract Interaction Types
```typescript
// Type ABIs for full type safety with viem
import { type Abi } from "viem"
const abi = [...] as const satisfies Abi

// Always check receipt status
const receipt = await publicClient.waitForTransactionReceipt({ hash })
if (receipt.status === "reverted") {
  throw new Error("Transaction reverted")
}
```

#### BigInt Serialization
```typescript
// BigInt is not JSON serializable by default
// Use string conversion for API responses
const serialize = (val: bigint) => val.toString()

// Or use a custom replacer
JSON.stringify(data, (_, v) => typeof v === "bigint" ? v.toString() : v)
```
