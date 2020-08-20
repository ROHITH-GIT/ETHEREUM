pragma solidity ^0.6.0;

// importing Ownable smart contract form the OpenZeppilin and SafeMath for the Uint verification

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelincontracts/contracts/math/SafeMath.sol";



//creating a Smart contract with a Name Allowance and importing the Ownablble.sol pre-built features
contract Allowance is Ownable{
    
    using SafeMath for uint;
    //safemath from openzeppilin

    event AllowanceChanged(address indexed _forWho, address indexed _byWhom, uint _oldAmount, uint _newAmount);

    
    mapping(address=> uint) public allowance;
    
    
    //Function to check the validity of user is owner
    
     function isOwner() internal view returns(bool) {
 return owner() == msg.sender;
 }



//function to add allowances to the memebers

function addAllowance(address _who, uint _amount) public  {
    
emit AllowanceChanged(_who, msg.sender, allowance[_who], allowance[_who] += _amount);
    allowance[_who] = _amount;
}

//modifier to restrict the access over the smart contract

modifier  ownerOrAllowed (uint _amount)  {
    require(isOwner() || allowance[msg.sender] >= _amount, "You are not the Owner");
    _;
}

//function to reducce the allowance after the transaction

function reduceAllowance(address _who, uint _amount) internal {
    emit AllowanceChanged(_who, msg.sender, allowance[_who], allowance[_who].sub(_amount)
);
    allowance[_who] = allowance[_who].sub(_amount);
}
    
}

//shared wallet contract importing Allowance contract
contract SharedWallet is Allowance{
    
    event MoneySent(address indexed _beneficiary, uint _amount);
 event MoneyReceived(address indexed _from, uint _amount);

    
    //withdraw function to send the money to the desired account
    
 function withdrawMoney(address payable _to, uint _amount) ownerOrAllowed (_amount) public {
       require(_amount <= address(this).balance, "Contract doesn't own enough money");
       if (!isOwner() ) {
           reduceAllowance(msg.sender,_amount);
       }
       emit MoneySent(_to, _amount);


 _to.transfer(_amount);
 }
 
 //reverting the renounce ownership function 
 
 function renounceOwnership() public onlyOwner{
     revert("cant renounce the Ownership");
 }
 // external payable function to receive money to the contract
    receive() external  payable{
         emit MoneyReceived(msg.sender, msg.value);

    }
    
    
    
    
}
