require("botApiLua")

bot = Bot.create("BOT TOKEN")
chat_id = 123
text = ""

while true do
    bot.send_message(chat_id, text)
end