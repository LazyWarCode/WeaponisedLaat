// This addon is authored and maintained by BFG9000.
// If you have any questions or concerns, I would prefer that you PM me at http://www.facepunch.com/member.php?u=404602
// or leave a comment on the workshop page of this add-on.
if SEAT_WEAPONISER_VERSION2 then return end
AddCSLuaFile()

/*
ToDo:
- Make it so that you can save weapon-enabled seats
- enable toggling of the in-seat crosshair via console variable
*/



hook.Add("CanPlayerEnterVehicle", "BFG_WeaponSeats_WeaponEnabler", function(ply, vehicle, role)
	//if not vehicle.CanHaveGunner then player.GetByID(1):Kill() end
	//print(vehicle:GetNWBool("Weapon_Usage_Allowed", false))
	if vehicle:GetNWBool("Weapon_Usage_Allowed", false) then
		ply:SetAllowWeaponsInVehicle(true)
	else
		ply:SetAllowWeaponsInVehicle(false)
	end
end)


local function GetAllVehicles()
	local ents = ents.GetAll()
	local vehicles = {}
	for k,v in pairs(ents) do
		if IsValid(v) and v:IsVehicle() then
			table.ForceInsert( vehicles, v )
		end
	end
	return vehicles
end

hook.Add("Think", "BFG_WeaponSeats_CallbackCaller", function()
	for k,v in pairs(GetAllVehicles()) do
		if v.ResetPunchThink then
			v:ResetPunchThink()
		end
	end
end)



// Compensation for differences between eye angles and aimvectors, and other detours
local PLAYER = FindMetaTable("Player")


if not PLAYER._BEyeAngles_WeaponSeatsBackup then
	//PLAYER._BEyeAngles_WeaponSeatsBackup = PLAYER.EyeAngles
	PLAYER._BEyeAngles_WeaponSeatsBackup = FindMetaTable("Entity").EyeAngles
end
function PLAYER:EyeAngles()
		if self:InVehicle() and self:GetVehicle():GetNWBool("Weapon_Usage_Allowed", false) then
			return self:GetAimVector():Angle()
		else
			return self:_BEyeAngles_WeaponSeatsBackup()
		end
end

/*
if not PLAYER._BGetAimVector_WeaponSeatsBackup then
	//PLAYER._BEyeAngles_WeaponSeatsBackup = PLAYER.EyeAngles
	PLAYER._BGetAimVector_WeaponSeatsBackup = FindMetaTable("Player").GetAimVector
end
function PLAYER:GetAimVector()
		if self:InVehicle() then
			return self:EyeAngles():Forward()
		else
			return self:_BGetAimVector_WeaponSeatsBackup()
		end
end
*/
/*
if not PLAYER._BGetEyeTrace_WeaponSeatsBackup then
	PLAYER._BGetEyeTrace_WeaponSeatsBackup = PLAYER.GetEyeTrace
end
function PLAYER:GetEyeTrace()
	if self:InVehicle() then
		local trdata = { start = self:GetShootPos(), endpos = self:GetAimVector() * 99999, filter = self }
		local trace = util.TraceLine(trdata)
		return trace
	else
		return self:_BGetEyeTrace_WeaponSeatsBackup()
	end
end
*/


if not PLAYER._BSetEyeAngles_WeaponSeats then
	PLAYER._BSetEyeAngles_WeaponSeats = PLAYER.SetEyeAngles
end
function PLAYER:SetEyeAngles(targetangle)
	if self:InVehicle() and self:GetVehicle():GetNWBool("Weapon_Usage_Allowed", false) then
		local calcangle = self:GetVehicle():WorldToLocalAngles(targetangle)
		self:_BSetEyeAngles_WeaponSeats(calcangle)
	else
		self:_BSetEyeAngles_WeaponSeats(targetangle)
	end
end
--[[
hook.Add("PlayerLeaveVehicle", "BFG_WeaponSeats_EyeAngleReset", function( ply, veh )
	local components = ply:GetEyeAngles()
	ply:SetEyeAngles(Angle(components.p, components.y, 0))
end)
]]--
if not PLAYER._BViewPunch_WeaponSeats then
	PLAYER._BViewPunch_WeaponSeats = PLAYER.ViewPunch
end
function PLAYER:ViewPunch(ang)
	if self:InVehicle() then
		self:SetViewPunchAngles(ang)
	else
		return self:_BViewPunch_WeaponSeats(ang)
	end
end

