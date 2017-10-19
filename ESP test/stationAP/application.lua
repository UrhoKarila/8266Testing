--sock = net.createConnection()
--
--sock:on("connection", function (sck, c)
--    sck:send("GET / HTTP/1.1\r\nHost: ESP8266\r\nConnection: close\r\nAccept: */*\r\n\r\n")
--end)
--
--sock:on("receive", function (sck, c)
--    print("\nReceived response: "..c)
--end)

function spam(interval)
tmr.create():alarm(interval, tmr.ALARM_AUTO, function()

    print(node.heap())

    local sock = net.createConnection()

    sock:on("connection", function (sck, c)
        sck:send("GET / HTTP/1.1\r\nHost: ESP8266\r\nConnection: close\r\nAccept: */*\r\n\r\n")
    end)
    
--    sock:on("receive", function (sck, c)
--        --print("\nReceived response: "..c)
--    end)

    print("attempted connection")
    sock:connect(80, "192.168.4.2")
    tmr.create():alarm(1000, tmr.ALARM_SINGLE, function() sock = nil end)
end)
end