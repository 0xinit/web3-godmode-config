---
name: web3-hardhat
description: Hardhat toolchain reference for Solidity development. Use when working with hardhat.config.ts, ethers.js testing, deployment scripts, or Hardhat plugins. Covers configuration, testing, deployment, and common plugins.
---

# Hardhat Toolchain Reference

## Core Commands

```bash
npx hardhat compile            # Compile contracts
npx hardhat test               # Run tests
npx hardhat test --grep "mint" # Filter tests
npx hardhat node               # Local node
npx hardhat run scripts/deploy.ts --network sepolia  # Deploy
npx hardhat verify --network mainnet ADDR arg1 arg2  # Verify
npx hardhat coverage           # Test coverage
npx hardhat clean              # Clean artifacts
```

## Configuration

### hardhat.config.ts
```typescript
import { HardhatUserConfig } from "hardhat/config"
import "@nomicfoundation/hardhat-toolbox" // ethers, chai, coverage, gas, typechain, verify
import "hardhat-deploy" // optional: deployment management

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.28",
    settings: {
      optimizer: { enabled: true, runs: 200 },
      viaIR: false,
    },
  },
  networks: {
    hardhat: {
      forking: {
        url: process.env.ETH_RPC_URL || "",
        enabled: !!process.env.FORK,
      },
    },
    mainnet: {
      url: process.env.ETH_RPC_URL || "",
      accounts: process.env.DEPLOYER_KEY ? [process.env.DEPLOYER_KEY] : [],
    },
    base: {
      url: process.env.BASE_RPC_URL || "https://mainnet.base.org",
      accounts: process.env.DEPLOYER_KEY ? [process.env.DEPLOYER_KEY] : [],
    },
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL || "",
      accounts: process.env.DEPLOYER_KEY ? [process.env.DEPLOYER_KEY] : [],
    },
  },
  etherscan: {
    apiKey: {
      mainnet: process.env.ETHERSCAN_API_KEY || "",
      base: process.env.BASESCAN_API_KEY || "",
    },
  },
}

export default config
```

## Testing (ethers.js + chai)

### Basic Test
```typescript
import { expect } from "chai"
import { ethers } from "hardhat"
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers"

describe("MyToken", function () {
  async function deployFixture() {
    const [owner, alice, bob] = await ethers.getSigners()
    const Token = await ethers.getContractFactory("MyToken")
    const token = await Token.deploy("MyToken", "MTK")
    return { token, owner, alice, bob }
  }

  it("should mint tokens", async function () {
    const { token, alice } = await loadFixture(deployFixture)
    await token.connect(alice).mint(100)
    expect(await token.balanceOf(alice.address)).to.equal(100)
  })
})
```

### Fixtures (loadFixture)
- Snapshot and revert between tests — much faster than redeploying
- Always use `loadFixture` over `beforeEach` for deployment

### Time Manipulation
```typescript
import { time } from "@nomicfoundation/hardhat-toolbox/network-helpers"

await time.increase(3600)          // Advance 1 hour
await time.increaseTo(timestamp)   // Set to specific time
await time.latest()                // Get current block timestamp
```

### Event Testing
```typescript
await expect(token.transfer(alice.address, 100))
  .to.emit(token, "Transfer")
  .withArgs(owner.address, alice.address, 100)
```

### Revert Testing
```typescript
await expect(token.connect(alice).adminMint(100))
  .to.be.revertedWithCustomError(token, "OwnableUnauthorizedAccount")
  .withArgs(alice.address)
```

## Deployment

### Using Hardhat Ignition (recommended)
```typescript
// ignition/modules/MyToken.ts
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules"

export default buildModule("MyToken", (m) => {
  const token = m.contract("MyToken", ["MyToken", "MTK"])
  return { token }
})
```

```bash
npx hardhat ignition deploy ignition/modules/MyToken.ts --network sepolia
```

### Using Scripts
```typescript
// scripts/deploy.ts
import { ethers } from "hardhat"

async function main() {
  const Token = await ethers.getContractFactory("MyToken")
  const token = await Token.deploy("MyToken", "MTK")
  await token.waitForDeployment()
  console.log("Deployed to:", await token.getAddress())
}

main().catch(console.error)
```

## Common Plugins

| Plugin | Purpose |
|--------|---------|
| `@nomicfoundation/hardhat-toolbox` | All-in-one (ethers, chai, coverage, etc.) |
| `@nomicfoundation/hardhat-verify` | Contract verification |
| `hardhat-deploy` | Deployment management |
| `hardhat-gas-reporter` | Gas usage per function |
| `@typechain/hardhat` | TypeScript types for contracts |
| `solidity-coverage` | Test coverage |

## Hardhat vs Foundry

| Feature | Hardhat | Foundry |
|---------|---------|---------|
| Language | TypeScript | Solidity |
| Speed | Slower | Much faster |
| Ecosystem | Larger plugin ecosystem | Growing |
| Testing | JS/TS tests | Solidity tests |
| Fuzzing | Limited | Built-in |
| Debugging | console.log | Traces + console.log |
| Best for | JS/TS teams, complex deploy | Performance, Solidity-native |

Many projects use both: Foundry for testing, Hardhat for deployment/scripts.
