fx_version  'cerulean'
games       { 'gta5' }
author      'Akkariin'
description 'FiveM 国服联合封禁系统'
version     '1.0.0'
server_only 'yes'

server_scripts {
    'config.lua',
    'server.lua',
}

server_exports {
    'IsPlayerBanned',
    'IsSteamBanned',
    'IsLicenseBanned',
    'IsIpBanned',
    'IsDiscordBanned',
    'IsXblBanned',
    'IsLiveBanned',
    'IsFivemBanned',
    'GetRawBanData',
    'UpdateBanData',
    'LocalBanPlayer',
    'LocalBanOffline',
    'LocalUnban',
}
