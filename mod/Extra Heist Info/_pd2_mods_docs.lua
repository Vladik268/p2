---@meta

----------------
--- SuperBLT ---
----------------

---@class BLT
---@field Mods BLTModManager
_G.BLT = {}

---@class BLTModManager
---@field Mods fun(self: self): BLTMod[]

---@class BLTMod
---@field GetAuthor fun(self: self): string
---@field GetName fun(self: self): string
---@field IsEnabled fun(self: self): boolean

---@class Hooks
---@field _function_hooks table
---@field Add fun(self: self, key: string, id: string, func: function)
---@field PostHook fun(self: self, object: table, func: string, id: string, post_call: function)
---@field PreHook fun(self: self, object: table, func: string, id: string, pre_call: function)
---@field RemovePostHook fun(self: self, id: string)
_G.Hooks = {}

---@class NetworkHelper
_G.NetworkHelper = {}

---Sends networked data with a message id to all connected players except specific ones
---@param peer_id integer|integer[] @Peer ID or table of peer IDs of the player(s) to exclude
---@param id string @Unique name of the data to send
---@param data string @Data to send
function NetworkHelper:SendToPeersExcept(peer_id, id, data)
end

---Registers a function to be called when network data with a specific message id is received
---@param message_id string @The message id to hook to
---@param hook_id string @A unique name for this hook
---@param func fun(data: string, sender: integer) @Function to be called when network data for that specific message id is received
function NetworkHelper:AddReceiveHook(message_id, hook_id, func)
end

---Converts a string representation of a color to a color
---@param str string
---@return Color?
function NetworkHelper:StringToColour(str)
end

---Rounds a number to the specified precision (decimal places)
---@param num number @The number to round
---@param idp integer? @The number of decimal places to round to (defaults to `0`)
---@return number @The input number rounded to the input precision
function math.round_with_precision(num, idp)
end

-----------------------
--- End of SuperBLT ---
-----------------------

----------------
--- Beardlib ---
----------------

---@class CustomAchievementPackage
---@field new fun(self: self, package_id: string): self
---@field Achievement fun(self: self, achievement_id: string): CustomAchievement?
_G.CustomAchievementPackage = {}

---@class CustomAchievement
---@field GetIcon fun(self: self): string Returns icon path
---@field GetName fun(self: self): string Returns localizated name of the achievement
---@field GetObjective fun(self: self): string Returns localizated achievement objective
---@field IsUnlocked fun(self: self): boolean
_G.CustomAchievement = {}

-----------------------
--- End of Beardlib ---
-----------------------

----------------------------
--- Why Are You Running? ---
----------------------------

---@class SWAYRMod
---@field included fun(level_id: string): boolean
_G.SWAYRMod = {}

-----------------------------------
--- End of Why Are You Running? ---
-----------------------------------