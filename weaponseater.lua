if SEAT_WEAPONISER_VERSION2 then return end

TOOL.Category = "BFG's Weapon Seats"
TOOL.Author = "BFG"
TOOL.Name = "Seat Weaponiser"
TOOL.Command = nil
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 
 
//TOOL.ClientConVar[ "myparameter" ] = "fubar"

if CLIENT then
	language.Add ("Tool.weaponseater.name", TOOL.Name)
	language.Add ("Tool.weaponseater.desc", "Enable the usage of weapons in seats and vehicles")
	language.Add ("Tool.weaponseater.0", "Primary: Enable in-seat weapons. Secondary: Disable in-seat weapons.")
end

local NotVehicleNotification = function( user, entityname )
		user:ChatPrint( '"' .. entityname .. '"' .. " is not a vehicle!" )
end
local BlacklistNotification = function( user, entityname )
		user:ChatPrint( '"' .. entityname .. '"' .. " is on the blacklist!" )
end

// I have removed this for now because some third party vehicles use the jeep entity on a custom model that does not have a collision mesh blocking the driver seat.
TOOL.VehicleBlacklist = { --we don't want these vehicles to be usable because the nature of their hitbox doesn't allow you to shoot from inside
	"prop_vehicle_jeep_old",
	"prop_vehicle_jeep",
	"prop_vehicle_airboat"
}

function TOOL:LeftClick( trace )
	if SERVER and IsValid(trace.Entity) and (not trace.HitWorld) then
		local vehickey = trace.Entity
		if vehickey:IsVehicle() /* and (not table.HasValue(self.VehicleBlackList, vehickey:GetClass()) ) */ then
			WeaponSeats_Designate( vehickey, false)
			self:GetOwner():ChatPrint("You can now use weapons in this " .. vehickey:GetClass() .. "!")
		else
			NotVehicleNotification( self:GetOwner(), vehickey:GetClass() )
		end
	end
	return true
end
 
function TOOL:RightClick( trace )
	if SERVER and IsValid(trace.Entity) and (not trace.HitWorld) then
		local vehickey = trace.Entity
		if vehickey:IsVehicle() then
			if vehickey:GetNWBool("Weapon_Usage_Allowed", false) then
				self:GetOwner():ChatPrint("Weapon usage functionality removed from this " .. vehickey:GetClass() .. "!")
			end
			WeaponSeats_Designate( vehickey, true )
		else
			NotVehicleNotification( self:GetOwner(), vehickey:GetClass() )
		end
	end
	return true
end