--- net library for remote function execution
--  NOTE: When registering a function, make sure it is safe and not sensitive to exploits!

--[[
	Copyright (c) 2017, JY "Arena" Wolvekamp
	All rights reserved.

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:
		* Redistributions of source code must retain the above copyright
		notice, this list of conditions and the following disclaimer.
		* Redistributions in binary form must reproduce the above copyright
		notice, this list of conditions and the following disclaimer in the
		documentation and/or other materials provided with the distribution.
		* Neither the name of the <organization> nor the
		names of its contributors may be used to endorse or promote products
		derived from this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]--

impact.Net 	= {}
local fun	= impact.Net

local net_string = "Impact Networked Functions"
local register = {}

if SERVER then
	util.AddNetworkString( net_string )

	--- Run a networked function on a specific player
	-- @param id The function unique identifier
	-- @param ply The player to run the function on
	-- @param ... Function arguments
	function fun.Run( id, ply, ... )
		net.Start( net_string )
			net.WriteString( id )
			net.WriteTable( { ... } )
		net.Send( ply )
	end

	--- Run a networked function on all players at once
	-- @param id The function unique identifier
	-- @param ... Function arguments
	function fun.RunAll( id, ... )
		net.Start( net_string )
			net.WriteString( id )
			net.WriteTable( { ... } )
		net.Broadcast()
	end

	--- Remove a networked function
	-- @param id The function unique identifier
	function fun.Remove( id )
		register[ id ] = nil
	end
end

if CLIENT then
	--- Run a networked function on the server
	-- @param id The function unique identifier
	-- @param ... Function arguments
	function fun.Run( id, ... )
		net.Start( net_string )
			net.WriteString( id )
			net.WriteTable( { ... } )
		net.SendToServer()
	end
end

--- Register a new networked function handler
-- @param id The function unique identifier
-- @param handle The handling function; SERVER: function( ply, ... ) - CLIENT: function( ... )
function fun.Add( id, handle )
	register[ id ] = handle
end

-- Handling code
net.Receive( net_string, function( len, ply )
	if len <= 0 then return end
	local id = net.ReadString()

	if SERVER and ( not ply or not id ) then return end
	if CLIENT and ply then return end

	if register[ id ] ~= nil then
		if SERVER then
			register[ id ]( ply, unpack( net.ReadTable() ) )
		elseif CLIENT then
			register[ id ]( unpack( net.ReadTable() ) )
		end
	end
end )
