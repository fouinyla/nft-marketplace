// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTTrader {
    IERC20 public usdtToken;

    mapping(address => mapping(uint256 => Listing)) public listings;
    // mapping(address => uint256) public balances;

    struct Listing {
        uint256 price;
        address seller;
    }

    constructor(address usdtAddress) {
        usdtToken = IERC20(usdtAddress);
    }

    function addListing(
        uint256 price,
        address contractAddr,
        uint256 tokenId
    ) public {
        ERC1155 token = ERC1155(contractAddr);
        require(
            token.balanceOf(msg.sender, tokenId) > 0,
            "caller must own given nft token"
        );
        require(
            token.isApprovedForAll(msg.sender, address(this)),
            "contract must be approved"
        );

        listings[contractAddr][tokenId] = Listing(price, msg.sender);
    }

    function purchase(
        address contractAddr,
        uint256 tokenId,
        uint256 amount
    ) public payable {
        Listing memory item = listings[contractAddr][tokenId];

        uint256 totalPrice = item.price * amount;
        // require(msg.value >= item.price * amount, "insufficient funds sent");
        require(
            usdtToken.balanceOf(msg.sender) >= totalPrice,
            "insufficient USDT balance"
        );
        require(
            usdtToken.allowance(msg.sender, address(this)) >= totalPrice,
            "contract not approved to spend USDT"
        );

        // balances[item.seller] += msg.value;

        usdtToken.transferFrom(msg.sender, item.seller, totalPrice);

        ERC1155 token = ERC1155(contractAddr);
        token.safeTransferFrom(item.seller, msg.sender, tokenId, amount, "");
    }

    // function withdraw(uint256 amount, address payable destAddr) public {
    //     require(amount <= balances[msg.sender], "insufficient funds");

    //     destAddr.transfer(amount);
    //     balances[msg.sender] -= amount;
    // }
}
