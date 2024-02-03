-- MedicineCabinet --
function look_around(types, cb, range, justOne)
    local count = 0
    if range == "max" then
        range = 9999
    end
    for k, v in pairs(types) do
        local os = this.GetNearbyObjects(v, (range or nearbyRange))
        for o, distance in pairs(os) do
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

function getObjCell(o)
    return World.GetCell(math.floor(o.Pos.x), math.floor(o.Pos.y))
end

local current_room_id
function sameRoom(o)
    return (current_room_id == getObjCell(o).Room.u)
end

function SpawnAt(type, to, dx, dy)
    return Object.Spawn(type, (to.Pos.x + (dx or 0)), (to.Pos.y + (dy or 0)))
end

local prefix = "medcab__"
local miz_last = nil
local miz = nil

function diffMenu(miz)
    if not miz_last then
        return true
    end
    local index = 0
    for i, v in pairs(miz) do
        index = i
        if not miz_last[i] or miz_last[i][1] ~= v[1] then
            return true
        end
    end
    if miz_last[index + 1] then
        return true
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
        Interface.SetCaption(this, prefix .. cn, prefix .. translation, t[3], t[4], t[5], t[6], t[7], t[8])
    end
end

function refreshMenu(miz)
    -- print('refreshMenu')
    if miz_last then
        for i, t in pairs(miz_last) do
            local cn = t[1]
            if type(cn) == 'table' then
                cn = cn[1]
            end
            Interface.RemoveComponent(this, prefix .. cn)
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
        Interface.AddComponent(this, prefix .. cn, t[2], prefix .. translation, t[3], t[4], t[5], t[6], t[7], t[8])
    end
    miz_last = miz
end

function extend(t1, t2)
    if t2 then
        for i, v in pairs(t2) do
            table.insert(t1, v)
        end
    end
    return t1
end

function today()
    return math.floor(World.TimeIndex / (24 * 60)) + 1
end

local inited = false

function Init()
    inited = true

    if this.max_level == nil then
        this.max_level = 3
    end
    if this.call_doctor_for_injured == nil then
        this.call_doctor_for_injured = false
    end
    if this.this_is_medicalward == nil then
        this.this_is_medicalward = false
    end
    if this.call_range == nil then
        this.call_range = 5
    end

    if this.last_doc_was_here == nil then
        this.last_doc_was_here = World.TimeIndex
    end

    if this.last_serve_day == nil then
        this.last_serve_day = today()
    end
    if this.treat_count == nil then
        this.treat_count = 0
    end
    if this.treat_cost == nil then
        this.treat_cost = 0
    end

    menu()
    updateTT()
end

function updateTT()
    if this.last_call ~= nil then
        this.Tooltip = {'medcab__tt__doc_called', this.treat_count, 'X', this.treat_cost, 'Y'}
    elseif this.this_is_medicalward and World.TimeIndex - this.last_doc_was_here > 2 then
        this.Tooltip = {'medcab__tt__doc_away_time', this.treat_count, 'X', this.treat_cost, 'Y',
                        math.floor(World.TimeIndex - this.last_doc_was_here), 'M'}
    else
        this.Tooltip = {'medcab__tt', this.treat_count, 'X', this.treat_cost, 'Y'}
    end
end

local Ready = 0

function Update()
    if not inited then
        Init()
    end

    if World.TimeIndex > Ready then
        Ready = World.TimeIndex + 1
        main()

        if this.last_serve_day < today() then
            this.last_serve_day = today()
            this.treat_count = 0
            this.treat_cost = 0
            updateTT()
        end

    end
end

function menu()
    local mi_level
    if this.max_level > 0 then
        mi_level = {"level", "Button", this.max_level, "L"}
    else
        mi_level = {"level_no", "Button"}
    end

    local miz = {mi_level, {"call_doctor_for_injured", "Button", tostring(this.call_doctor_for_injured), "B"},
                 {"call_range", "Button", this.call_range, "R"},
                 {"this_is_medicalward", "Button", tostring(this.this_is_medicalward), "B"}}

    -- if this.last_call == nil then
    -- 	extend(miz, {
    -- 		{'test', 'Button'},
    -- 	})
    -- else
    -- 	extend(miz, {
    -- 		{'calling'},
    -- 	})
    -- end

    updateMenu(miz)
end

function medcab__testClicked()
    call(this)
end

function medcab__levelClicked()
    this.max_level = this.max_level - 1
    menu()
end

function medcab__level_noClicked()
    this.max_level = 3
    menu()
end

function medcab__call_doctor_for_injuredClicked()
    this.call_doctor_for_injured = not this.call_doctor_for_injured
    menu()
end

function medcab__this_is_medicalwardClicked()
    this.this_is_medicalward = not this.this_is_medicalward
    menu()
end

function medcab__call_rangeClicked()
    this.call_range = this.call_range + 1
    if this.call_range > 9 then
        this.call_range = 5
    end
    menu()
