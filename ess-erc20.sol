// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IRarity {
    function ownerOf(uint256) external view returns (address);

    function balanceOf(address) external view returns (uint256);

    function level(uint256) external view returns (uint256);
}

contract Essence is ERC20 {
    using SafeMath for uint256;
    IRarity constant rarity =
        IRarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
    address beneficiary;
    uint256 private immutable register_fee = 5 * 10**16;
    uint256 private immutable _cap = 198 * 10**28;
    mapping(uint256 => bool) public registered;

    event Registered(uint256 token_id);

    constructor() ERC20("Essence", "ESS") {
        beneficiary = msg.sender;
        _mint(msg.sender, 2 * 66 * 10**28);
    }

    function pre_register(uint256 token_id) external payable {
        require(
            rarity.ownerOf(token_id) == msg.sender,
            "You are not the token holder"
        );
        require(!registered[token_id], "This token has been registered");
        require(msg.value >= register_fee);
        uint256 _level = rarity.level(token_id);
        transfer(beneficiary, msg.value);
        uint256 reward = _level.mul(1000);
        if (reward.add(ERC20.totalSupply()) <= _cap) {
            _mint(msg.sender, reward);
        } else {
            _mint(msg.sender, _cap.sub(ERC20.totalSupply()));
        }
        registered[token_id] = true;
        emit Registered(token_id);
    }

    function register(uint256 token_id) external payable {
        require(
            rarity.ownerOf(token_id) == msg.sender,
            "You are not the token holder"
        );
        require(!registered[token_id], "This token has been registered");
        require(msg.value >= register_fee);
        registered[token_id] = true;
        transfer(beneficiary, msg.value);
        emit Registered(token_id);
    }

    function cap() public view virtual returns (uint256) {
        return _cap;
    }
}
