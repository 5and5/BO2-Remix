#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

main()
{
    //replaceFunc( maps/mp/zm_tomb::include_weapons, ::include_weapons_override );

    level.initial_spawn_buried = true;
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
    self.initial_spawn_buried = true;
    
    for(;;)
    {
        self waittill("spawned_player");

        if(self.initial_spawn_buried)
		{
            self.initial_spawn_buried = true;
        }

        if(level.initial_spawn_buried)
        {
            level.initial_spawn_buried = false;
        }
    }
}