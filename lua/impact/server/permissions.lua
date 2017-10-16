--- impact server-end permissions, Haven, Re-Dream
-- Global
impact.Friends = {}

impact.Permissions = {
	BlockTool 	= 1,
	PlayerGrab 	= 2,
	ModifyAll 	= 4,
	ModifyWorld = 8,
	Cleanup		= 16,
	BypassBlock	= 32
}

impact.Assigned = {}
impact.Blocked 	= {}

for k, v in pairs( impact.Permissions ) do impact.Permissions[ v ] = k end

impact.Permissions.AdminDefault = CreateConVar( "impact_admindefault", "55", FCVAR_ARCHIVE ) 

-- Optimization

local bit_band = bit.band


-- Functions

--- Checks entity permissions
-- @param ent Entity to check against
-- @param ply Activator
-- @param flag Flag to check
-- @param varargs Additional arguments
function impact.Flag( ent, ply, flag, ... )
	local vargs = { ... }

	local owner 		= impact.Owner( ent ) or false
	local ownerPly		= owner and impact.Player( owner ) or false
	local worldSpawn 	= ent:IsWorld()
	local player 		= impact.IsPlayer( ent )
	local steamID		= impact.IsPlayer( ply ) and impact.SteamID( ply ) or false

	-- TODO In this order; ( intentionally left in code for reference )
	-- World is god - OK
	-- Block tool on player - OK
	-- Blocked tools (note: bypass perm?) - OK
	-- Allow tool on worldspawn - OK
	-- Allow use on world entity - OK
	-- Allow if ent owner = ply - OK
	-- Allow if exception - OK
	-- Allow if modifyAll, modifyWorld, playerGrab as admin - OK
	-- Disallow if no owner beyond this point - OK
	-- Disallow if ent owner has no friends - OK
	-- Disallow if activator is not friend - OK
	-- Playergrab check - OK
	-- Allow if flag met - OK
	-- Disallow all else - OK

	if not impact.IsPlayer( ply ) then return true end

	if flag == impact.Flags.Tool then
		if player then return false end

		if impact.Blocked[ vargs[ 1 ] ] then
			return ( impact.Query( ply, "BypassBlock" ) and ply:GetInfoNum( "impact_bypassblock", 0 ) > 0 )
		elseif worldSpawn then
			return true
		end
	end

	if flag == impact.Flags.Use and not owner then return true end
	if ply == owner then return true end
	if bit_band( ent:GetNWInt( "Impact Exceptions", 0 ), flag ) == flag then return true end

	if impact.Query( ply, "ModifyAll" ) and ply:GetInfoNum( "impact_modifyall", 0 ) > 0 and owner and not player then return true end
	if impact.Query( ply, "ModifyWorld" ) and ply:GetInfoNum( "impact_modifyworld", 0 ) > 0 and not owner and not player then return true end
	if impact.Query( ply, "PlayerGrab" ) and ply:GetInfoNum( "impact_playergrab", 0 ) > 0 and player then return true end

	if not owner then return false end

	local ownID = impact.SteamID( owner )

	if not impact.Friends[ ownID ] then return false end
	if not impact.Friends[ ownID ][ steamID ] then return false end

	if flag == impact.Flags.Physgun and player and ply:GetInfoNum( "impact_playergrab", 0 ) > 0 and ownerPly:GetInfoNum( "impact_playergrab", 0 ) > 0 and bit_band( impact.Friends[ ownID ][ steamID ].Flags or 0, impact.Flags.PlayerGrab ) == impact.Flags.PlayerGrab then return true end
	if bit_band( impact.Friends[ ownID ][ steamID ].Flags or 0, flag ) == flag then return true end

	return false
end

--- Queries player permission
-- @param ply Player to query
-- @param flag Permission flag to query
function impact.Query( ply, flag )
	local check = ( type( flag ) == "number" and flag or impact.Permissions[ flag ] ) or 65535
	return ( bit_band( impact.Assigned[ ply ] or 0, check ) == check )
end

--- Assigns (default) permissions
-- @param ply Player to assign
function impact.Assign( ply )
	if ply == nil then for _, v in pairs( player.GetAll() ) do impact.Assign( v ) end return end

	local pFlags = hook.Call( "ImpactAssignPermissions", ply ) or nil
	if pFlags == nil and ( ply:IsAdmin() or ply:IsSuperAdmin() ) then pFlags = impact.Permissions.AdminDefault:GetInt() end

	impact.Assigned[ ply:SteamID() ] = pFlags or 0
end

-- Netfunctions
impact.Net.Add( "Synchronize Friends", function( ply, newFriends )
	impact.Friends[ ply:SteamID() ] = impact.Sanitize( newFriends )
end )

impact.Net.Add( "Change Exceptions", function( ply, ent, newExceptions )
	if impact.Flag( ent, ply, impact.Flags.Manage ) and type( newExceptions ) == "number" then
		ent:SetNWInt( "Impact Exceptions", newExceptions )
	end
end )