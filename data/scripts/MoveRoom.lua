-- MoveRoom --
local flip

function look(who, types, cb, range, justOne)
    local count = 0
    if range == "max" then
        range = 9999
    end
    for k, v in pairs(types) do
        local os = who.GetNearbyObjects(v, range)
        for o, distance in pairs(os) do
            -- print(o.Type)
            count = count + 1
            if cb then
                cb(o)
            end
            if justOne then
                return o
            end
        end
    end
    if justOne then
        return nil
    else
        return count
    end
end

function deleteO(o)
    -- o.Hidden = true
    o.Pos.x = 0.5
    o.Pos.y = 0.5
    o.Delete()
end

local anchor
local rs

function setRoomSelector(o)
    if not o.discarded then
        rs = o
    end
end

function Create()
    anchor = Object.Spawn('Anchor', 0, 0)

    look(this, {'RoomSelector'}, setRoomSelector, 'max')
    if rs then
        -- print('clone...')
        moveRoom()
        rs.b = rs.b + this.Pos.y - 0.5 - rs.t
        rs.r = rs.r + this.Pos.x - 0.5 - rs.l
        rs.t = this.Pos.y - 0.5
        rs.l = this.Pos.x - 0.5
        rs.Pos.x = this.Pos.x
        rs.Pos.y = this.Pos.y
        anchor.Delete()
    else
        this.Hidden = true
    end
    -- this.Delete()d
    deleteO(this)
end

local objects_already_moved = {}
local new_mats1 = {}
local new_mats2 = {}

function matLater1(x, y, type)
    local k = x * 1000 + y
    new_mats1[k] = {
        x = x,
        y = y,
        type = type
    }
end

function matLater2(x, y, type)
    local k = x * 1000 + y
    new_mats2[k] = {
        x = x,
        y = y,
        type = type
    }
end

function override(t1, t2)
    for k, v in pairs(t2) do
        t1[k] = v
    end
    return t1
end

function moveRoom()
    local destLeft = this.Pos.x - 0.5
    local destTop = this.Pos.y - 0.5
    local tx
    local ty

    for sy = rs.t, rs.b do

        if flip == 'y' then
            ty = destTop + (rs.b - sy)
        else
            ty = destTop + (sy - rs.t)
        end

        for sx = rs.l, rs.r do
            if flip == 'x' then
                tx = destLeft + (rs.r - sx)
            else
                tx = destLeft + (sx - rs.l)
            end
            moveCell(sx, sy, tx, ty, flip)
        end
    end

    local new_mats = override(new_mats1, new_mats2)

    for id, m in pairs(new_mats) do
        local c = World.GetCell(m.x, m.y)
        c.Mat = m.type
        print('m')
        print(m.x)
        print(m.y)
        print(m.type)
    end

end

local wallTypeDict = {
    ConcreteWall = true,
    BrickWall = true,
    BurntWall = true,
    Fence = true,
    PerimeterWall = true
}

local objTypes = {'PersonalSink', 'MedicineCabinet', 'AccountingTable', "Bed", "BunkBed", "Light", "Crib", "PlayMat",
                  "Toilet", "Table", "Chair", "Bench", "JailDoor", "JailDoorLarge", "JailDoorXL", "Door", "StaffDoor",
                  "SolitaryDoor", "RemoteDoor", "JailBars", "Window", "WindowLarge", "Cooker", "Fridge", "Bin", "Sink",
                  "ServingTable", "ShowerHead", "Bookshelf", "OfficeDesk", "SchoolDesk", "FilingCabinet", "MedicalBed",
                  "MorgueSlab", "PowerSwitch", "WaterBoiler", "PipeValve", "Sprinkler", "Drain", "MetalDetector",
                  "WeightsBench", "PhoneBooth", "Tv", "LargeTv", "PoolTable", "Cctv", "CctvMonitor",
                  "DoorControlSystem", "PhoneMonitor", "Servo", "DoorTimer", "LogicCircuit", "LogicBridge",
                  "PressurePad", "StatusLight", "LaundryMachine", "IroningBoard", "WorkshopSaw", "WorkshopPress",
                  "CarpenterTable", "VisitorTable", "VisitorTableSecure", "DogCrate", "GuardLocker", "WeaponRack",
                  "SofaChairSingle", "SofaChairDouble", "DrinkMachine", "ArcadeCabinet", "Radio", "Altar", "Pews",
                  "PrayerMat", "LibraryBookshelf", "SortingTable", "ShopFront", "ShopShelf", "GuardTower", "Radiator",
                  'TimedCaller', 'Tree', 'RoomCellMarker'}

-- "PowerStation", "WaterPumpStation", "Capacitor",

function moveCell(sx, sy, tx, ty)
    local cellSource = World.GetCell(sx, sy)
    local cellTarget = World.GetCell(tx, ty)

    local newFloor
    if cellSource.Ind then
        newFloor = 'ConcreteFloor'
    else
        newFloor = 'Dirt'
    end
    matLater1(sx, sy, newFloor)
    matLater2(tx, ty, cellSource.Mat)

    local new
    local dx
    local dy
    for k, v in pairs(objTypes) do
        anchor.Pos.x = sx + 0.5
        anchor.Pos.y = sy + 0.5
        local os = anchor.GetNearbyObjects(v, 0.75)
        for o, distance in pairs(os) do
            -- print(o.Type)
            if objects_already_moved[o] then
                -- Object moved from elsewhere in the same room
            elseif o.Pos.x == sx + 1 or o.Pos.y == sy + 1 then
                -- Not this cell
                -- print('Not this cell')
            else
                if o.Pos.x == sx and flip == 'x' then
                    dx = 1
                else
                    dx = 0
                end
                if o.Pos.y == sy and flip == 'y' then
                    dy = 1
                else
                    dy = 0
                end

                local new_x = o.Pos.x + tx - sx + dx
                local new_y = o.Pos.y + ty - sy + dy
                o.Pos.x = new_x
                o.Pos.y = new_y

                objects_already_moved[o] = true
            end

        end
    end
end
