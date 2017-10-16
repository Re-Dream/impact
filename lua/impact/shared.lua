--- module loader, Re-Dream
-- Global
impact.Version = 201710.0

-- Variables
local pathRoot = "impact/"
local pathLoad = { "shared/", "server/", "client/" }

-- Helper functions
local function loadFolder( path, realm )
	if realm == 2 and not SERVER then return end
	if realm == 3 and not CLIENT then return end

	local files 	 = file.Find( pathRoot .. path .. "*.lua", "LUA" )
	local _, folders = file.Find( pathRoot .. path .. "*", "LUA" )

	for _, v in pairs( files ) do
		local fullPath = pathRoot .. path .. v

		if realm == 1 then AddCSLuaFile( fullPath ) end
		include( fullPath )

		impact.Print( fullPath )
	end

	for _, v in pairs( folders ) do if v ~= "disabled" then loadFolder( path .. v .. "/", realm ) end end
end

-- Functions
function impact.Load()
	hook.Call( "ImpactPreLoad" )

	local startTime = SysTime()
	impact.Print( "Loading modules" )

	for k, v in pairs( pathLoad ) do
		impact.Print( "Loading realm " .. k .. " '" .. v .. "'" )
		loadFolder( v, k )
	end

	local elapsedUS = math.ceil( ( SysTime() - startTime ) * 1000000 )
	impact.Print( "Load took " .. elapsedUS .. "us" )

	hook.Call( "ImpactPostLoad" )
end

function impact.Unload()
	hook.Call( "ImpactUnload" )
	impact.Print( "Unloaded" )
end

function impact.Reload()
	impact.Unload()
	impact.Load()
end

-- Initialize
impact.Load()