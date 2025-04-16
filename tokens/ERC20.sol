// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract META is ERC20, Ownable {
    constructor() ERC20("Meta Token", "META") Ownable(msg.sender) {
        // Mint 1,000,000 tokens to the contract creator
        // Note: ERC20 uses 18 decimals by default, so we multiply by 10^18
        _mint(msg.sender, 1000000 * 10**18);
    }
    
    // Optional: Add additional functionality like burning tokens
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
    
    // Optional: Allow owner to mint additional tokens if needed
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}