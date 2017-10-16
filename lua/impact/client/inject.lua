hook.Add( "PhysgunPickup", "Impact Fix Halo PhysgunPickup", function() return false end )

hook.Add( "ImpactUnload", "Impact Inject ImpactUnload", function()
    impact.Print( "Injection cleaned" )
	hook.Remove( "PhysgunPickup", "Impact Fix Halo PhysgunPickup" )
    hook.Remove( "ImpactUnload", "Impact Inject ImpactUnload" )
end )