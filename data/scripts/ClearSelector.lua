-- ClearSelector --

function look(who, types, cb, range, justOne)
	local count = 0
	if range == "max" then range = 9999 end
	for k, v in pairs(types) do
		local os = who.GetNearbyObjects(v, range)
		for o, distance in pairs( os ) do
			-- print(o.Type)
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

function deleteO( o )
	o.Pos.x = 0
	o.Pos.y = 0
	o.Delete()
end

function Create()
	look(this, {'RoomSelector', 'RoomCellMarker'}, deleteO, 'max')
	deleteO(this)
end
