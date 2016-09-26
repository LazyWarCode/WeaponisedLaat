if SEAT_WEAPONISER_VERSION2 then return end
//if not FindMetaTable("Entity").IsScar then return end

TOOL.Category = "BFG's Weapon Seats"
TOOL.Author = "BFG"
TOOL.Name = "SCar Weaponiser"
TOOL.Command = nil
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 
 
//TOOL.ClientConVar[ "myparameter" ] = "fubar"

if CLIENT then
	language.Add ("Tool.weaponseater_scars.name", TOOL.Name)
	language.Add ("Tool.weaponseater_scars.desc", "Enable the usage of weapons in SCar passenger seats.")
	language.Add ("Tool.weaponseater_scars.0", "Primary: Enable in-seat weapons for passengers. Secondary: Disable in-seat weapons. Reload: Toggle weapons for the driver.")
end

local NotVehicleNotification = function( user, entityname )
		user:ChatPrint( '"' .. entityname .. '"' .. " is not an SCar!" )
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
		if vehickey:IsVehicle() and vehickey.IsScar and vehickey:IsScar() then
			for k,v in pairs(vehickey.Seats) do
				if not (k == 1) then
					WeaponSeats_Designate( v, false)
				end
			end
			self:GetOwner():ChatPrint("You can now use weapons in the passenger seats of " .. vehickey:GetClass() .. "!")
		else
			NotVehicleNotification( self:GetOwner(), vehickey:GetClass() )
		end
	end
	return true
end
 
function TOOL:RightClick( trace )
	if SERVER and IsValid(trace.Entity) and (not trace.HitWorld) then
		local vehickey = trace.Entity
		if vehickey:IsVehicle() and vehickey.IsScar and vehickey:IsScar() then
				self:GetOwner():ChatPrint("Weapon usage functionality removed from passenger seats of " .. vehickey:GetClass() .. "!")
			for k,v in pairs(vehickey.Seats) do
				if not (k == 1) then
					WeaponSeats_Designate( v, true)
				end
			end
		else
			NotVehicleNotification( self:GetOwner(), vehickey:GetClass() )
		end
	end
	return true
end

function TOOL:Reload(trace)
	if SERVER and IsValid(trace.Entity) and (not trace.HitWorld) then
		local vehickey = trace.Entity
		if vehickey:IsVehicle() and vehickey.IsScar and vehickey:IsScar() then
			if vehickey.Seats[1]:GetNWBool("Weapon_Usage_Allowed", false) then
				self:GetOwner():ChatPrint("Driver seat weapons disallowed.")
				WeaponSeats_Designate(vehickey.Seats[1], true)
			else
				self:GetOwner():ChatPrint("Driver seat weapons allowed.")
				WeaponSeats_Designate(vehickey.Seats[1])
			end
		else
			NotVehicleNotification( self:GetOwner(), vehickey:GetClass() )
		end
	end
	return true
end