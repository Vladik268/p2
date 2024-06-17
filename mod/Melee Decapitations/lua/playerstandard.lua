function PlayerStandard:_is_melee_instant()
	return tweak_data.blackmarket.melee_weapons[ managers.blackmarket:equipped_melee_weapon() ].instant
end

Hooks:PreHook( PlayerStandard , "_do_melee_damage" , "MeleeDecapPlayerStandardPreDoMeleeDamage" , function( self , t , bayonet_melee , melee_hit_ray )

	if MeleeDecap:HasSetting( "Decapitation" ) then
		local LeftArm = {
			[ Idstring( "hit_LeftArm" ):key() ] = true,
			[ Idstring( "hit_LeftForeArm" ):key() ] = true,
			[ Idstring( "rag_LeftArm" ):key() ] = true,
			[ Idstring( "rag_LeftForeArm" ):key() ] = true
		}
		local RightArm = {
			[ Idstring( "hit_RightArm" ):key() ] = true,
			[ Idstring( "hit_RightForeArm" ):key() ] = true,
			[ Idstring( "rag_RightArm" ):key() ] = true,
			[ Idstring( "rag_RightForeArm" ):key() ] = true
		}
		local LeftLeg = {
			[ Idstring( "LeftUpLeg" ):key() ] = true,
			[ Idstring( "LeftLeg" ):key() ] = true,
			[ Idstring( "rag_LeftUpLeg" ):key() ] = true,
			[ Idstring( "rag_LeftLeg" ):key() ] = true
		}
		local RightLeg = {
			[ Idstring( "RightUpLeg" ):key() ] = true,
			[ Idstring( "RightLeg" ):key() ] = true,
			[ Idstring( "rag_RightUpLeg" ):key() ] = true,
			[ Idstring( "rag_RightLeg" ):key() ] = true
		}
		
		local BodyParts = {
			iLeftArm = {
				"LeftArm",
				"LeftForeArm",
				"LeftHand"
			},
			iRightArm = {
				"RightArm",
				"RightForeArm",
				"RightHand"
			},
			iLeftLeg = {
				"LeftLeg",
				"LeftFoot"
			},
			iRightLeg = {
				"RightLeg",
				"RightFoot"
			}
		}
		
		local function get_limb( i )
			if LeftArm[ i ] then
				return "LeftArm"
			elseif RightArm[ i ] then
				return "RightArm"
			elseif LeftLeg[ i ] then
				return "LeftLeg"
			elseif RightLeg[ i ] then
				return "RightLeg"
			else
				return nil
			end
		end
		
		local melee_entry = managers.blackmarket:equipped_melee_weapon()
		local sphere_cast_radius = 20
		local col_ray
		
		if melee_hit_ray then
			col_ray = melee_hit_ray ~= true and melee_hit_ray or nil
		else
			col_ray = self:_calc_melee_hit_ray( t , sphere_cast_radius )
		end
		
		local melee_type = tweak_data.blackmarket.melee_weapons[ melee_entry ].melee_type
		
		if col_ray and alive( col_ray.unit ) then
			if col_ray.unit and col_ray.unit:character_damage() and col_ray.unit:character_damage():dead() and col_ray.body and col_ray.body:name() then
				if not MeleeDecap:HasSetting( "RealisticGore" ) or ( MeleeDecap:HasSetting( "RealisticGore" ) and melee_type == "LargeBladed" ) then
					if get_limb( col_ray.body:name():key() ) then
						for k , v in ipairs( BodyParts[ "i" .. get_limb( col_ray.body:name():key() ) ] ) do
							col_ray.unit:body( col_ray.unit:get_object( Idstring( v ) ) ):set_enabled( false )
						end
						col_ray.unit:movement():add_dismemberment( get_limb( col_ray.body:name():key() ) )
						col_ray.unit:sound():play("split_gen_body")
					end
				end
			end
		end
	end
end )