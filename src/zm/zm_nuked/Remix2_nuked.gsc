#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_blockers;

#include scripts/zm/zm_nuked/remix/_nuked_perks;
#include scripts/zm/zm_nuked/remix/_nuked_weapons;
#include scripts/zm/zm_nuked/remix/_nuked_zones;


main()
{
    // replaceFunc( maps/mp/zm_nuked::nuked_update_traversals, ::nuked_update_traversals );
    // replaceFunc( maps/mp/zm_nuked_perks::perks_from_the_sky, perks_from_the_sky_override );
	// replaceFunc( maps/mp/zm_nuked_perks::init_nuked_perks, init_nuked_perks_override );
    
	level.initial_spawn_nuked = true;
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
    self.initial_spawn_nuked = true;
    
    for(;;)
    {
        self waittill("spawned_player");

        if(self.initial_spawn_nuked)
		{
            self.initial_spawn_nuked = false;
        }

        if(level.initial_spawn_nuked)
        {
            level.initial_spawn_nuked = false;

			flag_wait( "start_zombie_round_logic" );
   			wait 0.05;

            // nuked_zone_changes();
            remove_ground_spawns();
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