/*
if not PLAYER._BSetViewPunchAngles_WeaponSeatsBackup then
	//PLAYER._BEyeAngles_WeaponSeatsBackup = PLAYER.EyeAngles
	PLAYER._BSetViewPunchAngles_WeaponSeatsBackup = PLAYER.SetViewPunchAngles
end
function PLAYER:SetViewPunchAngles(targetangle)
		if self:InVehicle() and self:GetVehicle():GetNWBool("Weapon_Usage_Allowed", false) then
			local calcangle = self:GetVehicle():WorldToLocalAngles(targetangle)
			//self:_BSetEyeAngles_WeaponSeats(calcangle)
			return self:_BSetViewPunchAngles_WeaponSeatsBackup(targetangle)
		else
			return self:_BSetViewPunchAngles_WeaponSeatsBackup(targetangle)
		end
end
*/

/*
if not PLAYER._BGetShootPos_WeaponSeats then
	PLAYER._BGetShootPos_WeaponSeats = PLAYER.GetShootPos
end
function PLAYER:GetShootPos()
	if self:InVehicle() and self:GetVehicle():GetNWBool("Weapon_Usage_Allowed", false) then
		local attindex = self:LookupAttachment("eyes")
		local attpos = self:GetAttachment(attindex).Pos 

		return (attpos or self:_BGetShootPos_WeaponSeats())
	else
		return (self:_BGetShootPos_WeaponSeats())
	end
end
*/



// Utility funcs

function WeaponSeats_Designate( vehicle, shouldRemove )
	if not shouldRemove then
		function vehicle:ResetPunchThink()
			//print("Let me think….")
			local driver = self:GetDriver()
			if IsValid(driver) then
			//	print(driver:GetAimVector():Angle())
			//	print(driver:EyeAngles())
				if driver:GetViewPunchAngles() != Angle(0,0,0) then
					driver:SetViewPunchAngles(driver:GetViewPunchAngles()*0.925)
				end
				/*
				local eyeangles = driver:EyeAngles()
				if eyeangles.roll != driver:GetAngles().roll then
					local targetroll = driver:GetAngles().roll
					local rolldiff = math.NormalizeAngle(math.AngleDifference(targetroll, eyeangles.roll))
					local calcroll = (rolldiff * .9) + targetroll
					print(eyeangles.roll)
					print(calcroll)
					driver:SetEyeAngles(Angle(eyeangles.pitch, eyeangles.yaw, calcroll))
				end
				*/
			end
		end
			vehicle.CanHaveGunner = true
			vehicle:SetNWBool("Weapon_Usage_Allowed", true)
	else
		vehicle.ResetPunchThink = nil
		vehicle.CanHaveGunner = nil
		vehicle:SetNWBool("Weapon_Usage_Allowed", false)
	end
end





//



if SERVER then


hook.Add("EntityTakeDamage", "BFG_WeaponSeats_DamageFilter", function( target, dmginfo )
	if target:IsPlayer() and target:InVehicle() and target:GetVehicle():GetNWBool("Weapon_Usage_Allowed", false) then
		if (dmginfo:GetAttacker() == target) and (not dmginfo:IsExplosionDamage()) then
			dmginfo:ScaleDamage(0)
		end
	end
end)



end -- if SERVER then




if CLIENT then

hook.Add("HUDPaint", "BFG_WeaponSeats_HUDElement", function()
	local ply = LocalPlayer()
	if ply:InVehicle() and ply:GetVehicle():GetNWBool("Weapon_Usage_Allowed", false) then
		local aimtrace = ply:GetEyeTrace()
		local center = aimtrace.HitPos:ToScreen()
		local radius = math.max( ScrH()/150, ScrW()/150 )

		surface.DrawCircle( center.x, center.y, radius, Color(255,255,255,220))
		surface.DrawCircle( center.x, center.y, radius + 1, Color(20,20,20,220))
	end
end)


hook.Add("CalcView", "BFG_WeaponSeats_CalcVehViewCompensation", function(ply, pos, ang)
	if IsValid(ply:GetVehicle()) and ply:GetVehicle():GetNWBool("Weapon_Usage_Allowed", false) then
		local oldang = ang
		ang:Set(ply:EyeAngles() + ply:GetViewPunchAngles())
		local localvec, localang = WorldToLocal( Vector(0,0,0), ang, Vector(0,0,0), ply:GetVehicle():GetAngles())		

		ang:RotateAroundAxis( ang:Forward() * -1, localang.r)
	end
end)

hook.Add("CalcViewModelView", "BFG_WeaponSeats_CalcViewModelViewCompensation", function(wep, vm, oldpos, newpos, oldang, newang)
	if IsValid(vm:GetOwner()) then
		local ply = vm:GetOwner()
		if ply:InVehicle() and ply:GetVehicle():GetNWBool("Weapon_Usage_Allowed", false) then
			newang:Set(ply:EyeAngles() + ply:GetViewPunchAngles())
			local localvec, localang = WorldToLocal( Vector(0,0,0), newang, Vector(0,0,0), ply:GetVehicle():GetAngles())		
			newang:RotateAroundAxis( newang:Forward() * -1, localang.r )
		end
	end
end)


end --if CLIENT then