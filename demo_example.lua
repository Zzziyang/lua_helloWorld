module(..., package.seeall)

_VERSION = "1.0.0"

local messageHandle


--
--Send fix message
--
local function sendFixInfo(fixInfo)
  local id, err = messageHandle:send(2, { Latitude = fixInfo.latitude, Longitude = fixInfo.longitude })
  if err == nil then
    printf("sent fixInfo success\n")
  else
    printf("%s: fixInfo failed with error: %s\n", _NAME, err)
  end  
end

--
-- Received to-mobile message "RequestEcho"
--
local function receivedRequestEcho(message)      
  printf("%s: received RequestEcho with text: %s\n", _NAME, message.fields.longText)
  sendRespondEcho(message.fields.longText)    
end

--
-- Send from-mobile message "RespondEcho"
--
function sendRespondEcho(text)
  local min = 1
  local id, err = messageHandle:send(min, { shortText = text })
  if err == nil then
    printf("%s: sent RespondEcho with text: %s\n", _NAME, text)
  else
    printf("%s: RespondEcho failed with error: %s\n", _NAME, err)
  end  
end

--
-- Run service
--
function entry()
  printf("%s: service started\n", _NAME)
  
  -- initialize queues
  local messageQ = sched.createEventQ(5, messageHandle, 'RX_DECODED')
  
  -- check for to-mobile message received
  while true do
    local q, event, args = sched.waitQ(-1, messageQ)
    if q == messageQ then
      local message = args
      if message.min == 1 then
        receivedRequestEcho(message)
      elseif message.min == 2 then
          if properties.enableSendPosition then
              printf("GPS fix request\n")
              svc.position.requestFix("3D", 1, 60, sendFixInfo)
          end
      end
    end
  end
end

--
-- Initialize service
--
function init()
  messageHandle = svc.message.register(_SIN)  
end