
function CreateGrants()

    CreateShortTermInvestment()
    CreateLongTermInvestment()

    CreateEnhancedSecurityGrant()
    CreateAdvancedSecurityGrant()
    CreateSecurityOutdoorGrant()
    CreateSecurityTunnelGrant()
    CreateSecurityOfficeGrant1()
    CreateSecurityOfficeGrant2()
    CreateSecurityOfficeGrant3()

    CreatePrisonerVisitationGrant()
    CreateEducationReformGrant()
    CreateReferralReformGrant()
    CreatePrisonLabourGrant()
    CreateFurnitureManufacturingGrant()

    CreateRelease1Grant()
    CreateRelease2Grant()
    CreateRelease3Grant()
    CreateRelease4Grant()
    CreateParole1Grant()
    CreateParole2Grant()
    CreateParole3Grant()

    CreateFireProtectionGrant()
    CreateSmallIsBeautifulGrant()
end



function  CreateShortTermInvestment()
    Objective.CreateGrant       ( "Grant_ShortTermInvestment", -5000, 15000 )
    Objective.SetPreRequisite   ( "Unlocked", "Finance", 0 )
    Objective.HiddenWhileLocked ()

    Objective.CreateGrant       ( "Grant_ShortTermInvestment_Wait", 0, 0 )
    Objective.SetParent         ( "Grant_ShortTermInvestment" )
    Objective.RequireTimePassed ( 4320 )
end

function CreateLongTermInvestment()
    Objective.CreateGrant       ( "Grant_LongTermInvestment", -10000, 100000 )
    Objective.SetPreRequisite   ( "Unlocked", "Finance", 0 )
    Objective.HiddenWhileLocked     ()

    Objective.CreateGrant       ( "Grant_LongTermInvestment_Wait", 0, 0 )
    Objective.SetParent         ( "Grant_LongTermInvestment" )
    Objective.RequireTimePassed ( 11520 )
end








function CreateEnhancedSecurityGrant()
    Objective.CreateGrant           ( "Grant_EnhancedSecurity", 0, 0 )
    Objective.SetPreRequisite       ( "Completed", "Grant_BasicSecurity", 1 )
    Objective.HiddenWhileLocked ()

    Objective.CreateGrant           ( "Grant_EnhancedSecurity_Armoury", 2000, 5000 )
    Objective.SetParent             ( "Grant_EnhancedSecurity" )
    Objective.RequireRoom           ( "Armoury", true )

    --Objective.CreateGrant           ( "Grant_EnhancedSecurity_Guards", 0, 0 )
    --Objective.SetParent             ( "Grant_EnhancedSecurity" )
    --Objective.RequireObjects        ( "ArmedGuard", 2 )

    Objective.CreateGrant           ( "Grant_EnhancedSecurity_Kennel", 1000, 2000 )
    Objective.SetParent             ( "Grant_EnhancedSecurity" )
    Objective.RequireRoom           ( "Kennel", true )

    --Objective.CreateGrant           ( "Grant_EnhancedSecurity_Dogs", 0, 0 )
    --Objective.SetParent             ( "Grant_EnhancedSecurity" )
    --Objective.RequireObjects        ( "DogHandler", 2 )

    Objective.CreateGrant           ( "Grant_EnhancedSecurity_PatrolDogs", 2000, 5000 )
    Objective.SetParent             ( "Grant_EnhancedSecurity" )
    Objective.Requires              ( "PatrolDogs", "AtLeast", 2 )

    Objective.CreateGrant           ( "Grant_EnhancedSecurity_PatrolArmed", 5000, 8000 )
    Objective.SetParent             ( "Grant_EnhancedSecurity" )
    Objective.Requires              ( "PatrolArmed", "AtLeast", 2 )
end



