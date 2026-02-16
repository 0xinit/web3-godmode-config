# Order Patterns

All orders on Polymarket are expressed as limit orders. Market orders are limit orders with a marketable price that execute immediately.

## Order Types

| Type | Behavior | Use Case |
|------|----------|----------|
| **GTC** | Good-Til-Cancelled — rests on book until filled or cancelled | Default for limit orders |
| **GTD** | Good-Til-Date — active until expiration timestamp (UTC seconds) | Auto-expire before known events |
| **FOK** | Fill-Or-Kill — fill entirely immediately or cancel | All-or-nothing market orders |
| **FAK** | Fill-And-Kill — fill what's available, cancel rest | Partial-fill market orders |

## Tick Sizes

Price must conform to the market's tick size or the order is rejected.

| Tick Size | Precision | Example Prices |
|-----------|-----------|----------------|
| `0.1` | 1 decimal | 0.1, 0.2, 0.5 |
| `0.01` | 2 decimals | 0.01, 0.50, 0.99 |
| `0.001` | 3 decimals | 0.001, 0.500, 0.999 |
| `0.0001` | 4 decimals | 0.0001, 0.5000, 0.9999 |

Get tick size: `client.getTickSize(tokenID)` (TS) / `client.get_tick_size(token_id)` (Python). Also available as `minimum_tick_size` on market objects.

## Limit Order (GTC)

```typescript
// TypeScript — one-step
const response = await client.createAndPostOrder(
  { tokenID: "TOKEN_ID", price: 0.50, size: 10, side: Side.BUY },
  { tickSize: "0.01", negRisk: false },
  OrderType.GTC
);
```

```python
# Python — one-step
response = client.create_and_post_order(
    OrderArgs(token_id="TOKEN_ID", price=0.50, size=10, side=BUY),
    options={"tick_size": "0.01", "neg_risk": False},
    order_type=OrderType.GTC,
)
```

### Two-step (sign then submit)

```typescript
// TypeScript
const signedOrder = await client.createOrder(
  { tokenID: "TOKEN_ID", price: 0.50, size: 10, side: Side.BUY },
  { tickSize: "0.01", negRisk: false }
);
const response = await client.postOrder(signedOrder, OrderType.GTC);
```

```python
# Python
signed_order = client.create_order(
    OrderArgs(token_id="TOKEN_ID", price=0.50, size=10, side=BUY),
    options={"tick_size": "0.01", "neg_risk": False},
)
response = client.post_order(signed_order, OrderType.GTC)
```

## Market Order (FOK / FAK)

- **BUY**: `amount` = dollar amount to spend
- **SELL**: `amount` = number of shares to sell
- `price` = worst-price limit (slippage protection), not target execution price

```typescript
// TypeScript — FOK BUY: spend exactly $100 or cancel
const buyOrder = await client.createMarketOrder(
  { tokenID: "TOKEN_ID", side: Side.BUY, amount: 100, price: 0.50 },
  { tickSize: "0.01", negRisk: false }
);
await client.postOrder(buyOrder, OrderType.FOK);

// One-step convenience
const response = await client.createAndPostMarketOrder(
  { tokenID: "TOKEN_ID", side: Side.BUY, amount: 100, price: 0.50 },
  { tickSize: "0.01", negRisk: false },
  OrderType.FOK
);
```

```python
# Python — FOK BUY
buy_order = client.create_market_order(
    token_id="TOKEN_ID", side=BUY, amount=100, price=0.50,
    options={"tick_size": "0.01", "neg_risk": False},
)
client.post_order(buy_order, OrderType.FOK)
```

## GTD Order (Expiring)

Expiration = UTC seconds timestamp. Security threshold: add 60 seconds minimum.

**Effective lifetime of N seconds: `now + 60 + N`**

```typescript
// TypeScript — expire in 1 hour
const expiration = Math.floor(Date.now() / 1000) + 60 + 3600;

const response = await client.createAndPostOrder(
  { tokenID: "TOKEN_ID", price: 0.50, size: 10, side: Side.BUY, expiration },
  { tickSize: "0.01", negRisk: false },
  OrderType.GTD
);
```

```python
# Python — expire in 1 hour
import time
expiration = int(time.time()) + 60 + 3600

response = client.create_and_post_order(
    OrderArgs(token_id="TOKEN_ID", price=0.50, size=10, side=BUY, expiration=expiration),
    options={"tick_size": "0.01", "neg_risk": False},
    order_type=OrderType.GTD,
)
```

## Post-Only Orders

Guarantee maker status. If order would cross spread, it's rejected (not executed).

```typescript
// TypeScript
const response = await client.postOrder(signedOrder, OrderType.GTC, true);
```

```python
# Python
response = client.post_order(signed_order, OrderType.GTC, post_only=True)
```

- Only works with GTC and GTD
- Rejected if combined with FOK or FAK

## Batch Orders

Up to **15 orders** in a single request.

