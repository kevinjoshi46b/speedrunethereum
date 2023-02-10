pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    YourToken public yourToken;
    uint256 public constant tokensPerEth = 100;

    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
    }

    function buyTokens() public payable {
        uint256 _tokenAmount = msg.value * tokensPerEth;
        yourToken.transfer(msg.sender, _tokenAmount);
        emit BuyTokens(msg.sender, msg.value, _tokenAmount);
    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function sellTokens(uint256 _amount) public payable {
        yourToken.transferFrom(msg.sender, address(this), _amount);
        uint256 _ethAmount = _amount / tokensPerEth;
        payable(msg.sender).transfer(_ethAmount);
    }

    // KJ
}
