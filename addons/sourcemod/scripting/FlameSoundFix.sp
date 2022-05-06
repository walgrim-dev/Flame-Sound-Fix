#pragma semicolon 1

#include <sdkhooks>
#include <sdktools_functions>
#include <sourcemod>
#pragma newdecls required

public Plugin myinfo =
{
	name        = "[TF2] FlameSoundFix",
	author      = "Walgrim",
	description = "Fix the annoying flame sound on player hurt",
	version     = "1.1",
	url         = "http://steamcommunity.com/id/walgrim/"
};

/*
** If it's a tf_projectile_rocket or tf_projectile_sentryrocket.
** Hook when this projectile spawns.
*******************************************************************************/
public void OnEntityCreated(int entity, const char[] classname)
{
	if ((StrEqual(classname, "tf_projectile_rocket") || StrEqual(classname, "tf_projectile_sentryrocket")))
	{
		SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher", -1);
		SetEntPropEnt(entity, Prop_Send, "m_hLauncher", -1);
		int m_hOriginal = GetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher");
		int m_hLauncher = GetEntPropEnt(entity, Prop_Send, "m_hLauncher");
		PrintToChatAll("Original launcher = %i, actual launcher = %i", m_hOriginal, m_hLauncher);
	}
}

public void OnEntityDestroyed(int entity)
{
	char classname[32];
	GetEntPropString(entity, Prop_Data, "m_iClassname", classname, sizeof(classname));
	if (StrEqual(classname, "tf_projectile_rocket") || StrEqual(classname, "tf_projectile_sentryrocket"))
	{
		int m_hOriginal = GetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher");
		int m_hLauncher = GetEntPropEnt(entity, Prop_Send, "m_hLauncher");
		PrintToChatAll("Destruction: Original launcher = %i, actual launcher = %i", m_hOriginal, m_hLauncher);
	}
}