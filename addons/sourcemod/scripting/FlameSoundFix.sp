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
		SDKHook(entity, SDKHook_Touch, killRocketEntity);
	}
}

public Action killRocketEntity(int entity, int other)
{
	if (other > MaxClients || other < 1)
	{
		return Plugin_Continue;
	}
	if (IsValidEntity(entity) && entity != -1)
	{
		float vOrigin[3];
		float vAngleRotation[3];
		float damage      = GetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected") + 4);
		int   ref         = EntIndexToEntRef(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"));
		int   deflections = GetEntProp(entity, Prop_Send, "m_iDeflected");
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", vOrigin);
		GetEntPropVector(entity, Prop_Data, "m_angRotation", vAngleRotation);
		// We create our explosion
		CreateExplosion(vOrigin, vAngleRotation, ref, damage, deflections, entity);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

void CreateExplosion(float vOrigin[3], float vAngleRotation[3], int ref, float damage, int deflections, int entity)
{
	char damageBuffer[16];
	char damageForce[32];
	int  owner = EntRefToEntIndex(ref);

	FloatToString(damage, damageBuffer, sizeof(damageBuffer));
	FloatToString(damage * 2.0, damageForce, sizeof(damageForce));

	int explosion = CreateEntityByName("env_explosion");
	if (IsValidEntity(explosion) && explosion != -1)
	{
		SetEntityFlags(explosion, 17172);
		SetEntPropEnt(explosion, Prop_Data, "m_hEffectEntity", GetEntPropEnt(entity, Prop_Data, "m_hEffectEntity"));
		SetEntPropEnt(explosion, Prop_Data, "m_hOwnerEntity", (deflections > 0) ? owner : -1);
		SetEntPropEnt(explosion, Prop_Data, "m_hInflictor", entity);
		SetEntProp(explosion, Prop_Data, "m_iTeamNum", GetClientTeam(owner));
		DispatchKeyValue(explosion, "iMagnitude", damageBuffer);
		DispatchKeyValue(explosion, "iRadiusOverride", "100");
		DispatchKeyValue(explosion, "DamageForce", damageForce);
		DispatchSpawn(explosion);
		TeleportEntity(explosion, vOrigin, vAngleRotation, NULL_VECTOR);
		AcceptEntityInput(explosion, "Explode");
		AcceptEntityInput(entity, "Kill");
		AcceptEntityInput(explosion, "Kill");
	}
}