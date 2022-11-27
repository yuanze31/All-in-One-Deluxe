-- MoveObject

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


local to_clear = false

function checkMarker(o)
	if not o.Hidden then
		if o.Pos.x == this.Pos.x and o.Pos.y == this.Pos.y then
			this.Sound("_Interface", "Cancel") -- Dewww
		else
			this.Sound("Guard", "Place") -- Fffoww
			moveFromMarker(o)
		end
		to_clear = true
		o.Hidden = true
		o.Delete()
	end
end


function Create()
	-- this.Or.x = 0
	-- this.Or.y = 1
	look(this, {'MoveObjectMarker'}, checkMarker, 'max')
	if not to_clear then
		Object.Spawn('MoveObjectMarker', this.Pos.x, this.Pos.y)
	end
	this.Delete()
end

local wallTypeDict = {ConcreteWall=true, BrickWall=true, BurntWall=true, Fence=true, PerimeterWall=true}


local objTypes = {'PersonalSink', 'MedicineCabinet', 'AccountingTable', "Bed", "BunkBed", "Toilet", "Table", "Chair", "Bench", "ElectricChair", "JailDoor", "JailDoorLarge", "JailDoorXL","Door", "StaffDoor", "SolitaryDoor", "RemoteDoor", "JailBars", "Window", "WindowLarge", "Cooker", "Fridge", "Bin", "Sink", "ServingTable", "ShowerHead", "Bookshelf", "OfficeDesk", "SchoolDesk", "FilingCabinet", "MedicalBed", "MorgueSlab", "PowerSwitch", "WaterBoiler", "PipeValve", "Sprinkler", "Drain", "MetalDetector", "WeightsBench", "PhoneBooth", "Tv", "LargeTv", "PoolTable", "Cctv", "CctvMonitor", "DoorControlSystem", "PhoneMonitor", "Servo", "DoorTimer", "LogicCircuit", "LogicBridge", "PressurePad", "StatusLight", "LaundryMachine", "IroningBoard", "WorkshopSaw", "WorkshopPress", "CarpenterTable", "VisitorTable", "VisitorTableSecure", "DogCrate", "GuardLocker", "WeaponRack", "SofaChairSingle", "SofaChairDouble", "DrinkMachine", "ArcadeCabinet", "Radio", "Altar", "Pews", "PrayerMat", "LibraryBookshelf", "SortingTable", "ShopFront", "ShopShelf", "Crib", "PlayMat", 'GuardTower', "Radiator", 'TimedCaller', 'Tree', }

-- "PowerStation", "WaterPumpStation", "Capacitor",


function moveFromMarker(marker)
	local offset = {}
	offset.x = this.Pos.x - marker.Pos.x
	offset.y = this.Pos.y - marker.Pos.y
	-- print(offset.x)
	-- print(offset.y)

	for k, v in pairs(objTypes) do
		local os = marker.GetNearbyObjects(v, 0.75)
		for o, distance in pairs( os ) do
			if o.Hidden then
			else
				-- Need dev fix a bug first...
				-- o.Pos.x = o.Pos.x + offset.x
				-- o.Pos.y = o.Pos.y + offset.y
				-- updateWall(o)

				local new = Object.Spawn(v, o.Pos.x + offset.x, o.Pos.y + offset.y)
				new.Or.x = o.Or.x
				new.Or.y = o.Or.y
				new.Walls.x = o.Walls.x
				new.Walls.y = o.Walls.y
				if o.OpenDir then
					new.OpenDir.x = o.OpenDir.x
					new.OpenDir.y = o.OpenDir.y
				end
				-- if o.TriggeredBy then
				-- 	new.TriggeredBy.i = o.TriggeredBy.i
				-- 	new.TriggeredBy.u = o.TriggeredBy.u
				-- end

				if o.Door then
					new.Door.i = o.Door.i
					new.Door.u = o.Door.u
				end

				o.Hidden = true
				o.Delete()
				o.Pos.x = o.Pos.x + offset.x
				o.Pos.y = o.Pos.y + offset.y
				print(o.Pos.x)
				print(o.Pos.y)
				print('----')
				updateWall(new)
			end
		end
	end
end


local orDirs = {
	{-1, 0},
	{0, -1},
	{1, 0},
	{0, 1},
	{-1, 0},
}

function tryFindNewWall(o)
	-- print('tryFindNewWall')
	o.Walls.x = 0
	o.Walls.y = 0
	if o.Type == 'Servo' then
		return
	end
	local dir = {}
	local cellOr = {}
	for i, xy in pairs( orDirs ) do

		if i > 4 then break end

		local dx = xy[1]
		local dy = xy[2]
		-- print(dx)
		-- print(dy)
		-- print('...')
		if dx == o.Walls.x and dy == o.Walls.y then
		else
			local cell = getCell(o.Pos.x + dx, o.Pos.y + dy)
			if wallTypeDict[cell.Mat] then
				-- print('NEW WALL!')
				-- print(dx)
				-- print(dy)
				o.Walls.x = dx
				o.Walls.y = dy
				-- dir = {
				-- 	x = dx,
				-- 	y = dy,
				-- }
				if dx == o.Or.x and dy == o.Or.y then
					-- cellOr = {
					-- 	x = dx,
					-- 	y = dy,
					-- }
					break
				end
			end
		end
	end
	-- if dir.x == nil then
	-- else
	-- end
end




function makeBooleanDict(t)
	local d = {}
	for k, v in pairs(t) do
		d[v] = true
	end
	return d
end

local AttachToWallTypes = {'Radio', 'Crib', 'Toilet', 'Table', 'ShowerHead', 'Bookshelf', 'OfficeDesk', 'FilingCabinet', 'MorgueSlab', 'PhoneBooth', 'Tv', 'Cctv', 'GuardLocker', 'SofaChairSingle', 'SofaChairDouble', 'DrinkMachine', 'ArcadeCabinet', 'Altar', 'Radiator',}
-- 'Bed', 'SuperiorBed', 'SchoolDesk', 'Sprinkler', 'WeaponRack',
local AttachToWallTypeDict = makeBooleanDict(AttachToWallTypes)

function updateWall(o)
	if not AttachToWallTypeDict[o.Type] then
		return
	end

	if o.Walls.x == 0 and o.Walls.y == 0 then
		tryFindNewWall(o)
	else
		local cellWall = getCell(o.Pos.x + o.Walls.x, o.Pos.y + o.Walls.y)
		-- print(cellWall.Mat)
		if not wallTypeDict[cellWall.Mat] then
			tryFindNewWall(o)
		end
	end
end

function getCell(x, y)
	return World.GetCell(math.floor(x), math.floor(y))
end

