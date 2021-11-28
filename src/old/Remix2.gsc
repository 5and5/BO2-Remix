#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/zombies/_zm_pers_upgrades_system;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_pers_upgrades_functions;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_weap_claymore;
#include maps/mp/zombies/_zm_melee_weapon;
#include maps/mp/zombies/_zm_craftables;

main()
{ 
	level.VERSION = "0.6.4";



    level.inital_spawn = true;
    level thread onConnect();
}
onConnect()
{
    for (;;)
    {
        level waittill("connected", player);
        player thread connected();
    }
}
connected()
{
    level endon( "game_ended" );
    self endon("disconnect");

    self.initial_spawn = true;

    for(;;)
    {
        self waittill("spawned_player");

		// testing
		// self thread set_starting_round( 51 );
		// self thread give_all_perks();
		// self thread give_weapons( "blundergat_zm", "blundersplat_upgraded_zm", "raygun_mark2_upgraded", "upgraded_tomahawk_zm");
		// self thread give_tomahwak();
		// self thread give_weapon_camo( "m14_zm" );
		
    	if(self.initial_spawn)
		{
            self.initial_spawn = false;

			self iprintln("Welcome to Remix!");
			self iPrintLn("Version " + level.VERSION);
			// self iprintln("Made by 5and5");
       		// self setClientDvar( "com_maxfps", 101 );

        }

        if(level.inital_spawn)
		{
			level.inital_spawn = false;


			flag_wait( "start_zombie_round_logic" );
   			wait 0.05;

			
			
			
			
			



			
			



			switch( getDvar("mapname") )
			{
				case "zm_transit":
					//remove_tombstone();

				case "zm_nuked":
				case "zm_highrise":

				case "zm_prison":

				case "zm_buried":
				case "zm_tomb":
					
			}
		}
	}
}





/*
* *************************************************
*	
* ****************** Functions ********************
*
* *************************************************
*/













/*
* *********************************************************************
*
* *************************** Self Theards *****************************
*
* *********************************************************************
*/











/*
* *********************************************************************
*
* *************************** Level Theards *****************************
*
* *********************************************************************
*/







/*
* *********************************************************************
*
* *************************** Die Rise ********************************
*
* *********************************************************************
*/




/*
* *********************************************************************
*
* *************************** Tranzit *********************************
*
* *********************************************************************
*/



/*
* *********************************************************************
*
* *************************** Origins *********************************
*
* *********************************************************************
*/




/*
* *********************************************************************
*
* *************************** Mob *************************************
*
* *********************************************************************
*/

