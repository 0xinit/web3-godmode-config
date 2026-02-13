# Web3 Wallet Patterns

## Multi-Wallet Support

### Supported Wallet Categories
| Category | Examples | Library |
|----------|----------|---------|
| Browser Extension | MetaMask, Rabby, Coinbase | wagmi connectors |
| Mobile | Trust, Rainbow | WalletConnect v2 |
| Hardware | Ledger, Trezor | wagmi connectors |
| Smart Wallet | Safe, Coinbase Smart Wallet | EIP-4337 compatible |
| Embedded | Privy, Dynamic, Web3Auth | SDK-specific |

### wagmi Multi-Connector Setup
```typescript
import { injected, walletConnect, coinbaseWallet } from "wagmi/connectors"

const config = createConfig({
  chains: [mainnet, base],
  connectors: [
    injected(),                          // MetaMask, Rabby, etc.
    walletConnect({ projectId }),         // WalletConnect v2
    coinbaseWallet({ appName: "MyApp" }), // Coinbase
  ],
  transports: {
    [mainnet.id]: http(),
    [base.id]: http(),
  },
})
```

## WalletConnect v2

### Setup
```typescript
import { walletConnect } from "wagmi/connectors"

const wc = walletConnect({
  projectId: process.env.NEXT_PUBLIC_WC_PROJECT_ID!,
  metadata: {
    name: "My dApp",
    description: "My dApp description",
    url: "https://mydapp.com",
    icons: ["https://mydapp.com/icon.png"],
  },
  showQrModal: true,
})
```

### Required
- WalletConnect Cloud project ID (free at cloud.walletconnect.com)
- HTTPS in production (required for secure pairing)

## Disconnection Handling

### Graceful Disconnect
```typescript
import { useAccount, useDisconnect } from "wagmi"

function WalletStatus() {
  const { address, isConnected, isReconnecting } = useAccount()
  const { disconnect } = useDisconnect()

  // Handle reconnection state (page refresh)
  if (isReconnecting) return <Spinner />

  // Clear local state on disconnect
  const handleDisconnect = () => {
    disconnect()
    // Clear any cached user data
    queryClient.clear()
    // Reset app state
    resetAppState()
  }
}
```

### Auto-Disconnect Detection
```typescript
useEffect(() => {
  // Listen for account/chain changes from wallet
  if (window.ethereum) {
    window.ethereum.on("accountsChanged", (accounts: string[]) => {
      if (accounts.length === 0) {
        // User disconnected from wallet
        disconnect()
      }
    })

    window.ethereum.on("chainChanged", () => {
      // Full page reload on chain change (recommended by MetaMask)
      window.location.reload()
    })
  }
}, [])
```

## Session Persistence

### wagmi Handles This
```typescript
// wagmi auto-persists connection via localStorage
// On page refresh, it reconnects automatically
// Use `reconnect` from config if needed manually
```

### Custom Session Management
```typescript
// For embedded wallets (Privy, etc.)
// Session tokens are managed by the SDK
// Always check auth state on mount
useEffect(() => {
  const checkSession = async () => {
    const isValid = await authProvider.checkSession()
    if (!isValid) {
      router.push("/login")
    }
  }
  checkSession()
}, [])
```

## Network Mismatch Detection

```typescript
function useNetworkGuard(requiredChainId: number) {
  const { chain } = useAccount()
  const { switchChain } = useSwitchChain()

  const isWrongNetwork = chain?.id !== requiredChainId

  return {
    isWrongNetwork,
    switchToCorrectNetwork: () => switchChain({ chainId: requiredChainId }),
    currentChain: chain,
  }
}

// Usage in components
function MintButton() {
  const { isWrongNetwork, switchToCorrectNetwork } = useNetworkGuard(8453) // Base

  if (isWrongNetwork) {
    return <button onClick={switchToCorrectNetwork}>Switch to Base</button>
  }

  return <button onClick={handleMint}>Mint</button>
}
```

## Mobile Deep Linking

```typescript
// WalletConnect v2 handles deep linking automatically
// For custom deep links:
function openInWallet(uri: string) {
  const isIOS = /iPhone|iPad/.test(navigator.userAgent)
  const isAndroid = /Android/.test(navigator.userAgent)

  if (isIOS) {
    // iOS universal links
    window.location.href = `metamask://wc?uri=${encodeURIComponent(uri)}`
  } else if (isAndroid) {
    // Android intent
    window.location.href = `metamask://wc?uri=${encodeURIComponent(uri)}`
  }
}
```

## Security Considerations

- Always verify the connected chain before transactions
- Display transaction details clearly before signing
- Show token approvals with clear unlimited/limited distinction
- Warn users about signing messages (EIP-712 typed data)
- Never store private keys or seed phrases in frontend code
- Use simulation (eth_call) before sending transactions
- Validate contract addresses against known deployments
