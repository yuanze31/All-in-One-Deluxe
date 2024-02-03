-- TimedCaller --
function look(who, types, cb, range, justOne)
    local count = 0
    if range == "max" then
        range = 9999
    end
    for k, v in pairs(types) do
        local os = who.GetNearbyObjects(v, range)
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

function extend(t1, t2)
    if t2 then
        for i, v in pairs(t2) do
            table.insert(t1, v)
        end
    else
    end
    return t1
end

local prefix = "tc__"
local miz_last
local miz

function diffMenu(miz)
    if not miz_last then
        return true
    end
    for i, v in pairs(miz) do
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
        local l = miz_last[i]
        -- local diff = false
        for ii, v in pairs(t) do
            if l[ii] ~= v then
                local cn = t[1]
                local translation = t[1]
                t[2] = t[2] or 'Caption'
                if type(cn) == 'table' then
                    cn = t[1][1]
                    translation = t[1][2]
                end
                Interface.SetCaption(this, prefix .. cn, prefix .. translation, t[3], t[4], t[5], t[6], t[7], t[8])
                miz_last[i] = t
                break
                -- diff = true
            end
        end
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

function menu()

    local miz = {{'when', 'Caption', this.when_h, 'H', this.when_m, 'M'}, {'h_p', 'Button'}, {'h_m', 'Button'},
                 {'m_p', 'Button'}, {'m_m', 'Button'}, {'test', 'Button'}}

    -- if this.last_call == nil then
    -- 	extend(miz, {
    -- 		{'test', 'Button'},
    -- 	})
    -- else
    -- 	extend(miz, {
    -- 		{'calling'},
    -- 	})
    -- end

    if this.last_call == nil and this.last_response_time ~= nil then
        this.Tooltip = {'tc__tt__last_response_time', this.last_response_time, 'M'}
        -- extend(miz, {
        -- 	{'last_response_time', nil, this.last_response_time, 'M'},
        -- })
    end

    updateMenu(miz)

end

local hourNow
local minNow
function renewDateTime()
    hourNow = math.floor(World.TimeIndex / 60) % 24
    minNow = math.floor(World.TimeIndex) % 60
end

local Ready = 0
local inited

function Update()
    if not inited then
        Init()
    end

    if World.TimeIndex > Ready then
        Ready = World.TimeIndex + 0.99

        renewDateTime()
        Go()
        menu()
    end
end

local g

function Init()
    inited = true

    if this.when_h == nil then
        this.when_h = 12
    end
    if this.when_m == nil then
        this.when_m = 30
    end

    if this.g_id then
        g = search(this.g_id, {'Guard'}, this, 'max')
    end
end

function Go()
    if this.last_call ~= nil then
        if not isOk(g) then
            call(true)
            return
        elseif World.TimeIndex - this.last_call > 10 then
            musterG(g)
        end
    end

    if look(this, {'Guard'}, nil, 3, true) then
        if this.last_call ~= nil then
            this.last_response_time = math.floor(World.TimeIndex - this.last_call)
            this.last_call = nil
            this.g_id = nil
            g = nil
            this.Tooltip = ''
            menu()
        end
        return
    end

    if this.when_h == hourNow and this.when_m == minNow then
    else
        return
    end

    if look(this, {'Guard'}, nil, 3, true) then
        return
    end

    call()
end

function call(change_guard)
    if change_guard or this.last_call_from == nil then
        g = look(this, {'Guard'}, isOk, 10, true) or look(this, {'Guard'}, isOk, 15, true) or
                look(this, {'Guard'}, isOk, 20, true) or look(this, {'Guard'}, isOk, 25, true) or
                look(this, {'Guard'}, isOk, 30, true)
        if g then
            musterG(g)
            this.last_call = World.TimeIndex
            this.g_id = g.Id.u
            this.Tooltip = 'tc__tt__waiting_for_guard'
        else
            this.Tooltip = 'tc__tt__no_guard_available'
        end
    end
    menu()
end

function isOk(g)
    if g and g.Damage ~= nil and g.Damage < 0.1 and g.Energy > 10 and g.TargetObject.u <= 0 and g.Carrying.u <= 0 then
        return true
    else
        return false
    end
end

function musterG(g)
    g.PlayerOrderPos.x, g.PlayerOrderPos.y = this.Pos.x, this.Pos.y
end

function tc__h_pClicked()
    this.when_h = this.when_h + 1
    if this.when_h > 23 then
        this.when_h = 0
    end
    menu()
end

function tc__h_mClicked()
    this.when_h = this.when_h - 1
    if this.when_h < 0 then
        this.when_h = 23
    end
    menu()
end

function tc__m_pClicked()
    this.when_m = this.when_m + 5
    if this.when_m > 55 then
        this.when_m = 0
    end
    menu()
end

function tc__m_mClicked()
    this.when_m = this.when_m - 5
    if this.when_m < 0 then
        this.when_m = 55
    end
    menu()
end

function tc__testClicked()
    call()
end

