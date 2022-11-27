function sizeOf(t)
	local count = 0
	for k, v in pairs(t) do
		count = count + 1
	end
	return count
end

function makeBooleanDict(t)
	local d = {}
	for k, v in pairs(t) do
		d[v] = true
	end
	return d
end


function extend( t1, t2 )
	if t2 then
		for i, v in pairs(t2) do
			table.insert(t1, v)
		end
	end
	return t1
end

function index(t, value)
	for k, v in pairs(t) do
		if value == v then return k end
	end
	return nil
end

function look_around(types, cb, range, justOne)
	local who = this
	local count = 0
	if range == "max" then range = 9999 end
	for k, v in pairs(types) do
		local os = who.GetNearbyObjects(v, (range or nearbyRange))
		for o, distance in pairs( os ) do
			count = count + 1
			if cb then
				cb(o)
			else
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



local borderTypes = {'PavingStone', "Dirt", "Grass", "LongGrass", "Sand", "Water", }
local borderTypeSize = sizeOf(borderTypes)

local mainTypes = {"Dirt", "Grass", "LongGrass", "Sand", 'Mud', 'Gravel', }
local mainTypeSize = sizeOf(mainTypes)
local mainTypeDict = makeBooleanDict(mainTypes)

local indoorTypes = {'ConcreteFloor', 'WoodenFloor', 'CeramicFloor', 'MosaicFloor', 'MetalFloor', 'MarbleTiles', 'WhiteTiles', 'FancyTiles',}
local indoorTypeSize = sizeOf(indoorTypes)
local indoorTypeDict = makeBooleanDict(indoorTypes)

local wallTypes = {'BrickWall', 'ConcreteWall', 'Fence', 'PerimeterWall', 'BurntWall'}
local wallTypeSize = sizeOf(wallTypes)
local wallTypeDict = makeBooleanDict(wallTypes)

-- local roadTypes = {'PavingStone', 'Stone', 'Gravel', 'Road',}
-- local roadTypeSize = sizeOf(roadTypes)
-- local roadTypeDict = makeBooleanDict(roadTypes)

local gridTypes = {'PavingStone', 'Dirt', 'Mud', 'Stone', 'Gravel', 'Grass', "LongGrass", "Sand",}
local gridTypeSize = sizeOf(gridTypes)
local gridTypeDict = makeBooleanDict(gridTypes)



local resumed = false

function Resume()
	resumed = true

	local cell00 = World.GetCell(0, 0)
	this.border_num = this.border_num or index(borderTypes, cell00.Mat) or 1
	local cellTR = World.GetCell(World.NumCellsX-2, 1)
	this.main_num = this.main_num or index(mainTypes, cellTR.Mat) or 1
	local cellAA = World.GetCell(10, 10)
	this.grid_num = this.grid_num or index(gridTypes, cellAA.Mat) or 1
	this.grid_enabled = this.grid_enabled or false
end




local miz_last = nil
local miz = nil

function diffMenu(miz)
	if not miz_last then return true end
	for i, v in pairs( miz ) do
		if not miz_last[i] or miz_last[i][1] ~= v[1] then
			return true
		end
	end
	return false
end

function updateMenu(miz)
	miz = miz or {}
	if diffMenu(miz) then
		refreshMenu(miz)
	else
		setCaptions(miz)
	end
end

function setCaptions(miz)
	for i, t in pairs(miz) do
		local cn = t[1]
		local translation = t[1]
		t[2] = t[2] or 'Caption'
		if type(cn) == 'table' then
			cn = t[1][1]
			translation = t[1][2]
		end
		Interface.SetCaption(this, "mc__"..cn, "mc__"..translation, t[3], t[4], t[5], t[6], t[7], t[8])
	end
end

function refreshMenu(miz)
	if miz_last then
		for i, t in pairs(miz_last) do
			local cn = t[1]
			if type(cn) == 'table' then cn = cn[1] end
			Interface.RemoveComponent(this, "mc__"..cn)
		end
	end

	for i, t in pairs(miz) do
		local cn = t[1]
		local translation = t[1]
		t[2] = t[2] or 'Caption'
		if type(cn) == 'table' then
			cn = t[1][1]
			translation = t[1][2]
		end
		Interface.AddComponent(this, "mc__"..cn, t[2], "mc__"..translation, t[3], t[4], t[5], t[6], t[7], t[8])
	end
	miz_last = miz
end


local roadWidth = 7
local roadRightMargin = 5
local roadR
local roadL

function updateRoadX()
	roadR = World.OriginW + World.OriginX - roadRightMargin - 1
	roadL = roadR - roadWidth + 1
end

function nextValue(arr, i, size)
	i = i + 1
	if i > size then i = 1 end
	return arr[i]
end



function mc__reinstall_passiveClicked()
	this.reinstall_passive = true
	Go()
end

function mc__change_borderClicked()
	this.border_num = this.border_num + 1
	if this.border_num > borderTypeSize then this.border_num = 1 end
	makeBorder(borderTypes[this.border_num])
	Go()
