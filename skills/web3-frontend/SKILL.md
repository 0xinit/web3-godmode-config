---
name: web3-frontend
description: Web3 frontend patterns for dApp development. Use when building wallet connections, transaction UX, token displays, or any blockchain-connected frontend. Covers wagmi/viem, ethers.js, Solana wallet adapter, BigNumber handling, and error translation.
---

# Web3 Frontend Patterns

## Wallet Connection

### EVM (wagmi + viem)
```typescript
import { WagmiProvider, createConfig, http } from "wagmi"
import { mainnet, base, arbitrum } from "wagmi/chains"
import { QueryClient, QueryClientProvider } from "@tanstack/react-query"
import { ConnectKitProvider, getDefaultConfig } from "connectkit"

const config = createConfig(
  getDefaultConfig({
    chains: [mainnet, base, arbitrum],
    transports: {
      [mainnet.id]: http(),
      [base.id]: http(),
      [arbitrum.id]: http(),
    },
    walletConnectProjectId: process.env.NEXT_PUBLIC_WC_PROJECT_ID!,
    appName: "My dApp",
  })
)

// In component
import { useAccount, useConnect, useDisconnect } from "wagmi"

function ConnectButton() {
  const { address, isConnected, chain } = useAccount()
  const { disconnect } = useDisconnect()
  // ...
}
```

### Solana (@solana/wallet-adapter)
```typescript
import { WalletAdapterNetwork } from "@solana/wallet-adapter-base"
import { WalletModalProvider } from "@solana/wallet-adapter-react-ui"
import { ConnectionProvider, WalletProvider } from "@solana/wallet-adapter-react"
import { PhantomWalletAdapter } from "@solana/wallet-adapter-wallets"

const network = WalletAdapterNetwork.Mainnet
const endpoint = clusterApiUrl(network)
const wallets = [new PhantomWalletAdapter()]
```

## Transaction State Management

```typescript
type TxState =
  | { status: "idle" }
  | { status: "confirming" }       // Wallet popup open
  | { status: "pending"; hash: `0x${string}` }  // Submitted, waiting
  | { status: "success"; receipt: TransactionReceipt }
  | { status: "error"; error: Error }

// Always show user which step they're on
// Handle wallet rejection (user closed popup) gracefully
```

### Transaction Flow
```typescript
async function sendTransaction() {
  setTxState({ status: "confirming" })
  try {
    const hash = await walletClient.writeContract({
      address: contractAddress,
      abi: contractAbi,
      functionName: "mint",
      args: [amount],
    })
    setTxState({ status: "pending", hash })

    const receipt = await publicClient.waitForTransactionReceipt({ hash })
    if (receipt.status === "reverted") {
      throw new Error("Transaction reverted")
    }
    setTxState({ status: "success", receipt })
  } catch (error) {
    if (isUserRejection(error)) {
      setTxState({ status: "idle" })  // Don't show error for user cancel
      return
    }
    setTxState({ status: "error", error: error as Error })
  }
}
```

## BigNumber Display

```typescript
import { formatEther, formatUnits } from "viem"

// ETH (18 decimals)
const display = formatEther(balanceWei) // "1.234567890123456789"

// Tokens (variable decimals)
const display = formatUnits(amount, decimals) // e.g., USDC has 6 decimals

// Formatting for display
function formatTokenAmount(amount: bigint, decimals: number, maxDecimals = 4): string {
  const formatted = formatUnits(amount, decimals)
  const num = parseFloat(formatted)
  if (num === 0) return "0"
  if (num < 0.0001) return "<0.0001"
  return num.toLocaleString(undefined, { maximumFractionDigits: maxDecimals })
}
```

## Error Translation

```typescript
function getHumanError(error: unknown): string {
  const message = error instanceof Error ? error.message : String(error)

  // User rejection
  if (message.includes("User rejected") || message.includes("user rejected"))
    return "Transaction cancelled"

  // Insufficient funds
  if (message.includes("insufficient funds"))
    return "Insufficient funds for gas"

  // Contract revert — try to decode
  if (message.includes("execution reverted")) {
    const reason = extractRevertReason(message)
    return reason || "Transaction would fail — check your inputs"
  }

  // Network errors
  if (message.includes("network") || message.includes("timeout"))
    return "Network error — please try again"

  return "Something went wrong — please try again"
}
```

## Chain Switching UX

```typescript
import { useSwitchChain } from "wagmi"

function ChainSwitcher() {
  const { switchChain } = useSwitchChain()
  const { chain } = useAccount()

  // Prompt user to switch if on wrong chain
  if (chain?.id !== expectedChainId) {
    return (
      <button onClick={() => switchChain({ chainId: expectedChainId })}>
        Switch to {expectedChainName}
      </button>
    )
  }
}
```

## ENS / SNS Resolution

```typescript
// ENS (Ethereum Name Service)
import { normalize } from "viem/ens"
const address = await publicClient.getEnsAddress({ name: normalize("vitalik.eth") })
const name = await publicClient.getEnsName({ address })

// Display: show ENS name if available, truncated address otherwise
function formatAddress(address: string, ensName?: string): string {
  if (ensName) return ensName
  return `${address.slice(0, 6)}...${address.slice(-4)}`
}
```

## Detailed References

- [Wallet Patterns](./wallet-patterns.md) — Multi-wallet, WalletConnect, disconnection
