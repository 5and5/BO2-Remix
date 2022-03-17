#include common_scripts/utility;

create_dvar( dvar, set )
{
    if( getDvar( dvar ) == "" )
		setDvar( dvar, set );
}

wait_network_frame_override() 
{
	wait 0.05;
}

chat_command( message, player )
{
    level waittill( "say", message, player, isHidden );
}