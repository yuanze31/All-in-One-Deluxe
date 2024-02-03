-- ExecutionWitness --
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

local Ready = 0

local inited

function Update(timePassed)
    -- if not inited then Init() end
    if not this.arrived and World.TimeIndex > Ready then
        Ready = World.TimeIndex + 1
        Go()
    end
end

function Go()
    local ec = look(this, {'ElectricChair'}, activeEC, 'max', true)
    -- local ec = look(this, {'ElectricChair'}, nil, 'max', true)
    if ec then
        this.Pos.x = ec.Pos.x
        this.Pos.y = ec.Pos.y
        this.arrived = true
    end
end

function activeEC(ec)
    return ec.is_active
end

