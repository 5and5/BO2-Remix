
electric_trap_always_kill()
{
	level.etrap_damage = maps/mp/zombies/_zm::ai_zombie_health( 255 );
}

set_claymores_max( max )
{
	level.claymores_max_per_player = max;
}