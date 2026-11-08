# AutoStrafeTool2

L4D2（求生之路 2）服务端 SourceMod 插件：空中自动加速、连跳、摆动模拟，以及僵尸 / 特感 / Witch 避让。

- **Steam**：STᗜ ‸ ᗜGE — https://steamcommunity.com/id/ST2ange/
- **Bilibili**：剑聖STR様 — https://space.bilibili.com/399718078

问题反馈、功能建议、更新通知都在这两个地方。

---

## 安装

完整步骤见 **[安装说明.txt](安装说明.txt)**。

简版：把 `addons` 和 `cfg` 两个文件夹拖进 `...\Left 4 Dead 2\left4dead2\`，合并覆盖即可。

```
left4dead2\addons\sourcemod\plugins\AutoStrafeTool2.smx          插件本体
left4dead2\addons\sourcemod\gamedata\AutoStrafeTool2.games.txt   引擎函数地址（不能缺）
left4dead2\cfg\sourcemod\AutoStrafeTool2.cfg                     默认参数
```

依赖：SourceMod 1.12+（DHooks 自 1.10 起内置）。

---

## 最重要的一个指令：`!asm`

**`!asm` 打开游戏内菜单**，装完先按它看一眼，所有设置都能在里面点。

```
第 1 页（功能）              第 2 页（模块 + 常用开关）
1. 普通模式 [开]             1. 跳跃设置 >
2. 八向模式 [关]             2. 避障设置 >
3. 整跳模拟 [开]             3. 强拐设置 >
4. 半跳模拟 [关]             4. 整跳设置 >
5. 自动连跳 [开]             5. 接管视角 [开]
6. 加速力度 4档 >            6. 避障 [开]
7. 进服自动开加速 [开]        7. 强拐 [关]
8. 进服自动开连跳 [开]        8. 查看指令说明
9. 下一页 > 模块设置          9. 上一页 < 主菜单
```

数字键直接切，`0` 退出。开着菜单时鼠标会被释放、视角不能转，站定设置用。

---

## 四个基础模式

插件共四种模式，互斥、后选的覆盖前一个，再选一次关闭。**默认是关的，要自己开一个。**

| 指令 | 名称 | 干什么 |
| --- | --- | --- |
| `!as` | 普通模式 | 空中松开方向键，自动沿**视角方向**加速。最像原版空速，适合保留手感只补空中加速 |
| `!asbx` | 八向模式 | 沿**视角 + 方向键**加速，八个方向任意衔接，转向不断速，适合自由跑图 |
| `!mn` | 整跳模拟 | 模拟真人**前后整跳 / 旋转跳 / 高低差摆动**，跨跳相位连续，像真人在空中摆身 |
| `!mnbt` | 半跳模拟 | 模拟**前后半跳**，每跳从头重摆一遍，观感更"碎" |

不知道选哪个就先 `!mn`，观感最接近真人连跳。

---

## 其它指令

| 指令 | 作用 |
| --- | --- |
| `!aszl` | 指令清单（9 行） |
| `!aszt` | 状态面板（模式 / 力度 / 速度 / 本跳 / 强拐 / 引擎参数） |
| `!ascvar` | 按分组列出全部可调 cvar |
| `!ab` | 自动连跳（按住空格，落地自动再跳） |
| `!asd 1-5` | 加速力度档位（1 最弱 ≈10000/跳，5 最强 13980/跳） |
| `!asz 数值` | 加速力度数值模式（1-13980 自定义） |

控制台用同名指令，`!` 换成 `sm_`：`sm_asm` / `sm_aszt` / `sm_as` / `sm_ab` …

---

## 配置

所有参数都是 `sm_autostrafe_` 前缀，配置文件 `cfg/sourcemod/AutoStrafeTool2.cfg`。

```cfg
sm_autostrafe_mn_cam "0"          // 关掉镜头接管（觉得视角被拽就设 0）
sm_autostrafe_avoid_mob "1"       // 打开僵尸 / 特感 / Witch 避让
sm_autostrafe_flick_rate "200"    // 甩视角强拐的触发门槛
sm_autostrafe_mn_fwd_loop "0"     // 长滞空只折返一次（落地不抽，高低差会偏）
```

改完重进地图，或控制台 `sm plugins reload AutoStrafeTool2`。

---

## 卸载

删掉这三个文件：

```
addons/sourcemod/plugins/AutoStrafeTool2.smx
addons/sourcemod/gamedata/AutoStrafeTool2.games.txt
cfg/sourcemod/AutoStrafeTool2.cfg
```

---

## 许可

仅供学习与个人服务器使用，请勿用于商业用途。
