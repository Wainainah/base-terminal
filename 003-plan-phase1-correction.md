# Phase 1: Remediation & Implementation Plan - Reverse Dutch Auction

## 1. The Pivot: Reverse Dutch Auction
We are correcting the core mechanic from a "Timer Reset Pot" to a **Reverse Dutch Auction**.
- **Goal:** Users bid to "win" the round.
- **Mechanism:** Price decays over time. First to pay the current price wins.
- **Loop:** Winning triggers a reset for the next round.

## 2. The Math: Linear Price Decay
We need a gas-efficient way to calculate the current price based on `block.timestamp`.

**Formula:**
$$ P(t) = P_{start} - \frac{(P_{start} - P_{reserve}) \times (t - t_{start})}{D} $$

Where:
- $P(t)$: Current Price
- $P_{start}$: `START_PRICE` (e.g., 0.01 ETH)
- $P_{reserve}$: `RESERVE_PRICE` (e.g., 0.0001 ETH)
- $t$: `block.timestamp`
- $t_{start}$: `currentRoundStart` (State Variable)
- $D$: `DURATION` (e.g., 60 minutes)

**Solidity Implementation:**
```solidity
function getCurrentPrice() public view returns (uint256) {
    uint256 elapsed = block.timestamp - currentRoundStart;
    if (elapsed >= DURATION) {
        return RESERVE_PRICE;
    }
    
    uint256 totalDrop = START_PRICE - RESERVE_PRICE;
    uint256 currentDrop = (totalDrop * elapsed) / DURATION;
    
    return START_PRICE - currentDrop;
}
```

## 3. The State
We will strip the "extension" logic and focus on the auction loop.

**Storage:**
```solidity
// Auction State
uint256 public currentRoundStart;
uint256 public roundId; // Track how many rounds have passed

// Constants (Tunable)
uint256 public constant DURATION = 15 minutes; 
uint256 public constant START_PRICE = 0.01 ether;
uint256 public constant RESERVE_PRICE = 0.0001 ether;
```

**Removed:**
- `timeRemaining` (No extensions)
- `potBalance` (Funds are settled immediately or sent to treasury)
- `currentLeader` (Instant win, no leader holding the hill)

## 4. The Hook: BlobKit & Events
**Requirement:** Capture the win event *without* expensive storage arrays.
**Solution:** Use standard EVM Events. Indexers (like BlobKit) will reconstruct the history off-chain.

**BlobKitEHoF.sol (Revised):**
Instead of storing `Winner[]`, we simply define the event standard.

```solidity
interface IBlobKitEHoF {
    event RoundWon(
        uint256 indexed roundId, 
        address indexed winner, 
        uint256 pricePaid, 
        uint256 timestamp
    );
}
```

**BaseTerminal.sol Integration:**
```solidity
function buy() external payable {
    uint256 price = getCurrentPrice();
    if (msg.value < price) revert InsufficientPayment();
    
    // 1. Handle Payment (Send to Treasury/Owner)
    // payable(owner()).transfer(msg.value); 
    
    // 2. Emit Win Event (The "Blob")
    emit RoundWon(roundId, msg.sender, msg.value, block.timestamp);
    
    // 3. Reset for Next Round
    roundId++;
    currentRoundStart = block.timestamp;
}
```

## 5. Verification Plan
1.  **Unit Test:** Verify `getCurrentPrice()` returns `START_PRICE` at $t=0$ and `RESERVE_PRICE` at $t=D$.
2.  **Integration:** Verify `buy()` fails if `msg.value` is too low.
3.  **Loop:** Verify `buy()` resets `currentRoundStart` and increments `roundId`.
