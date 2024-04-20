# ✨ Journal

Logging makes easy and efficient! 

Install using wally: 

```toml
Journal = "shards-tech/journal@0.1.0"
```

Simple use of case in Knit:

```lua
local MyService = Knit.CreateService({
    Name = "MyService",
    Journal = Journal.new("MyService")
})

function MyService:KnitInit()
    local Journal = self.Journal :: typeof(Journal.new())
    local GreetCtx = Journal:useContext("greet")

    GreetCtx:atLog("Hello there!") --> [MyService] :: log(greet) -> Hello there!
    Journal:atLog("Hello Journals!") --> [MyService] :: log -> Hello Journals!
end
```

## 📃 Documentation

Types:

```lua
type Journal = {
    JournalId: string, -- The placeholder.
    Schema: string,
    Context: string?,
    State: boolean, -- State of the Journal
}
```

1. Using `Journal.setGlobalSchema(Schema: string)` 

For example:

```lua
Journal.setGlobalSchema("[%s] :: %s -> %s") -- Default schema.

local App = Journal.new("App")

App:atLog("Hello, World") --> [App] :: log -> Hello, World
```

2. Using `Journal.new(JournalId: string, Schema: string?)` returns `self`

For example:

```lua
local App = Journal.new("App")
```

3. Using `Journal:atDebug(Message: string)`

For example:

```lua
local App = Journal.new("App")

App:atDebug("Here.") --> [App] :: debug -> Here.
-- The exact same as atLog, but use debug for pin pointing problems for developer.
```

4. Using `Journal:atLog(Message: string)`

For example:

```lua
local App = Journal.new("App")

App:atLog("Hello, World!") --> [App] :: log -> Hello, World!    
```

5. Using `Journal:atSuccess(Message: string)`

For example:

```lua
local App = Journal.new("App")

App:atSuccess("Player purchase success")
-- Again It's like atLog, but atSuccess can be used to log
-- a successful attempt at stuff.
```

6. Using `Journal:atWarn(Message: string)`

For example:

```lua
local App = Journal.new("App")

App:atWarn("Failed to fetch api data :(") 
--> [App] :: warn -> Failed to fetch api data :(
```

7. Using `Journal:atError(Message: string)`

For example:

```lua
local App = Journal.new("Error")
local AssetsCtx = App:useContext("assets")

App:atError("Failed to load experience sounds as is invalid!", "assets")
--> [App] :: error(assets) -> Failed to load experience sounds as is invalid! <traceback>
```

8. Using `Journal:atFatal(Message: string)`

For example:

```lua
local App = Journal.new("App")
local DataLoaderCtx = App:useContext("data")

-- Give a fatal message cause of datastore cannot load
-- Causing players not saving any data.
DataLoaderCtx:atFatal("Failed to load datastores.")
--> [App] :: fatal(data) -> Failed to load datastores. <traceback>
```

9. Using `Journal:useContext(Context: string)` returns `self`

For example:

```lua
local App = Journal.new("App")
local HttpCtx = App:useContext("http")

HttpCtx:atLog("Fetching some data..")
--> [App] :: log(http) -> Fetching some data..
App:atLog("A test log")
--> [App] :: log -> A test log
```

10. Using `Journal:setState(Trigger: boolean)`

For example:

```lua
local App = Journal.new("App")
local Ctx = App:useContext("Ctx")

Ctx:setState(false)

Ctx:atLog("Hello, World") --> Doesn't show anything.
App:atLog("This does work") --> Prints out 
--> [App] :: log -> This does work
```