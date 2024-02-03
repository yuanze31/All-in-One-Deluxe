local Delay = 2 -- Clock Minutes
local Ready = 0
function Update()
    if World.TimeIndex > Ready then
        Ready = World.TimeIndex + Delay
        local didUpgrade = false
        local cctvs = Object.GetNearbyObjects(this, "Cctv", 0)
        if cctvs ~= nil then
            for cctv, distance in pairs(cctvs) do
                if not cctv.SortsTarget then
                    cctv.SortsTarget = true
                    didUpgrade = true
                end
            end
        end
        if didUpgrade then
            this.Delete()
        else
            this.Tooltip = "PrisonerSorter_DidNotUpgrade"
        end

    end
end
