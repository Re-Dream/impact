--- client-side permissions, Re-Dream
-- Global

impact.FriendDefault = CreateConVar( "impact_frienddefault", "6143", FCVAR_ARCHIVE )

CreateClientConVar( "impact_modifyall", 1, true, true, "Whether, as an admin, you would like to be able to touch others' entities." )
CreateClientConVar( "impact_playergrab", 1, true, true, "Whether, you would like to be able to grab players/for players to grab you using the physgun." )
CreateClientConVar( "impact_modifyworld", 0, true, true, "Whether, as an admin, you would like to be able to modify world entities." )
CreateClientConVar( "impact_bypassblock", 0, true, true, "Whether, as an admin, you would like to be able to use blocked tools." )


-- Optimization

local bit_band 	= bit.band
local bit_bor	= bit.bor
local bit_bxor	= bit.bxor


-- Functions

--- Checks whether a friend has a certain flag
-- @param ply Player to check against
-- @param flag Flag to check
function impact.Flag( ply, flag )
	local steamID = impact.SteamID( ply )

	if not impact.Friends[ steamID ] then return false end
	return ( bit_band( impact.Friends[ steamID ].Flags or 0, flag ) == flag )
end

--- Checks whether a friend exists, if not creates it
-- @param steamID SteamID
function impact.Check( steamID ) if not impact.Friends[ steamID ] then impact.Friends[ steamID ] = { Flags = 0, Name = steamID } end end

--- Grants a flag to someone
-- @param steamID Player's SteamID to grant flag to
-- @param flag Flag to grant
function impact.Grant( steamID, flag )
	impact.Check( steamID )
	
	impact.Friends[ steamID ].Flags = bit_bor( impact.Friends[ steamID ].Flags, flag )
	
	impact.UpdateNicks()
	impact.SaveFriends()
	impact.SynchronizeFriends()
end

--- Revokes a flag from someone
-- @param steamID Player's SteamID to revoke flag from
-- @param flag Flag to revoke
function impact.Revoke( steamID, flag )
	impact.Check( steamID )
	
	impact.Friends[ steamID ].Flags = bit_bxor( impact.Friends[ steamID ].Flags, flag )
	
	impact.UpdateNicks()
	impact.SaveFriends()
	impact.SynchronizeFriends()
end

--- Sets someone's flags
-- @param steamID Player's SteamID to set
-- @param flags Flags to set
function impact.Set( steamID, flags )
	impact.Check( steamID )
	
	impact.Friends[ steamID ].Flags = flags
	
	impact.UpdateNicks()
	impact.SaveFriends()
	impact.SynchronizeFriends()
end

--- Assigns default permissions if player is a friend
-- @param ply Player to check against
function impact.Assign( ply )
	if not impact.IsPlayer( ply ) then return end
	if ply:GetFriendStatus() ~= "friend" then return end
	if impact.Friends[ impact.SteamID( ply ) ] then return end

	impact.Print( "Granted '" .. ply:Nick() .. "' default friend permissions" )

	impact.Friends[ impact.SteamID( ply ) ] = { Flags = impact.FriendDefault:GetInt(), Name = ply:Nick() }
	
	impact.SaveFriends()
	impact.SynchronizeFriends()
end

--- Synchronizes friends with the server
function impact.SynchronizeFriends()
	impact.Net.Run( "Synchronize Friends", impact.Friends )
end


-- Netfunctions

impact.Net.Add( "Synchronization Request", function()
	for _, v in pairs( player.GetAll() ) do impact.Assign( v ) end
	
	impact.UpdateNicks()
	impact.SynchronizeFriends()
end )

impact.Net.Add( "Player InitialSpawn", function( steamID )
	local ply = impact.Player( steamID )
	if ply ~= LocalPlayer() then impact.Assign( ply ) end

	impact.Players[ steamID ] = ply
	impact.Players[ ply ] = steamID
end )


-- Hooks

hook.Add( "ImpactPostEntity", "Impact CL Permissions ImpactPostEntity", function()
	for _, v in pairs( player.GetAll() ) do 
		impact.Assign( v )
		impact.SteamID( v )
	end

	impact.Print( "Built cache" )
end )

hook.Add( "ImpactUnload", "Impact CL Permissions ImpactUnload", function()
	hook.Remove( "ImpactPostEntity", "Impact CL Permissions ImpactPostEntity" )
    hook.Remove( "ImpactUnload", "Impact Inject ImpactUnload" )
end )