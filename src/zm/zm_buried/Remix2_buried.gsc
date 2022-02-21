#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_perks;

#include scripts/zm/remix/_debug;
#include scripts/zm/zm_buried/remix/_buried_ai_sloth;
#include scripts/zm/zm_buried/remix/_buried_buildables;
#include scripts/zm/zm_buried/remix/_buried_weapons;
#include scripts/zm/zm_buried/remix/_buried_zones;


main()
{
    replaceFunc( maps/mp/zombies/_zm_perks::give_random_perk, ::give_random_perk_override );

    level.initial_spawn_buried = true;
    level thread onplayerconnect();
	
	level thread spawn_turbine_bench( (457.209, -489, 8.125), ( 0, 0, 0 ) );
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
    self.initial_spawn_buried = true;

    for(;;)
    {
        self waittill("spawned_player");

        if(self.initial_spawn_buried)
		{
            self.initial_spawn_buried = false;

			//debug
			// self thread print_origin();
			// self thread teleport_players((-293.211, -1193.89, 187.517));
        }

        if(level.initial_spawn_buried)
        {
            level.initial_spawn_buried = false;

			remove_barricade_jug();
			level thread override_sloth_damage_func();
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

give_random_perk_override() //checked partially changed to match cerberus output
{
	random_perk = undefined;
	vending_triggers = getentarray( "zombie_vending", "targetname" );
	perks = [];
	i = 0;
	while ( i < vending_triggers.size )
	{
		perk = vending_triggers[ i ].script_noteworthy;
		if ( isDefined( self.perk_purchased ) && self.perk_purchased == perk )
		{
			i++;
			continue;
		}
		if ( perk == "specialty_weapupgrade" )
		{
			i++;
			continue;
		}
		if ( !self hasperk( perk ) && !self has_perk_paused( perk ) )
		{
			perks[ perks.size ] = perk;
		}
		i++;
	}
	if ( perks.size > 0 )
	{
		perks = array_randomize( perks );
		random_perk = perks[ 0 ];
		while ( random_perk == "specialty_nomotionsensor" && perks.size > 1 )
		{
			perks = array_randomize( perks );
			random_perk = perks[ 0 ];
		}
		self give_perk( random_perk );
	}
	else
	{
		self playsoundtoplayer( level.zmb_laugh_alias, self );
	}
	return random_perk;
}