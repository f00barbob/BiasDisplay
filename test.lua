local host, port = "127.0.0.1", 2222
local socket = require("socket")
local tcp = assert(socket.tcp())
local s, status, partial
local moob
local retrycount = 0
local laststatus = "nil"

function love.load()
	do_tcp_connect()
end

function love.update(dt)
	moob = dt or " "
	s, status, partial = tcp:receive()
	--print(s or partial)
	if status == "closed"
	or status == "Socket is not connected" 
	or status == "timeout" 
	then
		tcp:close()
		do_tcp_connect()
	end
end

function love.draw()
	if status == "closed"
	or status == "Socket is not connected" 
	or status == "timeout" 
	then 
		retrycount = retrycount + 1
		love.graphics.print("Not Connected! Retry #" .. retrycount, 400,300)
		laststatus = status or "nil"

	else
		retrycount = 0
		love.graphics.print(status or "status is nil; status was " .. laststatus, 400,330)
		tcp:send("HI!.\n")
	end

	love.graphics.print("DT: " .. moob, 400,360)

end

function do_tcp_connect()
    tcp:settimeout(1)
    tcp:connect(host, port)
    tcp:send("hello...\n")
end

