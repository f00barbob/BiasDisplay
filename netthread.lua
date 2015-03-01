print("entered networking thread!")


--local host, port = "192.168.1.50", 2222 -- was for testing
local host, port = "127.0.0.1", 22222
local socket = require("socket")
local tcp = assert(socket.tcp())
local moob
local retrycount = 0
local laststatus = "nil"
local msgcnt = 0
local recvcnt = 0
local next_push = ""

print("grabbing channel..")
local netchun = love.thread.getChannel("netchan")
print("got channel..")


function connect_tcp()
	
	print("Attempting tcp connection: " .. host .. ":" .. port)
	tcp:settimeout(1)
	local condata, conerr = tcp:connect(host, port)
	if not conerr then
		retrycount = 0
	end
	print()
	io.write("condata: \t")
	io.write(condata or "nil")
	io.write("\tconerr: \t")
	io.write(conerr or "nil")
	io.write("\n")

	if conerr == "already connected" then
		tcp:close()
		tcp = assert(socket.tcp())
		connect_tcp()
	end

--	print("data:" .. condata)--or "nil...err:" .. conerr or "nil"  )
	tcp:send("hello...\n")	
	print("greeting sent ")

end



print("pro")
connect_tcp()

while true do
	io.write("\r") -- return the cursor to start of line
	local s, status, partial
	s, status, partial = tcp:receive()

	local nom = s or partial

	if s or partial and status ~= "timeout" then 
		recvcnt = recvcnt + 1
    next_push = nom
		--print("pushing" .. next_push)
		netchun:push(next_push)
		tcp:send("ACK:" .. recvcnt)
	end

	if status == "closed"
	or status == "Socket is not connected"
	or status == "Transport endpoint is not connected" then
		retrycount = retrycount + 1	
		print("Attempting reconnect:" .. retrycount)
		socket.sleep(1)
		connect_tcp()

	elseif status == "timeout" then
		
	end
	--io.write("\trecvcnt:" .. recvcnt)
	io.flush()

	socket.sleep(.01) -- prevent 100% core usage.
end





