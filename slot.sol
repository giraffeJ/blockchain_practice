pragma solidity ^0.4.18;
contract slot{
    address owner;
    uint gameNumber;
    struct game{
        address player;
        bool win;
        uint betting_amount;
        uint game_result;
        uint reward;
        uint blockNumber;
    }
    game[] public games;
    event sendResult(address player,bool win,uint amount,uint n1,uint n2,uint n3);
    function slot() public payable{        owner=msg.sender;}
    
    function bet() public payable{
        // jackpot = 64
        if (address(this).balance < msg.value * 64 )
            revert();
        bool win=false;
        uint game_result = uint(block.blockhash(block.number-1))%1000; // 0~999
        uint n1 = game_result/100;
        uint n2 = (game_result%100)/10;
        uint n3 = game_result%10;
        
        uint reward = msg.value;
        if(n1 == n2){ reward = reward*4; win=true;}
        if(n2 == n3){ reward = reward*4; win=true;}
        if(n1 == n3){ reward = reward*4; win=true;}
        
        if(win)
            msg.sender.transfer(reward);
        else
            reward=0;
        sendResult(msg.sender,win,reward,n1,n2,n3);
        games.push(game(msg.sender,win,msg.value,game_result,reward,block.number));
    }
    function killcontract() public{
        require(owner==msg.sender);
        selfdestruct(owner);
    }
}