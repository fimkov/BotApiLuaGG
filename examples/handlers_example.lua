require("botApiLua")

bot = Bot.create("BOT TOKEN")

function start(message)
    bot.send_message(message.chat.id, "Hello!", "HTML", message.message_id) -- send message "Hello!"
end

function help(message)
    bot.send_message(message.chat.id, "This is example of <a href='fimkov.github.io'>GG-BotApi</a>", "HTML", message.message_id) -- send message "Hello!"
end

bot.handlers.register_handler({
    ["type"] = "message",
    ["text"] = "/start",
    ["function"] = start
})

bot.handlers.register_handler({
    ["type"] = "message",
    ["text"] = "/help",
    ["function"] = help
})

bot.mainloop(1) -- 1 is delay between updates