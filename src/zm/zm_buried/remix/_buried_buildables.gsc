#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;


spawn_turbine_bench( origin, angles )
{
	level endon("end_game");
	level endon("disconnect");

	precachemodel( "collision_clip_64x64x64" );
	bench = spawn("script_model", origin);
	bench SetModel("p6_zm_work_bench");
	bench.angles = angles;
	col = spawn("script_model", origin + (15, 0, 0));
	col SetModel("collision_clip_64x64x64");
	col.angles = angles;
	shieldModel = spawn("script_model", origin + ( 0, 0, 44 ) );
	shieldModel SetModel("p6_zm_buildable_turbine_mannequin");
	shieldModel.angles = ( angles + vectorScale( ( 0, 0, 0 ), 90 ) );
	trigger = spawn("trigger_radius", origin + (0,0,32), 20, 35, 70);
	trigger.targetname = "shield_trigger";
	trigger.angles = angles;
	trigger SetCursorHint("HINT_NOICON");
	trigger SetHintString("Hold ^3&&1^7 for Turbine");
	wait 5;
	level thread update_hint_string( trigger );
	while( 1 )
	{
		trigger waittill( "trigger", player );
		if( player UseButtonPressed() )
		{
			if( !player hasWeapon( "equip_turbine_zm" ) )
			{
				player maps/mp/zombies/_zm_equipment::equipment_buy( "equip_turbine_zm" );
			}
		}
		wait 0.1;
	}
}

update_hint_string( trig )
{
	level endon("end_game");
	level endon("disconnect");

	while( 1 )
	{
		foreach(player in level.players)
		{	
			//if ( isDefined( player.buildableturbine.owner ) && player.buildableturbine.owner.name == player.name || player hasweapon( "equip_turbine_zm" ) )
			if( player hasWeapon( "equip_turbine_zm" ) )
			{
				trig SetHintString("Took Turbine");
			}
			else
			{
				trig SetHintString("Hold ^3&&1^7 for Turbine");
			}
		}
		wait 0.1;
	}
}

/*
* *****************************************************
*	
* ********************* Overrides *********************
*
* *****************************************************
*/

startsubwooferdecay( weapon )
{
	self notify( "subwooferDecay" );
	self endon( "subwooferDecay" );
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_subwoofer_zm_taken" );
	weapon endon( "death" );
	roundlives = 4;
	if ( !isDefined( self.subwoofer_power_level ) )
	{
		self.subwoofer_power_level = roundlives;
	}
	while ( weapon.subwoofer_kills < 45 )
	{
		old_power_level = self.subwoofer_power_level;
		if ( isDefined( self.subwoofer_emped ) && self.subwoofer_emped && isDefined( self.subwoofer_is_powering_on ) && !self.subwoofer_is_powering_on )
		{
			emp_time = level.zombie_vars[ "emp_perk_off_time" ];
			now = getTime();
			emp_time_left = emp_time - ( ( now - self.subwoofer_emp_time ) / 1000 );
			if ( emp_time_left <= 0 )
			{
				self.subwoofer_emped = undefined;
				self.subwoofer_emp_time = undefined;
				old_power_level = -1;
			}
		}
		if ( isDefined( self.subwoofer_emped ) && self.subwoofer_emped )
		{
			self.subwoofer_power_level = 0;
		}
		cost = 1;
		if ( weapon.subwoofer_kills > 30 )
		{
			self.subwoofer_power_level = 1;
			if ( isDefined( weapon.low_health_sparks ) && !weapon.low_health_sparks )
			{
				weapon.low_health_sparks = 1;
				playfxontag( level._effect[ "switch_sparks" ], weapon, "tag_origin" );
			}
		}
		else if ( weapon.subwoofer_kills > 15 )
		{
			self.subwoofer_power_level = 2;
		}
		else
		{
			self.subwoofer_power_level = 4;
		}
		if ( old_power_level != self.subwoofer_power_level )
		{
			self notify( "subwoofer_power_change" );
		}
		wait 1;
	}
	if ( isDefined( weapon ) )
	{
		self destroy_placed_subwoofer();
		subwoofer_disappear_fx( weapon );
	}
	self thread wait_and_take_equipment();
	self.subwoofer_health = undefined;
	self.subwoofer_power_level = undefined;
	self.subwoofer_round_start = undefined;
	self.subwoofer_power_on = undefined;
	self.subwoofer_emped = undefined;
	self.subwoofer_emp_time = undefined;
	self cleanupoldsubwoofer();
}

