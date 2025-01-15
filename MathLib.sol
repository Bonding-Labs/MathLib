// SPDX-License-Identifier: UNLICENCED
// Copyright: Bonding Labs - Begic Nedim

pragma solidity ^0.8.0;

/**
 * @title MathLib
 * @notice Provides approximate log(1+x) and exp(x/1e18) for small x, reverts if out of range.
 */
library MathLib {
    /**
     * @notice log1p(x) ~ x - x^2/2 for x < 1e14 (in 1e18 scale).
     *         Reverts if x >= 1e14 to prevent inaccurate expansions.
     */
    function log1p(uint256 x) internal pure returns (uint256) {
        require(x < 1e14, "x too large for log");
        // x^2 in 1e36 scale, then /1e18 => back to 1e18
        uint256 x2 = (x * x) / 1e18;
        // Approx: log(1+x) ~ x - x^2/2
        return x - (x2 / 2);
    }

    /**
     * @notice expWad(x) ~ 1 + x + x^2/2 for |x| < 1e16, in 1e18 scale
     *         Reverts if x not in the (-1e16, +1e16) domain.
     */
    function expWad(int256 x) internal pure returns (uint256) {
        require(x > -1e16 && x < 1e16, "x out of range");
        uint256 one = 1e18;
        // take absolute
        uint256 xx = x >= 0 ? uint256(x) : uint256(-x);
        // x^2 in 1e36, /1e18 => 1e18 scale
        uint256 x2 = (xx * xx) / 1e18;
        uint256 halfx2 = x2 / 2;
        if (x >= 0) {
            // e^x ~ 1 + x + x^2/2
            return one + xx + halfx2;
        } else {
            // e^-x ~ 1 - x + x^2/2
            return one - xx + halfx2;
        }
    }
}