end

function makeBorder(BorderType)
	updateRoadX()
	local endX=-1
	local endY=-1
	local foundEndX=false
	local foundEndY=false

	while foundEndX==false do
		endX=endX+1
		local cell = World.GetCell(0, endX)
		if cell.Mat~=nil then
			cell.Mat=BorderType
		else
			endX=endX-1
			foundEndX=true
		end
	end

	while foundEndY==false do
		endY=endY+1
		local TopRowCell = World.GetCell(endY,0)
		local BottomRowCell = World.GetCell(endY,endX)
		if TopRowCell.Mat~=nil then
			if endY == roadL then
				endY=endY+roadWidth-1
			else
				TopRowCell.Mat=BorderType
				BottomRowCell.Mat=BorderType
			end
		else
			endY=endY-1
			foundEndY=true
		end

	end

	for i=0,endX do
		local cell = World.GetCell(endY,i)
		cell.Mat=BorderType
 	end

end



function mc__change_mainClicked()
	this.main_num = this.main_num + 1
	if this.main_num > mainTypeSize then this.main_num = 1 end
	makemain(mainTypes[this.main_num])
	if this.grid_enabled then
		makeGrid(gridTypes[this.grid_num])
	end
	Go()
end

function makemain(mainType)
	updateRoadX()
	local cell
	for x = 1, World.NumCellsX-2 do
		if x >= roadL and x <= roadR then
		else
			for y = 1, World.NumCellsY-2 do
				cell = World.GetCell(x, y)
				if cell.Room.u > 0 then
					-- do nothing
				-- elseif wallTypeDict[cell.Mat] then
				-- elseif indoorTypeDict[cell.Mat] then
				elseif mainTypeDict[cell.Mat] then
				-- else
					cell.Mat = mainType
				end
			end
		end
	end
end


function mc__toggle_gridClicked()
	this.grid_enabled = not this.grid_enabled
	if this.grid_enabled then
		makeGrid(gridTypes[this.grid_num])
	else
		makemain(mainTypes[this.main_num])
	end
	Go()
end

function mc__change_gridClicked()
	this.grid_num = this.grid_num + 1
	if this.grid_num > gridTypeSize then this.grid_num = 1 end
	makeGrid(gridTypes[this.grid_num])
	Go()
end

function makeGrid(gridType)
	updateRoadX()
	local cell

	local x = 10
	while x < World.NumCellsX do
		if x >= roadL and x <= roadR then
		else
			for y = 1, World.NumCellsY-2 do
				cell = World.GetCell(x, y)
				if cell.Room.u > 0 then
				elseif cell.Mat == 'PavingStone' then
				elseif wallTypeDict[cell.Mat] then
				elseif indoorTypeDict[cell.Mat] then
				else
					cell.Mat = gridType
				end
			end
		end
		x = x + 10
	end

	local y = 10
	while y < World.NumCellsY do
		for x = 1, World.NumCellsX-2 do
			if x >= roadL and x <= roadR then
			else
				cell = World.GetCell(x, y)
				if cell.Room.u > 0 then
				elseif wallTypeDict[cell.Mat] then
				elseif indoorTypeDict[cell.Mat] then
				else
					cell.Mat = gridType
				end
			end
		end
		y = y + 10
	end

end















function Create()
	-- mc__change_borderClicked()
	if not resumed then
		Resume()
	end
	local x = math.floor(this.Pos.x)
	local y = math.floor(this.Pos.y)
	cellHere = World.GetCell(x,y)
	print(cellHere.Room.u)
	Go()
end


local Ready = 0
local Delay = 0.5
function Update(timePassed)
	if not resumed then
		Resume()
	end

	if World.TimeIndex > Ready then
		Ready = World.TimeIndex + Delay
		Go()
	end
end

function Go()
	-- local mi_rp

	-- if this.reinstall_passive then
	-- 	mi_rp = {'reinstall_passive_waiting'}
	-- else
	-- 	mi_rp = {'reinstall_passive', 'Button'}
	-- end

	local miz = {
		-- mi_rp,
	}

	if World.CheatsEnabled then
		extend(miz, {
			-- {'sep'},
			{'reminder'},
			{'current_border_type', nil, 'material_'..borderTypes[this.border_num], 'N'},
			{'change_border', 'Button', 'material_'..nextValue(borderTypes, this.border_num, borderTypeSize), 'N'},
			{'current_main_type', nil, 'material_'..mainTypes[this.main_num], 'N'},
			{'change_main', 'Button', 'material_'..nextValue(mainTypes, this.main_num, mainTypeSize), 'N'},
			{'toggle_grid', 'Button', tostring(this.grid_enabled), 'B'},
		})

		if this.grid_enabled then
			extend(miz, {
				{'current_grid_type', nil, 'material_'..gridTypes[this.grid_num], 'N'},
				{'change_grid', 'Button', 'material_'..nextValue(gridTypes, this.grid_num, gridTypeSize), 'N'},
			})
		end
	end

	updateMenu(miz)

end


