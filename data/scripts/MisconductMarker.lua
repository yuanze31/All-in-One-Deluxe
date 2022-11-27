-- MisconductMarker --

function search(uid, types, center_object, range)
	center_object = center_object or this
	if range == "max" then range = 9999 end

	for k, v in pairs(types) do
		local os = center_object.GetNearbyObjects(v, (range or nearbyRange))
		for o, distance in pairs( os ) do
			if o.Id.u == uid then
				print("Found object "..v.." #"..uid)
				return o
			end
		end
	end
	return nil
end


local target

function trackTarget()
	if not target then return end

	this.Pos.x = target.Pos.x + target.Or.x * 0.1
	-- local dy = 0.4 - (Game.Time() % 0.8) / 2
	-- local dy = (3 - math.floor(Game.Time() * 5) % 6) / 15
	this.Pos.y = target.Pos.y - 1.7
end


local Ready = 0
local misconduct_timespan = 8 -- minutes

function Update()
	if not target then
		if this.target_id then
			target = search(this.target_id, {'Prisoner'}, this, 5)
		else
			this.Delete()
		end
	end

	if target == nil or target.Category == nil or target.Damage >= 1 or World.TimeIndex - target.TimeOfLastMisconduct > misconduct_timespan * World.TimeWarpFactor then
		this.Delete()
		return
	end

	-- if Game.Time() > Ready then
	-- 	Ready = Game.Time() + 0.00001
		if target.Pos.x == nil then
			this.Delete()
		else
			trackTarget()
		end
	-- end

end

