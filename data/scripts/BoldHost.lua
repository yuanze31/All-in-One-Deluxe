-- Warden --
local radius = 0.6

function SpawnBonus(p, count)
    -- Game.DebugOut(count)
    -- print_r(p)
    -- Game.DebugOut(p.pos.x)
    -- Game.DebugOut(p.pos.y)

    local i = 0
    while i < count do
        local curve = (0.25 + i / count) * 2 * math.pi
        local d_x = math.cos(curve) * radius
        local d_y = math.sin(curve) * radius
        -- print(d_x, d_y)
        local o = Object.Spawn("MoneyBag100", p.Pos.x + d_x, p.Pos.y + d_y)

        i = i + 1
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

-- # Game Events -------------------------------------------------------------

local Delay = 1 -- Clock Minutes
local Ready = World.TimeIndex + 0.1
local interview_interval = 3 -- Clock Minutes
local nearbyRange = 6

local each_bonus = 100 -- amount of each bonus

local inited = false
local at_office = nil
local has_cm = nil

function Update()
    if World.TimeIndex > Ready then
        Ready = World.TimeIndex + Delay

        checkCameraman()

        if not inited then
            inited = true
            this.bonus_check_count = this.bonus_check_count or 0
            this.bonus_generated = this.bonus_generated or 0
            this.spoiling_count = this.spoiling_count or 0
            this.last_interview_ready = this.last_interview_ready or -1
        end

        Go()
    end

end

function dist(from, to)
    return math.pow(math.pow((from.Pos.x - to.Pos.x), 2) + math.pow((from.Pos.y - to.Pos.y), 2), 0.5)
end

local CheckSpan = 15
local owned_cameraman = nil

function checkCameraman()
    at_office = false
    if getObjCell(this).Room.u == this.Office.u then
        at_office = true
    else
        this.Tooltip = {"dangerous_meeting__not_at_office"}
        return
    end

    owned_cameraman = nil

    if this.cameraman_id then
        owned_cameraman = search(this.cameraman_id, {"CameraMan"}, this, "max")
    end

    -- print('this.cameraman_id')
    -- print(this.cameraman_id)

    has_cm = false
    if not owned_cameraman or owned_cameraman.Damage == nil or owned_cameraman.Damage >= 0.7 then
        owned_cameraman = nil
        this.cameraman_id = nil
        Object.Spawn('CameraMan', World.OriginW + World.OriginX - 10, 0)
        -- Object.Spawn('CameraMan', this.Pos.x, this.Pos.y)
    else
        if getObjCell(owned_cameraman).Room.u == this.Office.u then
            has_cm = true
        else
            this.Tooltip = {"dangerous_meeting__need_cameraman"}
        end
    end
end

function Go()
    if not this.last_timeindex then
        this.last_timeindex = World.TimeIndex
    end

    if this.Damage >= 0.1 and this.Damage < 1 then
        if this.last_call == nil then
            this.last_call = 0
        end
        if World.TimeIndex - this.last_call > 60 then
            this.last_call = World.TimeIndex
            this.CreateJob('DoctorCalled')
        end
    end

    if World.TimeIndex - this.last_timeindex >= CheckSpan then
        this.last_timeindex = World.TimeIndex

        if this.Damage >= 0.7 then
            this.Tooltip = ''
            return
        end

        if at_office and has_cm then
            local bonus = CalcBonus()
            if bonus == -1 then
                -- No prisoners nearby
            else
                SpawnBonus(this, bonus)
                this.bonus_check_count = this.bonus_check_count + 1
                this.bonus_generated = this.bonus_generated + bonus
                if bonus >= 1 then -- and this.bonus_check_count % 2 == 0
                    this.Sound("_Finance", "MakePaymentMedium") -- Coin
                    -- this.Sound("__EpilogueOutro", "Music3") -- News
                end
            end
        end
    end

    if this.Damage >= 1 or (at_office and has_cm) then
        this.Tooltip = {"dangerous_meeting__stats", this.bonus_check_count, "X", this.bonus_generated * each_bonus, "Y",
                        this.spoiling_count, "Z"}
    end

end

local m_pc = 0.3
local m_bp = 0.7
local pow_to_b = 1.5
local pow_from_b = 0.8
local max = 0.16
local ignored = 0.01
local bonus_base = 2

