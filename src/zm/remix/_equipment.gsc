#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_weap_claymore;
#include maps/mp/zombies/_zm_melee_weapon;
#include maps/mp/zombies/_zm_craftables;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_equip_springpad;
#include maps/mp/zombies/_zm_equipment;

electric_trap_always_kill()
{
	level.etrap_damage = maps/mp/zombies/_zm::ai_zombie_health( 255 );
}

set_claymores_max( max )
{
	level.claymores_max_per_player = max;
}

enemies_ignore_equipments()
{
	equipment = getFirstArrayKey(level.zombie_include_equipment);
	while (isDefined(equipment))
	{
		maps/mp/zombies/_zm_equipment::enemies_ignore_equipment(equipment);
		equipment = getNextArrayKey(level.zombie_include_equipment, equipment);
	}
}

enemies_ignore_equipment( equipname ) //checked matches cerberus output
{
	if ( !isDefined( level.equipment_ignored_by_zombies ) )
	{
		level.equipment_ignored_by_zombies = [];
	}
	level.equipment_ignored_by_zombies[ equipname ] = equipname;
}

enemies_ignore_equipment_custom( equipname, ingore ) //checked matches cerberus output
{
	if ( !isDefined( level.equipment_ignored_by_zombies ) )
	{
		level.equipment_ignored_by_zombies = [];
	}
	if( ingore )
		level.equipment_ignored_by_zombies[ equipname ] = equipname;
	else
		arrayremovevalue(level.equipment_ignored_by_zombies, equipname);
}

springpad_animate_custom( weapon, armed )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_springpad_zm_taken" );
	weapon endon( "death" );
	weapon useanimtree( -1 );
	f_animlength = getanimlength( %o_zombie_buildable_tramplesteam_reset_zombie );
	r_animlength = getanimlength( %o_zombie_buildable_tramplesteam_reset );
	l_animlength = getanimlength( %o_zombie_buildable_tramplesteam_launch );
	weapon thread springpad_audio();
	prearmed = 0;
	if ( isDefined( armed ) && armed )
	{
		prearmed = 1;
	}
	fast_reset = 0;
	while ( isDefined( weapon ) )
	{
		if ( !prearmed )
		{
			if ( fast_reset )
			{
				weapon setanim( %o_zombie_buildable_tramplesteam_reset_zombie );
				weapon thread playspringpadresetaudio( f_animlength );
				wait f_animlength;
			}
			else
			{
				weapon setanim( %o_zombie_buildable_tramplesteam_reset );
				weapon thread playspringpadresetaudio( r_animlength );
				wait r_animlength;
			}
		}
		else
		{
			wait 0.05;
		}
		prearmed = 0;
		weapon notify( "armed" );
		fast_reset = 0;
		if ( isDefined( weapon ) )
		{
			weapon setanim( %o_zombie_buildable_tramplesteam_compressed_idle );
			weapon waittill( "fling", fast );
			fast_reset = fast;
		}
		if ( isDefined( weapon ) )
		{
			weapon setanim( %o_zombie_buildable_tramplesteam_launch );
			wait l_animlength;
		}
	}
}

/*
* *****************************************************
*	
* ********************* Overrides *********************
*
* *****************************************************
*/

springpad_expired_override( weapon )
{
	iPrintLn("gas");
	// weapon maps/mp/zombies/_zm_equipment::dropped_equipment_destroy( 1 );
	// self maps/mp/zombies/_zm_equipment::equipment_release( "equip_springpad_zm" );
	// self.springpad_kills = 0;
}

