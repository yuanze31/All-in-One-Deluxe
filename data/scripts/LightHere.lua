-- RotateObject



function look(who, types, cb, range, justOne)
	local count = 0
	if range == "max" then range = 9999 end
	for k, v in pairs(types) do
		local os = who.GetNearbyObjects(v, range)
		for o, distance in pairs( os ) do
			count = count + 1
			if justOne then
				if cb then
					if cb(o, distance) then
						return o
					end
				else
					return o
				end
			else
				if cb then
					cb(o, distance)
				end
			end
		end
	end
	if justOne then
		return nil
	else
		return count
	end
end

function getCell(x, y)
	return World.GetCell(math.floor(x), math.floor(y))
end

function getObjCell(o)
	return World.GetCell(math.floor(o.Pos.x), math.floor(o.Pos.y))
end


function SpawnAt(type, to, dx, dy)
	return Object.Spawn(type, (to.Pos.x + (dx or 0)), (to.Pos.y + (dy or 0)))
end

function deleteO( o )
	o.Pos.x = 0.5
	o.Pos.y = 0.5
	o.Delete()
end


function Create()
	removeOther(2.2)
	deleteO(this)
end

local thisRoomId


function removeOther(range)
	local c = getObjCell(this)
	thisRoomId = c.Room.u
	look(this, {'Light'}, checkLight, range)
	SpawnAt('Light', this)
end

local wallTypeDict = {ConcreteWall=true, BrickWall=true, BurntWall=true, Fence=true, PerimeterWall=true}
local doorTypes = {'Door', 'JailDoor', 'JailDoorLarge', 'StaffDoor', 'SolitaryDoor', 'RemoteDoor',}

function checkLight(l)
	local c = getObjCell(l)
	if thisRoomId == c.Room.u or wallTypeDict[c.Mat] or look(l, doorTypes, nil, 0.5, true) then
		deleteO(l)
		if World.Balance then
			World.Balance = World.Balance + 30
		end
	end
end




