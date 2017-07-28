pragma solidity ^0.4.8;

import "./master.sol";

contract master3 {
  master ms1;
  address masterAddress;

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

    modifier onlyOwner{
        ms1=master(masterAddress);
        require(ms1.isOwner(msg.sender) == 1);
        _; 
    }

    modifier onlyInternal {
        ms1=master(masterAddress);
        require(ms1.isInternal(msg.sender) == 1);
        _; 
    }
   
function changeAllAddress1(uint version) onlyInternal
    {
        ms1=master(masterAddress);
        ms1.addRemoveAddress(version,0);
        ms1.addRemoveAddress(version,1);
        ms1.addRemoveAddress(version,2);
        ms1.addRemoveAddress(version,3);
        ms1.addRemoveAddress(version,4);
        ms1.addRemoveAddress(version,5);
        ms1.addRemoveAddress(version,6);
        ms1.addRemoveAddress(version,7);
        ms1.addRemoveAddress(version,8);
        ms1.addRemoveAddress(version,9);
        ms1.addRemoveAddress(version,10);
        ms1.addRemoveAddress(version,11);
        ms1.addRemoveAddress(version,12);
       

       
         
    }

    function changeAllAddress2(uint version) onlyInternal
    {
        ms1=master(masterAddress);
        
        ms1.addRemoveAddress(version,13);
        ms1.addRemoveAddress(version,14);
        ms1.addRemoveAddress(version,15);
        ms1.addRemoveAddress(version,16);
        ms1.addRemoveAddress(version,17);
        ms1.addRemoveAddress(version,18);
        ms1.addRemoveAddress(version,19);
        ms1.addRemoveAddress(version,20);
        ms1.addRemoveAddress(version,21);
        ms1.addRemoveAddress(version,22);
        ms1.addRemoveAddress(version,23);
        ms1.addRemoveAddress(version,24);
        ms1.addRemoveAddress(version,25);

       
         
    }
    function addNewVersion(address[] arr) onlyOwner
    {
       ms1=master(masterAddress);
        uint versionNo = ms1.versionLength();
        ms1.setVersionLength(versionNo+1);
         
        ms1.addContractDetails(versionNo,"Masters",masterAddress);
        ms1.addContractDetails(versionNo,"QuotationData",arr[0]);
        ms1.addContractDetails(versionNo,"TokenData",arr[1]);
        ms1.addContractDetails(versionNo,"ClaimData",arr[2]);
        ms1.addContractDetails(versionNo,"PoolData",arr[3]);
        ms1.addContractDetails(versionNo,"GovernanceData",arr[4]);
        ms1.addContractDetails(versionNo,"MCRData",arr[5]);
        ms1.addContractDetails(versionNo,"Quotation",arr[6]);
        ms1.addContractDetails(versionNo,"Quotation2",arr[7]);
        ms1.addContractDetails(versionNo,"NXMToken",arr[8]);
        ms1.addContractDetails(versionNo,"NXMToken2",arr[9]);
        ms1.addContractDetails(versionNo,"Claims",arr[10]);
        ms1.addContractDetails(versionNo,"Claims2",arr[11]);
        ms1.addContractDetails(versionNo,"ClaimsReward",arr[12]);
        
       
        
    }
     function addNewVersion2(uint versionNo,address[] arr) onlyOwner
    {
       ms1=master(masterAddress);
       
        ms1.addContractDetails(versionNo,"Pool",arr[0]);
        ms1.addContractDetails(versionNo,"Governance",arr[1]);
        ms1.addContractDetails(versionNo,"Governance2",arr[2]);
        ms1.addContractDetails(versionNo,"FiatFaucet",arr[3]);
        ms1.addContractDetails(versionNo,"Pool2",arr[4]);
        ms1.addContractDetails(versionNo,"FaucetUSD",arr[5]);
        ms1.addContractDetails(versionNo,"FaucetEUR",arr[6]);
        ms1.addContractDetails(versionNo,"FaucetGBP",arr[7]);
        ms1.addContractDetails(versionNo,"Masters2",arr[8]);
        ms1.addContractDetails(versionNo,"NXMToken3",arr[9]);
        ms1.addContractDetails(versionNo,"MCR",arr[10]);
        ms1.addContractDetails(versionNo,"Master3",arr[11]);
        
    }
}