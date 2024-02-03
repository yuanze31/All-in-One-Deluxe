-- RotateObject --
function look_around(types, cb, range, justOne)
    local count = 0
    if range == "max" then
        range = 9999
    end
    for k, v in pairs(types) do
        local os = this.GetNearbyObjects(v, (range or nearbyRange))
        for o, distance in pairs(os) do
            count = count + 1
            if cb then
                cb(o, distance)
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

function Create()
    rotateThose()
    this.Hidden = true
    this.Delete()
end

local wallTypeDict = {
    ConcreteWall = true,
    BrickWall = true,
    BurntWall = true,
    Fence = true,
    PerimeterWall = true
}

local objTypes = {'PersonalSink', 'MedicineCabinet', 'AccountingTable', "Bed", "BunkBed", "Crib", "PlayMat", "Toilet",
                  "Table", "Chair", "Bench", "JailDoor", "JailDoorLarge", "JailDoorXL", "Door", "StaffDoor",
                  "SolitaryDoor", "RemoteDoor", "JailBars", "Window", "WindowLarge", "Cooker", "Fridge", "Bin", "Sink",
                  "ServingTable", "ShowerHead", "Bookshelf", "OfficeDesk", "SchoolDesk", "FilingCabinet", "MedicalBed",
                  "MorgueSlab", "PowerSwitch", "WaterBoiler", "MetalDetector", "WeightsBench", "PhoneBooth", "Tv",
                  "LargeTv", "PoolTable", "Cctv", "CctvMonitor", "DoorControlSystem", "PhoneMonitor", "Servo",
                  "DoorTimer", "LogicCircuit", "IroningBoard", "VisitorTable", "VisitorTableSecure", "DogCrate",
                  "GuardLocker", "SofaChairSingle", "SofaChairDouble", "DrinkMachine", "ArcadeCabinet", "Radio",
                  "Altar", "Pews", "PrayerMat", "LibraryBookshelf", "SortingTable", "ShopFront", "ShopShelf",
                  "GuardTower", "WeaponRack", "Radiator"}
-- Except "PowerStation", "Capacitor", "WaterPumpStation", "ElectricChair", "LogicBridge", "StatusLight", "PipeValve", "Light", "Sprinkler", "Drain", "WorkshopSaw", "WorkshopPress", "CarpenterTable", "PressurePad", "LaundryMachine",

sizeDict = {
    AccountingTable = {3, 1},
    Table = {4, 1},
    Bench = {4, 1},
    Bed = {1, 2},
    BunkBed = {1, 2},
    SuperiorBed = {1, 2},
    MedicalBed = {2, 2},
    ElectricChair = {2, 2},
    JailDoorXL = {3, 1},
    JailDoorLarge = {2, 1},
    WindowLarge = {2, 1},
    Cooker = {2, 1},
    Fridge = {2, 1},
    Sink = {3, 1},
    ServingTable = {5, 1},
    OfficeDesk = {2, 1},
    WaterBoiler = {2, 1},
    LargeTv = {3, 1},
    ShopFront = {2, 1},
    CctvMonitor = {3, 1},
    DoorControlSystem = {2, 1},
    WeaponRack = {2, 1},
    SofaChairDouble = {2, 1},
    SchoolDesk = {1, 2},
    MorgueSlab = {1, 2},
    PowerStation = {3, 3},
    WaterPumpStation = {3, 3},
    Servo = {1, 2},
    PoolTable = {3, 2},
    WorkshopSaw = {3, 1},
    WorkshopPress = {3, 1},
    CarpenterTable = {3, 2},
    VisitorTable = {3, 2},
    VisitorTableSecure = {2, 2},
    IroningBoard = {3, 1},
    SortingTable = {3, 1},
    LibraryBookshelf = {3, 1},
    ShopShelf = {3, 1},
    Altar = {3, 2},
    Pews = {4, 1},
    DogCrate = {1, 2},
    GuardTower = {2, 2}
}

local orDirs = {{0, 1}, {-1, 0}, {0, -1}, {1, 0}, {0, 1}}

