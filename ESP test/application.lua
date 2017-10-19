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

function toggle()
    if status == gpio.LOW then
        status = gpio.HIGH
    else
        status = gpio.LOW
   end
    gpio.write(outpin, status)
--    print("---------------")
--    print("adc reads: "..adc.read(0))
--    print("Status of outpin is "..status.." and actual of outpin is "..gpio.read(outpin))
--    print("Inpin reads: "..gpio.read(inpin))
    
end

function parserequest(request)
    if(string.find(request, '/on') ~= nil) then
        status = gpio.HIGH
        gpio.write(outpin, status)
    elseif
        (string.find(request, '/off') ~= nil) then
        status = gpio.LOW
        gpio.write(outpin, status)
    elseif(string.find(request, 'GET / HTTP') ~= nil) then
        toggle()
    end
end

-- server listens on 80, if data received, print data to console and send "hello world" back to caller
-- 30s time out for a inactive client

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
  conn:on("receive",function(conn,payload)
    local temp = (adc.read(0) * 1.75)/1024
    print(payload)
    parserequest(payload)
    conn:send("<h1> Hello, NodeMCU!!! </h1>\n<p>The red LED is now "..status.."</p>"
    .."<p>The current temperature reading is "..(175*temp - 50).."°C.</p>"
    .."<p>Payload recieved is "..payload.."</p>")
  end)
  conn:on("sent",function(conn) conn:close() end)
end)
