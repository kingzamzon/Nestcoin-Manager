
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.5.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.5.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.5.0/access/AccessControl.sol";

contract NestToken is ERC20, Ownable, AccessControl {
    //Events for the front-end
    event SingleReward(address to, uint256 amount);
    event BatchRewards(address [] _recipients, uint256 [] _amounts);
    event singleAmount(address [] _recipients, uint256 _amount);
    event burnedToken (address _addr, uint256 _burned);

    // States
    bytes32 public constant NESTCOIN_ADMIN = keccak256("NESTCOIN_ADMIN");

    constructor() ERC20("NestToken", "NST") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(NESTCOIN_ADMIN, msg.sender);
    }

    //Reward single customer
    function SingleRewardMint(address to, uint256 amount) public onlyRole(NESTCOIN_ADMIN) {
         require(to != address(0),"invalid address");
        _mint(to, amount);
        emit SingleReward(to, amount);
    }

    //Reward Multiple customers at once different amounts
    //Input format for the array of addresses: ["0x1234....", "0x2345...", ...]
    //Input format for the array of amounts to be distributed: ["100", "200", ...]
    function BatchRewardMint(address [] memory _recipients, uint256 [] memory _amounts ) public onlyOwner {
      require(_recipients.length<=200, "input exceeds minting quota");
        for(uint i = 0; i< _recipients.length; ++i){
             require(_recipients[i] != address(0));
            _mint(_recipients[i], _amounts[i]);
        }
        emit BatchRewards(_recipients, _amounts);
    }  


    //This will reward multiple customers the same amount
    //Input format for the array of addresses: ["0x1234....", "0x2345...", ...]
      function sameRewardMint(address[] memory _recipients, uint256 _amount)public onlyOwner
    {
         require(_recipients.length<=200, "input exceeds minting quota");

           for(uint i = 0; i < _recipients.length; ++i)
           {
             require(_recipients[i] != address(0));
             _mint(_recipients[i], _amount);
           }
        emit singleAmount(_recipients, _amount);       
    }

    //this burns excess tokens from total supply
      function destroy(uint8 amount)public onlyOwner returns(uint256 , string memory)
    {
        require(balanceOf(msg.sender) >= amount,"insufficient funds");
        _burn(msg.sender,amount);
        emit burnedToken(msg.sender, amount);
        return (amount, " Nestcoin Tokens burned");
    }

}
