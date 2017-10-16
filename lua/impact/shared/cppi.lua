--- cppi compliance, Re-Dream

local ENT = FindMetaTable( "Entity" )
local PLY = FindMetaTable( "Player" )

-- ii.a
CPPI = CPPI or {}
CPPI.CPPI_DEFER 			= 4
CPPI.CPPI_NOTIMPLEMENTED 	= 8

-- ii.b
function CPPI:GetName() return "Impact" end
function CPPI:GetVersion() return tostring( impact.Version ) end
function CPPI:GetInterfaceVersion() return 1.3 end

-- ii.d
function ENT:CPPIGetOwner() return impact.Owner( self ), CPPI.CPPI_NOTIMPLEMENTED end

if SERVER then
	function ENT:CPPISetOwner( ply ) return impact.Player( impact.Owner( self, ply ) ) end
	function ENT:CPPICanTool( ply, toolmode ) return impact.Flag( self, ply, impact.Flags.Tool, nil, toolmode ) end
	function ENT:CPPICanPhysgun( ply ) return impact.Flag( self, ply, impact.Flags.Physgun ) end
	function ENT:CPPICanPickup( ply ) return impact.Flag( self, ply, impact.Flags.Pickup ) end
	function ENT:CPPICanPunt( ply ) return impact.Flag( self, ply, impact.Flags.Punt ) end

	function ENT:CPPICanUse( ply )
		if self:IsVehicle() then return impact.Flag( self, ply, impact.Flags.Vehicle ) end
		return impact.Flag( self, ply, impact.Flags.Use )
	end

	function ENT:CPPICanDamage( ply ) return impact.Flag( self, ply, impact.Flags.Damage, nil ) end
	function ENT:CPPIDrive( ply ) return impact.Flag( self, ply, impact.Flags.Drive ) end
	function ENT:CPPICanEditVariable( ply, key, val, edit ) return impact.Flag( self, ply, impact.Flags.EditVariable, key, val, edit ) end
end

-- ii.e
hook.Add( "CPPIAssignOwnership", "Impact CPPIAssignOwnership", function( ply, ent, uid )
	impact.Owner( ent, ply )
end )

hook.Add( "ImpactUnload", "Impact CPPI ImpactUnload", function()
    ENT.CPPIGetOwner 	= nil
	ENT.CPPISetOwner 	= nil
	ENT.CPPICanTool 	= nil
	ENT.CPPICanPhysgun	= nil
	ENT.CPPICanPickup	= nil
	ENT.CPPICanPunt		= nil
	ENT.CPPICanUse		= nil
	ENT.CPPICanDamage	= nil
	ENT.CPPIDrive		= nil
	ENT.CPPICanEditVariable = nil
	
	CPPI = nil

	impact.Print( "CPPI cleaned" )
	hook.Remove( "CPPIAssignOwnership", "Impact CPPIAssignOwnership" )
    hook.Remove( "ImpactUnload", "Impact CPPI ImpactUnload" )
end )
