#pragma semicolon 1

#include <sdkhooks>
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
	if (!(StrEqual(classname, "tf_projectile_rocket") || StrEqual(classname, "tf_projectile_sentryrocket")))
	{
		return;
	}
	SDKHook(entity, SDKHook_Spawn, OnRocketSpawn);
}

/*
** Verify if this one is valid, set it as a BaseProjectile (if I'm not wrong).
** Just unhook it at the end to avoid bugs (or double Hook I guess).
*******************************************************************************/
public Action OnRocketSpawn(int entity)
{
	if (IsValidEntity(entity))
	{
		int m_hOriginal = GetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher");
		int m_hLauncher = GetEntPropEnt(entity, Prop_Send, "m_hLauncher");
		PrintToChatAll("Original launcher = %i, actual launcher = %i", m_hOriginal, m_hLauncher);
	}
}
