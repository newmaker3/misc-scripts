#!/usr/bin/lua
math.randomseed(os.time())
args = {...}
local sb = string.byte
if not args[1] then
	io.stdout:write("Please enter file name: ")
	file = io.read()
else
	file = args[1]
end

if not file:find("%.gif") then
	error("Not a gif file")
end

fin = io.open(file,"rb")
foutname = file:gsub(".gif","").."-glitched.gif"
fout = io.open(foutname,"wb")


fout:write(fin:read(13)) -- write header, this will always be the same


fin:seek("set",10) -- seek to the 9th byte of the file(yes, 9th because even files start at 1 in lua)
gflags = sb(fin:read(1)) -- read global flags

if bit32.rshift(gflags,7) == 1 then -- if we have a global color table, write random garbage to it to "glitch" it
	local a = bit32.band(gflags,7) + 1
	local b = 2 ^ a
	local gcolorlen = 3 * b
	for i = 1,gcolorlen-1 do
		fout:write(string.char(math.random(0,255)))
	end
	fin:seek("set",12+gcolorlen) -- seek to the byte right after the global color table
	fout:write(fin:read("*all"))

	fin:close()
	fout:close()
else
	fin:close()
	fout:close()
	os.remove(foutname)
	error("no global table")
end
