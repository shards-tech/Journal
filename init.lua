-- Constants --
local DEFAULT_SCHEMA = "[%s] :: %s -> %s"

-- Types --
type Journal = {
    JournalId: string?, -- The placeholder. Default: Journal
    Schema: string?, -- The Message Schema. Default [%s] :: %s -> %s
    Context: string?, -- Journal Context.
    State: boolean, -- State of the Journal
}

-- Module --

--[=[
    Define a Journal class.
]=]
local Journal = {}
Journal.__index = Journal
Journal.Schema = DEFAULT_SCHEMA

local function FormatMessage(JournalId: string, LogLevel: string, Message: string, Schema: string, Context: string?)
    local Level: string = nil

    if Context ~= nil and typeof(Context) == "string" then
        Level = string.format("%s(%s)", LogLevel, string.lower(Context))
    end

    local Formed = string.format(Schema or DEFAULT_SCHEMA, JournalId, Level or LogLevel, Message)

    return Formed
end

--[=[
    Set the global schema. By global means where `Journal` module is required.
    How the formatting of schema works.
    
    `[%s] :: %s -> %s` is the default Journal schema
    Formatted using JournalId or Name, LogLevel, and Message.
]=]
function Journal.setGlobalSchema(Schema: string)
    assert(typeof(JournalId) == "string", "Schema must be a string.")

    Journal.Schema = Schema    
end

--[=[
    Construct a new `Journal` or we could call it `Journalist`. Nah
    
    ---
    Example:

    ```lua
    local App = Journal.new("App")

    App:atLog("Hello, World!") --> [App] :: log -> Hello, World!
    ```
]=]
function Journal.new(JournalId: string?, Schema: string?)
    local self = setmetatable({}, Journal)

    self.JournalId = JournalId or "Journal"
    self.Schema = Schema
    self.State = true
    self.Context = nil

    return self
end

--[=[
    Journal at `Debug` level. Just like `Journal:atLog` but with
    traceback enabled by default.
    
    ---
    Example:
    
    ```lua
    local App = Journal.new("App")

    App:atDebug("Point 1", "problem")
    --[[
        [App] :: debug(problem) -> Point 1
        [App] :: traceback => <stacktrace>
    ]]
    ```
]=]
function Journal:atDebug(Message: string)
    assert(typeof(Message) == "string", "Message must be a string!")    

    if self.State then
        local Formed = FormatMessage(self.JournalId, "debug", Message, self.Schema, self.Context)
    
        print(Formed)        
    end
end

--[=[
    Journal at `Log` level, for general logging in replace of print.

    ---
    Example:

    ```lua
    local App = Journal.new("App")

    App:atLog("Hello, World!") --> [App] :: log -> Hello, World!
    
    ```
]=]
function Journal:atLog(Message: string)
    assert(typeof(Message) == "string", "Message must be a string!")    

    if self.State then
        local Formed = FormatMessage(self.JournalId, "log", Message, self.Schema, self.Context)

        print(Formed)            
    end
end

--[=[
    Journal at `Success` level. Log a successful attempt at stuff.

    ---
    Example:

    ```lua
    local App = Journal.new("App")

    App:atSuccess("Roblox Api data fetched!") 
    --> [App] :: yay -> Roblox Api data fetched!
    ```
]=]
function Journal:atSuccess(Message: string)
    assert(typeof(Message) == "string", "Message must be a string!")    

    if self.State then
        local Formed = FormatMessage(self.JournalId, "yay", Message, self.Schema, self.Context)

        print(Formed)    
    end
end

--[=[
    Journal at `Warning` level. Log a warning if something wrong but 
    not interrupt the game mechanics.

    ---
    Example:

    ```lua
    local App = Journal.new("App")

    App:atWarn("Failed to fetch api data :(") 
    --> [App] :: warn -> Failed to fetch api data :(
    ```
]=]
function Journal:atWarn(Message: string)
    assert(typeof(Message) == "string", "Message must be a string!")    

    if self.State then
        local Formed = FormatMessage(self.JournalId, "warn", Message, self.Schema, self.Context)

        warn(Formed)
    end
end

--[=[
    Journal at `Error` level. Log an error message if somethings fail to
    work, but not affecting the game as much as `Fatal` level.

    ---
    Example:
    
    ```lua
    local App = Journal.new("Error")
    local AssetsCtx = App:useContext("assets")

    App:atError("Failed to load experience sounds as is invalid!", "assets")
    --> [App] :: error(assets) -> Failed to load experience sounds as is invalid! <traceback>
    ```
]=]
function Journal:atError(Message: string)
    assert(typeof(Message) == "string", "Message must be a string!")    

    if self.State then
        local Formed = FormatMessage(self.JournalId, "error", Message, self.Schema, self.Context)

        error(Formed, 2)
    end
end

--[=[
    Journal at `Fatal` level. Log a fatal message that something's really wrong
    that could affect the game mechanics.

    ---
    Example:
    
    ```lua
    local App = Journal.new("App")
    local DataLoaderCtx = App:useContext("data")

    -- Give a fatal message cause of datastore cannot load
    -- Causing players not saving any data.
    DataLoaderCtx:atFatal("Failed to load datastores.")
    --> [App] :: fatal(data) -> Failed to load datastores. <traceback>
    ```
]=]
function Journal:atFatal(Message: string)
    assert(typeof(Message) == "string", "Message must be a string!")    

    if self.State then
        local Formed = FormatMessage(self.JournalId, "error", Message, self.Schema, self.Context)

        error(Formed, 2)
    end
end

--[=[
    Use context to be more specific.

    ---
    Example:

    ```lua
    local App = Journal.new("App")
    local HttpCtx = App:useContext("http")

    HttpCtx:atLog("Fetching some data..")
    --> [App] :: log(http) -> Fetching some data..
    App:atLog("A test log")
    --> [App] :: log -> A test log
    ```
]=]
function Journal:useContext(Context: string)
    assert(typeof(Context) == "string", "Context must be a lowercase word.")
    local withContext = setmetatable({}, Journal)

    withContext.JournalId = self.JournalId
    withContext.Schema = self.Schema
    withContext.State = self.State
    withContext.Context = Context
    
    return withContext
end

--[=[
    Disable or Enable the Journal. Enabled by default, if inside
    of a `Context` then only the outside of `Context` could run.

    ```lua
    local App = Journal.new("App")
    local Ctx = App:useContext("Ctx")

    Ctx:setState(false)

    Ctx:atLog("Hello, World") --> Doesn't show anything.
    App:atLog("This does work") --> Prints out 
    --> [App] :: log -> This does work
    ```
]=]
function Journal:setState(Trigger: boolean)
    self.State = Trigger
end

return Journal