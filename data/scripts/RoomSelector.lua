-- local Delay  = 2 -- Clock Minutes
-- local Ready  = 0
function makeBooleanDict(t)
    local d = {}
    for k, v in pairs(t) do
        d[v] = true
    end
    return d
end

function getCell(x, y)
    return World.GetCell(math.floor(x), math.floor(y))
end

local thisRoomId
local thisRoomMat

local cellkey4r = {
    t = 'CellY',
    b = 'CellY',
    l = 'CellX',
    r = 'CellX'
}

function moveBorder(c, key, dX, dY, limit)
    if limit < 0 then
        return
    else
        limit = limit - 1
    end
    c = getCell(c.CellX + dX, c.CellY + dY)
    if c and c.CellX then

        if isWall(c) or isDoor(c) then
            this[key] = c[cellkey4r[key]]
            -- reach end
        elseif thisRoomId > 0 then
            this[key] = c[cellkey4r[key]]
            if thisRoomId == c.Room.u then
                moveBorder(c, key, dX, dY, limit)
            end
            -- reach end
        elseif thisRoomMat == c.Mat then
            this[key] = c[cellkey4r[key]]
            moveBorder(c, key, dX, dY, limit)
        end
    end
end

local wallTypes = {'BrickWall', 'ConcreteWall', 'Fence', 'PerimeterWall', 'BurntWall'}
local wallTypeDict = makeBooleanDict(wallTypes)

function isWall(c)
    return wallTypeDict[c.Mat]
end

local doorTypes = {'Door', 'JailDoor', 'JailDoorLarge', 'StaffDoor', 'SolitaryDoor', 'RemoteDoor'}
-- local doorTypeDict = makeBooleanDict(doorTypes)

local anchor

function look_at_cell(cell, types, cb, range, justOne)
    range = range or 0.5
    return look_at(cell.CellX + 0.5, cell.CellY + 0.5, types, cb, range, justOne)
end

function look_at(x, y, types, cb, range, justOne)
    anchor.Pos.x = x
    anchor.Pos.y = y
    return look(anchor, types, cb, range, justOne)
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

function isDoor(c)
    return look_at_cell(c, doorTypes, nil, nil, true)
end

function keepThis(o)
    if o.Id.u ~= this.Id.u then
        deleteO(o)
        o.discarded = true
    end
end

function deleteO(o)
    -- o.Hidden = true
    o.Pos.x = 0.5
    o.Pos.y = 0.5
    o.Delete()
end

local prefix = "rs__"
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

function menu()
    local miz = {{'adjust_t_u', 'Button'}, {'adjust_t_d', 'Button'}, {'adjust_b_u', 'Button'}, {'adjust_b_d', 'Button'},
                 {'adjust_l_l', 'Button'}, {'adjust_l_r', 'Button'}, {'adjust_r_l', 'Button'}, {'adjust_r_r', 'Button'}}
    updateMenu(miz)
end

function rs__adjust_t_dClicked()
    adjust('t', 1)
    menu()
end

function rs__adjust_t_uClicked()
    adjust('t', -1)
    menu()
end

function rs__adjust_b_dClicked()
    adjust('b', 1)
    menu()
end

function rs__adjust_b_uClicked()
    adjust('b', -1)
    menu()
end

function rs__adjust_l_lClicked()
    adjust('l', -1)
    menu()
end

function rs__adjust_l_rClicked()
    adjust('l', 1)
    menu()
end

function rs__adjust_r_lClicked()
    adjust('r', -1)
    menu()
end

function rs__adjust_r_rClicked()
    adjust('r', 1)
    menu()
end

function adjust(prop, delta)
    local old = this[prop]
    this[prop] = this[prop] + delta
    if this.b - this.t < 1 or this.r - this.l < 1 then
        this[prop] = old
    else
        -- look(this, {'RoomCellMarker'}, deleteO, 'max')
        markRoom()
    end
end

local inited
function Init()
    inited = true
    menu()
end

function Update()
    if not inited then
        Init()
    end
end

function Create()
    -- this.Hidden = true
    local thisCell = getCell(this.Pos.x, this.Pos.y)
    thisRoomId = thisCell.Room.u
    if thisRoomId <= 0 then
        thisRoomMat = thisCell.Mat
    end

    for i, key in pairs({'t', 'b', 'l', 'r'}) do
        this[key] = thisCell[cellkey4r[key]]
    end
    -- print('thisRoomId')
    -- print(thisRoomId)
    -- if thisRoomId > 0 then
    anchor = Object.Spawn('Anchor', 0, 0)
    moveBorder(thisCell, 't', 0, -1, 10)
    moveBorder(thisCell, 'b', 0, 1, 10)
    moveBorder(thisCell, 'l', -1, 0, 10)
    moveBorder(thisCell, 'r', 1, 0, 10)
    -- this.Hidden = true
    -- this.Pos.x = 0.5
    -- this.Pos.y = 1.5
    this.Or.x = 0
    this.Or.y = 1
    markRoom()
    anchor.Pos.x = 0.5
    anchor.Pos.y = 0.5
    anchor.Delete()
    -- else
    -- 	this.Delete()
    -- end
    menu()
end

function markRoom()
    look(this, {'RoomSelector'}, keepThis, 'max')
    look(this, {'RoomCellMarker'}, deleteO, 'max')
    this.Pos.x = this.l + 0.5
    this.Pos.y = this.t + 0.5
    for x = this.l, this.r do
        for y = this.t, this.b do
            Object.Spawn('RoomCellMarker', x + 0.5, y + 0.5)
        end
    end
end

