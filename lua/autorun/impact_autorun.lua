AddCSLuaFile()
AddCSLuaFile( "impact/debug.lua" )
AddCSLuaFile( "impact/shared.lua" )

if impact and impact.Unload then
	impact.Unload()
end

impact = {}

include( "impact/debug.lua" )
include( "impact/shared.lua" )