function CreateAdvancedSecurityGrant()
    Objective.CreateGrant       ( "Grant_AdvancedSecurity", 1000, 0 )
    Objective.SetPreRequisite   ( "Completed", "Grant_EnhancedSecurity", 1 )
    Objective.HiddenWhileLocked ()

    Objective.CreateGrant       ( "Grant_AdvancedSecurity_Guards", 1000, 1000 )
    Objective.SetParent         ( "Grant_AdvancedSecurity" )
    Objective.RequireObjects    ( "Guard", 20 )

    Objective.CreateGrant       ( "Grant_AdvancedSecurity_ResearchBodyArmour", 500, 1000 )
    Objective.SetParent         ( "Grant_AdvancedSecurity" )
    Objective.RequireResearched ( "BodyArmour" )

    Objective.CreateGrant       ( "Grant_AdvancedSecurity_ResearchTazers", 500, 0 )
    Objective.SetParent         ( "Grant_AdvancedSecurity" )
    Objective.RequireResearched ( "Tazers" )

    Objective.CreateGrant       ( "Grant_AdvancedSecurity_CCTVMonitor", 1000, 1000 )
    Objective.SetParent         ( "Grant_AdvancedSecurity" )
    Objective.RequireResearched ( "TazersForEveryone" )

    Objective.CreateGrant       ( "Grant_AdvancedSecurity_CCTVCameras", 1000, 2000 )
    Objective.SetParent         ( "Grant_AdvancedSecurity" )
    Objective.Requires          ( "ReformPassed", "TazerTraining", 10 )

end




function CreateSecurityOutdoorGrant()
    Objective.CreateGrant       ( "Grant_SecurityOutdoor", 5000, 5000 )
    Objective.SetPreRequisite   ( "Completed", "Grant_AdvancedSecurity", 1 )
    Objective.HiddenWhileLocked ()

    Objective.CreateGrant       ( "Grant_SecurityOutdoor_GuardTowers", 2000, 1000 )
    Objective.SetParent         ( "Grant_SecurityOutdoor" )
    Objective.RequireResearched ( "GuardTowers" )

    Objective.CreateGrant       ( "Grant_SecurityOutdoor_GuardTower", 1000, 2000 )
    Objective.SetParent         ( "Grant_SecurityOutdoor" )
    Objective.RequireObjects    ( "GuardTower", 1 )

    Objective.CreateGrant       ( "Grant_SecurityOutdoor_Sniper", 2000, 2000 )
    Objective.SetParent         ( "Grant_SecurityOutdoor" )
    Objective.RequireObjects    ( "Sniper", 1 )
end


function CreateSecurityTunnelGrant()
    Objective.CreateGrant       ( "Grant_SecurityTunnel", 0, 0 )
    Objective.SetPreRequisite   ( "Completed", "Grant_AdvancedSecurity", 1 )
    Objective.HiddenWhileLocked ()

    Objective.CreateGrant       ( "Grant_SecurityTunnel_Dog", 1000, 3000 )
    Objective.SetParent         ( "Grant_SecurityTunnel" )
    Objective.Requires          ( "PatrolDogs", "AtLeast", 6 )

    Objective.CreateGrant       ( "Grant_SecurityTunnel_PavingStone", 0, 1000 )
    Objective.SetParent         ( "Grant_SecurityTunnel" )
    -- Objective.SetFlags          (true, false)
    Objective.TargetZone        ( 1, 2, 70, 71 )
    Objective.RequireMaterials  ( "PavingStone", 5 )

    Objective.CreateGrant       ( "Grant_SecurityTunnel_PerimeterWall", 10000, 20000 )
    Objective.SetParent         ( "Grant_SecurityTunnel" )
    -- Objective.SetFlags          (true, false)
    Objective.TargetZone        ( 1, 1, 70, 70 )
    Objective.RequireMaterials  ( "PerimeterWall", 1 )



end




