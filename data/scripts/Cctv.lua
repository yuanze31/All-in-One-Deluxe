-- CCTV
local function sortPrisoner()

    local prisoners = Object.GetNearbyObjects(this, "Prisoner", 7)
    if prisoners ~= nil then
        for prisoner, distance in pairs(prisoners) do
            -- print(prisoner.Category)
            if this.SortsTarget and prisoner.SnitchTimer ~= 0 and prisoner.Category ~= "Protected" then
                print("==== Prisoner is a snitch ==== ")
                prisoner.Category = 4
                this.TargetFoundCount = (this.TargetFoundCount or 0) + 1
            elseif this.SortsGang then
                SortGang(prisoner)
                -- elseif prisoner.Category == "DeathRow" or prisoner.Category == "SuperMax" then
                --     print("Skip a prisoner who is a "..prisoner.Category)
            end
        end
        -- print( "prisoner.StatusEffects.suppressed" )
        -- print( prisoner.StatusEffects.suppressed )
    end
end

-- gang sorting
local applicable = {
    MinSec = true,
    Normal = true,
    MaxSec = true
};
local categoryNames = {'MinSec', 'Normal', 'MaxSec', '4', '5', '6'};
local gangCategory = {
    [2] = 3,
    [3] = 2,
    [4] = 1
}; -- [keys] = gang id; values = category id

function SortGang(prisoner)
    local category = gangCategory[tonumber(prisoner.Gang.Id)];
    if category and prisoner.Category ~= categoryNames[category] and applicable[prisoner.Category] then
        print(" ==== Prisoner of " .. prisoner.Category .. " is a member of Gang " .. prisoner.Gang.Id .. " ==== ")
        prisoner.Category = category
        print(" ==== Sorted into Category " .. categoryNames[category] .. " (" .. category .. ") ==== ")
        this.GangFoundCount = (this.GangFoundCount or 0) + 1
    end
end

-- # Game Events -------------------------------------------------------------

-- when object is first built
function Create()
    -- print_r ( World )
    Object.SetProperty(this, "SortsTarget", false)
    Object.SetProperty(this, "SortsGang", false)

    Object.SetProperty(this, "TargetFoundCount", 0)
    Object.SetProperty(this, "GangFoundCount", 0)

    local targetsorters = Object.GetNearbyObjects(this, "TargetSorter", 0.1)
    if targetsorters ~= nil then
        for sorter, distance in pairs(targetsorters) do
            this.SortsTarget = true
            sorter.Delete()
        end
    end
    local gangsorters = Object.GetNearbyObjects(this, "GangSorter", 0.1)
    if gangsorters ~= nil then
        for sorter, distance in pairs(gangsorters) do
            this.SortsGang = true
            sorter.Delete()
        end
    end
end

function setTooltip()
    if this.SortsTarget then
        if this.SortsGang then
            this.Tooltip = {"PrisonerSorter_TargetNGangFound", (this.TargetFoundCount or 0), "X",
                            (this.GangFoundCount or 0), "Y"}
        else
            this.Tooltip = {"PrisonerSorter_TargetFound", (this.TargetFoundCount or 0), "X"}
        end

    else
        if this.SortsGang then
            this.Tooltip = {"PrisonerSorter_GangFound", (this.GangFoundCount or 0), "X"}
        else
            this.Tooltip = {"PrisonerSorter_NeedUpgrade"}
        end
    end
end

local Delay = 1
local Ready = 0
function Update()
    if World.TimeIndex > Ready then
        Ready = World.TimeIndex + Delay
        if this.Triggered > 0 then
            if this.SortsTarget or this.SortsGang then
                sortPrisoner()
            end
            -- else
            --     print( "Not triggerd" )
            -- this.Tooltip = nil
        end
        setTooltip()
        -- print(this.SubType)
        -- this.SubType=3-this.SubType
    end
end

