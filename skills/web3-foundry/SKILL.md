---
name: web3-foundry
description: Foundry toolchain reference for Solidity development. Use when working with forge, cast, anvil, or chisel. Covers building, testing (unit, fuzz, invariant, fork), deployment, and verification.
---

# Foundry Toolchain Reference

## Core Commands

| Tool | Purpose |
|------|---------|
| `forge` | Build, test, deploy, verify |
| `cast` | Interact with contracts, encode/decode |
| `anvil` | Local Ethereum node |
| `chisel` | Solidity REPL |

## forge — Build & Test

```bash
forge build                          # Compile
forge test                           # Run all tests
forge test -vvvv                     # Max verbosity (traces)
forge test --match-test testMint     # Run specific test
forge test --match-contract MintTest # Run specific contract
forge test --gas-report              # Gas usage report
forge coverage                       # Test coverage
forge snapshot                       # Gas snapshot
forge inspect Contract storage-layout # Storage layout
forge inspect Contract methods        # Function selectors
```

## Testing Patterns

### Unit Test
```solidity
function test_Mint() public {
    uint256 balBefore = token.balanceOf(alice);
    vm.prank(alice);
    token.mint(100);
    assertEq(token.balanceOf(alice), balBefore + 100);
}
```

### setUp Pattern
```solidity
function setUp() public {
    token = new MyToken();
    alice = makeAddr("alice");
    vm.deal(alice, 10 ether);
}
```

### Fuzz Testing
```solidity
function testFuzz_Transfer(uint256 amount) public {
    amount = bound(amount, 1, token.balanceOf(alice));
    vm.prank(alice);
    token.transfer(bob, amount);
    assertEq(token.balanceOf(bob), amount);
}
```

### Fork Testing
```bash
forge test --fork-url $ETH_RPC_URL                    # Fork mainnet
forge test --fork-url $ETH_RPC_URL --fork-block-number 19000000  # Pinned block
```

```solidity
function test_SwapOnUniswap() public {
    // Test against real mainnet state
    vm.createSelectFork("mainnet");
    // ... interact with deployed contracts
}
```

### Invariant Testing
```solidity
function invariant_totalSupply() public {
    assertEq(token.totalSupply(), handler.ghost_mintedTotal() - handler.ghost_burnedTotal());
}
```

## Key Cheatcodes

| Cheatcode | Purpose |
|-----------|---------|
| `vm.prank(addr)` | Next call from `addr` |
| `vm.startPrank(addr)` | All calls from `addr` until `stopPrank` |
| `vm.deal(addr, amount)` | Set ETH balance |
| `vm.warp(timestamp)` | Set `block.timestamp` |
| `vm.roll(blockNum)` | Set `block.number` |
| `vm.expectRevert(selector)` | Expect next call to revert |
| `vm.expectEmit(true,true,false,true)` | Expect event |
| `vm.mockCall(addr, data, returnData)` | Mock external call |
| `vm.label(addr, "name")` | Label address in traces |
| `makeAddr("name")` | Deterministic address |
| `vm.envUint("VAR")` | Read env variable |

## Deployment

### Script Pattern
```solidity
// script/Deploy.s.sol
contract DeployScript is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("DEPLOYER_KEY");
        vm.startBroadcast(deployerKey);

        MyContract c = new MyContract(arg1, arg2);
        console.log("Deployed to:", address(c));

        vm.stopBroadcast();
    }
}
```

```bash
# Simulate (no broadcast)
forge script script/Deploy.s.sol --rpc-url $RPC_URL

# Deploy
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast

# Deploy + verify
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast --verify
```

## cast — Contract Interaction

```bash
# Read contract
cast call $ADDR "balanceOf(address)" $USER --rpc-url $RPC

# Write (send tx)
cast send $ADDR "transfer(address,uint256)" $TO $AMOUNT --private-key $KEY --rpc-url $RPC

# Encode calldata
cast calldata "transfer(address,uint256)" $TO $AMOUNT

# Decode calldata
cast 4byte-decode 0xa9059cbb...

# ABI encode
cast abi-encode "constructor(string,string)" "MyToken" "MTK"

# Read storage slot
cast storage $ADDR 0 --rpc-url $RPC

# Get block info
cast block latest --rpc-url $RPC

# Convert units
cast to-wei 1.5 ether    # 1500000000000000000
cast from-wei 1000000000000000000  # 1.0
```

## anvil — Local Node

```bash
anvil                              # Start local node
anvil --fork-url $ETH_RPC_URL      # Fork mainnet
anvil --fork-url $URL --fork-block-number 19000000  # Pinned fork

# Impersonate account
cast rpc anvil_impersonateAccount $WHALE_ADDR
cast send --from $WHALE_ADDR $TOKEN "transfer(address,uint256)" $ME $AMOUNT --unlocked
```
