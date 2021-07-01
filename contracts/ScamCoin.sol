// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ScamCoin is ERC20, Ownable {
    uint256 _maxSupply = 69420 * 10 ** decimals();

    /**
     * @dev Init token
     */
    constructor() ERC20("ScamCoin", "SCAMC") {
        _mint(msg.sender, maxSupply());

        _burn(msg.sender, totalSupply() / 100 * 16);
    }

    function maxSupply() public view returns(uint256) {
        return _maxSupply;
    }

    /**
     * @dev Expands the total
     */
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }

    function burn(address _to, uint256 _amount) public onlyOwner {
        _burn(_to, _amount);
    }
}