subwooferthink( weapon, armed )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_subwoofer_zm_taken" );
	weapon notify( "subwooferthink" );
	weapon endon( "subwooferthink" );
	weapon endon( "death" );
	direction_forward = anglesToForward( flat_angle( weapon.angles ) + vectorScale( ( 0, 0, 1 ), 30 ) );
	direction_vector = vectorScale( direction_forward, 512 );
	direction_origin = weapon.origin + direction_vector;
	original_angles = weapon.angles;
	original_origin = weapon.origin;
	tag_spin_origin = weapon gettagorigin( "tag_spin" );
	wait 0,05;
	while ( 1 )
	{
		while ( isDefined( weapon.power_on ) && !weapon.power_on )
		{
			wait 1;
		}
		wait 2;
		if ( isDefined( weapon.power_on ) && !weapon.power_on )
		{
			continue;
		}
		if ( !isDefined( level._subwoofer_choke ) )
		{
			level thread subwoofer_choke();
		}
		while ( level._subwoofer_choke )
		{
			wait 0,05;
		}
		level._subwoofer_choke++;
		weapon.subwoofer_network_choke_count = 0;
		weapon thread maps/mp/zombies/_zm_equipment::signal_equipment_activated( 1 );
		vibrateamplitude = 4;
		if ( self.subwoofer_power_level == 3 )
		{
			vibrateamplitude = 8;
		}
		else
		{
			if ( self.subwoofer_power_level == 2 )
			{
				vibrateamplitude = 13;
			}
		}
		if ( self.subwoofer_power_level == 1 )
		{
			vibrateamplitude = 17;
		}
		weapon vibrate( vectorScale( ( 0, 0, 1 ), 100 ), vibrateamplitude, 0,2, 0,3 );
		zombies = get_array_of_closest( weapon.origin, get_round_enemy_array(), undefined, undefined, 1200 );
		players = get_array_of_closest( weapon.origin, get_players(), undefined, undefined, 1200 );
		props = get_array_of_closest( weapon.origin, getentarray( "subwoofer_target", "script_noteworthy" ), undefined, undefined, 1200 );
		entities = arraycombine( zombies, players, 0, 0 );
		entities = arraycombine( entities, props, 0, 0 );
		_a681 = entities;
		_k681 = getFirstArrayKey( _a681 );
		while ( isDefined( _k681 ) )
		{
			ent = _a681[ _k681 ];
			if ( !isDefined( ent ) || !isplayer( ent ) && isai( ent ) && !isalive( ent ) )
			{
			}
			else
			{
				if ( isDefined( ent.ignore_subwoofer ) && ent.ignore_subwoofer )
				{
					break;
				}
				else
				{
					distanceentityandsubwoofer = distance2dsquared( original_origin, ent.origin );
					onlydamage = 0;
					action = undefined;
					if ( distanceentityandsubwoofer <= 32400 )
					{
						action = "burst";
					}
					else if ( distanceentityandsubwoofer <= 230400 )
					{
						action = "fling";
					}
					else if ( distanceentityandsubwoofer <= 1440000 )
					{
						action = "stumble";
					}
					else
					{
					}
					if ( !within_fov( original_origin, original_angles, ent.origin, cos( 45 ) ) )
					{
						if ( isplayer( ent ) )
						{
							ent hit_player( action, 0 );
						}
						break;
					}
					else weapon subwoofer_network_choke();
					ent_trace_origin = ent.origin;
					if ( isai( ent ) || isplayer( ent ) )
					{
						ent_trace_origin = ent geteye();
					}
					if ( isDefined( ent.script_noteworthy ) && ent.script_noteworthy == "subwoofer_target" )
					{
						ent_trace_origin += vectorScale( ( 0, 0, 1 ), 48 );
					}
					if ( !sighttracepassed( tag_spin_origin, ent_trace_origin, 1, weapon ) )
					{
						break;
					}
					else if ( isDefined( ent.script_noteworthy ) && ent.script_noteworthy == "subwoofer_target" )
					{
						ent notify( "damaged_by_subwoofer" );
						break;
					}
					else
					{
						if ( isDefined( ent.in_the_ground ) && !ent.in_the_ground && isDefined( ent.in_the_ceiling ) && !ent.in_the_ceiling && isDefined( ent.ai_state ) || ent.ai_state == "zombie_goto_entrance" && isDefined( ent.completed_emerging_into_playable_area ) && !ent.completed_emerging_into_playable_area )
						{
							onlydamage = 1;
						}
						if ( isplayer( ent ) )
						{
							ent notify( "player_" + action );
							ent hit_player( action, 1 );
							break;
						}
						else if ( isDefined( ent ) )
						{
							ent notify( "zombie_" + action );
/#
							ent thread subwoofer_debug_print( action, ( 0, 0, 1 ) );
#/
							shouldgib = distanceentityandsubwoofer <= 810000;
							if ( action == "fling" )
							{
								ent thread fling_zombie( weapon, direction_vector / 4, self, onlydamage );
								weapon.subwoofer_kills++;
								self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "kill", "subwoofer" );
								break;
							}
							else if ( action == "burst" )
							{
								ent thread burst_zombie( weapon, self );
								weapon.subwoofer_kills++;
								self thread maps/mp/zombies/_zm_audio::create_and_play_dialog( "kill", "subwoofer" );
								break;
							}
							else
							{
								if ( action == "stumble" )
								{
									ent thread knockdown_zombie( weapon, shouldgib, onlydamage );
								}
							}
						}
					}
				}
			}
			_k681 = getNextArrayKey( _a681, _k681 );
		}
		if ( weapon.subwoofer_kills >= 45 )
		{
			self thread subwoofer_expired( weapon );
		}
	}
}

