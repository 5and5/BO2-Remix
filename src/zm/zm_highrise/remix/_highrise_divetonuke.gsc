#include maps/mp/_visionset_mgr;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_net;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm;
#include common_scripts/utility;
#include maps/mp/_utility;

init_divetonuke()
{
	level.zombiemode_divetonuke_perk_func = ::divetonuke_explode;
    level.flopper_network_optimized = 1;
	maps/mp/_visionset_mgr::vsmgr_register_info( "visionset", "zm_perk_divetonuke", 9000, 400, 5, 1 );
	// level._effect[ "divetonuke_groundhit" ] = loadfx( "maps/zombie/fx_zmb_phdflopper_exp" );
	level._effect[ "default_explosion" ] = loadfx( "explosions/fx_default_explosion" );
}

divetonuke_explode( attacker, origin )
{
	radius = 300;
	min_damage = 1000;
	max_damage = 5000;
	if ( isdefined( level.flopper_network_optimized ) && level.flopper_network_optimized )
	{
		attacker thread divetonuke_explode_network_optimized(origin, radius, max_damage, min_damage, "MOD_GRENADE_SPLASH" );
	}
	else
	{   
		radiusdamage( origin, radius, max_damage, min_damage, attacker, "MOD_GRENADE_SPLASH" );
	}
	playfx( level._effect[ "default_explosion" ], origin );
	attacker playsound( "zmb_phdflop_explo" );
	// maps/mp/_visionset_mgr::vsmgr_activate( "visionset", "zm_perk_divetonuke", attacker );
	// wait 1;
	// maps/mp/_visionset_mgr::vsmgr_deactivate( "visionset", "zm_perk_divetonuke", attacker );
}

divetonuke_explode_network_optimized(origin, radius, max_damage, min_damage, damage_mod)
{
	self endon( "disconnect" );
	a_zombies = get_array_of_closest( origin, get_round_enemy_array(), undefined, undefined, radius );
	network_stall_counter = 0;
	if ( isdefined( a_zombies ) )
	{
		i = 0;
		while ( i < a_zombies.size )
		{
			e_zombie = a_zombies[ i ];
			if ( !isdefined( e_zombie ) || !isalive( e_zombie ) )
			{
				i++;
				continue;
			}
			dist = distance( e_zombie.origin, origin );
			damage = ( min_damage + max_damage ) - min_damage * ( 1 - ( dist / radius ) );
			e_zombie dodamage(damage, e_zombie.origin, self, self, 0, damage_mod);
			network_stall_counter--;
			if ( network_stall_counter <= 0 )
			{
				wait_network_frame();
				network_stall_counter = randomintrange( 1, 3 );
			}
			i++;
		}
	}
}


/*
* *****************************************************
*	
* ********************* Overrides **********************
*
* *****************************************************
*/

player_damage_changes()
{
	level.overrideplayerdamage = ::player_damage_override_override;
}

