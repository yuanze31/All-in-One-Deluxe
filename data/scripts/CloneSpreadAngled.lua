-- CloneSpread
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
    if rs and not inRoom(this.Pos.x, this.Pos.y, rs) then
        -- print('clone...')
        trySpread()
        if World.CheatsEnabled and World.ImmediateObjects then
            this.Hidden = true
            this.Delete()
        end

    else
        this.Hidden = true
        this.Delete()
    end

    anchor.Delete()
    this.Delete()
end

local dest = {}
local rc = {}
function trySpread()
    dest.x = this.Pos.x
    dest.y = this.Pos.y
    rc.x = math.floor((dest.x - rs.l) / (rs.r - rs.l))
    rc.y = math.floor((dest.y - rs.t) / (rs.b - rs.t))
    if math.abs(rc.x) > math.abs(rc.y) then
        spread('x', 'y')
    elseif math.abs(rc.x) < math.abs(rc.y) then
        spread('y', 'x')
    else
        this.Delete()
    end
end

function spread(primary, secondary)
    local primaryStep
    local primaryStartPoint
    if primary == 'x' then
        primaryStep = rs.r - rs.l
        primaryStartPoint = rs.l
    else
        primaryStep = rs.b - rs.t
        primaryStartPoint = rs.t
    end

    local secondaryStartPoint
    if secondary == 'x' then
        secondaryStartPoint = rs.l
    else
        secondaryStartPoint = rs.t
    end

    local loop_to
    if rc[primary] > 0 then
        loop_to = rc[primary]
    else
        loop_to = -rc[primary]
        primaryStep = -primaryStep
    end

    local secondaryStep
    secondaryStep = math.floor((dest[secondary] - secondaryStartPoint) / loop_to)

    for i = 1, loop_to do
        this.Pos[primary] = primaryStartPoint + i * primaryStep + 0.5
        this.Pos[secondary] = secondaryStartPoint + i * secondaryStep + 0.5
        clone()
    end
end

function clone()
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
            copyCell(sx, sy, tx, ty, flip)
        end

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
                  "Toilet", "Table", "Chair", "Bench", "ElectricChair", "JailDoor", "JailDoorLarge", "JailDoorXL",
                  "Door", "StaffDoor", "SolitaryDoor", "RemoteDoor", "JailBars", "Window", "WindowLarge", "Cooker",
                  "Fridge", "Bin", "Sink", "ServingTable", "ShowerHead", "Bookshelf", "OfficeDesk", "SchoolDesk",
                  "FilingCabinet", "MedicalBed", "MorgueSlab", "PowerStation", "Capacitor", "PowerSwitch",
                  "WaterPumpStation", "WaterBoiler", "PipeValve", "Sprinkler", "Drain", "MetalDetector", "WeightsBench",
                  "PhoneBooth", "Tv", "LargeTv", "PoolTable", "Cctv", "CctvMonitor", "DoorControlSystem",
                  "PhoneMonitor", "Servo", "DoorTimer", "LogicCircuit", "LogicBridge", "PressurePad", "StatusLight",
                  "LaundryMachine", "IroningBoard", "WorkshopSaw", "WorkshopPress", "CarpenterTable", "VisitorTable",
                  "VisitorTableSecure", "DogCrate", "GuardLocker", "WeaponRack", "SofaChairSingle", "SofaChairDouble",
                  "DrinkMachine", "ArcadeCabinet", "Radio", "Altar", "Pews", "PrayerMat", "LibraryBookshelf",
                  "SortingTable", "ShopFront", "ShopShelf", "GuardTower", "Radiator"}

function copyCell(sx, sy, tx, ty)
    local cellSource = World.GetCell(sx, sy)
    local cellTarget = World.GetCell(tx, ty)
    if not wallTypeDict[cellTarget.Mat] and cellTarget.Mat ~= cellSource.Mat then

        if World.CheatsEnabled and World.ImmediateObjects then
            cellTarget.Mat = cellSource.Mat
        else
            local cc = Object.Spawn('CCommand', tx, ty)
            cc.mat_type = cellSource.Mat
            cc.mat_type_old = cellTarget.Mat
            cellTarget.Mat = cellSource.Mat
        end

    end
    local new
    local dx
    local dy
    for k, v in pairs(objTypes) do
        anchor.Pos.x = sx + 0.5
        anchor.Pos.y = sy + 0.5
        local os = anchor.GetNearbyObjects(v, 0.75)
        for o, distance in pairs(os) do
            -- print(o.Type)
            if o.Pos.x == sx + 1 or o.Pos.y == sy + 1 then
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
                anchor.Pos.x = new_x
                anchor.Pos.y = new_y

                if look(anchor, {o.Type}, nil, 0.1, true) then
                else
                    new = Object.Spawn(o.Type, new_x, new_y)

                    if flip == 'x' then
                        new.Or.x = -o.Or.x
                        new.Walls.x = -o.Walls.x
                    else
                        new.Or.x = o.Or.x
                        new.Walls.x = o.Walls.x
                    end

                    if flip == 'y' then
                        new.Or.y = -o.Or.y
                        new.Walls.y = -o.Walls.y
                    else
                        new.Or.y = o.Or.y
                        new.Walls.y = o.Walls.y
                    end

                    if o.OpenDir then
                        new.OpenDir.x = o.OpenDir.x
                        new.OpenDir.y = o.OpenDir.y
                    end

                    if World.CheatsEnabled and World.ImmediateObjects then
                    else
                        local pc = Object.Spawn('PCommand', new.Pos.x, new.Pos.y)
                        pc.obj_type = new.Type
                        pc.Or.x = new.Or.x
                        pc.Or.y = new.Or.y
                        new.Delete()
                    end
                end

            end

        end
    end
end

function inRoom(x, y, room)
    x = math.floor(x)
    y = math.floor(y)
    if x >= room.l and x < room.r and y >= room.t and y < room.b then
        return true
    else
        return false
    end
end
