#!/usr/bin/env lua

local w = weechat
w.register("weespeak", "npmiller", "0.1", "GPL3", "Pass irc messages to espeak", "", "")

function cmd_str(cmd)
	--The ascii char for start of heading with code 1 is used to indicate commands
	return string.char(1) .. cmd
end

function nick_to_pitch(nick)
	count = 0
	for i=1,#nick do
		count = count + string.byte(nick, i)
	end
	return count % 100
end

function msg_callback(data, signal, signal_data)
	dic = w.info_get_hashtable("irc_message_parse", {message = signal_data})
	pos, _ = string.find(dic.arguments, ':')
	msg = string.sub(dic.arguments, pos+1, -1)
	if string.sub(msg, 1,7) == cmd_str('ACTION') then
		msg = dic.nick .. string.sub(msg, 8, -1)
	end
	w.hook_process_hashtable("espeak",
		{ arg1 = "-v", arg2 = "fr",
		  arg3 = "-p", arg4 = nick_to_pitch(dic.nick),
		  arg5 = msg },
		0, "", "")
	return w.WEECHAT_RC_OK
end

msg_hook = w.hook_signal("*,irc_in2_privmsg", "msg_callback", "")

