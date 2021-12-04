pragma solidity >=0.8.0, <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./1_Storage.sol";

contract 2_rpsToken is ERC20 {
    constructor ERC20(RockPaperScissorsGO, RPS){
        _mint(msg.sender, 5000 * 10^18);
        _setRPSAddress(this);
    }

}