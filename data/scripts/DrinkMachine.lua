local Ready = 0
local Delay = 0.6

local inited

function Update(timePassed)
    if not inited then
        Init()
    end
    if World.TimeIndex > Ready then
        Ready = World.TimeIndex + Delay
        Go()
    end
end

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

local typesStaff = {
    g = {'Sniper', 'DogHandler', 'ArmedGuard', 'Guard'},
    o = {'Doctor', 'Cook', 'Janitor', 'Workman'}
}

function getObjCell(o)
    return World.GetCell(math.floor(o.Pos.x), math.floor(o.Pos.y))
end

local storage_max = 10
local replenish_inteval = 20
local effect_range = 5

local power = 10
local price = 2

local storage_available
local room_id

entity_on_the_wayz = {}

function Go()
    this.nextTime = this.nextTime - Delay
    if this.nextTime <= 0 and this.storage < storage_max then
        this.storage = this.storage + 1
        this.nextTime = replenish_inteval
        updateTooltip()
    end

    if this.last_serve_day < today() then
        this.last_serve_day = today()
        this.count = 0
        updateTooltip()
    end

    if this.storage <= 0 then
        return
    end

    storage_available = this.storage

    if this.needs_same_room then
        room_id = getObjCell(this).Room.u
    end

    if this.serves_g and not World.StaffNeeds then
        look_around(typesStaff.g, checkEnergy, effect_range + 3)
    end
    if this.serves_o then
        look_around(typesStaff.o, checkEnergy, effect_range + 3)
    end

    for e, ti in pairs(entity_on_the_wayz) do
        if e and e.Or and World.TimeIndex > ti + 60 then
            print('Stuck?')
            nav(e, e, -0.1 * e.Or.x, -0.1 * e.Or.y)
            entity_on_the_wayz[e] = nil
        end
    end
    updateTooltip()
end

local wallTypeDict = {
    ConcreteWall = true,
    BrickWall = true,
    BurntWall = true,
    Fence = true,
    PerimeterWall = true
}

function checkEnergy(e, distance)

    if e.drinking_id and e.drinking_id ~= this.Id.u and World.TimeIndex <= e.drinking_timeout then
        return
    end

    if e.drinking_id ~= this.Id.u and storage_available <= 0 then
        return
    end
    if e.drinking_id == this.Id.u and entity_on_the_wayz[e] == nil then
        entity_on_the_wayz[e] = World.TimeIndex
        print('continue from loaded game')
    end

    if e.Energy > this.threshold or e.Damage >= 0.7 or e.Carrying.u > 0 or e.ReloadTimer > 0 then
    elseif this.needs_same_room and getObjCell(e).Room.u ~= room_id then
    end

    e.drinking_id = this.Id.u
    e.drinking_timeout = World.TimeIndex + 20

    storage_available = storage_available - 1

    if distance < 1.1 then
        e.Energy = e.Energy + power
        if World.Balance then
            World.Balance = World.Balance - price
        end

        e.drinking_id = nil
        e.drinking_timeout = nil

        if this.nextTime <= 0 and this.storage == storage_max then
            this.nextTime = replenish_inteval
        end

        this.storage = this.storage - 1

        this.count = this.count + 1
        nav(e, e)

        entity_on_the_wayz[e] = nil
    else
        if entity_on_the_wayz[e] then
            return
        end
        entity_on_the_wayz[e] = World.TimeIndex
        print(e.Type)
        print('come here')
        local nav_x = this.Or.x * 0.5 + this.Walls.x * 0.2
        local nav_y = this.Or.y * 0.6 + 0.1 + this.Walls.y * 0.3
        local c = World.GetCell(math.floor(this.Pos.x + this.Or.x), math.floor(this.Pos.y + this.Or.y))
        if wallTypeDict[c.Mat] then
            nav(e, this)
        else
            nav(e, this, nav_x, nav_y)
        end

    end

end

function updateTooltip()
    this.Tooltip = {'DrinkMachine_tt', this.count, 'C', (price * this.count), 'M', this.storage, 'S'}
end

function SpawnAt(type, to, dx, dy)
    return Object.Spawn(type, (to.Pos.x + (dx or 0)), (to.Pos.y + (dy or 0)))
end

function nav(who, to, dx, dy)
    who.NavigateTo((to.Pos.x + (dx or 0)), (to.Pos.y + (dy or 0)))
end

function dist(from, to)
    return math.pow(math.pow((from.Pos.x - to.Pos.x), 2) + math.pow((from.Pos.y - to.Pos.y), 2), 0.5)
end

function today()
    return math.floor(World.TimeIndex / (24 * 60)) + 1
end

function Init()
    inited = true

    if this.count == nil then
        this.count = 0
    end
    if this.last_serve_day == nil then
        this.last_serve_day = today()
    end
    if this.needs_same_room == nil then
        this.needs_same_room = false
    end
    if this.serves_g == nil then
        this.serves_g = true
    end
    if this.serves_o == nil then
        this.serves_o = true
    end
    this.nextTime = this.nextTime or replenish_inteval
    this.storage = this.storage or storage_max
    this.threshold = this.threshold or 40
    updateTooltip()
    if World.StaffNeeds then
        Interface.AddComponent(this, "dm__no_need_to_serves_g", 'Caption', "dm__no_need_to_serves_g")
    else
        Interface.AddComponent(this, "dm__toggle_serves_g", 'Button', "dm__toggle_serves_g", tostring(this.serves_g),
            'B')
    end
    Interface.AddComponent(this, "dm__toggle_serves_o", 'Button', "dm__toggle_serves_o", tostring(this.serves_o), 'B')
    Interface.AddComponent(this, "dm__change_threshold", 'Button', "dm__change_threshold", this.threshold, 'N')
    Interface.AddComponent(this, "dm__toggle_same_room", 'Button', "dm__toggle_same_room",
        tostring(this.needs_same_room), 'B')
end

function dm__toggle_same_roomClicked()
    this.needs_same_room = not this.needs_same_room
    Interface.SetCaption(this, "dm__toggle_same_room", "dm__toggle_same_room", tostring(this.needs_same_room), 'B')
end

function dm__toggle_serves_gClicked()
    this.serves_g = not this.serves_g
    Interface.SetCaption(this, "dm__toggle_serves_g", "dm__toggle_serves_g", tostring(this.serves_g), 'B')
end

function dm__toggle_serves_oClicked()
    this.serves_o = not this.serves_o
    Interface.SetCaption(this, "dm__toggle_serves_o", "dm__toggle_serves_o", tostring(this.serves_o), 'B')
end

function dm__change_thresholdClicked()
    this.threshold = this.threshold - 20
    if this.threshold <= 0 then
        this.threshold = 80
    end
    Interface.SetCaption(this, "dm__change_threshold", "dm__change_threshold", this.threshold, 'N')
end

