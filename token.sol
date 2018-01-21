pragma solidity ^0.4.0;
contract owned{
    address public owner;
    
    function owned(){
        owner = msg.sender;
    }
    //修改器
    modifier onlyOwner{
        if(msg.sender != owner){
            revert();
        }else{
            _;
        }
    }
    
    function transferOwner(address newOwner) onlyOwner{
        owner = newOwner;
        
    }
}

contract tokenDemo is owned{
    string public name;//代币名
    string public symbol;//代币符号
    uint8 public decimals = 0;//代币小数位
    uint public totalSupply;//代币总量
    
    uint public sellPrice = 1 ether;// 设置代币卖的价格等于一个以太币
    
    uint public buyPrice = 1 ether; //设置代币的买的价格
    
    //用一个映射类型的变量，来记录所有账户的代币的余额
    mapping(address => uint) public balanceOf;
     //用一个映射类型的变量，来记录被冻结的账户
    mapping(address => bool) public frozenAccount;
    
    function tokenDemo(uint initialSupply,string _name,string _symbol,uint8 _decimals,address centralMiner){
        if(centralMiner != 0){
            owner = centralMiner;
        }
        balanceOf[owner] = initialSupply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = initialSupply;
    }
    
    //发行代币,向指定的目标账户添加代币
    function mintToken(address target,uint mintedAmount) onlyOwner{
        if(target != 0){
            //设置目标账户相应的代币余额
            balanceOf[target] =mintedAmount;
            //增加总量
            totalSupply +=mintedAmount;
        }else{
            revert();
        }
    }
    //实现账户的冻结和解冻
    function freezeAccount(address target,bool _bool) onlyOwner{
        if(target != 0){
            frozenAccount[target] = _bool;
        }    
    }
    
    //实现账户间，代币的转移
    function transfer(address _to,uint _value){
        if(frozenAccount[msg.sender]){
            revert();
        }else{
            if(balanceOf[msg.sender] < _value){
                revert();
            }else{
                //检测溢出
                if(balanceOf[_to]+_value < balanceOf[_to]){
                    revert();
                }else{
                    //实现代币转移
                    balanceOf[msg.sender]-=_value;
                    balanceOf[_to]+=_value;
                }
            }
        }
    }
    
    function setPrice(uint newSellPrice,uint newBuyPrice)onlyOwner{
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }    
    
    function sell(uint amount) payable returns(uint revenue){
        if(frozenAccount[msg.sender]){
            revert();
        }
        
        if(balanceOf[msg.sender]<amount){
            revert();
        }
        
        balanceOf[owner]+=amount;
        balanceOf[msg.sender]-=amount;
        
        revenue = amount*sellPrice;
        if(msg.sender.send(revenue)){
            return revenue;
        }else{
            revert();
        }
    }
    
    function buy() payable returns(uint amount){
        if(buyPrice<=0){
            revert();
        }
        amount = msg.value / buyPrice;
        if(balanceOf[owner]<amount){
            revert();
        }
        if(!owner.send(msg.value)){
            revert();
        }
        balanceOf[owner]-=amount;
        balanceOf[msg.sender]+=amount;
        
    }
}