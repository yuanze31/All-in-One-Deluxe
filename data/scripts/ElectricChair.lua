-- ElectricChair --
function ec__activeClicked()
    this.is_active = not this.is_active
    Interface.SetCaption(this, "ec__active", "ec__active", tostring(this.is_active), 'B')
    updateTooltip()
end

function updateTooltip()
    if this.is_active then
        this.Tooltip = {'ec__tt_on'}
    else
        this.Tooltip = {'ec__tt_off'}
    end
end

local inited

function Init()
    inited = true
    if this.is_active == nil then
        this.is_active = false
    end
    Interface.AddComponent(this, "ec__active", 'Button', "ec__active", tostring(this.is_active), 'B')
    updateTooltip()
end

local Delay = 1
local Ready = 0
function Update()
    if not inited then
        Init()
    end

    -- if World.TimeIndex > Ready then
    -- 	Ready = World.TimeIndex + Delay * World.TimeWarpFactor
    -- end
end
