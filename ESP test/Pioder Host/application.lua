-- Pin definition 
local clk = 1--            --  GPIO01
local sig = 2
local status = gpio.LOW
local duration = 1000    -- 1 second duration for timer
local bitstream

local clockRate = 15
local clkPulseLife = clockRate / 5
local sigPulseLife = clockRate / 3

local clockTimeout = tmr.create()
clockTimeout:register(clkPulseLife, tmr.ALARM_SINGLE, function() gpio.write(clk, gpio.LOW) end)

local sigTimeout = tmr.create()
sigTimeout:register(sigPulseLife, tmr.ALARM_SINGLE, function() gpio.write(sig, gpio.LOW) end)

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

function pulseClk()
    gpio.write(clk, gpio.HIGH)
    clockTimeout:start()
end

function sigDecay()
    sigTimeout:start()
end

function spi_send()
    if bitstream ~= nil and (#bitstream > 0)
    then
        print(bitstream[1])
        if bitstream[1] == 1 then
            gpio.write(sig, gpio.HIGH)
        else
            gpio.write(sig, gpio.LOW)
        end

        pulseClk()
        sigDecay()

        table.remove(bitstream,1)
    end
end

--tmr.create():alarm(10, tmr.ALARM_AUTO, toggle)
tmr.create():alarm(clockRate, tmr.ALARM_AUTO, spi_send)


local function toBitArray(str)

    print("passed input: "..str)

    local bits = {}
    local num = tonumber(str)

    while num > 0 do
        rest = (num % 2)
        table.insert(bits, 1, rest)
        num = (num-rest)/2
    end
    
    while #bits < 8 do
        table.insert(bits, 1, 0)
    end  
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
    
    print("Parsed: -" .. key .. "- => " .. value)
    data[key] = value
    --print("parsed key is: "..key)
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

-- server listens on 80, if data received, print data to console and send "hello world" back to caller
-- 30s time out for a inactive client

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
  conn:on("receive",function(conn,payload)
    --local temp = (adc.read(0) * 1.75)/1024
    --print(payload)
    --parserequest(payload)
    local data = parseFormData(payload)

    print(data)
    print(data["blue"])
    print(data["green"])
    print(data["red"])
    
    bitstream = {}
    for k,v in pairs(data) do
        --print("key, value: "..k.." "..v)
        --print("Data for key "..k.." is "..data[k])
    --bitstream = array_concat(bitstream, toBitArray(data["red"]))
    --bitstream = array_concat(bitstream, toBitArray(data["green"]))
    --bitstream = array_concat(bitstream, toBitArray(data[blue]))
    end
    print(bitstream)
    --printTable(bitstream)
    --spi_send(bitstream, 1000)
    
    conn:close()
  end)
  conn:on("sent",function(conn) conn:close() end)
end)
