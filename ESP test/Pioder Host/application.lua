-- Pin definition 
local outpin = 1--            --  GPIO01
local inpin = 2
local status = gpio.LOW
local duration = 1000    -- 1 second duration for timer

-- Initialising pin
gpio.mode(outpin, gpio.OUTPUT)
gpio.write(outpin, status)

gpio.mode(inpin, gpio.INPUT)
print("In application.lua!")

--function toggle()
--    if status == gpio.LOW then
--        status = gpio.HIGH
--    else
--        status = gpio.LOW
--   end
--    gpio.write(outpin, status) 
--end

local function toBitArray(num)
    local bits = {}
    while num > 0 do
        rest = math.fmod(num, 2)
        bits[#bits+1] = rest
        num = (num-rest)/2
    end

    print(bits)
    return bits
end

local function parseFormData(body)
  local data = {}
  print("Parsing Form Data")
  for kv in body.gmatch(body, "%s*&?([^=]+=[^&]+)") do
    local key, value = string.match(kv, "(.*)=(.*)")
    
    print("Parsed: " .. key .. " => " .. value)
    data[key] = value
  end
  
  return data
end

-- server listens on 80, if data received, print data to console and send "hello world" back to caller
-- 30s time out for a inactive client

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
  conn:on("receive",function(conn,payload)
    local temp = (adc.read(0) * 1.75)/1024
    --print(payload)
    --parserequest(payload)
    local data = parseFormData(payload)
    for v in data
        toBitArray(data)
    end
    --    conn:send("<h1> Hello, NodeMCU!!! </h1>\n<p>The red LED is now "..status.."</p>"
--    .."<p>The current temperature reading is "..(175*temp - 50).."°C.</p>"
--    .."<p>Payload recieved is "..payload.."</p>")

--  srv.sendHeader("Connection", "close");
--  srv.sendHeader("Access-Control-Allow-Origin", "*");
--  conn:send(200, "text/plain", "OK\r\n");
    conn:close()
  end)
  conn:on("sent",function(conn) conn:close() end)
end)