function rotateDirOf(o, orGroup)
    for i, xy in pairs(orDirs) do

        if i > 4 then
            Game.DebugOut('Error: orGroup is invalid')
        else

            local dx = xy[1]
            local dy = xy[2]
            if dx == o[orGroup].x and dy == o[orGroup].y then
                local newOr = orDirs[i + 1]
                -- print('from')
                -- print(o[orGroup].x)
                -- print(o[orGroup].y)
                -- print('to')
                -- print(newOr[1])
                -- print(newOr[2])
                -- If not `* 1.01`, sometimes the image will not change as rotating happens.
                if orGroup == 'Or' then
                    o[orGroup].x = newOr[1]
                    -- o[orGroup].y = newOr[2] * 2
                    o[orGroup].y = newOr[2] * 1.01
                else
                    o[orGroup].x = newOr[1] * 1.01
                    o[orGroup].y = newOr[2]
                end
                return
            end

        end

    end
end

function offsetO(o)

    local rx = o.Pos.x - this.Pos.x
    local ry = o.Pos.y - this.Pos.y
    if rx == 0 and ry == 0 then
        return
    end

    local size = sizeDict[o.Type]
    if size == nil then
        print('No offset about such type:')
        print(o.Type)
        o.Pos.x = o.Pos.x + 0.0001 * o.Or.x
        return
    end
    if (size[1] + size[2]) % 2 == 0 then
        o.Pos.y = o.Pos.y + 0.0001 * o.Or.y
        return
    end

    print('offset')
    print(rx)
    print(ry)

    rx = rx * 2
    ry = ry * 2

    for i, xy in pairs(orDirs) do

        if i > 4 then
            Game.DebugOut('Error: rx an ry is invalid')
        else

            local dx = xy[1]
            local dy = xy[2]
            if dx == rx and dy == ry then
                local newOr = orDirs[i + 1]
                -- print('from')
                -- print(rx)
                -- print(ry)
                -- print('to')
                -- print(newOr[1])
                -- print(newOr[2])
                ry = newOr[2] / 2
                rx = newOr[1] / 2
                break
            end

        end

    end
    print(rx)
    print(ry)
    o.Pos.x = this.Pos.x + rx
    o.Pos.y = this.Pos.y + ry

    -- if o.Type == 'Pews' then
    -- 	if o.Or.x == 0 then
    -- 		-- vertical
    -- 		print('vertical')
    -- 		o.Pos.y = o.Pos.y + 0.5
    -- 		o.Pos.x = o.Pos.x + 0.5
    -- 	else
    -- 		o.Pos.y = o.Pos.y - 0.5
    -- 		o.Pos.x = o.Pos.x - 0.5
    -- 		-- o.Pos.y = o.Pos.y - 0.5
    -- 		-- o.Pos.x = o.Pos.x - 0.5
    -- 	end
    -- end
end

function rotateO(o)
    o.Or.x = math.min(o.Or.x, 1)
    o.Or.x = math.max(o.Or.x, -1)
    o.Or.y = math.min(o.Or.y, 1)
    o.Or.y = math.max(o.Or.y, -1)
    rotateDirOf(o, 'Or')
    offsetO(o)

    print('now-----')
    print(o.Or.x)
    print(o.Or.y)
    if o.OpenDir then
        rotateDirOf(o, 'OpenDir')
    end
    updateWall(o)
end

function rotateThose()

    for k, v in pairs(objTypes) do
        local os = this.GetNearbyObjects(v, 0.75)
        for o, distance in pairs(os) do
            if o.Hidden then
            else
                rotateO(o)
                this.Sound("Guard", "Place") -- Fffoww
            end
        end
    end
end

function tryFindNewWall(o)
    -- print('tryFindNewWall')
    o.Walls.x = 0
    o.Walls.y = 0
    local dir = {}
    local cellOr = {}
    for i, xy in pairs(orDirs) do

        if i > 4 then
            break
        end

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
                    print('o.Or.y')
                    print(o.Or.y)
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

local AttachToWallTypes = {'Radio', 'Crib', 'Toilet', 'Table', 'ShowerHead', 'Bookshelf', 'OfficeDesk', 'FilingCabinet',
                           'MorgueSlab', 'PhoneBooth', 'Tv', 'Cctv', 'GuardLocker', 'SofaChairSingle',
                           'SofaChairDouble', 'DrinkMachine', 'ArcadeCabinet', 'Altar', 'Radiator'}
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

