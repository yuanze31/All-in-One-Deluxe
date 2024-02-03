-- <Author: Brento666>--
-- <Copyright: Brento666, the Netherlands, 2015>--
-- <Don't redistribute: see base-language for cc>--
-- IMPLEMENTED for v0.69:
-- >Demolish perimiter walls
-- >Better sound timing
-- Possible future features if future API features allow:
-- Reveal/Destroy tunnels (cannot sense tunnels atm)
-- burnt-wall at 2 blocks away (increased wall-deconstruction affects burnt walls two atm)
local radius = 3.5
local vel_max = 3
local power_max = 7
local force = 2

-- function dist( from, to )
-- 	return math.pow(math.pow( (from.Pos.x - to.Pos.x), 2) + math.pow( (from.Pos.y - to.Pos.y), 2) , 0.5)
-- end

function calVel(obj, xy, mul)
    local delta = obj.Pos[xy] - this.Pos[xy]
    return delta * mul
end

function giveVel(obj, dist, weight)
    weight = weight or 1
    local mul = math.max(0, math.cos(dist / radius * math.pi / 2)) * vel_max / dist * (0.3 + 0.7 * 4 / (weight + 3))
    obj.ApplyVelocity(calVel(obj, 'x', mul), calVel(obj, 'y', mul))
end

local inited = false

function Init()
    this.Sound("__RiotAssault", "Explosion")
    inited = true
    StartFire(this.Pos.x, this.Pos.y)
    KillWalls()
    Explode()

    Object.Spawn("SmokeGenerator", this.Pos.x, this.Pos.y)
    Object.Spawn("SmokeGenerator", this.Pos.x, this.Pos.y)
    this.Sound("_World", "Explosion") -- crumble noise

end

function blowObjGroup(toughness, weight, objectTypes)
    for i, objectType in ipairs(objectTypes) do
        FindObjectsToDamage(objectType, toughness, weight)
    end
end

function Explode()

    -- normal entities
    local entityTypes = {"Prisoner", 'Avatar', "Warden", "Chief", "Guard", "DogHandler", "Dog", "Cook", "Janitor",
                         "Gardener", "Doctor", "Psychologist", "Accountant", "Lawyer", "Teacher", "Visitor",
                         "SpiritualLeader", "AppealsMagistrate", "AppealsLawyer", "ExecutionWitness", "Paramedic",
                         "ParoleOfficer", "ParoleLawyer", "TruckDriver", 'BoldHost', 'CameraMan'}
    for i, entityType in ipairs(entityTypes) do
        FindEntitiesToDamage(entityType, 1)
    end

    -- entities with protective clothing
    entityTypes = {"Workman", "Foreman", "ArmedGuard", 'Sniper', "Soldier", "RiotGuard", "Fireman"}
    for i, entityType in ipairs(entityTypes) do
        FindEntitiesToDamage(entityType, 2)
    end

    -- Rubble only gets velocity(no damage)
    local objects = Object.GetNearbyObjects("Rubble", radius)
    for obj, dist in pairs(objects) do
        giveVel(obj, dist)
    end

    -- Nearby garbage gets deleted and replaced by rubble + fire!
    local objects = Object.GetNearbyObjects("Garbage", radius)
    for obj, dist in pairs(objects) do
        local rubble = Object.Spawn("Rubble", obj.Pos.x, obj.Pos.y)
        giveVel(rubble, dist)
        -- local fire = Object.Spawn( "Fire", obj.Pos.x, obj.Pos.y )
        -- giveVel(fire, dist)

        obj.Delete()
    end

    -- easily damaged goods

    blowObjGroup(0.5, 0.7,
        {"Light", "ShowerHead", "Bleach", "Window", "FoodWaste", "Meal", "PrisonerUniform", "DirtyPrisonerUniform",
         "CrumpledPrisonerUniform", 'Cctv', 'PowerSwitch', 'LibraryBookUnsorted', 'LibraryBookSorted', 'MailUnsorted',
         'MailSorted', 'PrisonerMail', 'PrisonerMailOpened', 'ShopGoods'})

    blowObjGroup(1, 1,
        {"Box", "Stack", "Door", "StaffDoor", "WindowLarge", "Cooker", "Fridge", "Bin", "SheetMetal",
         "LicensePlateBlank", "LicensePlate", "Ingredients", "IngredientsCooking", "IngredientsCooked",
         "IngredientsSpoiled", "FoodTray", "FoodTrayDirty", "GrassTurf", "Log", "Wood", "SchoolDesk", "SofaChairSingle",
         "Radio", "Tv", "PrayerMat", 'Radiator', 'LaundryBasket', 'DogCrate', 'PhoneBooth', 'Capacitor', 'PipeValve',
         'Sprinkler', "Chair", 'MailSatchel', 'FoodBowl'})

    blowObjGroup(1, 6, {"Drain"})
    blowObjGroup(1.5, 2,
        {"Bed", "Toilet", 'PersonalSink', "Table", "Bench", "Bookshelf", "OfficeDesk", "FilingCabinet", 'IroningBoard',
         'LargeTv', "DrinkMachine", 'ArcadeCabinet'})
    blowObjGroup(2, 2,
        {"BunkBed", "SuperiorBed", "MedicalBed", "SofaChairDouble", "Sink", "ServingTable", 'VisitorTable',
         'WeightsBench', 'WeaponRack', 'WaterBoiler', 'PoolTable', 'Servo', 'DoorTimer'})
    blowObjGroup(2, 6, {'PressurePad'})

    blowObjGroup(2.5, 3,
        {"JailDoor", "JailBars", "Brick", "Concrete", "Steel", "MorgueSlab", "Altar", "Pews", "LibraryBookshelf",
         'SortingTable', 'ShopFront', 'GuardLocker', 'PhoneMonitor', 'LaundryMachine'})
    blowObjGroup(3, 4,
        {"ElectricChair", "JailDoorLarge", "JailDoorXL", "SolitaryDoor", "RemoteDoor", 'WorkshopSaw', 'WorkshopPress',
         'CarpenterTable', 'VisitorTableSecure', 'CctvMonitor', 'DoorControlSystem'})
    blowObjGroup(3, 5, {"RoadGate"})

    -- Won't move
    blowObjGroup(1.5, -1, {"Tree", "TreeStump", 'ShopShelf', 'PowerStation', 'WaterPumpStation'})
    blowObjGroup(3, -1,
        {"SupplyTruck", "PrisonerBus", "FireEngine", "RiotVan", "Ambulance", "Hearse", "Limo", "TroopTruck"})
    blowObjGroup(4, -1, {"GuardTower"})
    -- "SupplyTruck", "PrisonerBus", "FireEngine", "RiotVan", "Ambulance", "Hearse", "Limo", "TroopTruck"
