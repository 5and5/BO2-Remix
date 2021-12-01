#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zm_tomb;
#include maps/mp/zm_tomb_tank;
#include maps/mp/zombies/_zm_weapons;

#include scripts/zm/zm_tomb/remix/_tomb_dig;
#include scripts/zm/zm_tomb/remix/_tomb_weapons;

main()
{
    replaceFunc( maps/mp/zm_tomb::include_weapons, ::include_weapons_override );
    replaceFunc( maps/mp/zm_tomb_tank::wait_for_tank_cooldown, ::wait_for_tank_cooldown_override );
	replaceFunc( maps/mp/zm_tomb_dig::waittill_dug, ::waittill_dug );
	replaceFunc( maps/mp/zm_tomb_dig::dig_up_powerup, ::dig_up_powerup );
	replaceFunc( maps/mp/zm_tomb_dig::dig_get_rare_powerups, ::dig_get_rare_powerups );

    level.initial_spawn_tomb = true;
    level thread onplayerconnect();
}

onplayerconnect()
{   
    for(;;)
    {
        level waittill("connected", player);
        player thread onplayerspawned();
    }
}

onplayerspawned()
{
    self endon("disconnect");
    self.initial_spawn_tomb = true;
    
    for(;;)
    {
        self waittill("spawned_player");

		self tomb_give_shovel();

        if(self.initial_spawn_tomb)
		{
            self.initial_spawn_tomb = true;
        }

        if(level.initial_spawn_tomb)
        {
            level.initial_spawn_tomb = false;

			add_staffs_to_box();
			level thread tomb_remove_shovels_from_map();
			level thread tomb_zombie_blood_dig_changes();
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

include_weapons_override() //checked matches cerberus output
{
	include_weapon( "hamr_zm" );
	include_weapon( "hamr_upgraded_zm", 0 );
	include_weapon( "mg08_zm" );
	include_weapon( "mg08_upgraded_zm", 0 );
	include_weapon( "type95_zm" );
	include_weapon( "type95_upgraded_zm", 0 );
	include_weapon( "galil_zm" );
	include_weapon( "galil_upgraded_zm", 0 );
	include_weapon( "fnfal_zm" );
	include_weapon( "fnfal_upgraded_zm", 0 );
	include_weapon( "m14_zm", 0 );
	include_weapon( "m14_upgraded_zm", 0 );
	include_weapon( "mp44_zm", 0 );
	include_weapon( "mp44_upgraded_zm", 0 );
	include_weapon( "scar_zm" );
	include_weapon( "scar_upgraded_zm", 0 );
	include_weapon( "870mcs_zm", 0 );
	include_weapon( "870mcs_upgraded_zm", 0 );
	include_weapon( "ksg_zm" );
	include_weapon( "ksg_upgraded_zm", 0 );
	include_weapon( "srm1216_zm" );
	include_weapon( "srm1216_upgraded_zm", 0 );
	include_weapon( "ak74u_zm", 0 );
	include_weapon( "ak74u_upgraded_zm", 0 );
	include_weapon( "ak74u_extclip_zm" );
	include_weapon( "ak74u_extclip_upgraded_zm", 0 );
	include_weapon( "pdw57_zm" );
	include_weapon( "pdw57_upgraded_zm", 0 );
	include_weapon( "thompson_zm" );
	include_weapon( "thompson_upgraded_zm", 0 );
	include_weapon( "qcw05_zm" );
	include_weapon( "qcw05_upgraded_zm", 0 );
	include_weapon( "mp40_zm", 0 );
	include_weapon( "mp40_upgraded_zm", 0 );
	include_weapon( "mp40_stalker_zm" );
	include_weapon( "mp40_stalker_upgraded_zm", 0 );
	include_weapon( "evoskorpion_zm" );
	include_weapon( "evoskorpion_upgraded_zm", 0 );
	include_weapon( "ballista_zm", 0 );
	include_weapon( "ballista_upgraded_zm", 0 );
	include_weapon( "dsr50_zm" );
	include_weapon( "dsr50_upgraded_zm", 0 );
	include_weapon( "beretta93r_zm", 0 );
	include_weapon( "beretta93r_upgraded_zm", 0 );
	include_weapon( "beretta93r_extclip_zm" );
	include_weapon( "beretta93r_extclip_upgraded_zm", 0 );
	include_weapon( "kard_zm" );
	include_weapon( "kard_upgraded_zm", 0 );
	include_weapon( "fiveseven_zm", 0 );
	include_weapon( "fiveseven_upgraded_zm", 0 );
	include_weapon( "python_zm" );
	include_weapon( "python_upgraded_zm", 0 );
	include_weapon( "c96_zm", 0 );
	include_weapon( "c96_upgraded_zm", 0 );
	include_weapon( "fivesevendw_zm" );
	include_weapon( "fivesevendw_upgraded_zm", 0 );
	include_weapon( "m32_zm" );
	include_weapon( "m32_upgraded_zm", 0 );
	include_weapon( "beacon_zm", 0 );
	include_weapon( "claymore_zm", 0 );
	include_weapon( "cymbal_monkey_zm" );
	include_weapon( "frag_grenade_zm", 0 );
	include_weapon( "knife_zm", 0 );
	include_weapon( "ray_gun_zm" );
	include_weapon( "ray_gun_upgraded_zm", 0 );
	include_weapon( "sticky_grenade_zm", 0 );
	include_weapon( "tomb_shield_zm", 0 );
	add_limited_weapon( "c96_zm", 0 );
	add_limited_weapon( "ray_gun_zm", 4 );
	add_limited_weapon( "ray_gun_upgraded_zm", 4 );
	include_weapon( "staff_air_zm", 0 );
	include_weapon( "staff_air_upgraded_zm", 1 );
	precacheitem( "staff_air_upgraded2_zm" );
	precacheitem( "staff_air_upgraded3_zm" );
	include_weapon( "staff_fire_zm", 0 );
	include_weapon( "staff_fire_upgraded_zm", 0 );
	precacheitem( "staff_fire_upgraded2_zm" );
	precacheitem( "staff_fire_upgraded3_zm" );
	include_weapon( "staff_lightning_zm", 0 );
	include_weapon( "staff_lightning_upgraded_zm", 0 );
	precacheitem( "staff_lightning_upgraded2_zm" );
	precacheitem( "staff_lightning_upgraded3_zm" );
	include_weapon( "staff_water_zm", 0 );
	include_weapon( "staff_water_zm_cheap", 0 );
	include_weapon( "staff_water_upgraded_zm", 1 );
	precacheitem( "staff_water_upgraded2_zm" );
	precacheitem( "staff_water_upgraded3_zm" );
	include_weapon( "staff_revive_zm", 0 );
	add_limited_weapon( "staff_air_zm", 0 );
	add_limited_weapon( "staff_air_upgraded_zm", 0 );
	add_limited_weapon( "staff_fire_zm", 0 );
	add_limited_weapon( "staff_fire_upgraded_zm", 0 );
	add_limited_weapon( "staff_lightning_zm", 0 );
	add_limited_weapon( "staff_lightning_upgraded_zm", 0 );
	add_limited_weapon( "staff_water_zm", 0 );
	add_limited_weapon( "staff_water_zm_cheap", 0 );
	add_limited_weapon( "staff_water_upgraded_zm", 0 );
	if ( isDefined( level.raygun2_included ) && level.raygun2_included )
	{
		include_weapon( "raygun_mark2_zm", 1 );
		include_weapon( "raygun_mark2_upgraded_zm", 0 );
		add_weapon_to_content( "raygun_mark2_zm", "dlc3" );
		add_limited_weapon( "raygun_mark2_zm", 1 );
		add_limited_weapon( "raygun_mark2_upgraded_zm", 1 );
	}
}

wait_for_tank_cooldown_override()
{
	self thread snd_fuel();
	if ( self.n_cooldown_timer < 2 )
	{
		self.n_cooldown_timer = 2;
	}
	else
	{
		if ( self.n_cooldown_timer > 4 )
		{
			self.n_cooldown_timer = 4;
		}
	}
	wait self.n_cooldown_timer;
	level notify( "stp_cd" );
	self playsound( "zmb_tank_ready" );
	self playloopsound( "zmb_tank_idle" );
}