# GlobalBan
GlobalBan 是一款基于联网同步数据的 FiveM 封禁系统，可以在多个服务器之间共享封禁数据，被封禁的玩家将无法进入所有安装了此插件的服务器。

如果你想提交封禁信息，请创建一个 [Issue](https://github.com/kasuganosoras/globalban/issues) 或者 Fork 本项目然后提交 Pull Request。

在提交封禁信息时，请提供封禁该玩家的理由，并且附带 1~3 张截图作为证据，后续如果该玩家发起申诉时将会以此 Issue 作为判断依据之一。

![Preview Image](https://user-images.githubusercontent.com/34357771/236700105-a6fb69f1-5319-4e7e-a0d3-ecc7d29bed9c.png)

## 特性
- 无需数据库，数据存储在 GitHub 中
- 自动同步数据，支持自定义同步间隔
- 支持根据 SteamID、R 星账户、IP 地址、Discord、Xbox Live、Live ID 以及 FiveM ID 封禁玩家
- 支持本地封禁和云端封禁同时使用

## 安装
1. 前往 [Release](https://github.com/kasuganosoras/globalban/releases) 下载最新版本的 Source Code。
2. 将压缩包内的 `globalban-x.x.x` 文件夹放入服务器的 `resources` 目录。
3. 重命名文件夹为 `globalban`。
4. 在你的 server.cfg 中添加一行 `ensure globalban`。
5. 重启服务器。

## 指令
下方的 `<identifier>` 是玩家的身份标识符，可以是 `steam:`、`license:`、`ip:`、`discord:`、`xbl:`、`live:` 或者 `fivem:` 开头的字符。

在游戏内执行命令需要玩家拥有 `command.指令名称` 权限，例如 `command.localban`。

- `/localban <id> [理由]` 通过游戏 ID 封禁一个在线的玩家
- `/localbanoffline <identifier> [理由]` 通过 SteamID、R 星账户、IP 地址、Discord、Xbox Live、Live ID 以及 FiveM ID 封禁一个离线的玩家
- `/localunban <identifier>` 解封一个玩家

## API
利用 GlobalBan 的 API，你可以在你的脚本中使用 GlobalBan 的功能。

如果需要使用 API，请在 config.lua 中将 `rejectBanned` 设置为 `false`，否则会发生冲突。

### IsPlayerBanned
检查一个玩家是否被封禁，返回值为封禁信息，如果玩家没有被封禁则返回 `false`。

```lua
local banInfo = exports.globalban:IsPlayerBanned(source)
if banInfo then
    print(banInfo.reason)
end
```

### IsSteamBanned
检查一个 SteamID 是否被封禁，返回值为封禁信息，如果 SteamID 没有被封禁则返回 `false`。

```lua
local banInfo = exports.globalban:IsSteamBanned('steam:110000112345678')
if banInfo then
    print(banInfo.reason)
end
```

其他几个函数的用法与 IsSteamBanned 相同。

```lua
IsLicenseBanned('license:xxxxxxxxxxxxxxxxxxxx')
IsIpBanned('ip:xxx.xxx.xxx.xxx')
IsDiscordBanned('discord:xxxxxxxxxxxx')
IsXblBanned('xbl:xxxxxxxxxxxxxxx')
IsLiveBanned('live:xxxxxxxxxxxxxxx')
IsFivemBanned('fivem:xxxxxxxxx')
```

### GetRawBanData
获取原始的封禁数据，返回值为一个包含所有封禁信息的数组。

```lua
local banData = exports.globalban:GetRawBanData()
for _, banInfo in ipairs(banData) do
    print(banInfo.steam, banInfo.reason)
end
```

### UpdateBanData
立即联网更新封禁数据，不返回任何值。

```lua
exports.globalban:UpdateBanData()
```

### LocalBanPlayer
封禁一个在线的玩家，封禁成功返回 `true`，封禁失败返回 `false`。

```lua
local success = exports.globalban:LocalBanPlayer(source, '测试封禁')
if success then
    print('封禁成功')
end
```

### LocalBanOffline
封禁一个离线的玩家，封禁成功返回 `true`，封禁失败返回 `false`。

```lua
local success = exports.globalban:LocalBanOffline('steam:110000112345678', '测试封禁')
if success then
    print('封禁成功')
end
```

## 配置
```lua
Config = {
    -- 是否自动拒绝被封禁的玩家连接服务器（如果为 false 则不执行任何操作，需要自己在其他地方处理）
    rejectBanned   = true,
    
    -- 更新间隔（单位：分钟）设置为 0 则不自动更新
    updateInterval = 5,
    
    -- 是否打印更新日志
    printUpdateLog = true,
    
    -- 本地封禁列表文件名
    localBanData   = "bans-local.json",
    
    -- 封禁列表更新地址
    updateApi      = "https://raw.githubusercontent.com/kasuganosoras/globalban/master/bans.json",
    
    -- 被踢出服务器的提示信息
    banMessage     = "你已被国服联合封禁系统列为封禁用户，无法进入服务器，原因：%s<br>" ..
                     "如需申诉请前往 https://github.com/kasuganosoras/globalban/issues 提交 issue，并携带你的身份信息：" ..
                     "<ul style='margin-top:1em;margin-bottom:1em;'>%s</ul>" ..
                     "（以上内容可鼠标拖选后 Ctrl+C 复制）",
    
    -- 本地封禁提示信息
    localBanMsg    = "你已被服务器封禁，原因：%s<br>如需申诉请联系服务器管理员，并携带你的身份信息：" ..
                     "<ul style='margin-top:1em;margin-bottom:1em;'>%s</ul>" ..
                     "（以上内容可鼠标拖选后 Ctrl+C 复制）",
}
```

## 许可
本项目使用 GPT v3 协议开源，详情请见 [LICENSE](https://github.com/kasuganosoras/globalban/blob/master/LICENSE)。
