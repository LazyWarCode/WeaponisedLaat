
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Base = "fighter_base"
ENT.Type = "vehicle"

ENT.PrintName = "LAAT"
ENT.Author = "Liam0102"
ENT.Category = "Star Wars"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true;
ENT.AdminSpawnable = false;

ENT.EntModel = "models/ish/starwars/laat/laat_mk2.mdl"
ENT.Vehicle = "LAAT"
ENT.Allegiance = "Republic";

if SERVER then

ENT.FireSound = Sound("weapons/tie_shoot.wav");
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),Doors = CurTime(),};
ENT.StartHealth = 5000;

AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("laat");
	e:SetPos(tr.HitPos + Vector(0,0,10));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()


	self:SetNWInt("Health",self.StartHealth);
	
	self.WeaponLocations = {
		Right = self:GetPos()+self:GetForward()*360+self:GetUp()*25+self:GetRight()*58,
		Left = self:GetPos()+self:GetForward()*360+self:GetUp()*25+self:GetRight()*-58,
	}
	self.WeaponsTable = {};
	self.BoostSpeed = 1750;
	self.ForwardSpeed = 1000;
	self.UpSpeed = 500;
	self.AccelSpeed = 7;
	self.CanBack = true;
	self.CanShoot = true;
	self.AlternateFire = true;
	self.FireGroup = {"Right","Left"}
	
	self.Cooldown = 2;
	self.Overheat = 0;
	self.Overheated = false;
	
	self.Bullet = CreateBulletStructure(70,"green");
	
	self.SeatPos = {
	
		{self:GetPos()+self:GetUp()*31+self:GetRight()*-17.5, self:GetAngles()},
		{self:GetPos()+self:GetUp()*31+self:GetRight()*17.5,self:GetAngles()+Angle(0,180,0)},
		
		{self:GetPos()+self:GetUp()*31+self:GetRight()*-17.5+self:GetForward()*-24, self:GetAngles()},
		{self:GetPos()+self:GetUp()*31+self:GetRight()*17.5+self:GetForward()*-24, self:GetAngles()+Angle(0,180,0)},
		
		{self:GetPos()+self:GetUp()*31+self:GetRight()*-17.5+self:GetForward()*-45, self:GetAngles()},
		{self:GetPos()+self:GetUp()*31+self:GetRight()*17.5+self:GetForward()*-45, self:GetAngles()+Angle(0,180,0)},
		
		{self:GetPos()+self:GetUp()*31+self:GetRight()*-17.5+self:GetForward()*-68, self:GetAngles()},
		{self:GetPos()+self:GetUp()*31+self:GetRight()*17.5+self:GetForward()*-68, self:GetAngles()+Angle(0,180,0)},
		
		{self:GetPos()+self:GetUp()*31+self:GetRight()*-17.5+self:GetForward()*-90, self:GetAngles()},
		{self:GetPos()+self:GetUp()*31+self:GetRight()*17.5+self:GetForward()*-90, self:GetAngles()+Angle(0,180,0)},
		
		{self:GetPos()+self:GetUp()*31+self:GetRight()*-17.5+self:GetForward()*-113, self:GetAngles()},
		{self:GetPos()+self:GetUp()*31+self:GetRight()*17.5+self:GetForward()*-113, self:GetAngles()+Angle(0,180,0)},
		
		{self:GetPos()+self:GetUp()*31+self:GetRight()*-17.5+self:GetForward()*-135, self:GetAngles()},
		{self:GetPos()+self:GetUp()*31+self:GetRight()*17.5+self:GetForward()*-135, self:GetAngles()+Angle(0,180,0)},
	};
	
	self:SpawnSeats();
	self.ExitModifier = {x=0,y=87.5,z=20};

	self.PilotVisible = true;
	self.PilotPosition = {x=0,y=210,z=130};

	self.HasLookaround = true;
	self.BaseClass.Initialize(self);
	
	// Set Bodygroups after loading base initialize, otherwise there's no model set to run the bodygroups on
	self:SetBodygroup(8,1);
	self:SetBodygroup(9,1);
end


function ENT:SpawnSeats()
	self.Seats = {};
	for k,v in pairs(self.SeatPos) do
		local e = ents.Create("prop_vehicle_prisoner_pod");
		e:SetPos(v[1]);
		e:SetAngles(v[2]);
		e:SetParent(self);		
		e:SetModel("models/nova/airboat_seat.mdl");
		e:SetRenderMode(RENDERMODE_TRANSALPHA);
		e:SetColor(Color(255,255,255,0));	
		e:Spawn();
		e:Activate();
		e:GetPhysicsObject():EnableMotion(false);
		e:GetPhysicsObject():EnableCollisions(false);
		e.IsLAATSeat = true;
		e.LAAT = self;
		
		if(k % 2 > 0) then
			e.RightSide = true;
		else
			e.LeftSide = true;
		end
		
		self.Seats[k] = e;
	end

end

hook.Add("PlayerEnteredVehicle","LAATSeatEnter", function(p,v)
	if(IsValid(v) and IsValid(p)) then
		if(v.IsLAATSeat) then
			p:SetNetworkedEntity("LAATSeat",v);
			p:SetNetworkedEntity("LAAT",v:GetParent());
			p:SetNetworkedBool("LAATPassenger",true);
		end
	end
end);

