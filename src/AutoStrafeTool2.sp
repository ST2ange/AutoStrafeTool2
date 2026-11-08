/**
 * AutoStrafeTool2  v2.7.3
 * L4D2（求生之路 2）服务端 SourceMod 插件
 *
 * 空中自动加速 / 自动连跳 / 整跳与半跳摆动模拟 / 僵尸·特感·Witch 避让 / 甩视角强拐
 *
 * ---------------------------------------------------------------------------
 * 本文件是插件的公开接口层：插件声明、ConVar 注册、指令入口。
 *
 * 核心实现不在本仓库发布，包括：
 *   - 空中加速的最优偏航角推导与临界角判定
 *   - 整跳 / 半跳的摆动相位模型与折返时机
 *   - 避让目标的扫描、权重与换边迟滞
 *   - 甩视角强拐的门槛与方向推断
 *
 * 可直接使用的编译产物见 addons/sourcemod/plugins/AutoStrafeTool2.smx
 * 参数含义与默认值见 cfg/sourcemod/AutoStrafeTool2.cfg 与 功能详解.txt
 *
 * 作者：ST2ange
 *   Steam    https://steamcommunity.com/id/ST2ange/
 *   Bilibili https://space.bilibili.com/399718078
 * ---------------------------------------------------------------------------
 */

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>

#define PLUGIN_VERSION "2.7.3"

public Plugin myinfo =
{
	name        = "AutoStrafeTool2",
	author      = "ST2ange",
	description = "L4D2 服务端空中自动加速 / 连跳 / 摆动模拟 / 僵尸特感 Witch 避让",
	version     = PLUGIN_VERSION,
	url         = "https://github.com/ST2ange/AutoStrafeTool2"
};

// ── 配置句柄 ────────────────────────────────────────────────────────────────
// 默认值与取值范围见 cfg/sourcemod/AutoStrafeTool2.cfg

ConVar g_cvMode;          // 当前模式：0 关 / 1 普通 / 2 八向 / 3 整跳 / 4 半跳
ConVar g_cvPower;         // 加速力度档位 1-5
ConVar g_cvPowerRaw;      // 加速力度数值模式 1-13980
ConVar g_cvBhop;          // 自动连跳
ConVar g_cvAvoidMob;      // 避让开关
ConVar g_cvAvoidDeg;      // 避让触发角度
ConVar g_cvFlickRate;     // 甩视角强拐触发门槛
ConVar g_cvMnCam;         // 整跳模式是否接管视角
ConVar g_cvAutoOnJoin;    // 进服自动开加速
ConVar g_cvAutoBhopJoin;  // 进服自动开连跳

// 上述句柄由未公开的实现模块读取，此处声明后不直接引用
#pragma unused g_cvMode, g_cvPower, g_cvPowerRaw, g_cvBhop, g_cvAvoidMob, \
               g_cvAvoidDeg, g_cvFlickRate, g_cvMnCam, g_cvAutoOnJoin, g_cvAutoBhopJoin

// ── 生命周期 ────────────────────────────────────────────────────────────────

