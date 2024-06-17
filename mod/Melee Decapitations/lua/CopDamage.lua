function CopDamage:check_decapitations( damage_data )

	local body = damage_data.body
	local head = body:key() == Idstring( "head" ):key() or body:key() == Idstring( "hit_Head" ):key() or body:key() == Idstring( "rag_Head" ):key()
	
	local melee_entry = managers.blackmarket:equipped_melee_weapon() or "weapon"
	
	if not damage_data.attacker_unit then
		damage_data.attacker_unit = managers.player:player_unit()
	end
	if managers.network:session() and managers.network:session():peer_by_unit( damage_data.attacker_unit ) then
		melee_entry = managers.network:session():peer_by_unit( damage_data.attacker_unit ):melee_id()
	end
	
	local melee_type = tweak_data.blackmarket.melee_weapons[ melee_entry ].melee_type
	
	if self._dead then
		if MeleeDecap:HasSetting( "TrueDecapitation" ) and ( not MeleeDecap:HasSetting( "RealisticGore" ) or ( MeleeDecap:HasSetting( "RealisticGore" ) and melee_type == "LargeBladed" ) ) then
            if self._unit:base()._tweak_table == "spooc" then
                if head then
                    if self._unit:damage():has_sequence( "dismember_head" ) and not self._decapitated then    
                        self._unit:sound():play( "split_gen_head" )
                        self._unit:damage():run_sequence_simple( "dismember_head" )
                        self._decapitated = true    
                    end
                else
                    if self._unit:damage():has_sequence( "dismember_body_top" ) and not self._decapitated then    
                        self._unit:sound():play("split_gen_body")
                        self._unit:damage():run_sequence_simple("dismember_body_top")
                        self._decapitated = true
                    end
                end
            end
		end
		if MeleeDecap:HasSetting( "TrueDecapitation" ) and ( not MeleeDecap:HasSetting( "RealisticGore" ) or ( MeleeDecap:HasSetting( "RealisticGore" ) and melee_type == "Blunt" ) ) then
			if head then
				if self._unit:damage():has_sequence( "kill_tazer_headshot" ) and self._unit:base()._tweak_table == "taser" and not self._decapitated then
					self._unit:sound():play( "split_gen_head" )
					
					self:_spawn_head_gadget({
						position = self._unit:get_object( Idstring( "Head" ) ):position(),
						rotation = self._unit:get_object( Idstring( "Head" ) ):rotation(),
						dir = -self._unit:movement():m_head_rot():y()
					})
					
					self._unit:damage():run_sequence_simple( "kill_tazer_headshot" )
					self._decapitated = true
				end
			end
		end
		if head and not self._decapitated then
			self._unit:movement():enable_update()
			self._unit:movement()._frozen = nil
			
			if self._unit:movement()._active_actions[ 1 ] then
				self._unit:movement()._active_actions[ 1 ]:force_ragdoll(true)
			end
			
			self._unit:body( self._unit:get_object( Idstring( "Head" ) ) ):set_enabled( false )
			
			if not MeleeDecap:HasSetting( "RealisticGore" ) or ( MeleeDecap:HasSetting( "RealisticGore" ) and melee_type == "LargeBladed" ) then
				self._unit:sound():play( "split_gen_head" )
				
				self:_spawn_head_gadget({
					position = self._unit:get_object( Idstring( "Head" ) ):position(),
					rotation = self._unit:get_object( Idstring( "Head" ) ):rotation(),
					dir = -self._unit:movement():m_head_rot():y()
				})
				
				self._unit:get_object( Idstring( "Head" ) ):set_position( self._unit:get_object( Idstring( "Spine1" ) ):position() )
				self._unit:get_object( Idstring( "Head" ) ):set_rotation( self._unit:get_object( Idstring( "Spine1" ) ) )
				
				self._unit:movement():add_dismemberment( "Head" , MeleeDecap:HasSetting( "RealisticGore" ) and melee_type )
			end
			if MeleeDecap:HasSetting( "RealisticGore" ) and melee_type == "SmallBladed" then
				self._unit:sound():play( "split_gen_head" )
				self._unit:movement():add_dismemberment( "Head" , melee_type )
			end
			if MeleeDecap:HasSetting( "RealisticGore" ) and melee_type == "Blunt" then
				self._unit:get_object( Idstring( "Head" ) ):set_rotation( Rotation() )
			end
		end
	end

end

function CopDamage:check_blunt_force( damage_data )

	local body = damage_data.body
	local head = body:key() == Idstring( "head" ):key() or body:key() == Idstring( "hit_Head" ):key() or body:key() == Idstring( "rag_Head" ):key()
	
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	
	if not damage_data.attacker_unit then
		damage_data.attacker_unit = managers.player:player_unit()
	end
	if managers.network:session() and managers.network:session():peer_by_unit( damage_data.attacker_unit ) then
		melee_entry = managers.network:session():peer_by_unit( damage_data.attacker_unit ):melee_id()
	end
	
	local melee_type = tweak_data.blackmarket.melee_weapons[ melee_entry ].melee_type
	
	if damage_data.death and head and melee_type == "Blunt" and not managers.groupai:state():whisper_mode() then
		self._unit:movement():enable_update()
		self._unit:movement()._frozen = nil
		
		local hit_pos = mvector3.copy( self._unit:movement():m_pos() )
		local attack_dir = damage_data.attacker_unit:movement():m_head_rot():y()
		
		if self._unit:movement()._active_actions[ 1 ] then
			self._unit:movement()._active_actions[ 1 ]:force_ragdoll(true)
		end
		
		local height = mvector3.distance( hit_pos , self._unit:position() ) - 100
		local twist_dir = math.random( 2 ) == 1 and 1 or -1
		local rot_acc = ( attack_dir:cross( math.UP ) + math.UP * ( 0.5 * twist_dir ) ) * ( -1000 * math.sign( height ) )
		local rot_time = 1 + math.rand( 2 )
		local nr_u_bodies = self._unit:num_bodies()
		local i_u_body = 0
		
		while nr_u_bodies > i_u_body do
			local u_body = self._unit:body( i_u_body )
			if u_body:enabled() and u_body:dynamic() then
				World:play_physic_effect( Idstring( "physic_effects/shotgun_hit" ) , u_body , Vector3( attack_dir.x , attack_dir.y , attack_dir.z + 0.5 ) * 600 * MeleeDecap:HasSetting( "BluntForceMultiplier" ) , 4 * u_body:mass() / math.random( 2 ) , rot_acc , rot_time )
			end
			i_u_body = i_u_body + 1
		end
	end

end

Hooks:PostHook( CopDamage , "damage_melee" , "MeleeDecapCopDamagePostDamageMelee" , function( self , attack_data )

	if MeleeDecap:HasSetting( "Decapitation" ) then
		self:check_decapitations({
			body = attack_data.body_name or attack_data.col_ray.body:name(),
			attacker_unit = attack_data.attacker_unit
		})
	end
	
	if MeleeDecap:HasSetting( "BluntForceTrauma" ) then
		self:check_blunt_force({
			body = attack_data.body_name or attack_data.col_ray.body:name(),
			attacker_unit = attack_data.attacker_unit,
			death = attack_data.result and attack_data.result.type == "death"
		})
	end
	
end )