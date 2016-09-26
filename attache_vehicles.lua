local Category = "Syphas Attache seat"

local function StandAnimation( vehicle, player )
	return player:SelectWeightedSequence( ACT_HL2MP_IDLE_CROUCH ) 
end

local V = {
	Name = "Syphas Attache Custom Seat",
	Model = "models/nova/airboat_seat.mdl",
	Class = "prop_vehicle_prisoner_pod",
	Category = Category,

	Author = "Syphadias Attache",
	Information = "Seat by Syphadias with custom animation and added by Attache ability to use weapons",
	Offset = 16,

	KeyValues = {
		vehiclescript = "scripts/vehicles/prisoner_pod.txt",
		limitview = "0"
	},
	Members = {
		HandleAnimation = StandAnimation,
	}
}
list.Set( "Vehicles", "attache_seat", V )