springpadthink_override( weapon, electricradius, armed )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_springpad_zm_taken" );
	weapon endon( "death" );
	radiussquared = electricradius * electricradius;
	trigger = spawn( "trigger_box", weapon getcentroid(), 1, 48, 48, 32 );
	trigger.origin += anglesToForward( flat_angle( weapon.angles ) ) * -15;
	trigger.angles = weapon.angles;
	trigger enablelinkto();
	trigger linkto( weapon );
	weapon.trigger = trigger;
	weapon thread springpadthinkcleanup( trigger );
	direction_forward = anglesToForward( flat_angle( weapon.angles ) + vectorScale( ( 0, 0, 1 ), 60 ) );
	direction_vector = vectorScale( direction_forward, 1024 );
	direction_origin = weapon.origin + direction_vector;
	home_angles = weapon.angles;
	weapon.is_armed = 0;
	self thread springpad_fx( weapon );
	self thread springpad_animate( weapon, armed );
	weapon waittill( "armed" );
	weapon.is_armed = 1;
	weapon.cooling_down = 0;
	weapon.fling_targets = [];
	self thread targeting_thread( weapon, trigger );
	while ( isDefined( weapon ) )
	{
		if( weapon.cooling_down )
		{
			wait 10;
			weapon.cooling_down = 0;
			// weapon.is_armed = 1;
			enemies_ignore_equipment_custom( "equip_springpad_zm", 0 );
			iPrintLn("cooldown");
		}
		wait_for_targets( weapon );
		if ( isDefined( weapon.fling_targets ) && weapon.fling_targets.size > 0 )
		{
			weapon notify( "fling" );
			weapon.is_armed = 0;
			weapon.zombies_only = 1;
			_a490 = weapon.fling_targets;
			_k490 = getFirstArrayKey( _a490 );
			while ( isDefined( _k490 ) )
			{
				ent = _a490[ _k490 ];
				if ( isplayer( ent ) )
				{
					ent thread player_fling( weapon.origin + vectorScale( ( 0, 0, 1 ), 30 ), weapon.angles, direction_vector, weapon );
				}
				else if ( isDefined( ent ) && isDefined( ent.custom_springpad_fling ) )
				{
					if ( !isDefined( self.num_zombies_flung ) )
					{
						self.num_zombies_flung = 0;
					}
					self.num_zombies_flung++;
					self notify( "zombie_flung" );
					ent thread [[ ent.custom_springpad_fling ]]( weapon, self );
				}
				else
				{
					if ( isDefined( ent ) )
					{
						if ( !isDefined( self.num_zombies_flung ) )
						{
							self.num_zombies_flung = 0;
						}
						self.num_zombies_flung++;
						self notify( "zombie_flung" );
						if ( !isDefined( weapon.fling_scaler ) )
						{
							weapon.fling_scaler = 1;
						}
						if ( isDefined( weapon.direction_vec_override ) )
						{
							direction_vector = weapon.direction_vec_override;
						}
						ent dodamage( ent.health + 666, ent.origin );
						ent startragdoll();
						ent launchragdoll( ( direction_vector / 4 ) * weapon.fling_scaler );
						weapon.springpad_kills++;
					}
				}
				_k490 = getNextArrayKey( _a490, _k490 );
			}
			if ( weapon.springpad_kills >= 28 ) //28
			{
				iPrintLn("cooling down");
				weapon.springpad_kills = 0;
				weapon.cooling_down = 1;
				weapon.is_armed = 0;
				enemies_ignore_equipment_custom( "equip_springpad_zm", 1 );
				// weapon.is_armed = 0;
				// self thread springpad_fx( weapon );
				// self thread springpad_animate( weapon, 0 );
				// weapon waittill( "armed" );
				// weapon.is_armed = 1;


				// self thread springpad_expired( weapon );
			}
			weapon.fling_targets = [];
			weapon waittill( "armed" );
			weapon.is_armed = 1;
			continue;
		}
		else
		{
			wait 0.1;
		}
	}
}

item_attract_zombies_override() //checked partially changed to match cerberus output did not change for loop to while loop more info on the github about continues
{
	self endon( "death" );
	self notify( "stop_attracting_zombies" );
	self endon( "stop_attracting_zombies" );
/*
/#
	self thread debughealth();
#/
*/
	while ( 1 )
	{
		wait 0.05;
		if ( is_equipment_ignored( self.equipname ) )
		{
			continue;
		}
		if ( isDefined( level.vert_equipment_attack_range ) )
		{
			vdistmax = level.vert_equipment_attack_range;
		}
		else
		{
			vdistmax = 36;
		}
		if ( isDefined( level.max_equipment_attack_range ) )
		{
			distmax = level.max_equipment_attack_range * level.max_equipment_attack_range;
		}
		else
		{
			distmax = 4096;
		}
		if ( isDefined( level.min_equipment_attack_range ) )
		{
			distmin = level.min_equipment_attack_range * level.min_equipment_attack_range;
		}
		else
		{
			distmin = 2025;
		}
		ai = getaiarray( level.zombie_team );
		i = 0;
		while ( i < ai.size )
		{
			if ( !isDefined( ai[ i ] ) )
			{
				i++;
				continue;
			}
			if ( is_true( ai[ i ].ignore_equipment ) )
			{
				i++;
				continue;
			}
			if ( isDefined( level.ignore_equipment ) )
			{
				if ( self [[ level.ignore_equipment ]]( ai[ i ] ) )
				{
					i++;
					continue;
				}
			}
			if ( is_true( ai[ i ].is_inert ) )
			{
				i++;
				continue;
			}
			if ( is_true( ai[ i ].is_traversing ) )
			{
				i++;
				continue;
			}
			vdist = abs( ai[ i ].origin[ 2 ] - self.origin[ 2 ] );
			distsqrd = distance2dsquared( ai[ i ].origin, self.origin );
			if ( ( self.equipname == "riotshield_zm" || self.equipname == "alcatraz_shield_zm" ) && isDefined( self.equipname ) )
			{
				vdistmax = 108;
			}
			should_attack = 0;
			if ( isDefined( level.should_attack_equipment ) )
			{
				should_attack = self [[ level.should_attack_equipment ]]( distsqrd );
			}
			if ( distsqrd < distmax && distsqrd > distmin && vdist < vdistmax || should_attack )
			{
				if ( !is_true( ai[ i ].isscreecher ) && !ai[ i ] is_quad() && !ai[ i ] is_leaper() )
				{
					ai[ i ] thread attack_item( self );
					item_choke();
				}
			}
			item_choke();
			i++;
		}
		wait 0.05;
	}
}

/*
* *****************************************************
*	
* ********************* Overrides **********************
*
* *****************************************************
*/