function CreateSecurityOfficeGrant1()
    Objective.CreateGrant       ( "Grant_SecurityOffice1", 0, 2000 )
    Objective.SetPreRequisite   ( "Completed", "Grant_AdvancedSecurity", 1 )
    Objective.HiddenWhileLocked ()

    Objective.CreateGrant       ( "Grant_SecurityOffice1_Office", 1000, 1000 )
    Objective.SetParent         ( "Grant_SecurityOffice1" )
    Objective.RequireRoom       ( "Security", true )

    Objective.CreateGrant       ( "Grant_SecurityOffice1_RemoteAccess", 1000, 2000 )
    Objective.SetParent         ( "Grant_SecurityOffice1" )
    Objective.RequireResearched ( "RemoteAccess" )

    Objective.CreateGrant       ( "Grant_SecurityOffice1_DoorControlSystem", 1000, 1000 )
    Objective.SetParent         ( "Grant_SecurityOffice1" )
    Objective.RequireObjects    ( "DoorControlSystem", 1 )

    Objective.CreateGrant       ( "Grant_SecurityOffice1_RemoteDoor", 1000, 2000 )
    Objective.SetParent         ( "Grant_SecurityOffice1" )
    Objective.RequireObjects    ( "RemoteDoor", 2 )

    Objective.CreateGrant       ( "Grant_SecurityOffice1_Servo", 1000, 2000 )
    Objective.SetParent         ( "Grant_SecurityOffice1" )
    Objective.RequireObjects    ( "Servo", 3 )

end




function CreateSecurityOfficeGrant2()
    Objective.CreateGrant       ( "Grant_SecurityOffice2", 2000, 0 )
    Objective.SetPreRequisite   ( "Completed", "Grant_SecurityOffice1", 1 )
    Objective.HiddenWhileLocked ()

    Objective.CreateGrant       ( "Grant_SecurityOffice_Contraband", 1000, 2000 )
    Objective.SetParent         ( "Grant_SecurityOffice2" )
    Objective.RequireResearched ( "Contraband" )

    Objective.CreateGrant       ( "Grant_SecurityOffice_CCTV", 1000, 1000 )
    Objective.SetParent         ( "Grant_SecurityOffice2" )
    Objective.RequireResearched ( "Cctv" )

    Objective.CreateGrant       ( "Grant_SecurityOffice_PhoneMonitor", 1000, 2000 )
    Objective.SetParent         ( "Grant_SecurityOffice2" )
    Objective.RequireObjects    ( "PhoneMonitor", 1 )
end



function CreateSecurityOfficeGrant3()
    Objective.CreateGrant       ( "Grant_SecurityOffice3", 5000, 5000 )
    Objective.SetPreRequisite   ( "Completed", "Grant_SecurityOffice2", 1 )
    Objective.HiddenWhileLocked ()

    Objective.CreateGrant       ( "Grant_SecurityOffice_CCTVMonitor", 0, 0 )
    Objective.SetParent         ( "Grant_SecurityOffice3" )
    Objective.RequireObjects    ( "CctvMonitor", 1 )

    Objective.CreateGrant       ( "Grant_SecurityOffice_CCTVCameras", 0, 0 )
    Objective.SetParent         ( "Grant_SecurityOffice3" )
    Objective.RequireObjects    ( "Cctv", 6 )
end









function CreatePrisonerVisitationGrant()
    Objective.CreateGrant           ( "Grant_Visitation", 1000, 2000 )
    Objective.SetPreRequisite       ( "Completed", "Grant_bootstraps", 0 )

    Objective.CreateGrant           ( "Grant_Visitation_Room", 500, 1500 )
    Objective.SetParent             ( "Grant_Visitation" )
    Objective.RequireRoom           ( "Visitation", true )

    Objective.CreateGrant           ( "Grant_Visitation_Tables", 0, 2000 )
    Objective.SetParent             ( "Grant_Visitation" )
    Objective.Requires              ( "TotalVisitCount", "AtLeast", 5 )

    Objective.CreateGrant           ( "Grant_Visitation_Phones", 500, 1000 )
    Objective.SetParent             ( "Grant_Visitation" )
    Objective.RequireObjects        ( "PhoneBooth", 5 )

    Objective.CreateGrant           ( "Grant_Visitation_CommonRoom", 0, 500 )
    Objective.SetParent             ( "Grant_Visitation" )
    Objective.RequireObjects        ( "WeightsBench", 3 )

    Objective.CreateGrant           ( "Grant_Visitation_TV", 500, 0 )
    Objective.SetParent             ( "Grant_Visitation" )
    Objective.RequireObjects        ( "LargeTv", 1 )

    Objective.CreateGrant           ( "Grant_Visitation_PoolTable", 500, 0 )
    Objective.SetParent             ( "Grant_Visitation" )
    Objective.RequireObjects        ( "PoolTable", 1 )

