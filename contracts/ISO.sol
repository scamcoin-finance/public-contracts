// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IERC20V2.sol";

contract ISO is Ownable {
    IERC20V2 public tokenContract;
    IERC20V2 public busdContract;
    IERC20V2 public usdtContract;
    uint256 public priceBNB; // in wei
    uint256 public priceBUSD; // in wei
    uint256 public priceUSDT; // in wei
    uint256 public tokensSold;

    event Sold(address buyer, uint256 amount);

    function setPriceBNB(uint256 _price) public onlyOwner {
        priceBNB = _price;
    }
    function setPriceBUSD(uint256 _price) public onlyOwner {
        priceBUSD = _price;
    }
    function setPriceUSDT(uint256 _price) public onlyOwner {
        priceUSDT = _price;
    }
    function setTokenContract(IERC20V2 _tokenContract) public onlyOwner {
        tokenContract = _tokenContract;
    }
    function setBUSDContract(IERC20V2 _tokenContract) public onlyOwner {
        busdContract = _tokenContract;
    }
    function setUSDTContract(IERC20V2 _tokenContract) public onlyOwner {
        usdtContract = _tokenContract;
    }

    modifier hasTokens(uint256 tokenCount) {
		require(tokenContract.balanceOf(address(this)) >= tokenCount, 'Not enough token');
		_;
	}

    function buyTokensForBNB(uint256 tokenCount) public payable hasTokens(tokenCount) {
        uint256 cost = getCost(tokenCount, priceBNB, 18);
        require(msg.value >= cost, 'Not enough BNB');

        emit Sold(msg.sender, tokenCount);
        tokensSold += tokenCount;

        require(tokenContract.transfer(msg.sender, tokenCount), 'Failed transfer transaction');
    }

    function buyTokensForBUSD(uint256 tokenCount) public payable hasTokens(tokenCount) {
        uint256 busdAmount = getCost(tokenCount, priceBUSD, 18);
        require(busdContract.transferFrom(msg.sender, address(this), busdAmount), 'Failed transfer BUSD');

        emit Sold(msg.sender, tokenCount);
        tokensSold += tokenCount;

        require(tokenContract.transfer(msg.sender, tokenCount), 'Failed transfer transaction');
    }
    
    function buyTokensForUSDT(uint256 tokenCount) public payable hasTokens(tokenCount) {
        uint256 usdtAmount = getCost(tokenCount, priceUSDT, 18);
        require(usdtContract.transferFrom(msg.sender, address(this), usdtAmount), 'Failed transfer USDT');

        emit Sold(msg.sender, tokenCount);
        tokensSold += tokenCount;

        require(tokenContract.transfer(msg.sender, tokenCount), 'Failed transfer transaction');
    }

    function getCost(uint256 _tokens, uint256 _price, uint256 _decimals) public pure returns (uint256) {
        if (_tokens == 0) {
            return 0;
        } else {
            uint256 c = _tokens * _price;
            assert(c / _price == _tokens);
            return c / 10 ** _decimals;
        }
    }

    function exitTime() public onlyOwner {
        require(tokenContract.transfer(owner(), tokenContract.balanceOf(address(this))));
        require(busdContract.transfer(owner(), busdContract.balanceOf(address(this))));
        require(usdtContract.transfer(owner(), usdtContract.balanceOf(address(this))));

        address payable ownerWallet = payable(owner());
        ownerWallet.transfer(address(this).balance);
    }

    /**
     * @dev for testing
     */
    // function kill() public onlyOwner {
	// 	address payable wallet = payable(owner());
	// 	selfdestruct(wallet);
	// }
}