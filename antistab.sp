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
Handle sm_antistab_color_alpha;
float stabdmg;
float dmgtimer;
int red;
int green;
int blue;
int alpha;

enum FX
{
	FxNone = 0,
	FxPulseFast,
	FxPulseSlowWide,
	FxPulseFastWide,
	FxFadeSlow,
	FxFadeFast,
	FxSolidSlow,
	FxSolidFast,
	FxStrobeSlow,
	FxStrobeFast,
	FxStrobeFaster,
	FxFlickerSlow,
	FxFlickerFast,
	FxNoDissipation,
	FxDistort,               // Distort/scale/translate flicker
	FxHologram,              // kRenderFxDistort + distance fade
	FxExplode,               // Scale up really big!
	FxGlowShell,             // Glowing Shell
	FxClampMinScale,         // Keep this sprite from getting very small (SPRITES only!)
	FxEnvRain,               // for environmental rendermode, make rain
	FxEnvSnow,               //  "        "            "    , make snow
	FxSpotlight,     
	FxRagdoll,
	FxPulseFastWider,
}

enum Render
{
	Normal = 0, 		// src
	TransColor, 		// c*a+dest*(1-a)
	TransTexture,		// src*a+dest*(1-a)
	Glow,				// src*a+dest -- No Z buffer checks -- Fixed size in screen space
	TransAlpha,			// src*srca+dest*(1-srca)
	TransAdd,			// src*a+dest
	Environmental,		// not drawn, used for environmental effects
	TransAddFrameBlend,	// use a fractional frame value to blend between animation frames
	TransAlphaAdd,		// src + dest*(1-a)
	WorldGlow,			// Same as kRenderGlow but not fixed size in screen space
	None,				// Don't render.
}

bool hurt[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name = "Anti-Backstab for HNS",
	author = "Mando",
	description = "Blocks backstabs and grants knife immunity after getting stabbed.",
	version = PLUGIN_VERSION,
	url = "https://github.com/MandoCSGO"
}

public void OnPluginStart()
{
	sm_antistab_damage = CreateConVar("sm_antistab_damage", "55.0", "The damage limit for all stabs. (Default: 55.0)");
	sm_antistab_timer = CreateConVar("sm_antistab_timer", "5.0", "The length of knife immunity after getting stabbed. (Default: 5.0)");
	sm_antistab_color_red = CreateConVar("sm_antistab_color_red", "0", "Red color value for knife immunity glow. (Default: 0)");
	sm_antistab_color_green = CreateConVar("sm_antistab_color_green", "255", "Green color value for knife immunity glow. (Default: 255)");
	sm_antistab_color_blue = CreateConVar("sm_antistab_color_blue", "0", "Blue color value for knife immunity glow. (Default: 0)");
	sm_antistab_color_alpha = CreateConVar("sm_antistab_color_alpha", "120", "Alpha value for knife immunity glow. (Default: 120)");
	
	stabdmg = GetConVarFloat(sm_antistab_damage);
	dmgtimer = GetConVarFloat(sm_antistab_timer);
	red = GetConVarInt(sm_antistab_color_red);
	green = GetConVarInt(sm_antistab_color_green);
	blue = GetConVarInt(sm_antistab_color_blue);
	alpha = GetConVarInt(sm_antistab_color_alpha);
	
	AutoExecConfig(true, "plugin.antistab");
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

    if (damage > stabdmg)
    {
        char weapon[64];
        GetClientWeapon(attacker, weapon, sizeof(weapon));
        if (StrContains(weapon, "knife"))
        {
            if (hurt[victim])
			{
				return Plugin_Handled
			}
            damage = stabdmg
            SetEntityRenderColor(victim, red, green, blue, alpha);
            CreateTimer(dmgtimer, RemoveProtection, victim);
            hurt[victim] = true
            return Plugin_Changed 
        }
    }
    return Plugin_Continue
}

public Action RemoveProtection(Handle timer, any victim)
{
	if(IsClientInGame(victim))
	{
		SetEntityRenderColor(victim, 255, 255, 255, 255);
		hurt[victim] = false
	}
	return Plugin_Continue
}