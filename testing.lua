local Hooker = require("OrionHook")
local webhook = Hooker.create("https://discord.com/api/webhooks/1316102809002836059/B_2l6RncV-J8dUwXGSHl7r2v0f0o1K5sXi8ckZO45cK8pczq6_vaL7ELbn8gn3RJLEvE")

print(webhook:sendMessage("Testing"))