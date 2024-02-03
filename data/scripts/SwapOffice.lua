-- SwapOffice --
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
                -- print("Found object "..v.." #"..uid)
                return o
            end
        end
    end
    return nil
end

local target_range = 0.8
local target
local already_marked = false

function checkDuplication(marker)
    -- print(marker.target_id)
    if marker.target_id == target.Id.u then
        already_marked = true
    end
end

local adminTypes = {"Warden", "Chief", "Foreman", "Psychologist", "Accountant", "Lawyer", "BoldHost"}

function Create()
    target = look_around(adminTypes, nil, target_range, true)
    if target then
        -- print(target.Id.u)
        -- print('---')
        look_around({"SwapOfficeMarker"}, checkDuplication, 'max')
        if already_marked then
            this.Sound("_Interface", "Cancel")
        else
            local otherMarker = look_around({"SwapOfficeMarker"}, nil, 'max', true)
            if otherMarker then
                this.Sound("_Bureaucracy", "CountdownComplete") -- Dingding
                local target2 = search(otherMarker.target_id, adminTypes, otherMarker, 2)
                print('switching')
                switch(target, target2)
                print('done')
                -- deleteO(otherMarker)
                otherMarker.Hidden = true
                otherMarker.Delete()
            else
                this.Sound("Doctor", "Place") -- Q
                marker = Object.Spawn("SwapOfficeMarker", target.Pos.x, target.Pos.y - 0.7)
                marker.target_id = target.Id.u
            end
        end
    else
        this.Sound("_Interface", "Cancel")
    end

    deleteO(this)
end

function deleteO(o)
    o.Pos.x = 0.5
    o.Pos.y = 0.5
    o.Delete()
end

function switch(a1, a2)
    local temp_u = a1.Office.u
    local temp_i = a1.Office.i
    a1.Office.u = a2.Office.u
    a1.Office.i = a2.Office.i
    a2.Office.u = temp_u
    a2.Office.i = temp_i
end

