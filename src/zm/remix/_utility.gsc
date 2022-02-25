#include common_scripts/utility;

create_dvar( dvar, set )
{
    if( getDvar( dvar ) == "" )
		setDvar( dvar, set );
}

chat_command( message, player )
{
    level waittill( "say", message, player, isHidden );
}