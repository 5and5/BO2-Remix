#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/zombies/_zm_pers_upgrades_system;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_pers_upgrades_functions;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_weap_claymore;
#include maps/mp/zombies/_zm_melee_weapon;
#include maps/mp/zombies/_zm_craftables;

debug( debug )
{
	debug = getDvarIntDefault( "debug", debug );
	setDvar( "debug", debug );
	if(!debug)
	{
		return;
	}
	
	setDvar( "sv_cheats", 1 );
	setDvar( "ai_disablespawn", 1 );
	self.score = 555550;

	self thread set_starting_round( 1 );
	// self thread give_all_perks();
	// self thread give_weapons( "blundergat_zm", "blundersplat_upgraded_zm", "raygun_mark2_upgraded", "upgraded_tomahawk_zm");
	// self thread give_tomahwak();
	// self thread give_weapon_camo( "m14_zm" );
}

set_starting_round( round )
{
	flag_wait( "start_zombie_round_logic" );
	wait 0.05;

	if( getDvar( "start_round" ) == "")
		setDvar( "start_round", round );

	level.first_round = false;
	level.zombie_vars[ "zombie_spawn_delay" ] = 0.08;
	level.round_number = getDvarInt( "start_round" );
}

give_all_perks()
{	
	flag_wait( "initial_blackscreen_passed" );

	vending_triggers = getentarray( "zombie_vending", "targetname" );
	for ( i = 0; i < vending_triggers.size; i++ )
	{
		perk = vending_triggers[ i ].script_noteworthy;
		if ( isDefined( self.perk_purchased ) && self.perk_purchased == perk )
		{
			continue;
		}
		if ( perk == "specialty_weapupgrade" )
		{
			continue;
		}
		if ( !self hasperk( perk ) && !self has_perk_paused( perk ) )
		{
			self give_perk(perk, 1);
		}
		wait 0.1;
	}
}

give_tomahwak()
{
	flag_wait( "initial_blackscreen_passed" );
	wait 7;
	iPrintLn("tomahawk");

	if ( isDefined( self.current_tactical_grenade ) && !issubstr( self.current_tactical_grenade, "tomahawk_zm" ) )
	{
		self takeweapon( self.current_tactical_grenade );
	}
		// if ( self.current_tomahawk_weapon == "upgraded_tomahawk_zm" )
		// {
		// 	if ( !is_true( self.afterlife ) )
		// 	{
		// 		continue;
		// 	}
		// 	else 
		// 	{
		// 		self disable_self_move_states( 1 );
		// 		gun = self getcurrentweapon();
		// 		level notify( "bouncing_tomahawk_zm_aquired" );
		// 		self maps/mp/zombies/_zm_stats::increment_client_stat( "prison_tomahawk_acquired", 0 );
		// 		self giveweapon( "zombie_tomahawk_flourish" );
		// 		self thread tomahawk_update_hud_on_last_stand();
		// 		self switchtoweapon( "zombie_tomahawk_flourish" );
		// 		self waittill_any( "self_downed", "weapon_change_complete" );
		// 		if ( self.script_noteworthy == "redeemer_pickup_trigger" )
		// 		{
		// 			self.redeemer_trigger = self;
		// 			self setclientfieldtoself( "upgraded_tomahawk_in_use", 1 );
		// 		}
		// 		self switchtoweapon( gun );
		// 		self enable_self_move_states();
		// 		self.loadout.hastomahawk = 1;
		// 		continue;
		// 	}
		// }
	if ( !self hasweapon( "bouncing_tomahawk_zm" ) && !self hasweapon( "upgraded_tomahawk_zm" ) )
	{
		self.current_tomahawk_weapon = "upgraded_tomahawk_zm";

		self notify( "tomahawk_picked_up" );
		level notify( "bouncing_tomahawk_zm_aquired" );
		self notify( "player_obtained_tomahawk" );

		self.tomahawk_upgrade_kills = 99;
		self.killed_with_only_tomahawk = 1;
		self.killed_something_thq = 1;
		self notify( "tomahawk_upgraded_swap" );

		// if ( isDefined( self.current_tactical_grenade ) && !issubstr( self.current_tactical_grenade, "tomahawk_zm" ) )
		// {
		// 	self takeweapon( self.current_tactical_grenade );
		// }

		self disable_player_move_states( 1 );
		gun = self getcurrentweapon();
		self notify( "player_obtained_tomahawk" );
		self maps/mp/zombies/_zm_stats::increment_client_stat( "prison_tomahawk_acquired", 0 );
		self giveweapon( "zombie_tomahawk_flourish" );
		//self thread tomahawk_update_hud_on_last_stand();
		self switchtoweapon( "zombie_tomahawk_flourish" );
		self waittill_any( "player_downed", "weapon_change_complete" );
		self takeweapon( "zombie_tomahawk_flourish" );
		self enable_player_move_states();

		self.redeemer_trigger = self;
		self setclientfieldtoplayer( "upgraded_tomahawk_in_use", 1 );

		self giveweapon( "upgraded_tomahawk_zm" );
		self switchtoweapon( gun );

		wait 0.1;



		// player giveweapon( player.current_tomahawk_weapon );
		// player thread tomahawk_update_hud_on_last_stand();
		// player thread tomahawk_tutorial_hint();
		// player set_player_tactical_grenade( player.current_tomahawk_weapon );
		// if ( self.script_noteworthy == "retriever_pickup_trigger" )
		// {
		// 	player.retriever_trigger = self;
		// }
		// player notify( "tomahawk_picked_up" );
		// player setclientfieldtoplayer( "tomahawk_in_use", 1 );
		// gun = player getcurrentweapon();
		// level notify( "bouncing_tomahawk_zm_aquired" );
		// player notify( "player_obtained_tomahawk" );
		// player maps/mp/zombies/_zm_stats::increment_client_stat( "prison_tomahawk_acquired", 0 );
		// player giveweapon( "zombie_tomahawk_flourish" );
		// player switchtoweapon( "zombie_tomahawk_flourish" );
		// player waittill_any( "player_downed", "weapon_change_complete" );
		// if ( self.script_noteworthy == "redeemer_pickup_trigger" )
		// {
		// 	player setclientfieldtoplayer( "upgraded_tomahawk_in_use", 1 );
		// }
		// player switchtoweapon( gun );

		// player enable_player_move_states();
		// wait 0.1;
	}
}


