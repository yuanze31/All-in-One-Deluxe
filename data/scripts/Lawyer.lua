-- Lawyer --
function look_around(types, cb, range, justOne)
    local who = this
    if ms and ms.escaping then
        who = target
    end
    local count = 0
    if range == "max" then
        range = 9999
    end
    for k, v in pairs(types) do
        local os = who.GetNearbyObjects(v, (range or nearbyRange))
        for o, distance in pairs(os) do
            count = count + 1
            if cb then
                cb(o)
            else
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

function today()
    return math.floor(World.TimeIndex / 1440) + 1
end

function getObjCell(o)
    return World.GetCell(math.floor(o.Pos.x), math.floor(o.Pos.y))
end

function sameRoom(o)
    return (getObjCell(this).Room.u == getObjCell(o).Room.u)
end

local Ready = 0
local inited

function Update()
    if not inited then
        Init()
    end

    if World.TimeIndex > Ready then
        Ready = World.TimeIndex + 5

        if this.last_serve_day < today() then
            this.last_serve_day = today()
            this.served_visitor_count = 0
            this.visitor_bonus_count = 0
            this.Tooltip = {'lawyer__tt', this.served_visitor_count, 'S', this.visitor_bonus_count, 'B'}
        end

        serveVisitors()
    end
end

function Init()
    inited = true

    if this.served_visitor_count == nil then
        this.served_visitor_count = 0
    end
    if this.visitor_bonus_count == nil then
        this.visitor_bonus_count = 0
    end
    if this.last_serve_day == nil then
        this.last_serve_day = today()
    end

end

-- local bonus_poss = 0.1 -- possibility of bonus
local bonus_step = 4

function serveVisitors()
    look_around({'Visitor'}, serveV, 20)
end

function serveV(v)
    if (not v.Loaded) or v.already_served then
        return
    end

    if not sameRoom(v) then
        return
    end

    v.already_served = true
    this.served_visitor_count = this.served_visitor_count + 1

    -- if math.random() < bonus_poss then
    if this.served_visitor_count % bonus_step == 0 then
        local o = Object.Spawn("MoneyBag100", this.Pos.x, this.Pos.y + 0.8)
        this.visitor_bonus_count = this.visitor_bonus_count + 1
    end

    this.Tooltip = {'lawyer__tt', this.served_visitor_count, 'S', this.visitor_bonus_count, 'B'}
end

