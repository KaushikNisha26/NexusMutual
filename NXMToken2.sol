pragma solidity ^0.4.8;
import "./NXMTokenData.sol";
import "./quotation.sol";
import "./pool.sol";
import "./MCR.sol";
import "./NXMToken.sol";
import "./master.sol";
import "./NXMToken3.sol";

contract NXMToken2{
    master ms1;
    address masterAddress;
    quotation q1;
    NXMTokenData td1;
    pool p1;
    MCR m1;
    NXMToken t1;
    NXMToken3 t3;
    address tokenAddress;
    address NXMToken3Address;
    address quotationAddress;
    address tokenDataAddress;
    address poolAddress;
    address mcrAddress;
    event Transfer(address indexed from, address indexed to, uint256 value);
    function changeMasterAddress(address _add)
    {
        if(masterAddress == 0x000)
            masterAddress = _add;
        else
        {
            ms1=master(masterAddress);
            if(ms1.isInternal(msg.sender) == 1)
                masterAddress = _add;
            else
                throw;
        }
       
    }
    modifier onlyInternal {
        ms1=master(masterAddress);
        require(ms1.isInternal(msg.sender) == 1);
        _; 
    }
    function changeTokenAddress(address _add) onlyInternal
    {

        tokenAddress = _add;
        t1=NXMToken(tokenAddress);
    } 
      function changeToken3Address(address _add) onlyInternal
    {

        NXMToken3Address = _add;
       
    } 
    function changeQuotationAddress(address _add) onlyInternal
    {
        quotationAddress = _add;
        q1=quotation(quotationAddress);
    }
    function changeTokenDataAddress(address _add) onlyInternal
    {
        tokenDataAddress = _add;
        td1=NXMTokenData(tokenDataAddress);
    }
    function changePoolAddress(address _add) onlyInternal
    {
        poolAddress = _add;
        p1=pool(poolAddress);
    }
    function changeMCRAddress(address _add) onlyInternal
    {
        mcrAddress = _add;
        m1=MCR(mcrAddress);
    }
    function lockCN ( uint256 premiumCalculated , bytes16 quoteCurr ,uint quoteCoverPeriod ,uint quoteCoverId , address senderAddress) onlyInternal returns (uint amount)
    {
        td1=NXMTokenData(tokenDataAddress);

        uint pastlocked;
        (,pastlocked) = td1.getLockedCN_Cover(senderAddress,quoteCoverId);
        
        if(pastlocked !=0)
            throw;
     
        m1=MCR(mcrAddress);
        premiumCalculated = premiumCalculated*10000000000;
        amount = (premiumCalculated*50000000000000000)/m1.calculateTokenPrice(quoteCurr);  // <---------------token price diffrent for diffrent currency-------------->  amount that was sent //100000 * 5% tokens
       
        bytes16 curr = quoteCurr;
        td1.changeCurrencyTokens(curr , td1.getCurrencyTokens(curr) + amount);
        
        if(td1.getBalanceOf(senderAddress) == 0)
            td1.incMemberCounter();

        td1.changeBalanceOf(senderAddress,td1.getBalanceOf(senderAddress)+amount);   // mint new tokens

        if(td1.checkInallMemberArray(senderAddress)==0)
        {
            td1.addInAllMemberArray(senderAddress);
        }
        td1.changeTotalSupply(td1.getTotalSupply() + amount); // track the supply
        uint ldays=quoteCoverPeriod;
        uint ld=now+ ldays*1 days;
        td1.pushInLockedCN(senderAddress,ld,amount);
        td1.pushInLockedCN_Cover(senderAddress,quoteCoverId,ld,amount);
        td1.changePoolFundValue(curr , td1.getPoolFundValue(curr) + premiumCalculated );
        t1=NXMToken(tokenAddress);
        t1.callTransferEvent(0,senderAddress, amount); // notify of the event
        
    }

   
    function burnCAToken(uint claimid , uint _value , address _to) onlyInternal {
         
        td1=NXMTokenData(tokenDataAddress);
        t1=NXMToken(tokenAddress);
        if( td1.getBalanceCAWithAddress(_to) < _value)throw;
        td1.pushInBurnCAToken(_to,claimid,now,_value);

        td1.changeBalanceOf(_to,td1.getBalanceOf(_to) - _value); 

        if(td1.getBalanceOf(_to)==0)
            td1.decMemberCounter();
        
        uint rem = _value;
        uint len=td1.getLockedCALength(_to);
        uint vUpto;
        uint amount;
        for(uint i=0 ; i < len ;i++ )
        {
            (vUpto,amount) = td1.getLockedCA_index(_to , i);
            if(now<vUpto)
            {
                if(rem > amount)
                {
                    rem -= amount;
                    td1.changeLockedCA_Index(_to,i,0);
                }
                else
                {
                    td1.changeLockedCA_Index(_to,i,amount-rem);
                    rem=0;
                    break;
                }
            }
        }
        t1.callBurnEvent(_to,"BurnCA",claimid,_value);
        td1.changeCurrencyTokens("ETH",td1.getCurrencyTokens("ETH")-_value);
        td1.changeTotalSupply(td1.getTotalSupply() - _value);
        
        t1.callTransferEvent(_to, 0, _value); // notify of the event
       
    }
    // function bookCA(uint _value) 
    // {
    //     t1=NXMToken(tokenAddress);
    //     td1=NXMTokenData(tokenDataAddress);
    //     if(t1.getBalanceCAWithAddress(msg.sender)-td1.getBookedCA(msg.sender)<_value) throw;
    //     td1.pushInBookedCA(msg.sender, now+td1.getBookTime() , _value);
    // }
     function rewardToken(address _to,uint amount)  onlyInternal  {
      td1 = NXMTokenData(tokenDataAddress);
        if(td1.getBalanceOf(_to) == 0)
            td1.incMemberCounter();
        td1.changeBalanceOf(_to, td1.getBalanceOf(_to) + amount);// mint new tokens
        td1.changeTotalSupply(td1.getTotalSupply()+amount); // track the supply
        td1.changeCurrencyTokens("ETH" , td1.getCurrencyTokens("ETH") + amount);
        if(td1.checkInallMemberArray(_to)==0)
        {
            td1.addInAllMemberArray(_to);
        }
        Transfer(0,_to, amount); // notify of the event
       
    }
    function extendCAWithAddress(address _to ,uint _timestamp ,uint noOfTokens) onlyInternal
    {
        td1=NXMTokenData(tokenDataAddress);
        t1=NXMToken(tokenAddress);
        noOfTokens = noOfTokens * 10000000000;
        if(td1.getBalanceCAWithAddress(_to) < noOfTokens)throw;
        
        uint rem = noOfTokens;
        uint len = td1.getLockedCALength(_to);
        uint vUpto;
        uint amount;
        for(uint i=0 ; i < len ;i++ )
        {
            (vUpto , amount) = td1.getLockedCA_index(_to , i);
            if(amount>0 && vUpto > now)
            {
                if(rem > amount)
                {
                    rem -= amount;
                    td1.lockCA(_to,vUpto + _timestamp,amount);
                    td1.changeLockedCA_Index(_to,i,0);
                
                }
                else
                {
                    td1.lockCA(_to,vUpto + _timestamp,rem);
                    td1.changeLockedCA_Index(_to,i,amount-rem);
                    rem=0;
                
                    break;
                }
            }
        }
    }
    
    
    
    function burnCNToken(uint coverid) onlyInternal {
        
        td1=NXMTokenData(tokenDataAddress);
        q1=quotation(quotationAddress); 
        uint quoteId = q1.getQuoteId(coverid);
        bytes16 curr= q1.getCurrencyOfQuote(quoteId);
        address _to = q1.getMemberAddress(coverid);
        uint depositedTokens = td1.getDepositCN(coverid,_to);
        if(depositedTokens <= 0)throw;
        t1=NXMToken(tokenAddress);
        t3=NXMToken3(NXMToken3Address);
        t3.undepositCN(coverid,1);
        uint validity;
        uint amount1;
        (validity,amount1) = td1.getLockedCN_Cover(_to,coverid);
        uint len = td1.getLockedCNLength(_to);
        uint vUpto;
        uint amount;
        for(uint i=0;i<len ;i++)
        {
            (vUpto,amount) = td1.getLockedCN_index(_to,i);
            if(vUpto == validity && amount == amount1 )
            {
                td1.updateLockedCN(_to,i,vUpto,amount-depositedTokens);
                break;
            }
        }
        t1=NXMToken(tokenAddress);
        td1.updateLockedCN_Cover(_to,coverid,validity,amount1-depositedTokens);
        t1.callBurnEvent(_to,"Burn", coverid,depositedTokens);
        td1.changeCurrencyTokens(curr,td1.getCurrencyTokens(curr) - depositedTokens);
        td1.changeBalanceOf(_to,td1.getBalanceOf(_to) - depositedTokens);
        if(td1.getBalanceOf(_to)==0)
            td1.decMemberCounter();
        td1.changeTotalSupply(td1.getTotalSupply() - depositedTokens);
        
        t1.callTransferEvent(_to, 0, depositedTokens); // notify of the event
      
    }
    function depositCN(uint coverid,uint _value,uint _days,address _to) onlyInternal
    {
        td1=NXMTokenData(tokenDataAddress);
        uint amount;
        (,amount) = td1.getLockedCN_Cover(_to,coverid);
        if (amount - td1.getDepositCN(coverid,msg.sender) < _value) throw;           // Check if the sender has enough
        if (_value<=0) throw;
        //_value = _value * 10000000000;
        td1.pushInDepositCN_Cover(_to,coverid,_days,_value);
    }
   
   
    function checkForSurplusDistrubution() constant returns(uint check)
    {
        td1=NXMTokenData(tokenDataAddress);
        m1=MCR(mcrAddress);
        check=0;
        if(td1.getSDLength()==0)
        {   
            if(m1.getlastMCRPerc() >= 18000)
                check=1;
        }
        else if((td1.getLastDistributionTime() + td1.getsdDistributionTime() < now)&&( m1.getlastMCRPerc() >= 18000))
            check=1;
        
    }

    function distributeSurplusDistrubution() 
    {
        td1=NXMTokenData(tokenDataAddress);
        t1=NXMToken(tokenAddress);
        p1=pool(poolAddress);
         t3=NXMToken3(NXMToken3Address);
         if(checkForSurplusDistrubution()==1)
         {
            uint index = td1.getSDLength();
            uint distValue = t3.calSurplusDistributionValue();
            uint totalWeight =0;
            address _add;
            uint len = td1.getAllMembersLength();
            uint i;
           
            for(i=0;i<len;i++)
            {
                 _add = td1.getMember_index(i);
                uint indWeight=t3.calIndWeightForSD(_add);
                
                if(indWeight > 0)
                    td1.addInSDMemberPayHistory(index,_add,indWeight,0);
                else
                    td1.addInSDMemberPayHistory(index,_add,0,1);
                    
                totalWeight += indWeight;
            }

            for(i=0;i<len;i++)
            {
                _add = td1.getMember_index(i);
                uint amount = (td1.getSDDistributionIndWeight(index,_add) * distValue)/totalWeight;
                if(amount > 0)
                {
                    bool succ = p1.SDPayout(amount,_add);
                    if(succ == true)
                    {
                        td1.confirmSDDistribution(index,_add);
                    }
                }
            }
            if(td1.getSDLength()==0)
                td1.pushInSDHistory(distValue,now,block.number,distValue);
            else
                td1.pushInSDHistory(distValue,now,block.number,distValue + td1.getTotalSDTillNow());
                
         }
    }
    
}