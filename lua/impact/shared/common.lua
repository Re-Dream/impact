--- common variables and functions, Re-Dream
-- Global

impact.Flags = {
	Tool 	= 1,
	Physgun = 2,
	Pickup 	= 4,
	Punt 	= 8,
	Use		= 16,
	Damage	= 32,
	Drive	= 64,
	Property = 128,
	EditVariable = 256,
	Vehicle	= 512,
	Media	= 1024,
	Manage	= 2048,
	PlayerGrab = 4096
}

impact.Players = {}

for k, v in pairs( impact.Flags ) do impact.Flags[ v ] = k end

-- Helper functions
local function getOwner( ent )
	return impact.Player( ent:GetNWString( "Impact Owner", nil ) )
end

local function setOwner( ent, ply )
	if type( ply ) == "string" then
		ent.Owner = impact.Player( ply )
		ent:SetNWString( "Impact Owner", ply )
	else
		ent.Owner = ply
		ent:SetNWString( "Impact Owner", ply:SteamID() )
	end

	return true
end

-- Functions
function impact.IsPlayer( ply )
	if not ply then return false end
	if ply.IsPlayer == nil then return false end
	
	return ply:IsPlayer()
end

function impact.Player( steamID )
	if impact.Players[ steamID ] == nil then
		local ply = player.GetBySteamID( steamID )

		impact.Players[ steamID ] = ply
		impact.Players[ ply ] = steamID
	end

	return impact.Players[ steamID ]
end

function impact.SteamID( ply )
	if impact.Players[ ply ] == nil then
		local steamID = ply:SteamID()

		impact.Players[ steamID ] = ply
		impact.Players[ ply ] = steamID
	end

	return impact.Players[ ply ]
end

function impact.Owner( ent, ply )
	if ply == nil then
		return getOwner( ent )
	else
		return setOwner( ent, ply )
	end
end

-- types allowed in sanitized table
local typeOK = {
    number  = true,
    string  = true,
    boolean = true,
    table   = true
}

--- Sanitizes a table
-- @param tbl table to sanitize
function impact.Sanitize( tbl )
    local noMeta = debug.getmetatable( tbl ) or tbl
    
    for k, _ in pairs( noMeta ) do
        local v  = rawget( noMeta, k )
        local v_ = type( v )

        if not typeOK[ v_ ] then rawset( noMeta, k, nil ) end
        if v_ == "table" and v ~= tbl then rawset( noMeta, k, impact.Sanitize( v ) ) end
    end

    return noMeta
end