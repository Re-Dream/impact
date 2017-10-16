--- base injections, Haven
-- Overrides

-- cleanup.Add
cleanupAdd = cleanupAdd or cleanup.Add
function cleanup.Add( ply, type, ent )
	if IsValid( ent ) and impact.IsPlayer( ply ) then
		impact.Owner( ent, ply )
	end

	cleanupAdd( ply, type, ent )
end

-- undo.*
local undoAct = {}

undoCreate = undoCreate or undo.Create
function undo.Create( name )
	undoAct = { Name = name, Entities = {}, Player = false }
	undoCreate( name )
end

undoAddEntity = undoAddEntity or undo.AddEntity
function undo.AddEntity( ent )
	if ent ~= nil then undoAct.Entities[ ent ] = true end
	undoAddEntity( ent )
end

undoSetPlayer = undoSetPlayer or undo.SetPlayer
function undo.SetPlayer( ply )
	if impact.IsPlayer( ply ) then
		undoAct.Player = ply
	end

	undoSetPlayer( ply )
end

undoFinish = undoFinish or undo.Finish
function undo.Finish()
	if impact.IsPlayer( undoAct.Player ) then
		local steamID = undoAct.Player:SteamID()
		for _, v in pairs( undoAct.Entities ) do impact.Owner( v, steamID ) end
	end

	undoFinish()
end


-- Hooks

local regHooks = {}

local simpleHooks = {
    PhysgunPickup 			= impact.Flags.Physgun,
    CanPlayerUnfreeze 		= impact.Flags.Physgun,
    GravGunPickupAllowed 	= impact.Flags.Pickup,
    GravGunPunt 			= impact.Flags.Punt,
    CanDrive 				= impact.Flags.Drive
}

-- helper
local function regHook( name, func )
	local unique = "Impact " .. name

	hook.Remove( name, unique )
	hook.Add( name, unique, func )
	regHooks[ name ] = unique
end

-- register hooks with common template
for event, flag in pairs( simpleHooks ) do
    regHook( event, function( ... )
        local vargs = { ... }
        return impact.Flag( vargs[ 2 ], vargs[ 1 ], flag, unpack( vargs, 3 ) )
    end )
end

regHook( "CanTool", function( ply, tr, tool )
    return impact.Flag( tr.Entity, ply, impact.Flags.Tool, tool )
end )

regHook( "PhysgunDrop", function( ply, ent )
    if ent and ent:IsPlayer() and ent:GetMoveType() == MOVETYPE_NONE then
        ent:SetMoveType( MOVETYPE_WALK )
    end
end )

regHook( "EntityTakeDamage", function( ent, dmg )
    local vec = Vector( 0 )
    local att = dmg:GetAttacker()
          att = att:GetClass() ~= "entityflame" and att or ( ent.ImpactDamageSource or att ) -- flame fix

    local inf = dmg:GetInflictor()

    local ply = att:IsPlayer() and att or ( impact.IsPlayer( impact.Owner( att ) ) or ( impact.IsPlayer( impact.Owner( inf ) ) or ( att:IsWorld() and att ) ) )
    local own = impact.IsPlayer( impact.Owner( ent ) ) or ( ent == att and ent )

    if not ply or ( not own and ply and not ply:IsWorld() ) or not impact.Flag( ent, ply, impact.Flags.Damage ) then
        dmg:ScaleDamage( 0 )
        dmg:SetDamageForce( vec )

        if dmg:IsExplosionDamage() then return true end
    else
        ent.ImpactDamageSource = ply
    end
end )

regHook( "CanProperty", function( ply, property, ent )
    local query = impact.Flag( ent, ply, impact.Flags.Property, property )
    if query and property == "ignite" then ent.ImpactDamageSource = ply end

    return query
end )

regHook( "CanEditVariable", function( ent, ply, key, val, editor )
    return impact.Flag( ent, ply, impact.Flags.EditVariable, key, val, editor )
end )

regHook( "PlayerUse", function( ply, ent )
    if ent:IsVehicle() then return impact.Flag( ent, ply, impact.Flags.Vehicle ) end
    return impact.Flag( ent, ply, impact.Flags.Use )
end )

-- steamid cache
regHook( "PlayerAuthed", function( ply, steamID )
	impact.Players[ steamID ] = ply
	impact.Players[ ply ] = steamID
end )

regHook( "PlayerDisconnected", function( ply )
	impact.Players[ ply:SteamID() ] = nil
end )

-- friends sync
regHook( "PlayerInitialSpawn", function( ply )
	impact.Net.Run( "Synchronization Request", ply, true )
	impact.Net.RunAll( "Player InitialSpawn", ply:SteamID() )
	impact.Assign( ply )
end )

--- Remove lpp injections
hook.Add( "ImpactUnload", "Impact Inject ImpactUnload", function()
    cleanup.Add         = cleanupAdd
    undo.Create         = undoCreate
    undo.AddEntity      = undoAddEntity
    undo.SetPlayer      = undoSetPlayer
    undo.Finish         = undoFinish

    for k, v in pairs( regHooks ) do
        hook.Remove( k, v )
    end

    impact.Print( "Injection cleaned" )
    hook.Remove( "ImpactUnload", "Impact Inject ImpactUnload" )
end )

hook.Call( "ImpactInjected" )