give_weapons( weapon1, weapon2, weapon3, equipment )
{
	flag_wait( "initial_blackscreen_passed" );

	if(getDvar("mapname") == "zm_prison")
		wait 7;

	self giveWeapon(weapon1);
	self switchToWeapon(weapon1);
	if (isDefined( weapon2 ))
	{
		self giveWeapon(weapon2);
		self switchToWeapon(weapon2);
	}
	if (isDefined( weapon3 ))
	{
		self takeWeapon("m1911_zm");
		wait 0.05;
		self weapon_give(weapon3);
		self switchToWeapon(weapon3);
	}
	if (isDefined( equipment ))
	{
		self giveWeapon(equipment);
	}

}

give_weapon_camo( weapon )
{
	flag_wait( "initial_blackscreen_passed" );

	self giveweapon( weapon, 0, self calcweaponoptions( 40, 0, 0, 0 ) );
}

move_scriptmodel_with_dvar( model, origin, angles )
{
	scriptmodel = spawn_scriptmodel(model, origin, angles);

	x = origin[ 0 ]; y = origin[ 1 ]; z = origin[ 2 ]; a = angles[1];
	prev_x = 0; prev_y = 0; prev_z = 0; prev_a = 0;

	if ( getDvar("x") == "")
		setDvar("x", x);
	if ( getDvar("y") == "")
		setDvar("y", y);
	if ( getDvar("z") == "")
		setDvar("z", z);
	if ( getDvar("a") == "")
		setDvar("a", a);


	wait 1;
	while(1)
	{	
		x = getDvarInt("x"); y = getDvarInt("y"); z = getDvarInt("z"); a = getDvarInt("a");

		if( prev_x != x || prev_y != y || prev_z != z || prev_a != a )
		{
			iPrintLn("moved");
			origin[0] = int(x);
			origin[1] = int(y);
			origin[2] = int(z);
			angles[1] = int(a);


			prev_x = x; prev_y = y; prev_z = z; prev_a = a;

			scriptmodel delete();
			scriptmodel = spawn_scriptmodel(model, origin, angles);

			// scriptmodel forceteleport( origin );
			// scriptmodel setorigin( origin );
			// scriptmodel.origin = origin;
			// scriptmodel.angles = angles;
		}

		wait 0.1;
	}
}

spawn_scriptmodel( model, origin, angles )
{
	preCacheModel(model);
	scriptmodel = spawn("script_model", origin );
	scriptmodel SetModel(model);
	scriptmodel.angles = angles;
	return scriptmodel;
}

teleport_players( origin )
{
	flag_wait( "initial_blackscreen_passed" );
	foreach (player in level.players)
	{
		player setorigin( origin );
	}
}