-- Pin definition 
local clk = 1--            --  GPIO01
local sig = 2
local status = gpio.LOW
local duration = 1000    -- 1 second duration for timer
local bitstream

-- Initialising pin
gpio.mode(clk, gpio.OUTPUT)
gpio.write(clk, status)

--gpio.mode(sig, gpio.INPUT)
print("In application.lua!")

local function toggle()
    local pin = clk
    if status == gpio.LOW then
        status = gpio.HIGH
    else
        status = gpio.LOW
   end
    gpio.write(pin, status) 
end

tmr.create():alarm(10, tmr.ALARM_AUTO, toggle)
tmr.create():alarm(2000, tmr.ALARM_AUTO, toggle)


local function toBitArray(str)
    print(str)
    local bits = {}
    local num = tonumber(str)
    print(num)
    while num > 0 do
        rest = (num % 2)
        table.insert(bits, 1, rest)
        num = (num-rest)/2
    end
    
    while #bits < 8 do
        table.insert(bits, 1, 0)
    end
    printTable(bits)
    
    return bits
end

function printTable(table)
    local printval = ""
    for k,v in ipairs(table) do
        printval = printval .. v
    end
    print(printval)
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

-- return a new array containing the concatenation of all of its 
-- parameters. Scaler parameters are included in place, and array 
-- parameters have their values shallow-copied to the final array.
-- Note that userdata and function values are treated as scalar.
function array_concat(...) 
    local t = {}
    for n = 1,select("#",...) do
        local arg = select(n,...)
        if type(arg)=="table" then
            for _,v in ipairs(arg) do
                t[#t+1] = v
            end
        else
            t[#t+1] = arg
        end
    end
    return t
end


function spi_send(bitstream, rate)
    for n = 0,#bitstream,1 do
        print(bitstream[n])
        tmr.delay(rate)
    end
end
-- server listens on 80, if data received, print data to console and send "hello world" back to caller
-- 30s time out for a inactive client

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
  conn:on("receive",function(conn,payload)
    --local temp = (adc.read(0) * 1.75)/1024
    --print(payload)
    --parserequest(payload)
    local data = parseFormData(payload)
    bitstream = {}
    for k,v in pairs(data) do
        bitstream = array_concat(bitstream, toBitArray(v))
    end
    print(bitstream)
    printTable(bitstream)

    spi_send(bitstream, 100)
    
    conn:close()
  end)
  conn:on("sent",function(conn) conn:close() end)
end)

gpio.write(clk, gpio.HIGH)
gpio.write(sig, gpio.HIGH)
