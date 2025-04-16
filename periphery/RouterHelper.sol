// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IRouter.sol";
import "../interfaces/IERC20.sol";

// Helper contract for common DEX operations
contract RouterHelper {
    IRouter public immutable router;
    address public immutable WETH;
    
    constructor(address _router) {
        router = IRouter(_router);
        WETH = router.WETH();
    }
    
    // Swap exact ETH for tokens with slippage protection
    function swapExactETHForTokensWithSlippage(
        address tokenOut,
        uint slippagePercent,
        address to,
        uint deadline
    ) external payable returns (uint amountOut) {
        require(slippagePercent <= 100, "Slippage too high");
        
        // Create path
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = tokenOut;
        
        // Get expected amount out
        uint[] memory amounts = router.getAmountsOut(msg.value, path);
        uint expectedOut = amounts[1];
        
        // Calculate minimum amount with slippage
        uint minAmountOut = expectedOut * (100 - slippagePercent) / 100;
        
        // Execute swap
        amounts = router.swapExactETHForTokens{value: msg.value}(
            minAmountOut,
            path,
            to,
            deadline
        );
        
        return amounts[1];
    }
    
    // Swap exact tokens for ETH with slippage protection
    function swapExactTokensForETHWithSlippage(
        address tokenIn,
        uint amountIn,
        uint slippagePercent,
        address to,
        uint deadline
    ) external returns (uint amountOut) {
        require(slippagePercent <= 100, "Slippage too high");
        
        // Create path
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = WETH;
        
        // Approve router to spend tokens
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenIn).approve(address(router), amountIn);
        
        // Get expected amount out
        uint[] memory amounts = router.getAmountsOut(amountIn, path);
        uint expectedOut = amounts[1];
        
        // Calculate minimum amount with slippage
        uint minAmountOut = expectedOut * (100 - slippagePercent) / 100;
        
        // Execute swap
        amounts = router.swapExactTokensForETH(
            amountIn,
            minAmountOut,
            path,
            to,
            deadline
        );
        
        return amounts[1];
    }
    
    // Add liquidity with ETH and tokens in one transaction
    function addLiquidityETHWithSlippage(
        address token,
        uint amountTokenDesired,
        uint slippagePercent,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity) {
        require(slippagePercent <= 100, "Slippage too high");
        
        // Transfer tokens to this contract
        IERC20(token).transferFrom(msg.sender, address(this), amountTokenDesired);
        IERC20(token).approve(address(router), amountTokenDesired);
        
        // Calculate minimum amounts with slippage
        uint amountTokenMin = amountTokenDesired * (100 - slippagePercent) / 100;
        uint amountETHMin = msg.value * (100 - slippagePercent) / 100;
        
        // Add liquidity
        return router.addLiquidityETH{value: msg.value}(
            token,
            amountTokenDesired,
            amountTokenMin,
            amountETHMin,
            to,
            deadline
        );
    }
    
    // Get price of token in ETH
    function getTokenPriceInETH(address token, uint amountIn) external view returns (uint) {
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = WETH;
        
        uint[] memory amounts = router.getAmountsOut(amountIn, path);
        return amounts[1];
    }
    
    // Get price of ETH in token
    function getETHPriceInToken(address token, uint amountIn) external view returns (uint) {
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = token;
        
        uint[] memory amounts = router.getAmountsOut(amountIn, path);
        return amounts[1];
    }
}