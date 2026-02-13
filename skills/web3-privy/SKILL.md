---
name: web3-privy
description: Privy authentication SDK patterns for web3 apps. Use when implementing wallet-based auth, embedded wallets, social login, or server-side verification with Privy. Covers PrivyProvider setup, auth methods, embedded wallets, and wagmi integration.
---

# Privy SDK Patterns

## Setup (React)

```typescript
import { PrivyProvider } from "@privy-io/react-auth"

function App() {
  return (
    <PrivyProvider
      appId={process.env.NEXT_PUBLIC_PRIVY_APP_ID!}
      config={{
        loginMethods: ["email", "wallet", "google", "twitter"],
        appearance: {
          theme: "dark",
          accentColor: "#6366f1",
        },
        embeddedWallets: {
          createOnLogin: "users-without-wallets",
        },
        defaultChain: base,
        supportedChains: [mainnet, base, arbitrum],
      }}
    >
      {children}
    </PrivyProvider>
  )
}
```

## Authentication

### Login/Logout
```typescript
import { usePrivy } from "@privy-io/react-auth"

function AuthButton() {
  const { login, logout, authenticated, user, ready } = usePrivy()

  if (!ready) return <Spinner />

  if (!authenticated) {
    return <button onClick={login}>Sign In</button>
  }

  return (
    <div>
      <p>{user?.email?.address || user?.wallet?.address}</p>
      <button onClick={logout}>Sign Out</button>
    </div>
  )
}
```

### Auth Methods
| Method | Config Key | User Property |
|--------|-----------|---------------|
| Email | `"email"` | `user.email.address` |
| Wallet | `"wallet"` | `user.wallet.address` |
| Google | `"google"` | `user.google.email` |
| Twitter | `"twitter"` | `user.twitter.username` |
| Discord | `"discord"` | `user.discord.username` |
| Farcaster | `"farcaster"` | `user.farcaster.fid` |
| Passkey | `"passkey"` | `user.passkey` |

### User Object
```typescript
const { user } = usePrivy()

// Linked accounts
const email = user?.email?.address
const walletAddress = user?.wallet?.address
const linkedAccounts = user?.linkedAccounts // all linked methods
```

## Embedded Wallets

```typescript
import { usePrivy, useWallets } from "@privy-io/react-auth"

function WalletActions() {
  const { wallets } = useWallets()

  // Find embedded wallet
  const embeddedWallet = wallets.find((w) => w.walletClientType === "privy")

  // Get provider for transactions
  const provider = await embeddedWallet?.getEthereumProvider()

  // Send transaction
  const txHash = await provider?.request({
    method: "eth_sendTransaction",
    params: [{
      to: recipientAddress,
      value: "0x" + parseEther("0.01").toString(16),
    }],
  })
}
```

## wagmi Integration

```typescript
import { PrivyProvider } from "@privy-io/react-auth"
import { WagmiProvider, createConfig } from "@privy-io/wagmi"

// Privy provides its own wagmi config wrapper
import { createConfig as createPrivyWagmiConfig } from "@privy-io/wagmi"

const config = createPrivyWagmiConfig({
  chains: [mainnet, base],
  transports: {
    [mainnet.id]: http(),
    [base.id]: http(),
  },
})

function App() {
  return (
    <PrivyProvider appId={appId}>
      <WagmiProvider config={config}>
        <QueryClientProvider client={queryClient}>
          {children}
        </QueryClientProvider>
      </WagmiProvider>
    </PrivyProvider>
  )
}

// Then use standard wagmi hooks
import { useAccount, useBalance, useSendTransaction } from "wagmi"
```

## Server-Side Verification

```typescript
import { PrivyClient } from "@privy-io/server-auth"

const privy = new PrivyClient(
  process.env.PRIVY_APP_ID!,
  process.env.PRIVY_APP_SECRET!,
)

// Verify auth token (API route / middleware)
async function verifyAuth(req: Request) {
  const token = req.headers.get("authorization")?.replace("Bearer ", "")
  if (!token) throw new Error("No token")

  const { userId } = await privy.verifyAuthToken(token)
  return userId
}

// Get user by ID
const user = await privy.getUser(userId)
```

## Multi-Chain Wallet Support

```typescript
// Privy supports both EVM and Solana wallets
const config = {
  embeddedWallets: {
    createOnLogin: "users-without-wallets",
    // Solana embedded wallets
    solana: { createOnLogin: "users-without-wallets" },
  },
  supportedChains: [mainnet, base, arbitrum, polygon],
}

// Access Solana wallet
import { useSolanaWallets } from "@privy-io/react-auth/solana"
const { wallets: solanaWallets } = useSolanaWallets()
```

## Common Patterns

### Protected Routes
```typescript
function ProtectedPage() {
  const { ready, authenticated } = usePrivy()

  if (!ready) return <Loading />
  if (!authenticated) return <Redirect to="/login" />

  return <Dashboard />
}
```

### Link Additional Accounts
```typescript
const { linkEmail, linkWallet, linkGoogle } = usePrivy()

// User can link multiple auth methods to one account
await linkEmail() // Opens email verification flow
await linkWallet() // Opens wallet connection
```
