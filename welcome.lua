--[[

#Welcome!

ZeroBrane Studio is a **simple** and **friendly** environment to learn and explore programming, graphics, games, and other topics. Start with the lessons or go straight to the demonstrations to see what you can create.

#Lessons
- [ZeroBrane Studio basics](+zerobrane-lessons/01-zb-start.lua)
- [Programming basics](+programming-lessons/01-progr-start.lua)

#Demos
- [Turtle graphics demo](+turtle-samples/demo.lua)
- [Spirograph graphics demo](+spirograph-samples/demo.lua)
- [Scratchpad demo](+livecoding-samples/demo.lua)
- [LÖVE demo](+LOVE-samples/demo.lua)
- [Gideros demo](+gideros-samples/demo.lua)
- [Moai demo](+moai-samples/demo.lua)
- [Corona SDK demo](+corona-samples/demo.lua)
- [Conway Life demo](+conwaylife-samples/demo.lua)

#Other resources
- [Lua quick start guide](+quick-start.lua)
]]
-----------------------
--Automated Testing Tool
--Idle Power Test Case
--Date: 10/01/2017
--Author: Taranjeet Singh
--Comments: 
-----------------------
local TPC = require("Communication.Hardware.tpc")

local tpcInstance

local OGi_IDLE = 0.01
local OGi_SLEEP = 0.001
local OGi_RX = 0.07
local OGi_TX = 0.8
local OGi_BOOT = 0.03
local OGi_GPS = 0.068
                                
