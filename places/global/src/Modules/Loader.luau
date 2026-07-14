--[=[
	Utility module for loading ModuleScripts.

	```lua
--]=]

local Loader = {}

--[=[
	@within Loader
	@type PredicateFn (module: ModuleScript) -> boolean
	Predicate function type.
]=]
type PredicateFn = (module: ModuleScript) -> boolean

--[=[
	Utility function for spawning a specific method in all given modules.
	If a module does not contain the specified method, it is simply
	skipped. Methods are called with `task.spawn` internally.

	For example, if the modules are expected to have an `OnStart()` method,
	then `SpawnAll()` could be used to start all of them directly after
	they have been loaded:

	```lua
	local MyModules = ReplicatedStorage.MyModules

	-- Load all modules under MyModules and then call their OnStart methods:
	Loader.SpawnAll(Loader.LoadDescendants(MyModules), "OnStart")
	```
]=]
function Loader.SpawnAll(loadedModules: { [string]: any }, methodName: string)
	for name, mod in loadedModules do
		local method = mod[methodName]
		if type(method) == "function" then
			task.spawn(function()
				debug.setmemorycategory(name)
				method(mod)
			end)
		end
	end
end

--[=[
	Requires all descendant ModuleScripts.

	If a `predicate` function is provided, then the module will only
	be loaded if the predicate returns `true` for the the given
	ModuleScript.

	```lua
--]=]
function Loader.LoadDescendants(parent: Instance, predicate: PredicateFn?): { [string]: any }
	local modules: { [string]: any } = {}
	for _, descendant in parent:GetDescendants() do
		if descendant:IsA("ModuleScript") then
			if predicate and not predicate(descendant) then
				continue
			end
			local m = require(descendant)
			modules[descendant.Name] = m
		end
	end
	return modules
end

return Loader
