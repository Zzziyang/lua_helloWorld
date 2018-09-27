local campaignID =10100
local mobileID 


Test_021_SOTA = {} --class


  function Test_021_SOTA:Test_001_connection()
        assertNotNil(g_sotaServer)
  end
    

  
  function Test_021_SOTA:Test_002_version()
        local success, version = assert(g_sotaServer:getServiceVersion())
        print(version)
  end
    


  function Test_021_SOTA:Test_003_CreateCampaign()
        local success, Cid
        success, Cid = assert(g_sotaServer:CreateCampaign(00050806, "test", "//OTT-ZIYANGS/Users/zshen/Desktop/position/position_package.idppkg", 
                                                               false, "", "", "", --FTP config
                                                               false, false, false, false, false, false, false, false, ""))
                                                               
        print(string.format("Created campaign ID is %s",Cid))       
        campaignID = tonumber(Cid)
  end
    


  function Test_021_SOTA:Test_004_AddMobilesToCampaign()
    local success  
      success, mobileIDs = assert(g_sotaServer:AddMobilesToCampaign(campaignID,{"01093656SKYBEB5"}))
      if mobileIDs ~= nil then
      io.write("Added mobileID is :") 
        for i = 1, #mobileIDs do 
          assert(mobileIDs[i][1][1] == "0", mobileIDs[i][2][1]) 
          print(string.format("%s \n",mobileIDs[i][3][1]))
          end 
    end    
  end
    

 
  function Test_021_SOTA:Test_005_StartMobileCampaign()
    local success,errorMessage = assert(g_sotaServer:StartMobileCampaign(campaignID,"01093656SKYBEB5")  )
    if success then print("Started Campaign on mobile") end
   end
    


   function Test_021_SOTA:Test_006_DeleteMobileCampaign()
    local success,errormessage = assert(g_sotaServer:DeleteMobileCampaign(campaignID,"01093656SKYBEB5")  )
  end
    


    --check the state machine first by calling QueryMobileCanoaignState
    --if the state is not ready to be activated, which means if the state is not in validated, the activate fucntion would fail anyway
    --if the state is ready, then everything is fine
   function Test_021_SOTA:Test_007_ActivateMobileCampaign()
    local check, mobilestate=assert(g_sotaServer:QueryMobileCampaignState(campaignID,"01093656SKYBEB5"))
    if mobilestate~= "validated" then 
      print(string.format("Cannot activate, not in validated state, %s state currently",mobilestate)) end     
    local success,avtivatedOrNot = assert(g_sotaServer:ActivateMobileCampaign(campaignID,"01093656SKYBEB5"))
   end
    


  --check the state machine by calling WueryMobileState
  --if the state is not ready to be commited, the state is not in activated,commit function would fail
  function Test_021_SOTA:Test_008_CommitMobileCampaign()
     local check, mobilestate=assert(g_sotaServer:QueryMobileCampaignState(campaignID,"01093656SKYBEB5"))
     if mobilestate~= "activated" then 
      print(string.format("Cannot commit, not in activated state, %s state currently",mobilestate)) end     
     local success,commitOrNot = assert(g_sotaServer:CommitMobileCampaign(campaignID, "01093656SKYBEB5"))
    
  end
    

  
  function Test_021_SOTA:Test_009_RevertMobileCampaign()
    local check, mobilestate=assert(g_sotaServer:QueryMobileCampaignState(campaignID,"01093656SKYBEB5"))
    if mobilestate~= "activated" then 
      print(string.format("Cannot revert, not in activated state, %s state currently",mobilestate)) 
    end     
    local success,revertOrNot = assert(g_sotaServer:RevertMobileCampaign(campaignID,"01093656SKYBEB5"))
  end
    

      
  function Test_021_SOTA:Test_010_StopMobileCampaign()
    local check, mobilestate=assert(g_sotaServer:QueryMobileCampaignState(campaignID,"01093656SKYBEB5"))
      if mobilestate ~= "starting" and mobilestate ~= "loading" and  mobilestate ~= "activating"then
        print(string.format("Cannot stop, not in right state, %s state currently",mobilestate))
      end     
    local success,error = assert(g_sotaServer:StopMobileCampaign(campaignID,"01093656SKYBEB5") )
  end    
    

   
  function Test_021_SOTA:Test_011_CloseCampaign()
    local success,close
    success,close = assert(g_sotaServer:CloseCampaign(campaignID))
  end
    

   
  function Test_021_SOTA:Test_012_RemoveCampaign()
    local success,close = assert(g_sotaServer:RemoveCampaign(campaignID))
  end
    

---outputs are Campaign detail
  function Test_021_SOTA:Test_013_QueryCampaignDetail()
    local scuess,detailQuery = assert(g_sotaServer:QueryCampaignDetail(campaignID,"01093656SKYBEB5"))
    local backchannel,billable,campaignid,fragcount,fragsize,
    iscellonly,iscustomerhide,iscustomerreadonly,name,packagehash,
    packagename,packagesize,preserveconfig,preservedata
    backchannel        =   detailQuery[3][1]
    billable           =   detailQuery[4][1]
    campaignid         =   detailQuery[5][1]
    fragcount          =   detailQuery[6][1]
    fragsize           =   detailQuery[7][1]
    iscellonly         =   detailQuery[8][1]
    iscustomerhide     =   detailQuery[9][1]
    iscustomerreadonly =   detailQuery[10][1]
    name               =   detailQuery[11][1]
    packagehash        =   detailQuery[12][1]
    packagename        =   detailQuery[13][1]
    packagesize        =   detailQuery[14][1]
    preserveconfig     =   detailQuery[15][1]
    preservedata       =   detailQuery[16][1]
    size = #detailQuery
    for i =3, size-2  do 
    print(detailQuery[i][1]) end
  end
    


  function Test_021_SOTA:Test_014_QueryCampaignState()
    local success,status = assert(g_sotaServer:QueryCampaignState(campaignID))
    print(status)
  end
    

    
  function Test_021_SOTA:Test_015_QueryMobileCampaignState()
    local success, state = assert(g_sotaServer:QueryMobileCampaignState(campaignID,"01093656SKYBEB5"))
    print(state)
  end
 
  

  function Test_021_SOTA:Test_016_QueryLoadingProgress()  
    local success,loadingstate
    success,loadingstate = assert(g_sotaServer:QueryLoadingProgress(10098,"01093656SKYBEB5"))
    if type(loadingstate)~= "string" then print("not loading") else print(loadingstate) end
  end 
   



   function Test_021_SOTA:Test_017_QueryMobileIdsOfCampaign()
    local success, mobileIDs = assert(g_sotaServer:QueryMobileIdsOfCampaign(campaignID))
    if mobileIDs ~= nil then
    print(string.format("Mobile added on Campaign is %s \n",mobileIDs[1][1]))
    end
  end