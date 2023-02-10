pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract YourToken is ERC20 {
    constructor() ERC20("KevinCoin", "KEV") {
        _mint(msg.sender, 1100 * 10 ** 18);
    }

    // KJ
}
