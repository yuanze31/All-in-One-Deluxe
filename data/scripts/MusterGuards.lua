-- MusterGuards --

local types_guard = {"Guard", "ArmedGuard", "DogHandler"}


function look_around(types, cb, range, justOne)
	local count = 0
	if range == "max" then range = 9999 end
	for k, v in pairs(types) do
		local os = this.GetNearbyObjects(v, (range or nearbyRange))
		for o, distance in pairs( os ) do
			if cb then
				count = count + 1
				print("#"..count.." ["..v.."]")
				cb(o)
				print("")
			end
			if justOne then return o end
		end
	end
	return count
end

local range_max = 20
local range_min = 4

function Create()
	look_around(types_guard, comeHereG, range_max)
	this.Sound("DogHandler", "MoveOrderIssued") -- Dildil

	-- this.CreateJob('ArmedGuardCalled')
	-- this.CreateJob('GuardCalled')
	this.Delete()
end

function dist( from, to )
	return math.pow(math.pow( (from.Pos.x - to.Pos.x), 2) + math.pow( (from.Pos.y - to.Pos.y), 2) , 0.5)
end

function comeHereG(g)
	if dist(g, this) < range_min then
		-- Already very near
	else
		if g.Damage < 0.5 and g.TargetObject.u <= 0 and g.Carrying.u <= 0 then
			g.PlayerOrderPos.x, g.PlayerOrderPos.y = this.Pos.x, this.Pos.y
		end
	end

end


