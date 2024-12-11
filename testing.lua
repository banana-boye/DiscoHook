local Hooker = require("OrionHook")
local webhook = Hooker.create("https://discord.com/api/webhooks/1316102809002836059/B_2l6RncV-J8dUwXGSHl7r2v0f0o1K5sXi8ckZO45cK8pczq6_vaL7ELbn8gn3RJLEvE")

local message = webhook:sendMessage("Emoji here")
os.sleep(5)

print(webhook:getMessage(message and message or 0).author.id)