end







function CreateEducationReformGrant()
    Objective.CreateGrant      ( "Grant_EducationReformProgram", 0, 0 )
    Objective.SetPreRequisite  ( "Completed", "Grant_Administration", 1 )
    Objective.HiddenWhileLocked ()

    Objective.CreateGrant      ( "Grant_EducationReformProgram_Research", 1000, 2000 )
    Objective.SetParent        ( "Grant_EducationReformProgram" )
    Objective.RequireResearched( "Education" )

    Objective.CreateGrant      ( "Grant_EducationReformProgram_Classroom", 2000, 3000 )
    Objective.SetParent        ( "Grant_EducationReformProgram" )
    Objective.RequireRoom      ( "Classroom", true )

    Objective.CreateGrant      ( "Grant_EducationReformProgram_Desks", 0, 1000 )
    Objective.SetParent        ( "Grant_EducationReformProgram" )
    Objective.RequireObjects   ( "SchoolDesk", 10 )

    Objective.CreateGrant      ( "Grant_EducationReformProgram_FoundationEd", 2000, 3000 )
    Objective.SetParent        ( "Grant_EducationReformProgram" )
    Objective.Requires         ( "ReformPassed", "FoundationEducation", 10 )

    Objective.CreateGrant      ( "Grant_EducationReformProgram_GeneralEd", 0, 1000 )
    Objective.SetParent        ( "Grant_EducationReformProgram" )
    Objective.RequireObjects   ( "Bookshelf", 5 )
end







function CreateReferralReformGrant()
    Objective.CreateGrant      ( "Grant_ReferralReformProgram", 0, 0 )
    Objective.SetPreRequisite  ( "Completed", "Grant_Administration", 1 )
    Objective.HiddenWhileLocked ()

    Objective.CreateGrant      ( "Grant_ReferralReformProgram_Methadone", 1000, 2000 )
    Objective.SetParent        ( "Grant_ReferralReformProgram" )
    Objective.Requires         ( "ReformPassed", "Methadone", 3 )

    Objective.CreateGrant      ( "Grant_ReferralReformProgram_AlcoholicsMeeting", 1000, 3000 )
    Objective.SetParent        ( "Grant_ReferralReformProgram" )
    Objective.Requires         ( "ReformPassed", "AlcoholicsMeeting", 5 )

    Objective.CreateGrant      ( "Grant_ReferralReformProgram_Therapy", 3000, 10000 )
    Objective.SetParent        ( "Grant_ReferralReformProgram" )
    Objective.Requires         ( "ReformPassed", "Therapy", 1 )
end






function CreatePrisonLabourGrant()
    Objective.CreateGrant           ( "Grant_PrisonLabour", 0, 0 )
    Objective.SetPreRequisite       ( "Completed", "Grant_PrisonerWorkforce", 1 )

    Objective.CreateGrant           ( "Grant_PrisonLabour_Workshop", 2000, 3000 )
    Objective.SetParent             ( "Grant_PrisonLabour" )
    Objective.RequireRoom           ( "Workshop", true )

    Objective.CreateGrant           ( "Grant_PrisonLabour_Saw", 1000, 1000 )
    Objective.SetParent             ( "Grant_PrisonLabour" )
    Objective.RequireObjects        ( "WorkshopSaw", 2 )

    Objective.CreateGrant           ( "Grant_PrisonLabour_Press", 1000, 1000 )
    Objective.SetParent             ( "Grant_PrisonLabour" )
    Objective.RequireObjects        ( "WorkshopPress", 2 )

    Objective.CreateGrant           ( "Grant_PrisonLabour_Reform", 1000, 2000 )
    Objective.SetParent             ( "Grant_PrisonLabour" )
    Objective.Requires              ( "ReformPassed", "WorkshopInduction", 5 )

    Objective.CreateGrant           ( "Grant_PrisonLabour_Plates", 3000, 5000 )
    Objective.SetParent             ( "Grant_PrisonLabour" )
    Objective.RequireManufactured   ( "LicensePlate", 30 )
