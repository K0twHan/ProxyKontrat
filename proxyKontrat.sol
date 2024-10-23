// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "./firstContract.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Proxy {
    address public contractAddress;
    address public tokenAddress;

    IERC20 token;


    modifier IsThisUserOk(address _userWallet) {
        require(msg.sender == _userWallet,"Lutfen Kendi Adina islem yap");
        _;
    }
    constructor(address _tokenAddress) {
        FC newContract = new FC(address(this), _tokenAddress);
        contractAddress = address(newContract);
        tokenAddress = _tokenAddress;
        token = IERC20(_tokenAddress);
    }

    function deposit(address _userWallet, uint _days, uint _value) IsThisUserOk(_userWallet) public {
        require(token.allowance(msg.sender, address(this)) >= _value, "Yeterli izin verilmedi");
        token.approve(contractAddress, _value);
        token.transferFrom(_userWallet, address(this), _value);
        FC(contractAddress).Deposit(_userWallet, _days, _value);
    }

    function withdraw(address _userWallet, uint _value) IsThisUserOk(_userWallet) public {
        FC(contractAddress).Withdraw(_userWallet, _value);
    }

    function transferOwnership(address _oldUserWallet, address _newUserWallet) IsThisUserOk(_oldUserWallet) public {
        FC(contractAddress).TransferOwnership(_oldUserWallet, _newUserWallet);
    }
}