player_damage_override_override( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime ) //checked changed to match cerberus output
{
	if ( isDefined( level._game_module_player_damage_callback ) )
	{
		self [[ level._game_module_player_damage_callback ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
	}
	idamage = self check_player_damage_callbacks( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
	if ( is_true( self.use_adjusted_grenade_damage ) )
	{
		self.use_adjusted_grenade_damage = undefined;
		if ( self.health > idamage )
		{
			return idamage;
		}
	}
	if ( !idamage )
	{
		return 0;
	}
	if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
		return 0;
	}
	if ( isDefined( einflictor ) )
	{
		if ( is_true( einflictor.water_damage ) )
		{
			return 0;
		}
	}
	if ( isDefined( eattacker ) && is_true( eattacker.is_zombie ) || isplayer( eattacker ) )
	{
		if ( is_true( self.hasriotshield ) && isDefined( vdir ) )
		{
			if ( is_true( self.hasriotshieldequipped ) )
			{
				if ( self player_shield_facing_attacker( vdir, 0.2 ) && isDefined( self.player_shield_apply_damage ) )
				{
					self [[ self.player_shield_apply_damage ]]( 100, 0 );
					return 0;
				}
			}
			else if ( !isDefined( self.riotshieldentity ) )
			{
				if ( !self player_shield_facing_attacker( vdir, -0.2 ) && isDefined( self.player_shield_apply_damage ) )
				{
					self [[ self.player_shield_apply_damage ]]( 100, 0 );
					return 0;
				}
			}
		}
	}
	if ( isDefined( eattacker ) )
	{
		if ( isDefined( self.ignoreattacker ) && self.ignoreattacker == eattacker )
		{
			return 0;
		}
		if ( is_true( self.is_zombie ) && is_true( eattacker.is_zombie ) )
		{
			return 0;
		}
		if ( is_true( eattacker.is_zombie ) )
		{
			self.ignoreattacker = eattacker;
			self thread remove_ignore_attacker();
			if ( isDefined( eattacker.custom_damage_func ) )
			{
				idamage = eattacker [[ eattacker.custom_damage_func ]]( self );
			}
			else if ( isDefined( eattacker.meleedamage ) )
			{
				idamage = eattacker.meleedamage;
			}
			else
			{
				idamage = 50;
			}
		}
		eattacker notify( "hit_player" );
		if ( smeansofdeath != "MOD_FALLING" )
		{
			self thread playswipesound( smeansofdeath, eattacker );
			//changed to match bo3 _zm.gsc
			if ( is_true( eattacker.is_zombie ) || isplayer( eattacker ) )
			{
				self playrumbleonentity( "damage_heavy" );
			}
			canexert = 1;
			if ( is_true( self.pers_custom_flopper ) )
			{
				if ( smeansofdeath != "MOD_PROJECTILE_SPLASH" && smeansofdeath != "MOD_GRENADE" && smeansofdeath != "MOD_GRENADE_SPLASH" )
				{
					canexert = smeansofdeath;
				}
			}
			if ( is_true( canexert ) )
			{
				if ( randomintrange( 0, 1 ) == 0 )
				{
					self thread maps/mp/zombies/_zm_audio::playerexert( "hitmed" );
				}
				else
				{
					self thread maps/mp/zombies/_zm_audio::playerexert( "hitlrg" );
				}
			}
		}
	}

	
	finaldamage = idamage;
	//checked changed to match bo1 _zombiemode.gsc
	if ( is_placeable_mine( sweapon ) || sweapon == "freezegun_zm" || sweapon == "freezegun_upgraded_zm" )
	{
		return 0;
	}
	if ( isDefined( self.player_damage_override ) )
	{
		self thread [[ self.player_damage_override ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
	}
	if ( smeansofdeath == "MOD_FALLING" )
	{
		if ( is_true( self.pers_custom_flopper ) && isDefined( self.divetoprone ) && self.divetoprone == 1 )
		{
			if ( isDefined( level.zombiemode_divetonuke_perk_func ) )
			{
				[[ level.zombiemode_divetonuke_perk_func ]]( self, self.origin );
			}
			return 0;
		}
		if ( is_true( self.pers_custom_flopper ) )
		{
			return 0;
		}
	}
	//checked changed to match bo1 _zombiemode.gsc
	if ( smeansofdeath == "MOD_PROJECTILE" || smeansofdeath == "MOD_PROJECTILE_SPLASH" || smeansofdeath == "MOD_GRENADE" || smeansofdeath == "MOD_GRENADE_SPLASH" )
	{
		if ( self hasperk( "specialty_flakjacket" ) )
		{
			return 0;
		}
		if ( is_true( self.pers_custom_flopper ) )
		{
			return 0;
		}
		if ( self.health > 75 && !is_true( self.is_zombie ) )
		{
			return 75;
		}
	}
	if ( idamage < self.health )
	{
		if ( isDefined( eattacker ) )
		{
			if ( isDefined( level.custom_kill_damaged_vo ) )
			{
				eattacker thread [[ level.custom_kill_damaged_vo ]]( self );
			}
			else
			{
				eattacker.sound_damage_player = self;
			}
			if ( !is_true( eattacker.has_legs ) )
			{
				self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "crawl_hit" );
			}
			else if ( isDefined( eattacker.animname ) && eattacker.animname == "monkey_zombie" )
			{
				self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "monkey_hit" );
			}
		}
		return finaldamage;
	}
	if ( isDefined( eattacker ) )
	{
		if ( isDefined( eattacker.animname ) && eattacker.animname == "zombie_dog" )
		{
			self maps/mp/zombies/_zm_stats::increment_client_stat( "killed_by_zdog" );
			self maps/mp/zombies/_zm_stats::increment_player_stat( "killed_by_zdog" );
		}
		else if ( isDefined( eattacker.is_avogadro ) && eattacker.is_avogadro )
		{
			self maps/mp/zombies/_zm_stats::increment_client_stat( "killed_by_avogadro", 0 );
			self maps/mp/zombies/_zm_stats::increment_player_stat( "killed_by_avogadro" );
		}
	}
	self thread clear_path_timers();
	if ( level.intermission )
	{
		level waittill( "forever" );
	}
	if ( level.scr_zm_ui_gametype == "zcleansed" && idamage > 0 )
	{
		if ( !is_true( self.laststand ) && !self maps/mp/zombies/_zm_laststand::player_is_in_laststand() || !isDefined( self.last_player_attacker ) && isDefined( eattacker ) && isplayer( eattacker ) && eattacker.team != self.team )
		{
			if ( isDefined( eattacker.maxhealth ) && is_true( eattacker.is_zombie ) )
			{
				eattacker.health = eattacker.maxhealth;
			}
			if ( isDefined( level.player_kills_player ) )
			{
				self thread [[ level.player_kills_player ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
			}
		}
	}
	if ( self hasperk( "specialty_finalstand" ) && !self hasperk( "specialty_quickrevive"))
	{
		if(self.lives > 0)
			self.lives--;
		if ( isDefined( level.chugabud_laststand_func ) )
		{
			self thread [[ level.chugabud_laststand_func ]]();
			return 0;
		}
	}
	players = get_players();
	count = 0;
	//subtle changes in logic in the if statements
	for ( i = 0; i < players.size; i++ )
	{
		//count of dead players
		//checked changed to match bo1 _zombiemode.gsc
		if ( players[ i ] == self || players[ i ].is_zombie || players[ i ] maps/mp/zombies/_zm_laststand::player_is_in_laststand() || players[ i ].sessionstate == "spectator" )
		{
			count++;
		}
	}
	//checked against bo3 _zm.gsc changed to match 
	if ( count < players.size || isDefined( level._game_module_game_end_check ) && ![[ level._game_module_game_end_check ]]() )
	{
		if ( isDefined( self.lives ) && self.lives > 0 && is_true( level.force_solo_quick_revive ) && self hasperk( "specialty_quickrevive" ) )
		{
			self thread wait_and_revive();
		}
		return finaldamage;
	}
	solo_death = is_solo_death( self, players );
	non_solo_death = is_non_solo_death( self, players, count );
	if ( ( solo_death || non_solo_death ) && !is_true( level.no_end_game_check ) )
	{
		level notify( "stop_suicide_trigger" );
		self thread maps/mp/zombies/_zm_laststand::playerlaststand( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime );
		if ( !isDefined( vdir ) )
		{
			vdir = ( 1, 0, 0 );
		}
		self fakedamagefrom( vdir );
		if ( isDefined( level.custom_player_fake_death ) )
		{
			self thread [[ level.custom_player_fake_death ]]( vdir, smeansofdeath );
		}
		else
		{
			self thread player_fake_death();
		}
	}
	if ( count == players.size && !is_true( level.no_end_game_check ) )
	{
		if ( players.size == 1 && flag( "solo_game" ) )
		{
			if ( self.lives == 0 || !self hasperk( "specialty_quickrevive" ) )
			{
				self.lives = 0;
				level notify( "pre_end_game" );
				wait_network_frame();
				if ( flag( "dog_round" ) )
				{
					increment_dog_round_stat( "lost" );
				}
				level notify( "end_game" );
			}
			else
			{
				return finaldamage;
			}
		}
		else
		{
			level notify( "pre_end_game" );
			wait_network_frame();
			if ( flag( "dog_round" ) )
			{
				increment_dog_round_stat( "lost" );
			}
			level notify( "end_game" );
		}
		return 0;
	}
	else
	{
		surface = "flesh";
		return finaldamage;
	}
}

//added these functions to get around the compiler info.md No. 6
////////////////////////////////////////////////////////////////
is_solo_death( self, players )
{
	if ( players.size == 1 && flag( "solo_game" ) )
	{
		if ( !self hasPerk( "specialty_quickrevive" ) )
		{
			return 1;
		}
		if ( self.lives == 0 )
		{
			return 1;
		}
	}
	return 0;
}	

is_non_solo_death( self, players, count )
{
	if ( count > 1 || players.size == 1 && !flag( "solo_game" ) )
	{
		return 1;
	}
	return 0;
}
////////////////////////////////////////////////////////////////
