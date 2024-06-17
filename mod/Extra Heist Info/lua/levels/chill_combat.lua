local EHI = EHI
if EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish) then
    local SF = EHI.SpecialFunctions
    local TT = EHI.Trackers
    ---@type ParseAchievementTable
    local achievements =
    {
        cac_30 =
        {
            elements =
            {
                [100979] = { status = EHI.Const.Trackers.Achievement.Status.Defend, class = TT.Achievement.Status },
                [102831] = { special_function = SF.SetAchievementComplete },
                [102829] = { special_function = SF.SetAchievementFailed }
            },
            sync_params = { from_start = true }
        }
    }

    EHI:ParseTriggers({
        achievement = achievements
    })
end

local tbl =
{
    --units/payday2/props/stn_prop_armory_shelf_ammo/stn_prop_armory_shelf_ammo
    [100751] = { f = "IgnoreDeployable" },
    [101242] = { f = "IgnoreDeployable" }
}
EHI:UpdateUnits(tbl)
EHIAssaultManager:SetDiff(1)
EHI:AddXPBreakdown({
    wave_all = { amount = 14000, times = 3 }
})