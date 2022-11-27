-- AttentionToPrisoner --

function look_around(types, cb, range, justOne)
	local count = 0
	if range == "max" then range = 9999 end
	for k, v in pairs(types) do
		local os = this.GetNearbyObjects(v, (range or nearbyRange))
		for o, distance in pairs( os ) do
			count = count + 1
			if cb then
				cb(o)
			end
			if justOne then return o end
		end
	end
	if justOne then
		return nil
	else
		return count
	end
end


local target_range = 0.8
local target
local already_marked = false

function checkDuplication(marker)
	-- print(marker.target_id)
	if marker.target_id == target.Id.u then
		already_marked = true
	end
end

function Create()
	target = look_around({"Prisoner"}, nil, target_range, true)
	if target then
		-- print(target.Id.u)
		-- print('---')
		look_around({"AttentionMarker"}, checkDuplication, 'max')
		if already_marked then
			this.Sound("_Interface", "Cancel")
		else
			this.Sound("Doctor", "Place") -- Q
			marker = Object.Spawn("AttentionMarker", target.Pos.x, target.Pos.y - 0.7)
			marker.target_id = target.Id.u
		end
	else
		this.Sound("_Interface", "Cancel")
	end

	this.Delete()
end
