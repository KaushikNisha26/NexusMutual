pragma solidity ^0.4.8;
import "./quotation.sol";
import "./NXMToken.sol";
import "./claims.sol";
import "./pool2.sol";
import "./NXMToken2.sol";
import "./master.sol";
import "./claimsData.sol";
import "./NXMToken3.sol";


contract claims_Reward{ 
    NXMToken tc1;
    NXMToken2 tc2;
     NXMToken3 tc3;
    quotation q1;
    master ms1;
    address public masterAddress;
    claims c1;
    pool2 p2;
    address public token2Address;
    address public token3Address;
    address public pool2Address;
    address public tokenAddress;
    address public quotationAddress;
    address public claimsAddress;
    
    address claimsDataAddress;
    claimsData cd1;
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
    
    function changeToken2Address(address _add) onlyInternal
    {
        token2Address = _add;
        tc2 = NXMToken2(token2Address);
    }
       function changeToken3Address(address _add) onlyInternal
    {
        token3Address = _add;
        tc3 = NXMToken3(token3Address);
    }
      function changeClaimDataAddress(address _add) onlyInternal
    {
        claimsDataAddress = _add;
    }

    function changePool2Address(address _to) onlyInternal
    {
        pool2Address = _to;
    }
     function changeTokenAddress(address newAddress) onlyInternal
    {
        tokenAddress = newAddress;
    }
      function changeQuotationAddress(address newAddress) onlyInternal
    {
        quotationAddress = newAddress;
    }
     function changeClaimsAddress(address newAddress) onlyInternal
    {
        claimsAddress = newAddress;
    }
    function changeClaimStatusCA(uint claimid) internal
    {
        c1=claims(claimsAddress);
         cd1=claimsData(claimsDataAddress);
        q1=quotation(quotationAddress);
        if(c1.checkVoteClosing(claimid)==1)
            { 
              uint status=cd1.getClaimStatus(claimid);
              uint reward_claim=0;
             uint CATokens=c1.getCATokens(claimid,0);
             uint coverid=cd1.getClaimCoverId(claimid);
             uint sumassured=q1.getSumAssured(coverid);
             uint threshold_unreached=0;
             if(CATokens<5*sumassured*1000000000000000000)
                threshold_unreached=1;
            uint accept=cd1.getClaimVote(claimid,1);
            uint deny=cd1.getClaimVote(claimid,-1);
            
            if(CATokens==0)
            {
                status=4;
                
            }
            else
            {
                
                if(accept*100/(accept+deny) > 70 &&  threshold_unreached==0)
                {
                    status=8;
                   q1.updateCoverStatus(coverid,"Claim Accepted");
                   reward_claim=1;
                }
                else if(deny*100/(accept+deny) > 70 &&  threshold_unreached==0)
                    status=1;
                else if(deny*100/(accept+deny) > accept*100/(accept+deny) &&  threshold_unreached==0)
                    status=6;
               else if(deny*100/(accept+deny) <= accept*100/(accept+deny) &&  threshold_unreached==0)
                    status=5;
                else if(deny*100/(accept+deny) > accept*100/(accept+deny) &&  threshold_unreached==1)
                    status=4;
               else if(deny*100/(accept+deny) <= accept*100/(accept+deny) &&  threshold_unreached==1)
                    status=3;
            }
            c1.setClaimStatus(claimid,status);
            if(reward_claim==1)
                rewardAgainstClaim(claimid);

        }
    }
    function changeClaimStatusMV(uint claimid) internal
    {
         c1=claims(claimsAddress);
         q1=quotation(quotationAddress);  
         cd1=claimsData(claimsDataAddress);     
        if(c1.checkVoteClosing(claimid)==1)
            { 
             bytes16 coverStatus;
             uint status_orig=cd1.getClaimStatus(claimid);
             uint status=status_orig;
             uint MVTokens=c1.getCATokens(claimid,1);
             uint coverid=cd1.getClaimCoverId(claimid);
             uint sumassured=q1.getSumAssured(coverid);
             uint threshold_unreached=0;
             if(MVTokens<5*sumassured*1000000000000000000)
                threshold_unreached=1;
            uint accept=cd1.getClaimMVote(claimid,1);
            uint deny=cd1.getClaimMVote(claimid,-1);    
            
            if(MVTokens==0 )
            {
                status=15; 
                coverStatus="Claim Denied";                
            }
            else
            {
                if(accept*100/(accept+deny) >= 50 &&  threshold_unreached==0 && status_orig==2)
                 { status=9;coverStatus="Claim Accepted";}
                else if(deny*100/(accept+deny) > 50 &&  threshold_unreached==0 && status_orig==2)
                  {  status=10;coverStatus="Claim Denied";}
                else if(  threshold_unreached==1 && status_orig==2)
                   { status=11; coverStatus="Claim Denied";}
               else if(accept*100/(accept+deny) >= 50 &&  status_orig>2 && status_orig<=6 && threshold_unreached==0)
                   { status=12; coverStatus="Claim Accepted";}
                else if(deny*100/(accept+deny) > 50 &&  status_orig>2 && status_orig<=6 && threshold_unreached==0)
                   { status=13;coverStatus="Claim Denied";}
               else if(threshold_unreached==1 &&  (status_orig==3 || status_orig==5))
                   { status=14; coverStatus="Claim Accepted";}
               else if(threshold_unreached==1 &&  (status_orig==6 || status_orig==4))
                    { status=15; coverStatus="Claim Denied";}
            }
            c1.setClaimStatus(claimid,status);
            q1.updateCoverStatus(coverid,coverStatus);
            
            rewardAgainstClaim(claimid);
        }
    }

    // function closeClaims(uint[] array)
    // {
    //     for(uint i=0;i<array.length;i++)
    //     {
    //       changeClaimStatus(array[i]);
    //     }
    // }

    function changeClaimStatus(uint claimid)
    {
        ms1=master(masterAddress);
        p2=pool2(pool2Address);
       if( ms1.isInternal(msg.sender) != 1 && ms1.isOwner(msg.sender)!=1) throw;
        c1=claims(claimsAddress);
        cd1=claimsData(claimsDataAddress);
        uint status=cd1.getClaimStatus(claimid);
        q1=quotation(quotationAddress);
        uint coverid=cd1.getClaimCoverId(claimid);
        if(status==0)
        {
            changeClaimStatusCA(claimid);
           
        }
        else if(status==1)
        {
            c1.setClaimStatus(claimid,7);
            q1.updateCoverStatus(coverid,"Claim Denied");
            rewardAgainstClaim(claimid);
        }
        else if(status>=2 && status<=6)
        {
            changeClaimStatusMV(claimid);
        }
        else if(status == 16)
        {
            bool succ = p2.sendClaimPayout(coverid,claimid);
            if(succ)
            {
                c1.setClaimStatus(claimid,18);
            }
                
        }

        c1.changePendingClaimStart();
    }
    function rewardAgainstClaim(uint claimid) internal
    {
        tc1=NXMToken(tokenAddress);
        tc2=NXMToken2(token2Address);
        bool succ;
        q1=quotation(quotationAddress);
        c1=claims(claimsAddress);
        cd1=claimsData(claimsDataAddress);
        uint coverid=cd1.getClaimCoverId(claimid);
        uint status=cd1.getClaimStatus(claimid);
        p2=pool2(pool2Address);
        tc3=NXMToken3(token3Address);
         if(status==7)
             {
                c1.changeFinalVerdict(claimid,-1);
                rewardCAVoters(claimid,100);
                 tc2.burnCNToken(coverid);
                 
             }
             if(status==8)
             {
                c1.changeFinalVerdict(claimid,1);
                rewardCAVoters(claimid,100);
                tc1.unlockCN(coverid);
                succ = p2.sendClaimPayout(coverid,claimid);
                if(!succ)
                    throw;
             }
              if(status==9)
             {
                c1.changeFinalVerdict(claimid,1);
                rewardCAVoters(claimid,50);
                rewardMVoters(claimid,50);
                tc1.unlockCN(coverid);
                succ = p2.sendClaimPayout(coverid,claimid);
                if(!succ)
                    throw;
             }
             if(status==10)
             {
                 c1.changeFinalVerdict(claimid,-1);
                 rewardCAVoters(claimid,50);
                rewardMVoters(claimid,50);
                 tc2.burnCNToken(coverid);
             }
             if(status==11)
             {
                 c1.changeFinalVerdict(claimid,-1);
                 q1.increaseClaimCount(coverid);
                rewardCAVoters(claimid,100);
                tc3.undepositCN(coverid,0);
                 tc2.burnCNToken(coverid);
             }
             if(status==12)
             {
                c1.changeFinalVerdict(claimid,1);
                 rewardMVoters(claimid,100);
                  tc1.unlockCN(coverid);
                succ = p2.sendClaimPayout(coverid,claimid);
                if(!succ)
                    throw;
             }
              if(status==13)
             {
                  c1.changeFinalVerdict(claimid,-1);
                 rewardMVoters(claimid,100);
                  tc2.burnCNToken(coverid);
             }
              if(status==14)
             {
                 
                c1.changeFinalVerdict(claimid,1);
                  tc1.unlockCN(coverid);
                succ = p2.sendClaimPayout(coverid,claimid);
                if(!succ)
                    throw;
             }
              if(status==15)
             {
                 
                 c1.changeFinalVerdict(claimid,-1);
                 tc2.burnCNToken(coverid);
             }
             
              
             
    }
    uint[] public checkarray;
    function rewardCAVoters(uint claimid,uint perc) internal
    {
         q1=quotation(quotationAddress);
             tc1=NXMToken(tokenAddress);
             tc2=NXMToken2(token2Address);
             cd1=claimsData(claimsDataAddress);
              uint tokenx1e18=tc1.getTokenPrice("ETH");
             c1=claims(claimsAddress);
             
             uint sumassured=q1.getSumAssured(cd1.getClaimCoverId(claimid))*1000000000000000000;
         
             uint distributableTokens=sumassured*perc/(100*100*tokenx1e18); //1% of sum assured
             uint token_re;
             uint consesnsus_perc;
             
             uint accept=cd1.getClaimVote(claimid,1);
              uint deny=cd1.getClaimVote(claimid,-1);
              
                
                
                for(uint i=0;i<c1.getClaimVoteLength(claimid,1);i++)
                { 
                    
                      if(cd1.getvoteVerdict(claimid,i,1)==1 )
                      { 
                        if(cd1.getFinalVerdict(claimid)==1)
                        {
                          token_re=distributableTokens*c1.getvoteToken(claimid,i,1) /(accept);
                          tc2.rewardToken(c1.getvoteVoter(claimid,i,1),token_re);
                          c1.updateRewardCA(claimid,i,token_re);
                        }
                        else
                        {
                          consesnsus_perc=deny*100/(accept+deny);
                          if(consesnsus_perc>70)
                            consesnsus_perc=consesnsus_perc-70;

                          uint tokens = c1.getvoteToken(claimid,i,1)/10000000000;
                          tc2.extendCAWithAddress(c1.getvoteVoter(claimid,i,1),(consesnsus_perc)*12*60*60,tokens);
                        }
                      }
                      else if(cd1.getvoteVerdict(claimid,i,1)==-1)
                      {
                        if(cd1.getFinalVerdict(claimid)==-1)
                        {
                          token_re=distributableTokens*c1.getvoteToken(claimid,i,1) /(deny);
                          tc2.rewardToken(c1.getvoteVoter(claimid,i,1),token_re);
                          c1.updateRewardCA(claimid,i,token_re);
                        }
                        else
                        {
                          consesnsus_perc=accept*100/(accept+deny);
                          if(consesnsus_perc>70)
                            consesnsus_perc=(consesnsus_perc-70)*12*3600;
                          else
                            consesnsus_perc=consesnsus_perc*12*3600;
                        
                        uint token1 = c1.getvoteToken(claimid,i,1)/10000000000;
                        checkarray.push(consesnsus_perc*12*60*60);
                        checkarray.push(token1);
                        tc2.extendCAWithAddress(c1.getvoteVoter(claimid,i,1),consesnsus_perc,token1);
                        }
                      }
                    
                }
                
             
    }
     function rewardMVoters(uint claimid,uint perc) internal
    {
         q1=quotation(quotationAddress);
             tc1=NXMToken(tokenAddress);
             tc2=NXMToken2(token2Address);
             tc3=NXMToken3(token3Address);
             c1=claims(claimsAddress);
              uint tokenx1e18=tc1.getTokenPrice("ETH");
            cd1=claimsData(claimsDataAddress);
               uint coverid=cd1.getClaimCoverId(claimid);
             uint sumassured=q1.getSumAssured(coverid)*1000000000000000000;
             uint distributableTokens=sumassured*perc/(100*100*tokenx1e18);
            //  uint distributableTokens=10*sumassured*perc/tokenx10000; //1% of sum assured
             uint token_re;
              uint accept=cd1.getClaimMVote(claimid,1);
           uint deny=cd1.getClaimMVote(claimid,-1);
            
                for(uint i=0;i<c1.getClaimVoteLength(claimid,0);i++)
                {
                      address voter=c1.getvoteVoter(claimid,i,0);
                      uint token=c1.getvoteToken(claimid,i,0);

                      if(cd1.getvoteVerdict(claimid,i,0)==1 )
                      { 
                          if(cd1.getFinalVerdict(claimid)==1)
                          {
                              token_re=distributableTokens * token/(accept);
                              tc2.rewardToken(voter,token_re);
                              c1.updateRewardMV(claimid,i,token_re);
                          }
                          else
                          {

                              tc3.lockSDWithAddress(voter,3,token/10000000000);
                              // to be written
                          }
                      }
                      else if(cd1.getvoteVerdict(claimid,i,0)==-1)
                      {
                          if(cd1.getFinalVerdict(claimid)==-1)
                          {
                              token_re=distributableTokens * token/(deny);
                              tc2.rewardToken(voter,token_re);
                              c1.updateRewardMV(claimid,i,token_re);
                          }
                          else
                          {
                           tc3.lockSDWithAddress(voter,3,token/10000000000);
                              // to be written
                          }
                      }
                      
                }
                
             
    }
  
}