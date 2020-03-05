#!/usr/bin/expect

spawn ssh -oBatchMode=no -oStrictHostKeyChecking=no bbsu@ptt.cc

set BBS_ID "Account"
set BBS_PW "Password"

expect {
    "請輸入代號" { send "$BBS_ID\r" ; exp_continue }
    "請輸入您的密碼" { send "$BBS_PW\r" ; exp_continue }
    "您想刪除其他重複登入的連線嗎" { send "N\r" ; exp_continue }
    "您要刪除以上錯誤嘗試的記錄嗎" { send "N\r" ; exp_continue }
    "任意鍵繼續" { send "q\r" ; exp_continue }
    "密碼不對喔" { exit }
    "裡沒有這個人啦" { exit }
    "請勿頻繁登入以免造成系統過度負荷" { send "\r" ; exp_continue }
    "請按任意鍵繼續" { send "\r" ; exp_continue }
    "oodbye" { interact }
}

exit 0
