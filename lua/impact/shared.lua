-- Global
impact.Modules	= {}

-- Variables
local pathRoot	= "impact/"
local pathLoad	= { "shared", "server", "client" }
local loadOrder	= {}
local loaded 	= {}

-- Helper functions
local function loadFolder( path, realm )
	if realm == 1 and not SERVER then return end
	if realm == 2 and not CLIENT then return end

	local files 	 = file.Find( pathRoot .. path .. "/*.lua", "LUA" )
	local _, folders = file.Find( pathRoot .. path .. "/*", "LUA" )

	for _, v in pairs( files ) do
		if realm == 0 then AddCSLuaFile( v ) end
		
		local module 	= include( v )
		local index 	= 1

		for k, v in pairs( loadOrder ) do
			if module.Depends[ v ] then 
				index = k + 1

				local depends = impact.Modules[ v ]

				if not depends.Children then
					depends.Children = { module.Name }
				else 
					table.insert( depends.Children, module.Name )
				end
			end
		end

		table.insert( loadOrder, module.Name, index )
		impact.Modules[ module.Name ] = module
		loaded[ module.Name ] = false
	end

	for _, v in pairs( folders ) do loadFolder( v, realm ) end
end

local function unloadModule( module )
	if not loaded[ module ] then return end

	if module.Children then
		for k, v in pairs( module.Children ) do
			unloadModule( v )
		end

		impact.Print( "Module '" .. module .. "' and " .. #module.Children .. " children unloaded" )
	else
		impact.Print( "Module '" .. module .. "' unloaded" )
	end

	loaded[ module ] = false
end

-- Functions
function impact.Load()
	local startTime = SysTime()

	for k, v in pairs( pathLoad )
		impact.Print( "Pre-load realm '" .. v .. "'" )

		loadFolder( pathRoot .. v, k )
	end

	impact.Print( "Loading modules" )

	for _, v in pairs( loadOrder )
		impact.Modules[ v ].Load()
		impact.Print( "Module '" .. v .. "' loaded" )

		loaded[ v ] = true
	end

	local elapsedUS = math.ceil( ( SysTime() - startTime ) * 1000000 )
	impact.Print( "Load took " .. elapsedUS .. "us" )
end

function impact.Unload( module )
	if module == nil then
		for k, v in pairs( loaded ) do
			if v then
				unloadModule( module )
			end
		end
	else
		unloadModule( module )
	end
end

-- Initialize
impact.Load()