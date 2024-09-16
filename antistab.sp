#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>

#define PLUGIN_VERSION "1.0"

Handle sm_antistab_damage;
Handle sm_antistab_timer;
Handle sm_antistab_color_red;
Handle sm_antistab_color_green;
Handle sm_antistab_color_blue;
float antistab_damage;
float antistab_timer;
int antistab_color_red;
int antistab_color_green;
int antistab_color_blue;
bool hurt[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name = "Anti-Backstab for HNS",
	author = "Mando",
	description = "Blocks backstabs and grants knife immunity after getting stabbed.",
	version = PLUGIN_VERSION,
	url = "https://github.com/MandoCSGO",
}

public void OnPluginStart()
{
	sm_antistab_damage = CreateConVar("sm_antistab_damage", "55.0", "Damage limit for all stabs.");
	sm_antistab_timer = CreateConVar("sm_antistab_timer", "5.0", "Length of knife immunity after getting stabbed.");
	sm_antistab_color_red = CreateConVar("sm_antistab_color_red", "0", "Red color value for knife immunity glow.");
	sm_antistab_color_green = CreateConVar("sm_antistab_color_green", "255", "Green color value for knife immunity glow.");
	sm_antistab_color_blue = CreateConVar("sm_antistab_color_blue", "0", "Blue color value for knife immunity glow.");
	
	AutoExecConfig(true, "antistab");
}

public void OnClientPutInServer(client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
    hurt[client] = false;
}

public void OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	hurt[client] = false;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (victim < 1 || victim > MaxClients || attacker < 1 || attacker > MaxClients)
        return Plugin_Continue;

    if (damage > antistab_damage)
    {
        char weapon[64];
        GetClientWeapon(attacker, weapon, sizeof(weapon));
        if (StrContains(weapon, "knife"))
        {
            if (hurt[victim])
			{
				return Plugin_Handled;
			}
            antistab_damage = GetConVarFloat(sm_antistab_damage);
            antistab_timer = GetConVarFloat(sm_antistab_timer);
            antistab_color_red = GetConVarInt(sm_antistab_color_red);
            antistab_color_green = GetConVarInt(sm_antistab_color_green);
            antistab_color_blue = GetConVarInt(sm_antistab_color_blue);
            damage = antistab_damage;
            SetEntityRenderColor(victim, antistab_color_red, antistab_color_green, antistab_color_blue, 255);
            CreateTimer(antistab_timer, RemoveProtection, victim);
            hurt[victim] = true;
            return Plugin_Changed;
        }
    }
    return Plugin_Continue;
}

public Action RemoveProtection(Handle timer, any victim)
{
	if(IsClientInGame(victim))
	{
		SetEntityRenderColor(victim, 255, 255, 255, 255);
		hurt[victim] = false;
	}
	return Plugin_Continue;
}