pragma solidity ^0.4.8;

import "./quotation.sol";
import "./NXMToken.sol";
import "./NXMToken2.sol";
import "./pool.sol";
import "./claims_Reward.sol";
import "./claimsData.sol";
import "./claims.sol";
import "./master.sol";

contract claims2{

    quotation q1;
    NXMToken tc1;
    NXMToken2 tc2;
    pool p1;
    claims_Reward cr1;
    claimsData cd1;
    master ms1;
    address masterAddress;
    claims c1;
    address quotationAddress;
    address tokenAddress;
    address token2Address;
    address poolAddress;
    address claims_RewardAddress;
    address claimsDataAddress;
    address claimsAddress;

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
    function changeToken2Address(address _Add) onlyInternal
    {
        token2Address = _Add;
        tc2=NXMToken2(token2Address);
    }
    function changeQuotationAddress(address _add) onlyInternal
    {
        quotationAddress = _add;
        c1 = claims(claimsAddress);
        c1.changeQuotationAddress(_add);
    }
    function changeTokenAddress(address _add) onlyInternal
    {
        tokenAddress =_add;
        c1 = claims(claimsAddress);
        c1.changeTokenAddress(_add);
    }
    function changePoolAddress(address _add) onlyInternal
    {
        poolAddress = _add;
    }
    function changeClaimRewardAddress(address _add) onlyInternal
    {
        claims_RewardAddress = _add;
    }
    function changeClaimDataAddress(address _add) onlyInternal
    {
        claimsDataAddress = _add;
        cd1 = claimsData(claimsDataAddress);
    }
    function changeClaimAddress(address _add) onlyInternal
    {
        claimsAddress = _add;
        c1 = claims(claimsAddress);
    }

    function submitClaim(uint coverid) 
    {
        
        q1=quotation(quotationAddress);
        address qadd=q1.getMemberAddress(coverid);
        if(qadd != msg.sender) throw;
        tc1=NXMToken(tokenAddress);
         tc2=NXMToken2(token2Address);
        cd1=claimsData(claimsDataAddress);
        uint tokens = q1.getLockedTokens(coverid);
        tokens = tokens*20/100;
        uint timeStamp = now + 1*7 days;
        tc2.depositCN(coverid,tokens,timeStamp,msg.sender);
        uint len = cd1.actualClaimLength();
        cd1.setClaimLength(len+1);
       
        cd1.addClaim(len , coverid , now,0,0,now,0);
        cd1.addClaim_sender(msg.sender,len);
        cd1.addClaimStatus(len,0,now,block.number);
        cd1.addCover_Claim(coverid,len);
        q1.updateCoverStatusAndCount(coverid,"Claim Submitted");
        p1=pool(poolAddress);
        p1.closeClaimsOraclise(len,cd1.maxtime());
        
    }
    function submitCAVote(uint claimid,int verdict,uint tokens)
    {  
        cd1=claimsData(claimsDataAddress);
        c1 = claims(claimsAddress);
        if(c1.checkVoteClosing(claimid) == 1) throw;
        if(cd1.getClaimStatus(claimid) != 0) throw;
        if(cd1.getvote_ca(claimid,msg.sender) != 0) throw;
        tc1=NXMToken(tokenAddress);
        tc1.bookCATokens(msg.sender , tokens);
        cd1.addVote(msg.sender,tokens,claimid,verdict,now,0);
        uint vote_length=cd1.vote_length();
        cd1.addclaim_vote_ca(claimid,vote_length);
        cd1.setvote_ca(msg.sender,claimid,vote_length);
        cd1.addvote_address_ca(msg.sender,vote_length);
        cd1.setvote_length(vote_length+1);
        
        cd1.setclaim_tokensCA(claimid,verdict,tokens);
        

        int close = c1.checkVoteClosing(claimid);
        if(close==1)
        {
            cr1=claims_Reward(claims_RewardAddress);
            cr1.changeClaimStatus(claimid);
        }

    }

    function escalateClaim(uint coverId , uint claimId)
    {  
        tc2 = NXMToken2(token2Address);
        q1=quotation(quotationAddress);
        tc1=NXMToken(tokenAddress);
        address qadd=q1.getMemberAddress(coverId);
        if(qadd != msg.sender) throw;
        uint tokens = q1.getLockedTokens(coverId);
        tokens = tokens*20/100;
        cd1=claimsData(claimsDataAddress);
        uint d=864000 * cd1.escalationTime() ;
        uint timeStamp = now + d;
        tc2.depositCN(coverId,tokens,timeStamp,msg.sender);
         c1 = claims(claimsAddress);
        c1.setClaimStatus(claimId,2);
        q1.updateCoverStatusAndCount(coverId,"Claim Submitted");
        p1=pool(poolAddress);
        p1.closeClaimsOraclise(claimId,cd1.maxtime());
    } 
    function submitMemberVote(uint claimid,int verdict,uint tokens)
    {
         cd1=claimsData(claimsDataAddress);
         c1 = claims(claimsAddress);
        if(c1.checkVoteClosing(claimid) == 1) throw;
        uint stat=cd1.getClaimStatus(claimid);
       if(stat <2 || stat >6) throw;
        if(cd1.getvote_member(claimid,msg.sender) != 0) throw;
         uint vote_length=cd1.vote_length();
        cd1.addVote(msg.sender,tokens,claimid,verdict,now,0);
        cd1.addclaim_vote_member(claimid,vote_length);
        cd1.setvote_member(msg.sender,claimid,vote_length);
        cd1.addvote_address_member(msg.sender,vote_length);
        cd1.setvote_length(vote_length+1);
      
        cd1.setclaim_tokensMV(claimid,verdict,tokens);
        
        

        int close = c1.checkVoteClosing(claimid);
        if(close==1)
        {
            cr1=claims_Reward(claims_RewardAddress);
            cr1.changeClaimStatus(claimid);
        }
        
    }
}