end

function FindEntitiesToDamage(typeName, toughness)
    local damage_max = force * (0.1 + 0.5 * 2 / (toughness + 1))
    local entitys = Object.GetNearbyObjects(typeName, radius + 1)
    for entity, dist in pairs(entitys) do
        local curr = entity.Damage
        entity.Loaded = false
        entity.Carrier = false

        giveVel(entity, dist, 2)

        if curr < 1 then
            entity.Damage = math.min(curr + (damage_max * math.cos(dist / (radius + 1) * math.pi / 2)), 1)
        end
    end
end

function FindObjectsToDamage(typeName, toughness, weight)
    local damage_max = force * (0.7 + 0.3 * 4 / (toughness + 3))
    local objects = Object.GetNearbyObjects(typeName, radius)
    for obj, dist in pairs(objects) do
        local curr = obj.Damage
        -- calc velocity
        curr = curr + (damage_max * math.cos(dist / radius * math.pi / 2))
        if curr >= 1 then
            obj.Delete()
            if weight == 1 then
            elseif weight > 1 then
                obj = Object.Spawn("Rubble", obj.Pos.x, obj.Pos.y)
                if weight > 0 then
                    giveVel(obj, dist, (1 + weight) / 2)
                end
            elseif weight > 2 then
                obj = Object.Spawn("Rubble", obj.Pos.x, obj.Pos.y)
                if weight > 0 then
                    giveVel(obj, dist, (1 + weight) / 2)
                end
                obj = Object.Spawn("Rubble", obj.Pos.x, obj.Pos.y)
                if weight > 0 then
                    giveVel(obj, dist, (1 + weight) / 2)
                end
            end
            -- local fire = Object.Spawn( "Fire", obj.Pos.x, obj.Pos.y )
            -- fire.Spawned = this.Id.u
        else
            obj.Damage = curr
            if weight > 0 then
                giveVel(obj, dist, weight)
            end
        end

    end
end

function CreateFire(targetX, targetY)
    local fire = Object.Spawn("Fire", targetX, targetY)
    fire.Fuel = 1
    fire.Intensity = 0.2
end

function StartFire(targetX, targetY)
    local count = 0
    while count < 30 do
        CreateFire(targetX, targetY)
        count = count + 1
    end
    this.fire_count = count * 2
end

function KillWalls()
    for dx = -1, 1 do
        for dy = -1, 1 do
            KillWall(dx, dy)
            CreateFire(this.Pos.x + dx, this.Pos.y + dy)
            CreateFire(this.Pos.x + dx, this.Pos.y + dy)
            CreateFire(this.Pos.x + dx, this.Pos.y + dy)
        end
    end
end

function KillWall(dx, dy)
    local fX = this.Pos.x - 0.5 + dx
    local fY = this.Pos.y - 0.5 + dy

    local cell = World.GetCell(fX, fY)
    Object.Spawn("SmokeGenerator", fX, fY)
    if cell and cell.Mat then
        cell.Mat = "BurntFloor"
        if isWall(fX, fY) then
            replaceMatWithRubble(fX, fY)
            replaceMatWithRubble(fX, fY)
            replaceMatWithRubble(fX, fY)
        end
    end
end

function replaceMatWithRubble(fX, fY)
    local rubble = Object.Spawn("Rubble", fX + 0.5 + rand(-0.2, 0.2), fY + 0.5 + rand(-0.2, 0.2))
    giveVel(rubble, 0.5)
    return rubble
end

function rand(from, to)
    math.randomseed(math.random(99999))
    return math.random() * (to - from) + from
end

local WallMaterials = {
    ConcreteWall = true,
    BrickWall = true,
    BurntWall = true,
    Fence = true,
    PerimeterWall = true
}

function isWall(x, y)
    local material = Object.GetMaterial(x, y)
    -- Echo("Material: "..material.." x: "..x.." y:"..y)
    if WallMaterials[material] then
        -- Echo("WALL: "..material.." x: "..x.." y:"..y)
        return true
    end
    return nil
end

function Echo(text)
    Game.DebugOut(text)
end

local Delay = 0.05 -- Clock Minutes
local Ready = 0
function Update()
    if World.TimeIndex > Ready then
        Ready = World.TimeIndex + Delay
        Go()
    end
end

function Go()
    if not inited then
        Init()
    else
        this.Sound("_World", "Explosion") -- crumble noise
    end
    local count = this.fire_count
    local fires = this.GetNearbyObjects('Fire', 5)
    for o, dist in pairs(fires) do
        if count > 0 then
            o.Intensity = this.fire_count / 50
        else
            o.Delete()
        end
        count = count - 1
    end
    if this.fire_count == 0 then
        this.Delete()
    end
    this.fire_count = this.fire_count - 1
end
