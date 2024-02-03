-- AttentionMarker --
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

local prefix = "attention_marker__"
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
    print('refreshMenu')
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

function deleteO(o)
    o.Pos.x = 0
    o.Pos.y = 0
    o.Delete()
end

local target

function trackTarget()
    this.Pos.x = target.Pos.x + target.Or.x * 0.2
    local dy = 0.1 - (Game.Time() % 0.6) / 6
    this.Pos.y = target.Pos.y - 0.7 - dy
end

local Ready = 0

function Update()
    if not target then
        if this.target_id then
            target = search(this.target_id, {'Prisoner'}, this, 3)
            if target then
                menu()
            end
        end
    end

    -- if Game.Time() > Ready then
    -- 	Ready = Game.Time() + 0.0001

    if target == nil or target.Damage == nil then
        this.Delete()
        return
    end

    trackTarget()
    ao()
    -- end

end

function makeAttack(from, to)
    from.TargetObject.u = to.Id.u
    from.TargetObject.i = to.Id.i
    if from.Type == 'Prisoner' then
        from.Misbehavior = 5
    else
        -- Guard won't fight, but will shackle `to` if they get close enough.
    end
end

function ready2Fight(p)
    return (p.Damage < 0.7 and (not p.Shackled) and (p.Misbehavior == 'None'))
end

function ao()
    if this.attack_other then
        if ready2Fight(target) then
            look(this, {'AttentionMarker'}, tryFight, 5)
        else
        end
    end
end

function tryFight(m)
    -- if not m.attack_other then return end

    local t2 = search(m.target_id, {'Prisoner'}, m, 3)
    if t2 and ready2Fight(t2) then
        makeAttack(target, t2)
        -- makeAttack(t2, target)
    end

end

function extend(t1, t2)
    if t2 then
        for i, v in pairs(t2) do
            table.insert(t1, v)
        end
    end
    return t1
end

function menu()

    local miz = {{'delete', 'Button'}}

    if World.CheatsEnabled then

        local mi_deathrow
        if target.Category == 'DeathRow' then
            mi_deathrow = {'deathrow_already'}
        else
            mi_deathrow = {'deathrow_set', 'Button'}
        end

        extend(miz,
            {{"attack_other", "Button", tostring(this.attack_other), "A"}, mi_deathrow, {"StatusEffects"},
             {'calming', 'Button'}, {'drunk', 'Button'}, {'high', 'Button'}, {'foodpoisoning', 'Button'},
             {'wounded', 'Button'}, {'virusdeadly', 'Button'}})
    end

    updateMenu(miz)
end

function attention_marker__attack_otherClicked()
    this.attack_other = not this.attack_other
    menu()
end

function attention_marker__deleteClicked()
    deleteO(this)
    updateMenu({})
end

function attention_marker__deathrow_setClicked()
    target.Category = 6
    menu()
end

function attention_marker__calmingClicked()
    target.StatusEffects.calming = 720
    menu()
end

function attention_marker__drunkClicked()
    target.StatusEffects.drunk = 720
    menu()
end

function attention_marker__highClicked()
    target.StatusEffects.high = 72
    menu()
end

function attention_marker__woundedClicked()
    target.StatusEffects.wounded = 36
    menu()
end

function attention_marker__foodpoisoningClicked()
    target.StatusEffects.foodpoisoning = 720
    menu()
end

function attention_marker__virusdeadlyClicked()
    target.StatusEffects.virusdeadly = 720
    menu()
end

