pragma solidity ^0.4.18;

contract RichToken {
    address owner;
    string public constant name="Rich Token";
    string public constant symbol="RT";
    uint8 public constant decimals=0;
    address public icoAddress; // ICO의 주소
    mapping (address => uint) public balanceOf;
    event Transfer(address from, address to, uint value);
    function transfer(address _to, uint _value) public {
        address _from= msg.sender;
        require(_to != address(0)); // 주소를 입력하지 않은 경우의 예외 처리                              
        require(balanceOf[_from] >= _value); // 잔고가 부족한 경우의 예외 처리               
        balanceOf[_from] -= _value;                    
        balanceOf[_to] += _value;                         
        Transfer(_from, _to, _value);
    }
    function RichToken(address _icoAddress) public{
        owner=msg.sender;
        icoAddress=_icoAddress;
        ICO cs=ICO(icoAddress); 
        require(cs.getDeadline()<now);
        for(uint i=0;i<cs.getIndex();i++){
            balanceOf[cs.getInvestor(i)]=cs.getTokens(cs.getInvestor(i));
        }
    }
}

contract ICO{
    mapping (uint => address) investor;
    mapping (address=> uint) public amountInvested;
    address public owner;
    uint index;
    uint public constant exchangeRate=1000;
    uint public salesStatus;
	uint start;
    uint deadline;
    
    function getIndex() public constant returns(uint){return index;}
    function getInvestor(uint i) public constant returns(address){
        return investor[i];
    }
    function getDeadline() public constant returns(uint){
        return deadline;
    }
	function getNow() public constant returns(uint){
        return now;
    }
    function getStart() public constant returns(uint){
        return start;
    }
    function getTokens(address _investor) public constant returns(uint){
        return amountInvested[_investor]* exchangeRate;
    }
    function ICO(uint salesMinutes) public{
        owner = msg.sender;
		start = now;
        deadline = now + salesMinutes * 1 minutes;
    }
    function invest() public payable {  
        require( now < deadline );
        if(amountInvested[msg.sender] == 0 ){
            investor[index] = msg.sender;
            index++;
        }
        amountInvested[msg.sender]+=msg.value;
        salesStatus+=msg.value;
    }
    function withdraw(uint amount) {  // 판매가 끝나면 투자된 이더를 출금합니다.
        if(now > deadline && msg.sender == owner){
            msg.sender.transfer(amount);
        }
    }
}