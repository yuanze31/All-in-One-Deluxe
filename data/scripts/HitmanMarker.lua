-- HitmanMarker --
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

function search(uid, types, center_object, range)
    center_object = center_object or this
    if range == "max" then
        range = 9999
    end

    for k, v in pairs(types) do
        local os = center_object.GetNearbyObjects(v, (range or nearbyRange))
        for o, distance in pairs(os) do
            if o.Id.u == uid then
                print("Found object " .. v .. " #" .. uid)
                return o
            end
        end
    end
    return nil
end

local target

function trackTarget()
    if not target then
        return
    end

    this.Pos.x = target.Pos.x + target.Or.x * 0.2
    local dy = 0.1 - (Game.Time() % 0.6) / 6
    -- local dy = (3 - math.floor(Game.Time() * 5) % 6) / 15
    this.Pos.y = target.Pos.y - 0.7 - dy
end

local a48_play_dead_exposed_chance = 30

function PlayingDeadInProgress()

    if target == nil then
        this.Delete()
        return
    end

    if target.Loaded then

        local Hearses = Object.GetNearbyObjects(target, "Hearse", 3)

        for Hearse, distance in pairs(Hearses) do
            if target.a48__play_dead__in_progress then
                if math.random(100) <= a48_play_dead_exposed_chance then
                    target.a48__play_dead__exposed = true
                    PlayingDeadIsDone()
                else
                    target.a48__play_dead__success = true
                    target.a48__play_dead__in_progress = nil
                end
            else
                if World.NumCellsY - target.Pos.y < 5 then
                    PlayingDeadIsDone()
                    this.Delete()
                    return
                end
            end
        end
    end

    if target.a48__play_dead__exposed and target.Misbehavior == 'None' then
        target.a48__play_dead__in_progress = nil
        target.a48__play_dead__exposed = nil
        target.Tooltip = ''
        target = nil
        this.Delete()
    else
        if target.a48__play_dead__success then
            target.Tooltip = {"a48__target_info__play_dead__success"}
        elseif target.a48__play_dead__exposed then
            target.Tooltip = {"a48__target_info__play_dead__exposed"}
        else
            target.Tooltip = {"a48__target_info__play_dead__in_progress", a48_play_dead_exposed_chance, "X"}
        end
    end

end

function PlayingDeadIsDone()
    target.a48__play_dead__in_progress = false
    target.AvatarControl = false
    target.Damage = 0.2
    target.Shackled = false
    target.Misbehavior = 2
    -- target = nil

    print('PlayingDeadIsDone')
end

local iconz = {'MobilePhone', 'Shank', 'Knife', 'Dynamite', 'Poison', 'Ingredient', 'Medicine', 'FakeExtinguisher',
               'Flammable', 'Lighter', 'Scissors'}
local icon_fullnamez = {}
for i, v in pairs(iconz) do
    table.insert(icon_fullnamez, "Icon_" .. v)
end

function checkHitman()
    if not look(this, {"Avatar"}, nil, "max", true) then
        look(this, {"SightMarker", 'TargetDirection'}, deleteO, "max")
        look(this, icon_fullnamez, deleteO, "max")
        this.Delete()
    end
end

local Ready1 = 0
local Ready2 = 0

function Update()
    if not target then
        if this.target_id then
            target = search(this.target_id, {'Prisoner'}, this, 2) or search(this.target_id, {'Prisoner'}, this, 'max')
        end
    end

    -- if Game.Time() > Ready1 then
    -- Ready1 = Game.Time() + 0.01
    trackTarget()
    -- end

    if World.TimeIndex > Ready2 then
        Ready2 = World.TimeIndex + 0.3
        if this.continued then
            PlayingDeadInProgress()
        else
            checkHitman()
        end
    end

end