burst_zombie( weapon, player )
{
	if ( !isDefined( self ) || !isalive( self ) )
	{
		return;
	}
	if ( isDefined( self.subwoofer_burst_func ) )
	{
		self thread [[ self.subwoofer_burst_func ]]( weapon );
		return;
	}
	self dodamage( self.health + 666, weapon.origin );
	player notify( "zombie_subwoofer_kill" );
	if ( isDefined( self.guts_explosion ) && !self.guts_explosion )
	{
		self.guts_explosion = 1;
		self setclientfield( "zombie_gut_explosion", 1 );
		if ( isDefined( self.isdog ) && !self.isdog )
		{
			wait 0,1;
		}
		self ghost();
	}
}

fling_zombie( weapon, fling_vec, player, onlydamage )
{
	if ( !isDefined( self ) || !isalive( self ) )
	{
		return;
	}
	if ( isDefined( self.subwoofer_fling_func ) )
	{
		self thread [[ self.subwoofer_fling_func ]]( weapon, fling_vec );
		player notify( "zombie_subwoofer_kill" );
		return;
	}
	self dodamage( self.health + 666, weapon.origin );
	player notify( "zombie_subwoofer_kill" );
	if ( self.health <= 0 )
	{
		if ( isDefined( onlydamage ) && !onlydamage )
		{
			self startragdoll();
			self setclientfield( "subwoofer_flings_zombie", 1 );
		}
		self.subwoofer_death = 1;
	}
}

knockdown_zombie( weapon, gib, onlydamage )
{
	self endon( "death" );
	if ( isDefined( self.is_knocked_down ) && self.is_knocked_down )
	{
		return;
	}
	if ( !isDefined( self ) || !isalive( self ) )
	{
		return;
	}
	if ( isDefined( self.subwoofer_knockdown_func ) )
	{
		self thread [[ self.subwoofer_knockdown_func ]]( weapon, gib );
		return;
	}
	if ( isDefined( onlydamage ) && onlydamage )
	{
		self thread knockdown_zombie_damage( weapon );
		return;
	}
	if ( gib && isDefined( self.gibbed ) && !self.gibbed )
	{
		self thread knockdown_zombie_damage( weapon );
		self.a.gib_ref = random( level.subwoofer_gib_refs );
		self thread maps/mp/animscripts/zm_death::do_gib();
	}
	self.subwoofer_handle_pain_notetracks = ::handle_subwoofer_pain_notetracks;
	self thread knockdown_zombie_damage( weapon );
	self animcustom( ::knockdown_zombie_animate );
}