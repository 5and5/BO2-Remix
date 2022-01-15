// #include maps/mp/zombies/_zm;
// #include maps/mp/zombies/_zm_perks;
#include maps/mp/_visionset_mgr;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/_demo;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_pers_upgrades_functions;
#include maps/mp/zombies/_zm_power;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_magicbox;

#include scripts/zm/zm_transit/remix/_transit_ai;
#include scripts/zm/zm_transit/remix/_transit_equipment;
#include scripts/zm/zm_transit/remix/_transit_jetgun;
#include scripts/zm/zm_transit/remix/_transit_perks;
#include scripts/zm/zm_transit/remix/_transit_weapons;
#include scripts/zm/zm_transit/remix/_transit_zones;

main()
{
	replacefunc(maps/mp/zombies/_zm_perks::perk_machine_spawn_init, ::perk_machine_spawn_init_override);

	level.initial_spawn_transit = true;
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
    self.initial_spawn_transit = true;
    
    for(;;)
    {
        self waittill("spawned_player");

        if(self.initial_spawn_transit)
		{
            self.initial_spawn_transit = true;

        }

        if(level.initial_spawn_transit)
        {
            level.initial_spawn_transit = false;

			flag_wait( "start_zombie_round_logic" );
   			wait 0.05;

			spawn_custom_wallbuys();
			town_remove_speedcola();

			if ( level.scr_zm_map_start_location == "transit" && !is_classic() )
			{
				disable_screechers();
				self thread jetgun_buff();
			}
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
