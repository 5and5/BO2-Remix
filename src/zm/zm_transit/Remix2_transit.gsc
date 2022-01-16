#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_blockers;

#include scripts/zm/zm_transit/remix/_transit_ai_screecher;
#include scripts/zm/zm_transit/remix/_transit_equipment;
#include scripts/zm/zm_transit/remix/_transit_jetgun;
#include scripts/zm/zm_transit/remix/_transit_perks;
#include scripts/zm/zm_transit/remix/_transit_weapons;
#include scripts/zm/zm_transit/remix/_transit_zones;

main()
{
	replacefunc(maps/mp/zombies/_zm_perks::perk_machine_spawn_init, ::perk_machine_spawn_init_override);
	replacefunc(maps/mp/zombies/_zm_weap_jetgun::handle_overheated_jetgun, ::handle_overheated_jetgun);
	replacefunc(maps/mp/zombies/_zm_blockers::door_think, ::door_think);
	replacefunc(maps/mp/zm_transit_ai_screecher::portal_use, ::portal_use);
	replacefunc(maps/mp/zm_transit_ai_screecher::player_wait_land, ::player_wait_land);
	
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

			if ( level.scr_zm_map_start_location == "transit" && is_classic() )
			{
				self thread jetgun_fast_cooldown();
				// self thread jetgun_fast_spinlerp(); //op
			}
        }

        if(level.initial_spawn_transit)
        {
            level.initial_spawn_transit = false;

			flag_wait( "start_zombie_round_logic" );
   			wait 0.05;

			spawn_custom_wallbuys();
			town_remove_speedcola();

			if ( level.scr_zm_map_start_location == "transit" && is_classic() )
			{
				jetgun_remove_forced_weapon_switch();
				open_pap_power_door();
				disable_screechers();
				spawn_lightpost_portals();
				transit_zone_changes();
			}
        }
    }
}

open_pap_power_door() //checked changed at own discretion
{
	zombie_doors = getentarray( "zombie_door", "targetname" );
	foreach ( door in zombie_doors )
	{
		if ( isDefined( door.script_noteworthy ) && door.script_noteworthy == "local_electric_door" )
		{
			if( door.target == "lab_secret_hatch" )
				door notify( "local_power_on" );
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

door_think() //checked changed to match cerberus output
{
	self endon( "kill_door_think" );
	cost = 1000;
	if ( isDefined( self.zombie_cost ) )
	{
		cost = self.zombie_cost;
	}
	self sethintlowpriority( 1 );
	while ( 1 )
	{
		switch ( self.script_noteworthy )
		{
			case "local_electric_door":
				if ( !is_true( self.local_power_on ) )
				{
					self waittill( "local_power_on" );
				}
				if ( !is_true( self._door_open ) )
				{
					self door_opened( cost, 1 );
					if ( !isDefined( self.power_cost ) )
					{
						self.power_cost = 0;
					}
					self.power_cost += 200;
				}
				self sethintstring( "" );
				if ( is_true( level.local_doors_stay_open ) || self.target == "lab_secret_hatch" )
				{
					return;
				}

				wait 3;
				self waittill_door_can_close();
				self door_block();
				if ( is_true( self._door_open ) )
				{
					self door_opened( cost, 1 );
				}
				self sethintstring( &"ZOMBIE_NEED_LOCAL_POWER" );
				wait 3;
				continue;
			case "electric_door":
				if ( !is_true( self.power_on ) )
				{
					self waittill( "power_on" );
				}
				if ( !is_true( self._door_open ) )
				{
					self door_opened( cost, 1 );
					if ( !isDefined( self.power_cost ) )
					{
						self.power_cost = 0;
					}
					self.power_cost += 200;
				}
				self sethintstring( "" );
				if ( is_true( level.local_doors_stay_open ) )
				{
					return;
				}
				wait 3;
				self waittill_door_can_close();
				self door_block();
				if ( is_true( self._door_open ) )
				{
					self door_opened( cost, 1 );
				}
				self sethintstring( &"ZOMBIE_NEED_POWER" );
				wait 3;
				continue;
			case "electric_buyable_door":
				flag_wait( "power_on" );
				self set_hint_string( self, "default_buy_door", cost );
				if ( !self door_buy() )
				{
					continue;
				}
				break;
			case "delay_door":
				if ( !self door_buy() )
				{
					continue;
				}
				self door_delay();
				break;
			default:
				if ( isDefined( level._default_door_custom_logic ) )
				{
					self [[ level._default_door_custom_logic ]]();
					break;
				}
				if ( !self door_buy() )
				{
					continue;
				}
				break;
			}
			self door_opened( cost );
			if ( !flag( "door_can_close" ) )
			{
				break;
			}
	}
}
