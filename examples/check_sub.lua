require("botApiLua")

bot = Bot.create("BOT TOKEN")
chat_id = 123
user_id = 123

if bot.get_chat_member(chat_id, user_id) then
    gg.alert("successfully")
else
    os.exit(print("sub not found"))
end
