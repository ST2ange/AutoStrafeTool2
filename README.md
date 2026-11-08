# AutoStrafeTool2

L4D2（求生之路 2）服务端 SourceMod 插件：空中自动加速、连跳、摆动模拟，以及僵尸 / 特感 / Witch 避让。

## 安装

见 [安装说明.txt](安装说明.txt)。

简版：把 `addons` 和 `cfg` 两个文件夹拖进 `...\Left 4 Dead 2\left4dead2\`，合并覆盖即可。

## 文件

```
addons/sourcemod/plugins/AutoStrafeTool2.smx      插件本体
addons/sourcemod/gamedata/AutoStrafeTool2.games.txt  引擎函数地址（不能缺）
cfg/sourcemod/AutoStrafeTool2.cfg                默认参数
```

## 依赖

- SourceMod 1.12 或更新（DHooks 自 1.10 起内置）

## 用法

| 指令 | 作用 |
| --- | --- |
| `!asm` | 打开游戏内菜单（数字键切功能，0 退出） |
| `!aszl` | 指令清单 |
| `!aszt` | 状态面板 |
| `!as` / `!asbx` / `!mn` / `!mnbt` | 普通 / 八向 / 整跳 / 半跳模式 |

所有参数都是 `sm_autostrafe_` 前缀，配置文件 `cfg/sourcemod/AutoStrafeTool2.cfg`。

## 许可

仅供学习与个人服务器使用，请勿用于商业用途。