public void OnPluginStart()
{
	CreateConVar( "sm_autostrafe_version", PLUGIN_VERSION,
		"AutoStrafeTool2 版本号", FCVAR_NOTIFY | FCVAR_DONTRECORD );

	g_cvMode          = CreateConVar( "sm_autostrafe_mode",      "0",   "0=关 1=普通 2=八向 3=整跳 4=半跳", FCVAR_NOTIFY );
	g_cvPower         = CreateConVar( "sm_autostrafe_power",     "4",   "加速力度档位 1-5", FCVAR_NOTIFY );
	g_cvPowerRaw      = CreateConVar( "sm_autostrafe_power_raw", "0",   "加速力度数值模式，0 表示使用档位", FCVAR_NOTIFY );
	g_cvBhop          = CreateConVar( "sm_autostrafe_bhop",      "1",   "自动连跳", FCVAR_NOTIFY );
	g_cvAvoidMob      = CreateConVar( "sm_autostrafe_avoid_mob", "1",   "僵尸 / 特感 / Witch 避让", FCVAR_NOTIFY );
	g_cvAvoidDeg      = CreateConVar( "sm_autostrafe_avoid_deg", "75",  "避让触发角度", FCVAR_NOTIFY );
	g_cvFlickRate     = CreateConVar( "sm_autostrafe_flick_rate","200", "甩视角强拐触发门槛", FCVAR_NOTIFY );
	g_cvMnCam         = CreateConVar( "sm_autostrafe_mn_cam",    "0",   "整跳模式是否接管视角", FCVAR_NOTIFY );
	g_cvAutoOnJoin    = CreateConVar( "sm_autostrafe_auto_on",   "1",   "进服自动开加速", FCVAR_NOTIFY );
	g_cvAutoBhopJoin  = CreateConVar( "sm_autostrafe_auto_bhop", "1",   "进服自动开连跳", FCVAR_NOTIFY );

	AutoExecConfig( true, "AutoStrafeTool2" );

	// ── 聊天 / 控制台指令 ──
	RegConsoleCmd( "sm_as",      Cmd_Strafe,    "普通模式" );
	RegConsoleCmd( "sm_asbx",    Cmd_EightWay,  "八向模式" );
	RegConsoleCmd( "sm_mn",      Cmd_MnJump,    "整跳模拟" );
	RegConsoleCmd( "sm_mnbt",    Cmd_HalfJump,  "半跳模拟" );
	RegConsoleCmd( "sm_asm",     Cmd_Menu,      "打开设置菜单" );
	RegConsoleCmd( "sm_aszt",    Cmd_Status,    "状态面板" );
	RegConsoleCmd( "sm_aszl",    Cmd_List,      "指令清单" );
	RegConsoleCmd( "sm_ascvar",  Cmd_CvarList,  "按分组列出全部参数" );
	RegConsoleCmd( "sm_ab",      Cmd_Bhop,      "自动连跳开关" );
	RegConsoleCmd( "sm_asd",     Cmd_Power,     "加速力度档位 1-5" );
	RegConsoleCmd( "sm_asz",     Cmd_PowerRaw,  "加速力度数值 1-13980" );
}

// ── 指令入口 ────────────────────────────────────────────────────────────────
// 各指令的具体行为由未公开的实现模块接管，此处只保证指令可注册、可响应。

public Action Cmd_Strafe( int client, int args )    { return DispatchCommand( CmdKind_Normal,    client, args ); }
public Action Cmd_EightWay( int client, int args )  { return DispatchCommand( CmdKind_EightWay,  client, args ); }
public Action Cmd_MnJump( int client, int args )    { return DispatchCommand( CmdKind_MnJump,    client, args ); }
public Action Cmd_HalfJump( int client, int args )  { return DispatchCommand( CmdKind_HalfJump,  client, args ); }

public Action Cmd_Menu( int client, int args )      { return DispatchCommand( CmdKind_Menu,      client, args ); }
public Action Cmd_Status( int client, int args )    { return DispatchCommand( CmdKind_Status,    client, args ); }
public Action Cmd_List( int client, int args )      { return DispatchCommand( CmdKind_List,      client, args ); }
public Action Cmd_CvarList( int client, int args )  { return DispatchCommand( CmdKind_CvarList,  client, args ); }
public Action Cmd_Bhop( int client, int args )      { return DispatchCommand( CmdKind_Bhop,      client, args ); }
public Action Cmd_Power( int client, int args )     { return DispatchCommand( CmdKind_Power,     client, args ); }
public Action Cmd_PowerRaw( int client, int args )  { return DispatchCommand( CmdKind_PowerRaw,  client, args ); }

// 统一分派：按指令种类转到空中加速 / 摆动相位 / 避让决策 / 菜单渲染各模块。
// 这部分实现不在本仓库发布。
static Action DispatchCommand( int kind, int client, int args )
{
#pragma unused kind, client, args

	return Plugin_Handled;
}

// ── 模式与指令枚举 ──────────────────────────────────────────────────────────

enum
{
	CmdKind_Normal = 1,
	CmdKind_EightWay,
	CmdKind_MnJump,
	CmdKind_HalfJump,
	CmdKind_Menu,
	CmdKind_Status,
	CmdKind_List,
	CmdKind_CvarList,
	CmdKind_Bhop,
	CmdKind_Power,
	CmdKind_PowerRaw
};