Test_000_Power_Sanity = {} --class

    function Test_000_Power_Sanity:Setup()        
        --LuaUnit.skip(threshold[g_Terminal.platform] == nil, "Next Gen product test only")                
        assert(g_Relay.set(g_Terminal.testConfig.relaySN,1)) 
        local success
        success, tpcInstance = TPC.init(g_Terminal.accountSettings.powerApp.path, g_Terminal.accountSettings.powerApp.serial)       
        assert(success, tpcInstance)                       
    end
    
    function Test_000_Power_Sanity:TearDown()        
        assert(tpcInstance:deinit())
        assert(g_ATParser.goTo())
        --assert(g_Relay.set(g_Terminal.testConfig.relaySN,0)) 
    end
    
    function Test_000_Power_Sanity:Test_001_Idle()
    
        --Benchmark maximum threshold values
        local maxCurrent = {
                              OGi = OGi_IDLE * 5, 
                              ST6 = 0.0
                           }
    
        --Go to HWTest menu to get Idle current
        assert(g_CliParser.goTo(g_CliParser.interface.HWTEST),"HWTest Menu not reachable")
        
        --Start power sampling for 5 seconds
        assert(tpcInstance:setup("Current", 0.2, 5, 0, "100 mA", 0, 0.1,  0), "tpcInstance setup failed")  
        assert(tpcInstance:start())
        
        --Wait for power sampling to end and get status
        sleep(10)
        assert(tpcInstance:stop())        
        local success, statusTable = tpcInstance:status()
        assert(success, statusTable)
        
        --Check if total coulomb value exceeds threshold
        local CpM, CpH, CpD, Cacc =   statusTable.Coulombs.CpM, statusTable.Coulombs.CpH, statusTable.Coulombs.CpD, statusTable.Coulombs.Cacc
        print("File Location: "..statusTable.OutputFile)
        print("CpM: "..CpM.."\nCpH: "..CpH.."\nCpD: "..CpD.."\nCacc: "..Cacc)
        assertRange(Cacc, 0, maxCurrent[g_Terminal.platform],   "Power sampling out of range.")   
    end
    
    function Test_000_Power_Sanity:Test_002_Sleep()
    
        --Benchmark maximum threshold values
        local maxCurrent = {
                                OGi = OGi_SLEEP * 5, 
                                ST6 = 0.0
                            }
    
        --Go to HWTest menu and issue sleep command
        assert(g_CliParser.goTo(g_CliParser.interface.HWTEST),"HWTest Menu not reachable")   
        g_CliParser.serialWriteLn("power sleep 10000")
        g_CliParser.serialReadUntil("Entering sleep for")
        
        --Start power sampling for 5 seconds
        assert(tpcInstance:setup("Current", 0.2, 5, 0, "100 mA", 0, 0.1,  0), "tpcInstance setup failed")    
        assert(tpcInstance:start())
        
        --Wait for power sampling to end and get status
        sleep(10)
        assert(tpcInstance:stop())
        local success, statusTable = tpcInstance:status()
        assert(success, statusTable)
        
        --Check if total coulomb value exceeds threshold
        local CpM, CpH, CpD, Cacc =   statusTable.Coulombs.CpM, statusTable.Coulombs.CpH, statusTable.Coulombs.CpD, statusTable.Coulombs.Cacc
        print("File Location: "..statusTable.OutputFile)
        print("CpM: "..CpM.."\nCpH: "..CpH.."\nCpD: "..CpD.."\nCacc: "..Cacc)   
        assertRange(Cacc, 0, maxCurrent[g_Terminal.platform],   "Power sampling out of range.")  
        
        --Get prompt again.   
        g_CliParser.serialReadUntil("hwtest")
    end
    
    function Test_000_Power_Sanity:Test_003_Receive()
    
        --Benchmark maximum threshold values
        local maxCurrent = {
                                OGi = OGi_RX * 1 + OGi_IDLE * 9, --Receive is 1 sec with FI loading and decoding overhead. 
                                ST6 = 0.0
                            }
    
        --Go to Factory menu to issue ppsm rx command        
        assert(g_ATParser.checkRegistration(), "ERR: Failed registration") 
        assert(g_CliParser.goTo(g_CliParser.interface.MODEM_FACTORY),"Modem_Factory Menu not reachable")
        local success, response = g_CliParser.checkSuccess("?")
        assert(success, response)
        if not rex.find(response, "ppsm") then
            assert(g_CliParser.checkSuccess("debug")) 
        end 
        
        g_CliParser.checkSuccess("ppsm rxfreq 1533685000")       
        g_CliParser.checkSuccess("ppsm bs f")
        sleep(20)
        
        --Start power sampling for 10 seconds
        assert(tpcInstance:setup("Current", 0.2, 10, 0, "100 mA", 0, 0.1,  0), "tpcInstance setup failed")
        assert(tpcInstance:start())
        sleep(1)
        g_CliParser.checkSuccess("ppsm rx f 0")
        
        --Wait for power sampling to end and get status
        sleep(20)        
        assert(tpcInstance:stop())             
        local success, statusTable = tpcInstance:status()   
        assert(success, statusTable)
        
        --Check if total coulomb value exceeds threshold
        local CpM, CpH, CpD, Cacc =   statusTable.Coulombs.CpM, statusTable.Coulombs.CpH, statusTable.Coulombs.CpD, statusTable.Coulombs.Cacc
        print("File Location: "..statusTable.OutputFile)
        print("CpM: "..CpM.."\nCpH: "..CpH.."\nCpD: "..CpD.."\nCacc: "..Cacc)   
        assertRange(Cacc, 0, maxCurrent[g_Terminal.platform],   "Power sampling out of range.")  
    end
    
    function Test_000_Power_Sanity:Test_004_Transmit()
    
        --Benchmark maximum threshold values
        local maxCurrent = {
                                OGi = OGi_TX * 0.5 + OGi_IDLE * 14.5,
                                ST6 = 0.0
                            }
    
        --Go to Factory menu to issue ppsm tx command  
        assert(g_ATParser.checkRegistration(), "ERR: Failed registration") 
        assert(g_CliParser.goTo(g_CliParser.interface.MODEM_FACTORY),"Modem_Factory Menu not reachable")
        local success, response = g_CliParser.checkSuccess("?")
        assert(success, response)
        if not rex.find(response, "ppsm") then
            assert(g_CliParser.checkSuccess("debug")) 
        end 
           
        assert(g_CliParser.checkSuccess("ppsm rxfreq 1533685000")) --Set Rx frequency
        assert(g_CliParser.checkSuccess("ppsm txfreq 1635190000")) --Set Rx frequency
        assert(g_CliParser.checkSuccess("ppsm bs f")) --Do a beam search (forward link)
        sleep(20)
        
        --Start power sampling for 10 seconds    
        assert(tpcInstance:setup("Current", 0.2, 15, 0, "3 A", 0, 1,  0), "tpcInstance setup failed")       
        assert(tpcInstance:start()) 
        sleep(1)    
        assert(g_CliParser.checkSuccess("ppsm mtxrx tx 7 "))   --Do a trasmit on slot 7
        
        --Wait for power sampling to end and get status
        sleep(20)        
        assert(tpcInstance:stop())             
        local success, statusTable = tpcInstance:status()   
        assert(success, statusTable)
        
        --Check if total coulomb value exceeds threshold
        local CpM, CpH, CpD, Cacc =   statusTable.Coulombs.CpM, statusTable.Coulombs.CpH, statusTable.Coulombs.CpD, statusTable.Coulombs.Cacc
        print("File Location: "..statusTable.OutputFile)
        print("CpM: "..CpM.."\nCpH: "..CpH.."\nCpD: "..CpD.."\nCacc: "..Cacc)   
        assertRange(Cacc, 0, maxCurrent[g_Terminal.platform],   "Power sampling out of range.") 
    end
    
    function Test_000_Power_Sanity:Test_005_Reset()

        --Benchmark maximum threshold values
        local maxCurrent = {
                                OGi = OGi_BOOT * 5 + OGi_GPS * 50 + OGi_RX * 4 + OGi_TX * 0.5 + OGi_IDLE * 11,
                                ST6 = 0.0
                            }
    
        --Go to HWTest menu to issue reset command
        assert(g_CliParser.goTo(g_CliParser.interface.HWTEST),"HWTest Menu not reachable")
        
        --Start power sampling 
        assert(tpcInstance:setup("Current", 0.2, 500, 0, "1 A", 0, 1,  0), "tpcInstance setup failed")    
        assert(tpcInstance:start())
        g_CliParser.serialWriteLn("reset")
        sleep(2)        
        
        assert(g_ATParser.goTo(),"Failed to reach AT interface")
        assert(g_ATParser.configure(), "Failed to configure AT interface")
        assert(g_ATParser.checkRegistration(), "ERR: Failed registration")  
        
        --Wait for power sampling to end and get status      
        assert(tpcInstance:stop())
        local success, statusTable = tpcInstance:status()   
        assert(success, statusTable)
        
        --Check if total coulomb value exceeds threshold
        local CpM, CpH, CpD, Cacc =   statusTable.Coulombs.CpM, statusTable.Coulombs.CpH, statusTable.Coulombs.CpD, statusTable.Coulombs.Cacc
        print("File Location: "..statusTable.OutputFile)
        print("CpM: "..CpM.."\nCpH: "..CpH.."\nCpD: "..CpD.."\nCacc: "..Cacc)   
        assertRange(Cacc, 0, maxCurrent[g_Terminal.platform],   "Power sampling out of range.") 
    end
    
    function Test_000_Power_Sanity:Test_006_GPS_Power()
        
        --Benchmark maximum threshold values
        local maxCurrent = {
                                OGi = OGi_GPS * 5,
                                ST6 = 0.0
                            }
        
        --Go to HWTest menu to issue ublox command
        assert(g_CliParser.goTo(g_CliParser.interface.HWTEST),"HWTest Menu not reachable")   
        assert(g_CliParser.checkSuccess("ublox on"))
        
        
        --Start power sampling 
        assert(tpcInstance:setup("Current", 0.2, 5, 0, "100 mA", 0, 0.1,  0), "tpcInstance setup failed") 
        assert(tpcInstance:start())
        sleep(10)
        
        --Wait for power sampling to end and get status  
        --assert(tpcInstance:stop())
        local success, statusTable = tpcInstance:status()   
        assert(success, statusTable)
        
        --Check if total coulomb value exceeds threshold
        local CpM, CpH, CpD, Cacc =   statusTable.Coulombs.CpM, statusTable.Coulombs.CpH, statusTable.Coulombs.CpD, statusTable.Coulombs.Cacc
        print("File Location: "..statusTable.OutputFile)
        print("CpM: "..CpM.."\nCpH: "..CpH.."\nCpD: "..CpD.."\nCacc: "..Cacc)   
        assertRange(Cacc, 0, maxCurrent[g_Terminal.platform],   "Power sampling out of range.") 
        
        g_CliParser.checkSuccess("ublox off")           
    end
    
    function Test_000_Power_Sanity:Test_007_GPS_Fix()
    
        --Benchmark maximum threshold values
        local maxCurrent = {
                                OGi = OGi_BOOT * 5 + OGi_GPS * 40, --Only 40 seconds here because we are not waiting for 1pps.
                                ST6 = 0.0
                            }
    
        --Go to HWTest menu to issue reset command
        assert(g_CliParser.goTo(g_CliParser.interface.HWTEST),"HWTest Menu not reachable")   
        g_CliParser.serialWriteLn("reset")    
        
        --Start power sampling 
        assert(tpcInstance:setup("Current", 0.2, 300, 0, "100 mA", 0, 0.1,  0), "tpcInstance setup failed")      
        assert(tpcInstance:start())
        
        --Wait for power sampling to end and get status  
        assert(g_ATParser.goTo(),"Failed to reach AT interface")
        assert(g_ATParser.configure(), "Failed to configure AT interface")
        repeat
            local success, atResponse = g_ATParser.getResponse("AT%EVNT=4,1")
            assert(success, atResponse)
            sleep(1)
        until not rex.find(atResponse, "[ \n\t]*ERROR[ \n\t]*" )
        assert(tpcInstance:stop())             
        local success, statusTable = tpcInstance:status()   
        assert(success, statusTable)
        
        --Check if total coulomb value exceeds threshold
        local CpM, CpH, CpD, Cacc =   statusTable.Coulombs.CpM, statusTable.Coulombs.CpH, statusTable.Coulombs.CpD, statusTable.Coulombs.Cacc
        print("File Location: "..statusTable.OutputFile)
        print("CpM: "..CpM.."\nCpH: "..CpH.."\nCpD: "..CpD.."\nCacc: "..Cacc)   
        assertRange(Cacc, 0, maxCurrent[g_Terminal.platform],   "Power sampling out of range.") 
    end
    
--Test_000_Power_Sanity
LuaUnit:run("Test_000_Power_Sanity")
