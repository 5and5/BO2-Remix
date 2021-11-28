#include common_scripts/utility;

move_struct_dvar( x, y, z, a )
{
	if ( getDvar("x") == "")
		setDvar("x", x);
	if ( getDvar("y") == "")
		setDvar("y", y);
	if ( getDvar("z") == "")
		setDvar("z", z);
	if ( getDvar("a") == "")
		setDvar("a", a);

	prev_x = 0;
	prev_y = 0;
	prev_z = 0;
	prev_a = 0;

	flag_wait( "start_zombie_round_logic" );

	// if( !isDefined(struct))
	// {
	// 	struct = [];
	// 	structs = [];
	// }

	// structs = getstructarray( "zm_perk_machine", "targetname" );
	// for( i = 0; i < structs.size; i++ )
	// {
	// 	if( structs[i].script_noteworthy == "specialty_fastreload" )
	// 	{
	// 		struct = structs[i];
	// 	}
	// }

	while(1)
	{	
		x = getDvar("x");
		y = getDvar("y");
		z = getDvar("z");
		a = getDvar("a");

		if( prev_x != x || prev_y != y || prev_z != z || prev_a != a )
		{
			prev_x = x; prev_y = y; prev_z = z; prev_a = a;

			level.townPerk[ "specialty_fastreload" ].origin = (x, y, z);
			level.townPerk[ "specialty_fastreload" ].angle = ( 0, a, 0 );
		}

		wait 0.1;
	}
}