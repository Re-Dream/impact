AddCSLuaFile()
AddCSLuaFile( "impact/debug.lua" )
AddCSLuaFile( "impact/networked_functions.lua" )
AddCSLuaFile( "impact/shared.lua" )

if impact and impact.Unload then
	impact.Unload()
end

impact = {}

include( "impact/debug.lua" )
include( "impact/networked_functions.lua" )
include( "impact/shared.lua" )
