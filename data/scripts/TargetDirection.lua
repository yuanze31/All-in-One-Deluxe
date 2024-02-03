-- TargetDirection --
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

local Ready2 = 0

function Update()

    if World.TimeIndex > Ready2 then
        Ready2 = World.TimeIndex + 0.4
        checkHitman()
    end

end

function checkHitman()
    if not look(this, {"Avatar"}, nil, 9999, true) then
        if not look(this, {"HitmanMarker"}, nil, 9999, true) then
            this.Delete()
        end
    end
end