```typescript
// TypeScript
const orders: PostOrdersArgs[] = [
  {
    order: await client.createOrder(
      { tokenID: "TOKEN_ID", price: 0.48, side: Side.BUY, size: 500 },
      { tickSize: "0.01", negRisk: false }
    ),
    orderType: OrderType.GTC,
  },
  {
    order: await client.createOrder(
      { tokenID: "TOKEN_ID", price: 0.52, side: Side.SELL, size: 500 },
      { tickSize: "0.01", negRisk: false }
    ),
    orderType: OrderType.GTC,
  },
];
const response = await client.postOrders(orders);
```

```python
# Python
response = client.post_orders([
    PostOrdersArgs(
        order=client.create_order(
            OrderArgs(price=0.48, size=500, side=BUY, token_id="TOKEN_ID"),
            options={"tick_size": "0.01", "neg_risk": False},
        ),
        orderType=OrderType.GTC,
    ),
    PostOrdersArgs(
        order=client.create_order(
            OrderArgs(price=0.52, size=500, side=SELL, token_id="TOKEN_ID"),
            options={"tick_size": "0.01", "neg_risk": False},
        ),
        orderType=OrderType.GTC,
    ),
])
```

## Cancel Orders

All cancel endpoints require L2 authentication.

```typescript
// TypeScript
await client.cancelOrder("0xORDER_ID");                          // single
await client.cancelOrders(["0xID_1", "0xID_2"]);                 // multiple
await client.cancelAll();                                         // all orders
await client.cancelMarketOrders({ market: "0xCONDITION_ID" });  // by market
await client.cancelMarketOrders({                                 // by token
  market: "0xCONDITION_ID",
  asset_id: "TOKEN_ID",
});
```

```python
# Python
client.cancel(order_id="0xORDER_ID")
client.cancel_orders(["0xID_1", "0xID_2"])
client.cancel_all()
client.cancel_market_orders(market="0xCONDITION_ID")
```

### Onchain Cancellation (fallback)

If the API is unavailable, cancel directly on the Exchange contract by calling `cancelOrder(Order order)` onchain with the full signed order struct.

- Standard markets: CTF Exchange at `0x4bFb41d5B3570DeFd03C39a9A4D8dE6Bd8B8982E`
- Neg risk markets: Neg Risk CTF Exchange at `0xC5d563A36AE78145C45a50134d48A1215220f80a`

## Heartbeat

If heartbeat not received within **10 seconds** (5s buffer), **all open orders are cancelled**.

```typescript
// TypeScript
let heartbeatId = "";
setInterval(async () => {
  const resp = await client.postHeartbeat(heartbeatId);
  heartbeatId = resp.heartbeat_id;
}, 5000);
```

```python
# Python
import time
heartbeat_id = ""
while True:
    resp = client.post_heartbeat(heartbeat_id)
    heartbeat_id = resp["heartbeat_id"]
    time.sleep(5)
```

- First request: use empty string for `heartbeat_id`
- If expired ID: server returns `400` with correct ID — update and retry

## Error Codes

| Error | Description |
|-------|-------------|
| `INVALID_ORDER_MIN_TICK_SIZE` | Price doesn't conform to market tick size |
| `INVALID_ORDER_MIN_SIZE` | Size below minimum threshold |
| `INVALID_ORDER_DUPLICATED` | Identical order already placed |
| `INVALID_ORDER_NOT_ENOUGH_BALANCE` | Insufficient balance or allowance |
| `INVALID_ORDER_EXPIRATION` | Expiration in the past |
| `INVALID_POST_ONLY_ORDER_TYPE` | Post-only with FOK/FAK |
| `INVALID_POST_ONLY_ORDER` | Post-only would cross book |
| `FOK_ORDER_NOT_FILLED_ERROR` | FOK couldn't be fully filled |
| `EXECUTION_ERROR` | System error executing trade |
| `ORDER_DELAYED` | Delayed due to market conditions |
| `MARKET_NOT_READY` | Market not accepting orders |

## Insert Statuses

| Status | Description |
|--------|-------------|
| `live` | Resting on the book |
| `matched` | Matched immediately |
| `delayed` | Marketable but subject to matching delay |
| `unmatched` | Marketable but failed to delay — placement still successful |

## Trade Statuses

```
MATCHED → MINED → CONFIRMED
    ↓        ↑
RETRYING ───┘
    ↓
  FAILED
```

| Status | Terminal | Description |
|--------|----------|-------------|
| `MATCHED` | No | Sent to executor for onchain submission |
| `MINED` | No | Mined on chain, no finality yet |
| `CONFIRMED` | Yes | Finalized — trade successful |
| `RETRYING` | No | Failed, being resubmitted |
| `FAILED` | Yes | Permanently failed |

## Prerequisites

Before placing orders, the funder address must approve the Exchange contract:
- **BUY**: USDCe allowance >= spending amount
- **SELL**: conditional token allowance >= selling amount

Max order size = `balance - sum(openOrderSize - filledAmount)`

## Sports Markets

- Outstanding limit orders auto-cancelled when game begins
- Marketable orders have 3-second placement delay
- Game start times can shift — monitor accordingly