end

function JobComplete_DoctorCalled()
    this.last_call = nil
    menu()
    updateTT()
end

function main()
    current_room_id = getObjCell(this).Room.u

    additionalAidAround()
    turnWaste()

    if this.last_call ~= nil then
        local d = look_around({'Doctor'}, sameRoom, this.call_range, true)
        if d then
            JobComplete_DoctorCalled()
        end
    else
        if this.this_is_medicalward then
            callDoctorWhenAway()
        end
        if this.call_doctor_for_injured then
            callDoctorForInjured()
        end
    end

end

local service_range = 10

function turnWaste()
    look_around({'Medicine1', 'Medicine2', 'Medicine3'}, turnWasteO, service_range)
end

function turnWasteO(o)
    if o.Vel.x < 0.01 and o.Vel.y < 0.01 then
        local w = SpawnAt('MedWaste' .. tostring(o.level), o)
        w.Or.x = o.Or.y
        w.Or.y = o.Or.x
        o.Delete()
    end
end

local treats = {{
    help_amount = 0.2,
    price = 5
}, {
    help_amount = 0.3,
    price = 10
}, {
    help_amount = 0.4,
    price = 20
}}

function additionalAidAround()

    local h = look_around({'Prisoner', "Guard", "DogHandler", "Workman", "ArmedGuard", "Cook", "Janitor", "Gardener",
                           "Doctor", "Psychologist", 'BoldHost', 'CameraMan', "Warden", "Chief", "Foreman", 'Sniper',
                           "Accountant", "Lawyer"}, needAdditionalAid, service_range, true)
    if h then
        print('found one')
        local level = math.floor(h.Damage * 3) + 1
        print(h.Damage)
        -- print(level)
        level = math.min(level, this.max_level)

        local t = treats[level]
        h.Damage = math.max(0, h.Damage - t.help_amount)
        if h.Type == 'Prisoner' then
            h.StatusEffects.tazed = h.Damage * 50
        end
        h.LastTreated = World.TimeIndex

        this.treat_count = this.treat_count + 1
        this.treat_cost = this.treat_cost + t.price
        if World.Balance then
            World.Balance = World.Balance - t.price
        end
        local warden = look_around({'Warden'}, nil, 'max', true)
        if warden then
            warden.med_expense = warden.med_expense + t.price
        end

        updateTT()

        local m = SpawnAt('Medicine' .. tostring(level), this)
        local factor = 1.33
        local vx = (h.Pos.x - this.Pos.x) * factor
        local vy = (h.Pos.y - this.Pos.y) * factor

        m.ApplyVelocity(vx, vy)
        m.level = level
        -- w.Or.x = vy
        -- w.Or.y = vx
    end

end

function needAdditionalAid(e)
    -- return (e.Damage < 1 and e.Damage > 0.1 and (not e.Misbehavior) and sameRoom(e) and (World.TimeIndex - (e.LastTreated or 0)) > 60 and (e.Vel.x + e.Vel.y < 0.1))
    -- if e.Damage > 0.1 then
    -- 	print(e.Type)
    -- 	print(e.Misbehavior)
    -- 	print( (World.TimeIndex - (e.LastTreated or 0)) )
    -- end

    local from_last_treated = (World.TimeIndex - (e.LastTreated or 0))
    if from_last_treated > 0 and from_last_treated < 60 then
        return false
    end
    return (e.Damage < 1 and e.Damage > 0.1 and (e.Misbehavior == nil or e.Misbehavior == 'None') and sameRoom(e) and
               (e.Vel.x * e.Vel.x + e.Vel.y * e.Vel.y < 0.001))
end

function call(who)
    print('DoctorCalled')
    who.CreateJob('DoctorCalled')
    this.last_call = World.TimeIndex
    menu()
    updateTT()
end

function callDoctorWhenAway()
    local d = look_around({'Doctor'}, sameRoom, 15, true)
    if d then
        this.last_doc_was_here = World.TimeIndex
        updateTT()
    else
        if World.TimeIndex - this.last_doc_was_here > 60 then
            -- print('------- call back')
            call(this)
        else
            updateTT()
        end
    end
end

function callDoctorForInjured()
    -- if World.TimeIndex - this.last_call < 10 then
    -- 	return
    -- end

    local d = look_around({'Doctor'}, nil, this.call_range, true)
    if d then
        return
    end

    local h = look_around({'Prisoner'}, needDoctor1, this.call_range, true)
    if not h then
        h = look_around({'Prisoner'}, needDoctor2, this.call_range, true)
    end
    if h then
        call(h)
    end
end

function needDoctor1(p, distance)
    if p.Loaded and p.Damage > 0 and p.Damage < 0.8 and not p.Shackled and p.Carried == 0 then
        return true
    else
        return false
    end
end

function needDoctor2(p, distance)
    if p.Damage > 0 and p.Damage < 0.8 and p.Carried == 0 then
        return true
    else
        return false
    end
end

