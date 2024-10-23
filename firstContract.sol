// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FC {

    mapping (address => uint) usersAmount;
    mapping (address => uint) userDays;

    IERC20 token;
    address owner;
    modifier OnlyContract() {
        require(msg.sender == owner,"Sadece Kontrat Islem Yapabilir");
        _;
    }

    modifier Days(address _userWallet) {
        require(block.timestamp >= userDays[_userWallet],"Cekim Tarihi Daha Gelmedi");
        _;

    }


    constructor(address _owner,address tokenaddress)
    {
        token= IERC20(tokenaddress);
        owner = _owner;

    }


    function Deposit(address _userWallet,uint _days,uint value) OnlyContract public  returns (bool) {
        require(token.allowance(msg.sender, address(this)) >= value,"Yeterli Allowence yok Approve yetkisi verin");
        token.transferFrom(msg.sender, address(this), value);
        usersAmount[_userWallet] += value;
       
        userDays[_userWallet] = block.timestamp + _days * 1 days;

        return true;
    }

    function Withdraw(address _userWallet,uint _value) public Days(_userWallet) OnlyContract returns(bool) {
        require(usersAmount[_userWallet] >= _value,"Yetersiz Miktar");
       token.transfer(_userWallet, _value);
        usersAmount[_userWallet] -= _value;
        if(usersAmount[_userWallet] == 0)
        {
            delete userDays[_userWallet];
            delete usersAmount[_userWallet];
        }
        return true;
        
    }

    function TransferOwnership(address _OlduserWallet, address _NewOwnerWallet) public OnlyContract returns (bool) {
        if(usersAmount[_NewOwnerWallet] > 0)
        {
            usersAmount[_NewOwnerWallet] += usersAmount[_OlduserWallet];
            userDays[_NewOwnerWallet] = userDays[_OlduserWallet];
            delete usersAmount[_OlduserWallet];
            delete userDays[_OlduserWallet];
        }
        else{
            usersAmount[_NewOwnerWallet] += usersAmount[_OlduserWallet];
            if(userDays[_NewOwnerWallet] < userDays[_OlduserWallet])
            {
                userDays[_NewOwnerWallet] = userDays[_OlduserWallet];
            }
            
        }
            delete usersAmount[_OlduserWallet];
            delete userDays[_OlduserWallet];
            return true;
    }

}