end

function CreateFurnitureManufacturingGrant()
    Objective.CreateGrant           ( "Grant_FurnitureManufacturing", 0, 0 )
    Objective.SetPreRequisite       ( "Completed", "Grant_PrisonLabour", 1 )
    Objective.HiddenWhileLocked ()

    Objective.CreateGrant           ( "Grant_FurnitureManufacturing_Forestry", 0, 5000 )
    Objective.SetParent             ( "Grant_FurnitureManufacturing" )
    Objective.RequireRoom           ( "Forestry", true )

    Objective.CreateGrant           ( "Grant_FurnitureManufacturing_Forestrys", 5000, 10000 )
    Objective.SetParent             ( "Grant_FurnitureManufacturing" )
    Objective.RequireRoomsAvailable ( "Forestry", 5 )

    Objective.CreateGrant           ( "Grant_FurnitureManufacturing_Gardener", 0, 1000 )
    Objective.SetParent             ( "Grant_FurnitureManufacturing" )
    Objective.RequireObjects        ( "Gardener", 4 )

    Objective.CreateGrant           ( "Grant_FurnitureManufacturing_Table", 0, 1000 )
    Objective.SetParent             ( "Grant_FurnitureManufacturing" )
    Objective.RequireObjects        ( "CarpenterTable", 2 )

    Objective.CreateGrant           ( "Grant_FurnitureManufacturing_Reform", 0, 2000 )
    Objective.SetParent             ( "Grant_FurnitureManufacturing" )
    Objective.Requires              ( "ReformPassed", "Carpentry", 2 )

    Objective.CreateGrant           ( "Grant_FurnitureManufacturing_Bed", 1000, 5000 )
    Objective.SetParent             ( "Grant_FurnitureManufacturing" )
    Objective.RequireManufactured   ( "SuperiorBed", 10 )
end







function CreateRelease1Grant()
    Objective.CreateGrant           ( "Grant_Release1", 0, 0 )
    Objective.SetPreRequisite       ( "PrisonersReleased", "AtLeast", 1 )
    Objective.HiddenWhileLocked ()
    Objective.CreateGrant           ( "Grant_Release1_JustTakeIt", 0, 3000 )
    Objective.SetParent             ( "Grant_Release1" )
end

function CreateRelease2Grant()
    Objective.CreateGrant           ( "Grant_Release2", 0, 0 )
    Objective.SetPreRequisite       ( "Completed", "Grant_Release1", 1 )
    Objective.HiddenWhileLocked ()

    Objective.CreateGrant           ( "Grant_Release2_Population", 0, 3000 )
    Objective.SetParent             ( "Grant_Release2" )
    Objective.Requires              ( "PrisonersReleased", "AtLeast", 10 )

    Objective.CreateGrant           ( "Grant_Release2_ReoffendingRate", 0, 7000 )
    Objective.SetParent             ( "Grant_Release2" )
    Objective.Requires              ( "ReoffendingRate", "Below", 30 )
end

function CreateRelease3Grant()
    Objective.CreateGrant           ( "Grant_Release3", 0, 0 )
    Objective.SetPreRequisite       ( "Completed", "Grant_Release2", 1 )
    Objective.HiddenWhileLocked ()

    Objective.CreateGrant           ( "Grant_Release3_Population", 10000, 20000 )
    Objective.SetParent             ( "Grant_Release3" )
    Objective.Requires              ( "PrisonersReleased", "AtLeast", 50 )

    Objective.CreateGrant           ( "Grant_Release3_ReoffendingRate", 10000, 20000 )
    Objective.SetParent             ( "Grant_Release3" )
    Objective.Requires              ( "ReoffendingRate", "Below", 25 )
end


function CreateRelease4Grant()
    Objective.CreateGrant           ( "Grant_Release4", 0, 0 )
    Objective.SetPreRequisite       ( "Completed", "Grant_Release3", 1 )
    Objective.HiddenWhileLocked ()

    Objective.CreateGrant           ( "Grant_Release4_Population", 20000, 100000 )
    Objective.SetParent             ( "Grant_Release4" )
    Objective.Requires              ( "PrisonersReleased", "AtLeast", 200 )

    Objective.CreateGrant           ( "Grant_Release4_ReoffendingRate", 30000, 50000 )
    Objective.SetParent             ( "Grant_Release4" )
    Objective.Requires              ( "ReoffendingRate", "Below", 20 )
