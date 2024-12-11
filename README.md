# DiscoHook
Use discord webhooks in Computercraft to your advantage, allowing for sending, deleting, editing and reading.

[Wiki](https://github.com/banana-boye/DiscoHook/wiki/intro)

### Using DiscoHook

Install the API
```bash
wget https://raw.githubusercontent.com/banana-boye/DiscoHook/refs/heads/main/DiscoHook.lua DiscoHook
```

Add Discohook to your code
```lua
local DiscoHook = require("DiscoHook")
```

Now you can create a webhook and have fun from there
```lua
local webhook = Hooker.create("https://discord.com/api/webhooks/1316102809002836059/B_2l6RncV-J8dUwXGSHl7r2v0f0o1K5sXi8ckZO45cK8pczq6_vaL7ELbn8gn3RJLEvE")

local message = webhook:sendMessage("Hello everybody!")

print(webhook:getMessage(message and message or 0).content) --> "Hello everybody!"

webhook:editMessage(message, "Goodbye!")
```

All functions use LuaDoc and cc.expect for ease of use with camelCase (first word starts uncapitalized, rest starts capitalized)
