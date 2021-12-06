// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
contract Storage is Ownable {

    address internal _rpsToken;
    uint256 internal _bet = 1 * 10^18;

    function _setRPSAddress(address _tokenAddress) internal {
        _rpsToken = _tokenAddress;
    }
    
}