hook.Add("PlayerLeaveVehicle", "LAATSeatExit", function(p,v)
	if(IsValid(p) and IsValid(v)) then
		if(v.IsLAATSeat) then
			local e = v.LAAT;
			if(IsValid(e)) then
				if(v.LeftSide) then
					p:SetPos(e:GetPos()+e:GetRight()*65+e:GetUp()*20+e:GetForward()*-40);
				elseif(v.RightSide) then
					p:SetPos(e:GetPos()+e:GetRight()*-65+e:GetUp()*20+e:GetForward()*-40);
				end
			end
			p:SetNetworkedEntity("LAATSeat",NULL);
			p:SetNetworkedEntity("LAAT",NULL);
			p:SetNetworkedBool("LAATPassenger",false);			
		end
	end
end);



function ENT:Use(p)

	self.UsePos = {
		self:GetPos()+self:GetForward()*65+self:GetRight()*-70+self:GetUp()*10,
		self:GetPos()+self:GetForward()*110+self:GetRight()*50+self:GetUp()*140,
	}
	for k,v in pairs(ents.FindInBox(self.UsePos[1],self.UsePos[2])) do
		if(v:IsPlayer() and v == p) then
			if(not self.Inflight) then
				self:Enter(p);
			end
		end
	end
end


function ENT:Think()

	if(self.Inflight) then
		//self.AccelSpeed = math.Approach(self.AccelSpeed,7,0.2);
		if(IsValid(self.Pilot)) then
			if(IsValid(self.Pilot)) then // I don't know why I need this here for a second check but when I don't it causes an error
				if(self.Pilot:KeyDown(IN_RELOAD)) then
					self:ToggleDoors();
				end
			end
			
		end
	end	

	self.BaseClass.Think(self);
end

function ENT:ToggleDoors()

	if(self.NextUse.Doors < CurTime()) then
		if(self.Door) then
			self:SetBodygroup(8,1);
			self.Door = false;
		else
			self:SetBodygroup(8,3);
			self.Door = true;
		end
		self.NextUse.Doors = CurTime() + 1;
	end
end

function ENT:PhysicsSimulate(phys,d)
	self.BaseClass.PhysicsSimulate(self,phys,d);
	if(self.Inflight) then
		self.Pilot:SetPos(self:GetPos()+self:GetForward()*87.5+self:GetRight()*30+self:GetUp()*20);
		self.Pilot:SetAngles(self:GetAngles());
	end
end

function ENT:Enter(p)

	self:SetBodygroup(9,0);
	self.BaseClass.Enter(self,p);
	
end

function ENT:Exit()

	self:SetBodygroup(9,1);
	self.BaseClass.Exit(self);
	
end


end

if CLIENT then

	ENT.EnginePos = {}
	ENT.Sounds={
		//Engine=Sound("ambient/atmosphere/ambience_base.wav"),
		Engine=Sound("vehicles/laat/laat_fly2.wav"),
	}
	ENT.CanFPV = true;

	hook.Add("ScoreboardShow","LAATScoreDisable", function()
		local p = LocalPlayer();	
		local Flying = p:GetNWBool("FlyingLAAT");
		if(Flying) then
			return false;
		end
	end)
	
	//"ambient/atmosphere/ambience_base.wav"
	local View = {}
	local function CalcView()
		
		local p = LocalPlayer();	
		local Flying = p:GetNWBool("FlyingLAAT");
		local Sitting = p:GetNWBool("LAATPassenger");
		local pos, face;
		local self = p:GetNWEntity("LAAT");
	
		
		if(Flying) then
			if(IsValid(self)) then
				local fpvPos = self:GetPos()+self:GetUp()*155+self:GetForward()*210;
				View = SWVehicleView(self,950,400,fpvPos,true);		
				return View;
			end
		elseif(Sitting) then
			local v = p:GetNWEntity("LAATSeat");	
			if(IsValid(v)) then
				if(v:GetThirdPersonMode()) then
					View = SWVehicleView(self,800,350,fpvPos);		
					return View;
				end
			end
		end
		
	end
	hook.Add("CalcView", "LAATView", CalcView)
	
	hook.Add( "ShouldDrawLocalPlayer", "LAATDrawPlayerModel", function( p )
		local self = p:GetNWEntity("LAAT", NULL);
		local PassengerSeat = p:GetNWEntity("LAATSeat",NULL);
		if(IsValid(self)) then
			if(IsValid(PassengerSeat)) then
				if(PassengerSeat:GetThirdPersonMode()) then
					return true;
				end
			end
		end
	end);

	function LAATReticle()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingLAAT");
		local self = p:GetNWEntity("LAAT");
		if(Flying and IsValid(self)) then
			SW_HUD_DrawHull(5000);
			SW_WeaponReticles(self);
			SW_HUD_DrawOverheating(self);
			
			local pos = self:GetPos()+self:GetForward()*240+self:GetUp()*147.5;
			local x,y = SW_XYIn3D(pos);
			
			SW_HUD_Compass(self,x,y);
			SW_HUD_DrawSpeedometer();
		end
	end
	hook.Add("HUDPaint", "LAATReticle", LAATReticle)

end