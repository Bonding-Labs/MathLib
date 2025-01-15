```md
# MathLib Library Explanation

This **Solidity library** provides **approximate** implementations of:

1. \( \log(1 + x) \) for small \( x \) (in 1e18 fixed-point).
2. \( \exp(x / 1e18) \) for small \( x \) (in 1e18 fixed-point).

It imposes **range restrictions** to ensure numerical accuracy and will revert if inputs exceed those ranges.

---

## 1. Overview

- **Fixed-Point Math**: All calculations assume **1e18** scale, meaning 1 represents 1.0 in typical decimal notation.
- **Safe Approximations**:  
  - `log1p(x)` is approximated using the first two terms of its Taylor series expansion:  
    \[
      \log(1 + x) \approx x - \frac{x^2}{2}.
    \]
  - `expWad(x)` is approximated by the first three terms of the Taylor series for \(e^x\) or \(e^{-x}\):
    \[
      e^x \approx 1 + x + \frac{x^2}{2}, \quad |x| < 1e16.
    \]

- **Why Approximations?**  
  Full, high-precision log/exp in Solidity is expensive and complex. This library trades off precision for gas efficiency and simplicity—**so long as `x` remains small**.

---

## 2. `log1p(uint256 x)`

### Signature

```solidity
function log1p(uint256 x) internal pure returns (uint256);
```

### Logic

1. **Require**: `x < 1e14`  
   - If `x >= 1e14`, it reverts:  
     ```solidity
     require(x < 1e14, "x too large for log");
     ```
   - This ensures the approximation is valid for small \(x\).

2. **Taylor Expansion**:  
   \[
     \log(1 + x) \approx x - \frac{x^2}{2}
   \]
   - In 1e18 format, `x^2` is in 1e36, so we divide by 1e18 to get back to 1e18 scale.
   - The final result is in 1e18 scale.

#### Example

If `x = 1e13 (0.00001)`, then:
- \(x^2 / 1e18 = 1e26 / 1e18 = 1e8\)  
- \(\log1p(x) \approx x - x^2/2\)

---

## 3. `expWad(int256 x)`

### Signature

```solidity
function expWad(int256 x) internal pure returns (uint256);
```

### Logic

1. **Require**: `x > -1e16 && x < 1e16`  
   - If `x` is outside \((-1e16, +1e16)\), it reverts:
     ```solidity
     require(x > -1e16 && x < 1e16, "x out of range");
     ```
   - Keeps the approximation accurate for small `|x|`.

2. **Taylor Expansion**:  
   - For **`x >= 0`**:  
     \[
       e^x \approx 1 + x + \frac{x^2}{2}
     \]
   - For **`x < 0`**:  
     \[
       e^{-x} \approx 1 - x + \frac{x^2}{2}
     \]
   - Again, in **1e18** precision:
     - Compute `x^2` in 1e36.
     - Divide by 1e18 to return to 1e18 scale.
     - Add or subtract from `1e18` as needed.

#### Example

If `x = 5e15` (which is 0.005 in decimal):
- \(x^2 / 1e18 = (5e15)^2 / 1e18 = 25e30 / 1e18 = 25e12 = 2.5e13\)
- \(e^x \approx 1e18 + 5e15 + (2.5e13 / 2)\)

---

## 4. Use Cases

- **Bonding Curves**: Quickly approximate log/exp calculations for smaller inputs without heavy computational cost.
- **Financial Math**: Potentially used in interest calculations, growth rates, or other **DeFi** contexts, provided the input domain is kept small.
- **Gas-Efficient**: By truncating to a few terms of the Taylor series, the code remains cheaper on gas versus full-blown arbitrary-precision methods.

---

## 5. Summary

**MathLib** provides:
- **`log1p(x)`**: Approximates \(\log(1 + x)\) for `x < 1e14`, ensuring the series expansion is valid and reverts otherwise.
- **`expWad(x)`**: Approximates \(\exp(x)\) (or \(\exp(-x)\)) for `|x| < 1e16`, returning results in 1e18 fixed-point.

Both functions revert for inputs outside their intended “small range” to avoid large errors. This makes **MathLib** suitable for use in **contracts that only deal with moderate log/exp** calculations, such as certain **DeFi** or token bonding curve scenarios where the values don’t exceed the specified domains.
```
