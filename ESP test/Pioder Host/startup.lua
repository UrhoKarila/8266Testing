function startup()
    if file.open("init.lua") == nil then
        print("init.lua deleted or renamed")
    else
        print("Startup successful!")
        file.close("init.lua")
        print("Heap available: "..node.heap())
        -- the actual application is stored in 'application.lua'
        dofile("application.lua")
    end
end