end



function CreateParole1Grant()
    Objective.CreateGrant           ( "Grant_Parole1", 0, 0 )
    Objective.SetPreRequisite       ( "Completed", "Grant_PrisonerWorkforce", 1 )
    Objective.HiddenWhileLocked ()

    Objective.CreateGrant           ( "Grant_Parole1_ParoleRoom", 1000, 2000 )
    Objective.SetParent             ( "Grant_Parole1" )
    Objective.RequireRoom           ( "ParoleRoom", true )

    Objective.CreateGrant           ( "Grant_Parole1_Passed", 0, 2000 )
    Objective.SetParent             ( "Grant_Parole1" )
    Objective.Requires              ( "ReformPassed", "ParoleHearing", 5 )
end


function CreateParole2Grant()
    Objective.CreateGrant           ( "Grant_Parole2", 0, 0 )
    Objective.SetPreRequisite       ( "Completed", "Grant_Parole1", 1 )
    Objective.HiddenWhileLocked ()

    Objective.CreateGrant           ( "Grant_Parole2_Passed", 2000, 8000 )
    Objective.SetParent             ( "Grant_Parole2" )
    Objective.Requires              ( "ReformPassed", "ParoleHearing", 20 )

    Objective.CreateGrant           ( "Grant_Parole2_ReoffendingRate", 2000, 8000 )
    Objective.SetParent             ( "Grant_Parole2" )
    Objective.Requires              ( "ReoffendingRate", "Below", 15 )
end


function CreateParole3Grant()
    Objective.CreateGrant           ( "Grant_Parole3", 0, 0 )
    Objective.SetPreRequisite       ( "Completed", "Grant_Parole2", 1 )
    Objective.HiddenWhileLocked ()

    Objective.CreateGrant           ( "Grant_Parole3_Passed", 10000, 20000 )
    Objective.SetParent             ( "Grant_Parole3" )
    Objective.Requires              ( "ReformPassed", "ParoleHearing", 100 )

    Objective.CreateGrant           ( "Grant_Parole3_ReoffendingRate", 20000, 50000 )
    Objective.SetParent             ( "Grant_Parole3" )
    Objective.Requires              ( "ReoffendingRate", "Below", 10 )
end







function CreateFireProtectionGrant()
    Objective.CreateGrant           ( "Grant_FireProtection", 0, 0 )
    Objective.SetPreRequisite       ( "Completed", "Grant_AdvancedSecurity", 1 )
    Objective.HiddenWhileLocked ()

    Objective.CreateGrant           ( "Grant_FireProtection_Sprinkler", 1000, 1000 )
    Objective.SetParent             ( "Grant_FireProtection" )
    Objective.RequireObjects        ( "Sprinkler", 10 )
end


function CreateSmallIsBeautifulGrant()
    Objective.CreateGrant           ( "Grant_SmallIsBeautiful", 10000, 40000 )
    Objective.SetPreRequisite       ( "Completed", "Grant_AdvancedSecurity", 1 )
    Objective.HiddenWhileLocked()

    Objective.CreateGrant           ( "Grant_SmallIsBeautiful_Prisoners", 0, 0 )
    Objective.SetParent             ( "Grant_SmallIsBeautiful" )
    Objective.Requires              ( "Prisoners", "AtLeast", 120 )

    Objective.CreateGrant           ( "Grant_SmallIsBeautiful_Guards", 0, 0 )
    Objective.SetParent             ( "Grant_SmallIsBeautiful" )
    Objective.RequireObjects        ( "Guard", 25 )
    Objective.Invert()

    Objective.CreateGrant           ( "Grant_SmallIsBeautiful_ArmedGuard", 0, 0 )
    Objective.SetParent             ( "Grant_SmallIsBeautiful" )
    Objective.RequireObjects        ( "ArmedGuard", 4 )
    Objective.Invert()
end


