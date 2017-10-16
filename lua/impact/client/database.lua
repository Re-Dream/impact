--- client database stuff, Haven, Re-Dream
-- Global

impact.Friends = {}


-- Optimization

local jt = util.JSONToTable
local tj = util.TableToJSON


-- Functions

--- Updates friends' nicknames
function impact.UpdateNicks()
	for k, v in pairs( impact.Friends ) do
		local ply = impact.Player( k )

		if impact.IsPlayer( ply ) then
			impact.Friends[ k ].Name = ply:Nick()
		end
	end
end

--- Saves friends
function impact.SaveFriends()
	for k, v in pairs( impact.Friends ) do
		if type( v.Flags ) ~= "number" or v.Flags <= 0 then
			impact.Friends[ k ] = nil
		end
	end

	cookie.Set( "ImpactFriends", tj( impact.Friends ) )
end

--- Loads friends
function impact.LoadFriends()
    impact.Friends = jt( cookie.GetString( "ImpactFriends", "{}" ) )
end

impact.LoadFriends()