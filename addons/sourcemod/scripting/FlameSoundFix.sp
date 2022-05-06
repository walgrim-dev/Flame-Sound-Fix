#pragma semicolon 1

#include <sdkhooks>
#include <sdktools>
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
		SDKHook(entity, SDKHook_StartTouch, OnStartTouch);
	}
}

public Action OnStartTouch(int entity, int other)
{
	if (other > 0 && other <= MaxClients)
	{
		SDKHook(entity, SDKHook_Touch, killRocketEntity);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action killRocketEntity(int entity, int other)
{
	if (IsValidEntity(entity) && entity != -1)
	{
		float vOrigin[3];
		int ref = EntIndexToEntRef(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"));
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", vOrigin);
		AcceptEntityInput(entity, "Kill");
		// We create our explosion
		CreateExplosion(vOrigin, ref);
	}
}

Action CreateExplosion(float vOrigin[3], int ref)
{
	int owner = EntRefToEntIndex(ref);
	int explosion = CreateEntityByName("env_explosion");
	if (IsValidEntity(explosion) && explosion != -1)
	{
		SetEntityFlags(explosion, 912);
		SetEntPropEnt(explosion, Prop_Data, "m_hOwnerEntity", owner);
		SetEntProp(explosion, Prop_Data, "m_iTeamNum", GetClientTeam(owner));
		SetEntPropVector(explosion, Prop_Data, "m_vecOrigin", vOrigin);
		DispatchKeyValue(explosion, "iMagnitude", "250");
		DispatchKeyValue(explosion, "iRadiusOverride", "100");
		DispatchSpawn(explosion);
		AcceptEntityInput(explosion, "Explode");
	}
}