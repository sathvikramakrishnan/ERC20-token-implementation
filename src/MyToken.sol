// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract MyToken {
    /**Errors */
    error MyToken__InvalidSender(address);
    error MyToken__InvalidReceiver(address);
    error MyToken__InvalidApprover(address);
    error MyToken__InvalidSpender(address);
    error MyToken__ApproverIsSpender(address owner, address spender);
    error MyToken__InsufficientBalance(address account, uint256 balance);
    error MyToken__InsufficientAllowance(
        address owner,
        address spender,
        uint256 allowance,
        uint256 value
    );

    /**Variables */
    string public name;
    string public symbol;
    mapping(address => mapping(address => uint256)) public s_allowed;

    uint256 private s_totalSupply;
    mapping(address => uint256) private s_balances;

    /**Events */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return s_totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return s_balances[_owner];
    }

    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        address from = msg.sender;
        _transfer(from, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        address spender = msg.sender;
        if (spender == _from) {
            revert MyToken__ApproverIsSpender(_from, spender);
        }

        uint256 currentAllowance = allowance(_from, spender);
        if (currentAllowance < _value) {
            revert MyToken__InsufficientAllowance(
                _from,
                spender,
                currentAllowance,
                _value
            );
        }
        _transfer(_from, _to, _value);
        approve(_from, spender, currentAllowance - _value);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        if (_from == address(0)) {
            revert MyToken__InvalidSender(address(0));
        }
        if (_to == address(0)) {
            revert MyToken__InvalidReceiver(address(0));
        }
        _update(_from, _to, _value);
    }

    function approve(
        address _owner,
        address _spender,
        uint256 _value
    ) public returns (bool success) {
        if (_spender == _owner) {
            revert MyToken__ApproverIsSpender(_owner, _spender);
        }
        if (_spender == address(0)) {
            revert MyToken__InvalidSpender(address(0));
        }
        if (_owner == address(0)) {
            revert MyToken__InvalidApprover(address(0));
        }
        s_allowed[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);

        return true;
    }

    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint256 remaining) {
        return s_allowed[_owner][_spender];
    }

    function _mint(address _to, uint256 _value) external {
        if (_to == address(0)) {
            revert MyToken__InvalidReceiver(address(0));
        }
        _update(address(0), _to, _value);
    }

    function _burn(address _from, uint256 _value) external {
        if (_from == address(0)) {
            revert MyToken__InvalidSender(address(0));
        }
        _update(_from, address(0), _value);
    }

    function _update(address _from, address _to, uint256 _value) internal {
        if (_from == address(0)) {
            s_totalSupply += _value;
        } else {
            uint256 fromBalance = s_balances[_from];
            if (fromBalance < _value) {
                revert MyToken__InsufficientBalance(_from, fromBalance);
            }
            unchecked {
                // no need for underflow/overflow check
                // already known that _value < fromBalance
                s_balances[_from] = fromBalance - _value;
            }
        }

        if (_to == address(0)) {
            unchecked {
                // no need for underflow/overflow check
                // already known that _value < fromBalance from above block
                s_totalSupply -= _value;
            }
        } else {
            unchecked {
                s_balances[_to] += _value;
            }
        }

        emit Transfer(_from, _to, _value);
    }
}
