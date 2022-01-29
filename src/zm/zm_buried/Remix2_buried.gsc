#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

#include scripts/zm/remix/_debug;
#include scripts/zm/zm_buried/remix/_zm_ai_sloth;

main()
{
    override_sloth_damage_func();

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
            self.initial_spawn_buried = false;
        }

        if(level.initial_spawn_buried)
        {
            level.initial_spawn_buried = false;
        }
    }
}