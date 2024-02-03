-- world.lua --
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
    -- print('rs !!!!!!!!!')
    o.Delete()
end

local anchor

function deleteOldAnchor(o)
    if o.Id.u ~= anchor.Id.u then
        o.Delete()
    end
end

local Ready = 0
local Ready2 = 0

function Update(timePassed)

    if anchor and anchor.Damage == nil then
        anchor = nil
    end

    if not anchor then
        anchor = Object.Spawn('Anchor', -0.5, -0.5)
        anchor.Tooltip = 'anchor_tt'

        local warden = look(anchor, {'Warden'}, nil, 'max', true)
        if warden then
            anchor = warden
        end

        look(anchor, {'Anchor'}, deleteOldAnchor, 'max')
        look(anchor, {'RotateObject'}, deleteOldAnchor, 'max')
    end

    if this.TimeIndex > Ready then
        Ready = this.TimeIndex + this.TimeWarpFactor
        look(anchor, {'TreeStump'}, deleteO, 'max')

        if this.ImmediateObjects then
            if anchor.add_modifiers then
                -- print('add_modifiers')
                look(anchor, {'TimeWarpNeedModifier'}, reinstallO, 'max')
                anchor.add_modifiers = nil
            end
            if anchor.remove_modifiers then
                look(anchor, {'TimeWarpNeedModifier'}, dismantleO, 'max')
                anchor.remove_modifiers = nil
            end
        end

        look(anchor, {'Polaroid'}, markPolaroid, 'max')
        look(anchor, {'SearchToilets'}, doSearchToilets, 'max')

        look(anchor, {'PCommand'}, exePC, 'max')
        look(anchor, {'CCommand'}, exeCC, 'max')
    end

    if this.ImmediateObjects and this.TimeIndex > Ready2 then
        Ready2 = this.TimeIndex + 3 * this.TimeWarpFactor
        look(anchor, {'Box'}, deleteMostBox, 'max')
        look(anchor, {'Rubble'}, deleteO, 'max')
        look(anchor, {'Stack'}, deleteMatStack, 'max')
        -- look(anchor, {'Foreman'}, mayReinstall, 'max')
        -- look(anchor, {'Prisoner', }, testP, 10)

    end
end

function deleteMostBox(box)
    if box.Contents ~= 'SuperiorBed' then
        box.Delete()
    end
end

function deleteMatStack(stack)
    if stack.Contents == 'Concrete' or stack.Contents == 'Steel' or stack.Contents == 'Brick' or stack.Contents ==
        'GrassTurf' then
        stack.Delete()
    end
end

function mayReinstall(foreman)

    if foreman.reinstall_passive then
        look(anchor, {'Radio', 'Bin'}, reinstallO2, 'max')
        foreman.reinstall_passive = false
    end

end

-- function testP(p)
-- Will crash the game
-- 	print(p.Pos.x)
-- 	print(Game.IncreaseNeeds)
-- 	p.Name = 'hi'
-- 	Game.IncreaseNeeds('Food', 1000)
-- 	p.Name = nil
-- end

local polaroid

function markPolaroid(pol)
    if pol.PolaroidIndex == -1 then
        return
    end
    -- print('Found a Polaroid')
    -- print(pol.PolaroidIndex)
    -- print(pol.BirthTime)
    if this.TimeIndex - pol.BirthTime > 30 then
        pol.BirthTime = this.TimeIndex
        polaroid = pol
        local g = look(polaroid, {'Guard'}, nil, 20, true)
        if g then
            musterToPolaroid(g)
        end
        g = nil
    end

end

function musterToPolaroid(g)
    if g.Damage < 0.1 and g.TargetObject.u <= 0 and g.Carrying.u <= 0 then
        g.PlayerOrderPos.x, g.PlayerOrderPos.y = polaroid.Pos.x, polaroid.Pos.y
    end
end

function Init()
    print('Inited')
end

local sizeDict = {
    AccountingTable = {3, 1},
    Table = {4, 1},
    Bench = {4, 1},
    Bed = {1, 2},
    BunkBed = {1, 2},
    SuperiorBed = {1, 2},
    MedicalBed = {2, 2},
    ElectricChair = {2, 2},
    JailDoorLarge = {2, 1},
    WindowLarge = {2, 1},
    Cooker = {2, 1},
    Fridge = {2, 1},
    Sink = {3, 1},
    ServingTable = {5, 1},
    OfficeDesk = {2, 1},
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
    GuardTower = {2, 2},
    WaterBoiler = {2, 1}
}

function exePC(o)
    if o.obj_type then
        local size = sizeDict[o.obj_type]
        local dx = 0
        local dy = 0
        if size then
            if o.Or.x == 0 then
                dx = (size[1] / 2)
                dy = (size[2] / 2)
            else
                dx = (size[2] / 2)
                dy = (size[1] / 2)
            end
        end
        WorkQueue.Request("PlaceObject", o.obj_type, o.Pos.x - dx, o.Pos.y - dy, o.Or.x, o.Or.y)
    end
    o.Delete()
end

function doSearchToilets(o)
    look(o, {'Toilet'}, searchO, 8)
    o.Delete()
end

function searchO(o)
    WorkQueue.Request("SearchObject", o)
end

function exeCC(o)
    if o.mat_type then
        local cell = World.GetCell(o.Pos.x, o.Pos.y)
        cell.Mat = o.mat_type_old
        WorkQueue.Request("Construction", o.mat_type, o.Pos.x, o.Pos.y)
    end
    o.Delete()
end

function reinstallO(o)
    WorkQueue.Request("PlaceObject", o.Type, o.Pos.x, o.Pos.y, o.Or.x, o.Or.y)
    o.Delete()
end

function reinstallO2(o)
    WorkQueue.Request("DismantleObject", o.Type, o.Pos.x, o.Pos.y, o.Or.x, o.Or.y)
    WorkQueue.Request("PlaceObject", o.Type, o.Pos.x, o.Pos.y, o.Or.x, o.Or.y)
end

function dismantleO(o)
    WorkQueue.Request("DismantleObject", o.Type, o.Pos.x, o.Pos.y, o.Or.x, o.Or.y)
    o.Delete()
end

