local old_TripMineBase_spawn = TripMineBase.spawn
function TripMineBase.spawn(pos, rot, sensor_upgrade, peer_id, is_mx_mine)
    -- log("is_mx_mine? "..tostring(is_mx_mine))
    if is_mx_mine then
        local unit = World:spawn_unit(Idstring("units/payday2/equipment/gen_equipment_tripmine/gen_equipment_tripmine_mx"), pos, rot)
        managers.network:session():send_to_peers_synched("sync_trip_mine_setup", unit, sensor_upgrade, peer_id or 0)
        unit:base():setup(sensor_upgrade)
        return unit
    else 
        local result = old_TripMineBase_spawn(pos, rot, sensor_upgrade, peer_id)
        return result
    end
end
