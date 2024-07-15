// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {MyToken} from "./MyToken.sol";

contract MyTokenFactory {
    event TokenCreated(address indexed creator, address tokenAddress);

    MyToken[] public tokens;

    function createTokens(string memory _name, string memory _symbol) public {
        MyToken token = new MyToken(_name, _symbol);
        tokens.push(token);

        emit TokenCreated(msg.sender, address(token));
    }
}
