// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {MyToken} from "./MyToken.sol";

contract MyTokenFactory {
    error TokenFactory__TokenSymbolAlreadyExits(string symbol);

    MyToken[] private s_tokens;
    mapping(string => MyToken) private s_symbolToToken;

    event TokenCreated(address indexed creator, address tokenAddress);

    function createTokens(string memory _name, string memory _symbol) public {
        if (address(s_symbolToToken[_symbol]) != address(0)) {
            revert TokenFactory__TokenSymbolAlreadyExits(_symbol);
        }

        MyToken token = new MyToken(_name, _symbol);
        s_tokens.push(token);
        s_symbolToToken[_symbol] = token;

        emit TokenCreated(msg.sender, address(token));
    }

    // functions that use token address and call functions

    // setters
    function mint(MyToken _token, uint256 _value) external {
        _token._mint(msg.sender, _value);
    }

    function burn(MyToken _token, uint256 _value) external {
        _token._burn(msg.sender, _value);
    }

    function approve(
        MyToken _token,
        address _spender,
        uint256 _value
    ) external {
        _token.setSender(msg.sender);
        _token.approve(_spender, _value);
    }

    function transfer(MyToken _token, address _to, uint256 _value) external {
        _token.setSender(msg.sender);
        _token.transfer(_to, _value);
    }

    function transferFrom(
        MyToken _token,
        address _from,
        address _to,
        uint256 _value
    ) external {
        _token.setSender(msg.sender);
        _token.transferFrom(_from, _to, _value);
    }

    // view functions
    function getToken(uint256 _index) external view returns (MyToken) {
        return s_tokens[_index];
    }

    function getTokenFromSymbol(
        string memory _symbol
    ) external view returns (MyToken) {
        return s_symbolToToken[_symbol];
    }

    function getName(MyToken _token) external view returns (string memory) {
        return _token.name();
    }

    function getSymbol(MyToken _token) external view returns (string memory) {
        return _token.symbol();
    }

    function getDecimals(MyToken _token) external pure returns (uint256) {
        return _token.decimals();
    }

    function getSupply(MyToken _token) external view returns (uint256) {
        return _token.totalSupply();
    }

    function getBalance(MyToken _token) external view returns (uint256) {
        return _token.balanceOf(msg.sender);
    }

    function getAllowance(
        MyToken _token,
        address _owner,
        address _spender
    ) external view returns (uint256) {
        return _token.allowance(_owner, _spender);
    }
}