function getObjCell(o)
    return World.GetCell(math.floor(o.Pos.x), math.floor(o.Pos.y))
end

function CalcBonus()

    local ps = this.GetNearbyObjects("Prisoner", nearbyRange)
    local total = 0
    local size = 0
    if ps ~= nil then
        for p, distance in pairs(ps) do
            local c = getObjCell(p)
            if this.Office.u == c.Room.u and p.Loaded and not p.Shackled and p.Damage < 0.7 then

                p.tt__timer = 15
                p.tt = 'bp'

                local pc

                local bp = math.pow(1 - p.BoilingPoint / 100, pow_to_b)

                local rc = p.ReoffendingChance
                pc = math.pow(rc, pow_to_b)
                -- if pc == 96 then
                --     pc = math.floor(rc * 100)
                -- end
                -- print(pc)
                -- print(bp)
                -- local n = pc - p.BoilingPoint
                -- print(n)
                local b = pc * m_pc + bp * m_bp
                -- print(b)
                local c = math.floor(1000 * max * math.pow(b, pow_from_b))
                local r = math.random(1000)
                -- print('      '..tostring(c))
                -- print('  '..tostring(c)..'  '..tostring(r))
                -- print(r)
                if c > ignored and r < c then
                    this.Sound("Guard", "Damage") -- whooerrr
                    print('      SPOILING!')
                    -- print(math.random(4, 5))
                    p.Misbehavior = math.random(4, 5) -- Spoil or fight
                    this.spoiling_count = this.spoiling_count + 1
                    if p.Misbehavior == 5 then
                        local fight_target_case = math.random()
                        if fight_target_case < 0.5 then
                            p.TargetObject.u = this.Id.u
                            p.TargetObject.i = this.Id.i
                        elseif fight_target_case < 0.8 then
                            p.TargetObject.u = owned_cameraman.Id.u
                            p.TargetObject.i = owned_cameraman.Id.i
                        end
                    end
                end
                total = total + b * bonus_base
                size = size + 1
                print("")
                -- else
                -- 	p.eval_chance_lowest = p.ReoffendingChance
                -- end
                -- p.new_eval = true
            end
        end
        if size > 0 then
            -- print("--------")
            -- print(total)
            -- print(size)
            -- print(total / size)
            print("")
            total = math.floor(total + 0.5)
            return total
        end
    end
    return -1
end

function Tooltip_Eval(p)
    if not p.eval_time_first then
        return
    end
    if p.BoilingPoint_lowest == nil then
        p.BoilingPoint_lowest = 100
    end
    local BoilingPoint_current = math.floor(p.BoilingPoint)
    p.BoilingPoint_lowest = math.min(p.BoilingPoint_lowest, BoilingPoint_current)

    if p.eval_chance_lowest == 100 then
        p.Tooltip = {"prisoner_evaluation_info__first", p.eval_chance_first, "F", BoilingPoint_current, "B"}
    else
        if p.bonus_count > 0 then
            if p.BoilingPoint_lowest < 100 then
                p.Tooltip = {"prisoner_evaluation_info__bonus__boiling", p.eval_chance_first, "F", p.eval_chance_lowest,
                             "L", p.eval_chance_current, "C", p.eval_chance_improved, "I", p.bonus_count, "B",
                             p.eval_days, "D", p.BoilingPoint_lowest, "A", BoilingPoint_current, "B"}
            else
                p.Tooltip = {"prisoner_evaluation_info__bonus__boiling_full", p.eval_chance_first, "F",
                             p.eval_chance_lowest, "L", p.eval_chance_current, "C", p.eval_chance_improved, "I",
                             p.bonus_count, "B", p.eval_days, "D"}
            end
        else
            if p.BoilingPoint_lowest < 100 then
                p.Tooltip = {"prisoner_evaluation_info__no_bonus__boiling", p.eval_chance_first, "F",
                             p.eval_chance_lowest, "L", p.eval_chance_current, "C", p.eval_chance_improved, "I",
                             p.eval_days, "D", p.BoilingPoint_lowest, "A", BoilingPoint_current, "B"}
            else
                p.Tooltip = {"prisoner_evaluation_info__no_bonus__boiling_full", p.eval_chance_first, "F",
                             p.eval_chance_lowest, "L", p.eval_chance_current, "C", p.eval_chance_improved, "I",
                             p.eval_days, "D"}
            end
        end
    end
end

