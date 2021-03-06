-- load credentials, 'SSID' and 'PASSWORD' declared and initialize in there
--dofile("credentials.lua")
dofile("startup.lua")

if adc.force_init_mode(adc.INIT_ADC)
then
  print("Configuring for ADC")
  node.restart()
  return -- don't bother continuing, the restart is scheduled
end
print("Cofigured for ADC")
print("ADC voltage (mV):", adc.read(0))

-- Define WiFi station event callbacks 
wifi_connect_event = function(T) 
  print("Connection to AP("..T.SSID..") established!")
  print("Waiting for IP address...")
  if disconnect_ct ~= nil then disconnect_ct = nil end  
end

wifi_got_ip_event = function(T) 
  -- Note: Having an IP address does not mean there is internet access!
  -- Internet connectivity can be determined with net.dns.resolve().    
  print("Wifi connection is ready! IP address is: "..T.IP)
  print("Startup will resume momentarily, you have 3 seconds to abort.")
  print("Waiting...") 
end

wifi_disconnect_event = function(T)
  if T.reason == wifi.eventmon.reason.ASSOC_LEAVE then 
    --the station has disassociated from a previously connected AP
    return 
  end
  -- total_tries: how many times the station will attempt to connect to the AP. Should consider AP reboot duration.
  local total_tries = 75
  print("\nWiFi connection to AP("..T.SSID..") has failed!")

  --There are many possible disconnect reasons, the following iterates through 
  --the list and returns the string corresponding to the disconnect reason.
  for key,val in pairs(wifi.eventmon.reason) do
    if val == T.reason then
      print("Disconnect reason: "..val.."("..key..")")
      break
    end
  end

  if disconnect_ct == nil then 
    disconnect_ct = 1 
  else
    disconnect_ct = disconnect_ct + 1 
  end
  if disconnect_ct < total_tries then 
    print("Retrying connection...(attempt "..(disconnect_ct+1).." of "..total_tries..")")
    --print("Found following networks")
    --wifi.sta.getap(listap)
  else
    wifi.sta.disconnect()
    print("Aborting connection to AP!")
    disconnect_ct = nil  
  end
end

-- Register WiFi Station event callbacks
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, wifi_connect_event)
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, wifi_got_ip_event)
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, wifi_disconnect_event)


wifi.setmode(wifi.STATIONAP)
-- print AP list in new format
function listap(t)
    for k,v in pairs(t) do
        print(k.." : "..v)
    end
end
tmr.create():alarm(3000, tmr.ALARM_SINGLE, function()
    --print("Found following networks")
    --wifi.sta.getap(listap)
end
)

cfg = {}
cfg.ssid = "test network"
cfg.pwd = "82668266"
cfg.hidden = true

wifi.ap.config(cfg)

cfg = nil

print("Currently operating in "..wifi.getmode())
print("Wifi mode is "..wifi.getphymode())
print("Wifi config is "..wifi.ap.getconfig())

tmr.create():alarm(3000, tmr.ALARM_SINGLE, startup)

function getclients()
    local clients = wifi.ap.getclient()
    print("\n\nCurrently connected clients as of "..tmr.time()..": ")
    for mac, ip in pairs(clients) do
        print(mac, ip)
    end
end

tmr.create():alarm(60000, tmr.ALARM_AUTO, getclients)


--print("Connecting to WiFi access point...")
--wifi.setmode(wifi.STATION)
--print("Attempting to connect to "..SSID.." with password "..PASSWORD)
--wifi.sta.config({ssid=SSID, pwd=PASSWORD})
-- wifi.sta.connect() not necessary because config() uses auto-connect=true by default
