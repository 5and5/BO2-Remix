#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zm_alcatraz_traps;

prison_tower_trap_changes()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "prison"))
	{
		return;
	}

	// need to override the original function call
	// this level var is threaded though so it doesn't work
	level.custom_tower_trap_fires_func = ::prison_tower_trap_fires_override;

	trap_trigs = getentarray( "tower_trap_activate_trigger", "targetname" );
	foreach (trig in trap_trigs)
	{
		trig thread prison_tower_trap_trigger_think();
		trig thread prison_tower_upgrade_trigger_think();
	}
}

prison_tower_trap_fires_override( zombies )
{
	
}

prison_tower_trap_trigger_think()
{
	while (1)
	{
		self waittill("switch_activated");
		self thread prison_activate_tower_trap();
	}
}

prison_activate_tower_trap()
{
	self endon( "tower_trap_off" );

	if ( isDefined( self.upgraded ) )
	{
		self.weapon_name = "tower_trap_upgraded_zm";
		self.tag_to_target = "J_SpineLower";
		self.trap_reload_time = 1.5;
	}
	else
	{
		self.weapon_name = "tower_trap_zm";
		self.tag_to_target = "J_Head";
		self.trap_reload_time = 0.75;
	}

	while ( 1 )
	{
		zombies = getaiarray( level.zombie_team );
		zombies_sorted = [];
		foreach ( zombie in zombies )
		{
			if ( zombie istouching( self.range_trigger ) )
			{
				zombies_sorted[ zombies_sorted.size ] = zombie;
			}
		}

		if ( zombies_sorted.size <= 0 )
		{
			wait_network_frame();
			continue;
		}

		self prison_tower_trap_fires( zombies_sorted );
	}
}

prison_tower_trap_fires( zombies )
{
	self endon( "tower_trap_off" );

	org = getstruct( self.range_trigger.target, "targetname" );
	index = randomintrange( 0, zombies.size );

	while ( isalive( zombies[ index ] ) )
	{
		target = zombies[ index ];
		zombietarget = target gettagorigin( self.tag_to_target );

		if ( sighttracepassed( org.origin, zombietarget, 1, undefined ) )
		{
			self thread prison_tower_trap_magicbullet_think( org, target, zombietarget );
			wait self.trap_reload_time;
			continue;
		}
		else
		{
			arrayremovevalue( zombies, target, 0 );
			wait_network_frame();
			if ( zombies.size <= 0 )
			{
				return;
			}
			else
			{
				index = randomintrange( 0, zombies.size );
			}
		}
	}
}

prison_tower_trap_magicbullet_think( org, target, zombietarget )
{
	bullet = magicbullet( self.weapon_name, org.origin, zombietarget );
	bullet waittill( "death" );

	if ( self.weapon_name == "tower_trap_zm" )
	{
		if ( isDefined( target ) && isDefined( target.animname ) && target.health > 0 && target.animname != "brutus_zombie" )
		{
			if ( !isDefined( target.no_gib ) || !target.no_gib )
			{
				target maps/mp/zombies/_zm_spawner::zombie_head_gib();
			}
			target dodamage( target.health + 1000, target.origin );
		}
	}
	else if ( self.weapon_name == "tower_trap_upgraded_zm" )
	{
		radiusdamage( bullet.origin, 256, level.zombie_health * 1.5, level.zombie_health / 2, self, "MOD_GRENADE_SPLASH", "tower_trap_upgraded_zm" );
	}
}

prison_tower_upgrade_trigger_think()
{
	flag_wait( "initial_blackscreen_passed" );
	flag_wait( "start_zombie_round_logic" );
	wait 0.05;

	while (1)
	{
		level waittill( self.upgrade_trigger.script_string );
		self.upgraded = 1;
		level waittill( "between_round_over" );
		self.upgraded = undefined;
	}
}

fan_trap_damage( parent ) //checked partially changed to match cerberus output
{
	if ( isDefined( level.custom_fan_trap_damage_func ) )
	{
		self thread [[ level.custom_fan_trap_damage_func ]]( parent );
		return;
	}
	self endon( "fan_trap_finished" );
	while ( 1 )
	{
		self waittill( "trigger", ent );
		if ( isplayer( ent ) )
		{
			ent thread player_fan_trap_damage();
			wait 0.05;
		}
		else
		{
			if ( is_true( ent.is_brutus ) )
			{
				ent maps/mp/zombies/_zm_ai_brutus::trap_damage_callback( self );
				return;
			}
			if ( !isDefined( ent.marked_for_death ) )
			{
				ent.marked_for_death = 1;
				ent thread zombie_fan_trap_death();
			}
		}
	}
}

player_acid_damage( t_damage ) //checked changed to match cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	t_damage endon( "acid_trap_finished" );
	if ( !isDefined( self.is_in_acid ) && !self maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
	{
		self.is_in_acid = 1;
		cooldown = 1.5;
		self thread player_acid_damage_cooldown( cooldown );

		while ( self istouching( t_damage ) && !self maps\mp\zombies\_zm_laststand::player_is_in_laststand() && !self.afterlife )
		{
			self dodamage( self.maxhealth / 2, self.origin );
			wait cooldown;
		}
	}
}


player_acid_damage_cooldown( cooldown ) //checked matches cerberus output
{
	self endon( "disconnect" );
	wait cooldown;
	if ( isDefined( self ) )
	{
		self.is_in_acid = undefined;
	}
}