local mocks = cubictest.mocks
local nop, fixed = mocks.nop, mocks.fixed
local setter, getter, multi_setter, multi_getter = mocks.setter, mocks.getter, mocks.multi_setter, mocks.multi_getter
---
-- Mock version of ObjectRef
-- which is basically a reference to a C++ `ServerActiveObject`
mocks.ObjectRef = {
	new = function(self, object)
		object = object or {}
		return setmetatable(object, { __index = self })
	end,

	--* `remove()`: remove object (after returning from Lua)
	--    * Note: Doesn't work on players, use minetest.kick_player instead
	remove = nop,
	--* `getpos()`: returns `{x=num, y=num, z=num}`
	getpos = getter("pos", {x=0,y=0,z=0}),
	--* `setpos(pos)`; `pos`=`{x=num, y=num, z=num}`
	setpos = setter("pos"),
	--* `moveto(pos, continuous=false)`: interpolated move
	moveto = setter("pos"),
	--* `punch(puncher, time_from_last_punch, tool_capabilities, direction)`
	--    * `puncher` = another `ObjectRef`,
	--    * `time_from_last_punch` = time since last punch action of the puncher
	--    * `direction`: can be `nil`
	punch = nop,
	--* `right_click(clicker)`; `clicker` is another `ObjectRef`
	--* `get_hp()`: returns number of hitpoints (2 * number of hearts)
	get_hp = getter("hp", cubictest.constants.PLAYER_MAX_HP),
	--* `set_hp(hp)`: set number of hitpoints (2 * number of hearts)
	set_hp = setter("hp"),

	--* `get_inventory()`: returns an `InvRef`
	get_inventory = getter("inventory"),
	--* `get_wield_list()`: returns the name of the inventory list the wielded item is in
	get_wield_list = getter("wield_list", "main"),
	--* `get_wield_index()`: returns the index of the wielded item
	get_wield_index = getter("wield_index", 1),
	--* `get_wielded_item()`: returns an `ItemStack`
	get_wielded_item = function(self)
		self:get_inventory():get_stack(self:get_wield_list(), self:get_wield_index())
	end,
	--* `set_wielded_item(item)`: replaces the wielded item, returns `true` if successful
	set_wielded_item = function(self, item)
		self:get_inventory():set_stack(self:get_wield_list(), self:get_wield_index(), item)
		return true
	end,

	--* `set_armor_groups({group1=rating, group2=rating, ...})`
	set_armor_groups = setter("armor_groups"),
	--* `get_armor_groups()`: returns a table with the armor group ratings
	get_armor_groups = getter("armor_groups", { fleshy = 100 }),

	--* `set_animation({x=1,y=1}, frame_speed=15, frame_blend=0, frame_loop=true)`
	set_animation = multi_setter("animation"),
	--* `get_animation()`: returns range, frame_speed, frame_blend and frame_loop
	get_animation = multi_getter("animation", {x=1,y=1}, 15, 0, true),

	--* `set_attach(parent, bone, position, rotation)`
	--    * `bone`: string
	--    * `position`: `{x=num, y=num, z=num}` (relative)
	--    * `rotation`: `{x=num, y=num, z=num}`
	set_attach = multi_setter("attach"),
	--* `get_attach()`: returns parent, bone, position, rotation or nil if it isn't attached
	get_attach = multi_getter("attach"),
	--* `set_detach()`
	set_detach = function(self) self.attach = nil end,
	--* `set_bone_position(bone, position, rotation)`
	--    * `bone`: string
	--    * `position`: `{x=num, y=num, z=num}` (relative)
	--    * `rotation`: `{x=num, y=num, z=num}`
	set_bone_position = multi_setter("bone_position"),
	--* `get_bone_position(bone)`: returns position and rotation of the bone
	get_bone_position = multi_getter("bone_position"),

	--* `set_properties(object property table)`
	set_properties = setter("properties"),
	--* `get_properties()`: returns object property table
	get_properties = getter("properties"),
	--* `is_player()`: returns true for players, false otherwise
	is_player = fixed(false), -- we override for the player object
	--* `get_player_name()`: returns `""` if is not a player
	get_player_name = fixed(""), -- we override for the player object
}

mocks.LuaEntitySAO = {
	--* `setvelocity({x=num, y=num, z=num})`
	setvelocity = setter("velocity"),
	--* `getvelocity()`: returns `{x=num, y=num, z=num}`
	getvelocity = getter("velocity", {x=0,y=0,z=0}),
	--* `setacceleration({x=num, y=num, z=num})`
	setacceleration = setter("acceleration"),
	--* `getacceleration()`: returns `{x=num, y=num, z=num}`
	getacceleration = getter("acceleration", {x=0,y=0,z=0}),
	--* `setyaw(radians)`
	setyaw = setter("yaw"),
	--* `getyaw()`: returns number in radians
	getyaw = getter("yaw", 0),
	--* `settexturemod(mod)`
	settexturemod = setter("velocity"),
	--* `setsprite(p={x=0,y=0}, num_frames=1, framelength=0.2,
	--  select_horiz_by_yawpitch=false)`
	--    * Select sprite from spritesheet with optional animation and DM-style
	--      texture selection based on yaw relative to camera
	setsprite = multi_setter("sprite"),
	--* `get_entity_name()` (**Deprecated**: Will be removed in a future version)
	get_entity_name = function()
		-- since we would assume running in a testcase, we can happily through an error for this
		error("Deprecated function \"get_entity_name\" called.")
	end,
--* `get_luaentity()`
}
setmetatable(mocks.LuaEntitySAO, { __index = mocks.ObjectRef })

mocks.Player = {
	--* `is_player()`: returns true for players, false otherwise
	is_player = fixed(true),

	--* `get_player_name()`: returns `""` if is not a player
	get_player_name = getter("player_name", "Sam"),
	--* `get_player_velocity()`: returns `nil` if is not a player otherwise a table {x, y, z} representing the player's instantaneous velocity in nodes/s
	get_player_velocity = getter("player_velocity", {x=0,y=0,z=0}),

	--* `get_look_dir()`: get camera direction as a unit vector
	get_look_dir = getter("look_dir", {x=0,y=0,z=0}), -- vector.new(0, 0, 0)
	--* `get_look_pitch()`: pitch in radians
	get_look_pitch = getter("look_pitch", 0),
	--* `get_look_yaw()`: yaw in radians (wraps around pretty randomly as of now)
	get_look_yaw = getter("look_yaw", 0),
	--* `set_look_pitch(radians)`: sets look pitch
	set_look_pitch = setter("look_pitch"),
	--* `set_look_yaw(radians)`: sets look yaw
	set_look_yaw = setter("look_yaw"),

	--* `get_breath()`: returns players breath
	get_breath = getter("breath", cubictest.constants.PLAYER_MAX_BREATH),
	--* `set_breath(value)`: sets players breath
	--     * values:
	--        * `0`: player is drowning,
	--        * `1`-`10`: remaining number of bubbles
	--        * `11`: bubbles bar is not shown
	set_breath = setter("breath"),

	--* `set_inventory_formspec(formspec)`
	--    * Redefine player's inventory form
	--    * Should usually be called in on_joinplayer
	set_inventory_formspec = setter("inventory_formspec"),
	--* `get_inventory_formspec()`: returns a formspec string
	get_inventory_formspec = getter("inventory_formspec", ""),

	--* `get_player_control()`: returns table with player pressed keys
	--    * `{jump=bool,right=bool,left=bool,LMB=bool,RMB=bool,sneak=bool,aux1=bool,down=bool,up=bool}`
	get_player_control = getter("player_control", { jump=false, right=false, left=false, LMB=false, RMB=false, sneak=false, aux1=false, down=false, up=false }),

	--* `get_player_control_bits()`: returns integer with bit packed player pressed keys
	--    * bit nr/meaning: 0/up ,1/down ,2/left ,3/right ,4/jump ,5/aux1 ,6/sneak ,7/LMB ,8/RMB
	get_player_control_bits = function(self)
		if self.player_control_bits then return self.player_control_bits end

		local control = self:get_player_control()
		local control_integer = 0
		if control.up then control_integer = control_integer + 1 end
		if control.down then control_integer = control_integer + 2 end
		if control.left then control_integer = control_integer + 4 end
		if control.right then control_integer = control_integer + 8 end
		if control.jump then control_integer = control_integer + 16 end
		if control.aux1 then control_integer = control_integer + 32 end
		if control.sneak then control_integer = control_integer + 64 end
		if control.LMB then control_integer = control_integer + 128 end
		if control.RMB then control_integer = control_integer + 256 end
		return control_integer
	end,

	--* `set_physics_override(override_table)`
	--    * `override_table` is a table with the following fields:
	--        * `speed`: multiplier to default walking speed value (default: `1`)
	--        * `jump`: multiplier to default jump value (default: `1`)
	--        * `gravity`: multiplier to default gravity value (default: `1`)
	--        * `sneak`: whether player can sneak (default: `true`)
	--        * `sneak_glitch`: whether player can use the sneak glitch (default: `true`)
	set_physics_override = setter("physics_override"),
	--* `get_physics_override()`: returns the table given to set_physics_override
	get_physics_override = getter("physics_override", nil),

	--* `hud_add(hud definition)`: add a HUD element described by HUD def, returns ID
	--   number on success
	--* `hud_remove(id)`: remove the HUD element of the specified id
	--* `hud_change(id, stat, value)`: change a value of a previously added HUD element
	--    * element `stat` values: `position`, `name`, `scale`, `text`, `number`, `item`, `dir`
	--* `hud_get(id)`: gets the HUD element definition structure of the specified ID
	--* `hud_set_flags(flags)`: sets specified HUD flags to `true`/`false`
	--    * `flags`: (is visible) `hotbar`, `healthbar`, `crosshair`, `wielditem`, `minimap`
	--    * pass a table containing a `true`/`false` value of each flag to be set or unset
	--    * if a flag equals `nil`, the flag is not modified
	--    * note that setting `minimap` modifies the client's permission to view the minimap -
	--    * the client may locally elect to not view the minimap
	--* `hud_get_flags()`: returns a table containing status of hud flags
	--    * returns `{ hotbar=true, healthbar=true, crosshair=true, wielditem=true, breathbar=true, minimap=true }`
	--* `hud_set_hotbar_itemcount(count)`: sets number of items in builtin hotbar
	--    * `count`: number of items, must be between `1` and `23`
	--* `hud_get_hotbar_itemcount`: returns number of visible items
	--* `hud_set_hotbar_image(texturename)`
	--    * sets background image for hotbar
	--* `hud_get_hotbar_image`: returns texturename
	--* `hud_set_hotbar_selected_image(texturename)`
	--    * sets image for selected item of hotbar
	--* `hud_get_hotbar_selected_image`: returns texturename
	--* `hud_replace_builtin(name, hud_definition)`
	--    * replace definition of a builtin hud element
	--    * `name`: `"breath"` or `"health"`
	--    * `hud_definition`: definition to replace builtin definition

	--* `set_sky(bgcolor, type, {texture names})`
	--    * `bgcolor`: ColorSpec, defaults to white
	--    * Available types:
	--        * `"regular"`: Uses 0 textures, `bgcolor` ignored
	--        * `"skybox"`: Uses 6 textures, `bgcolor` used
	--        * `"plain"`: Uses 0 textures, `bgcolor` used
	--    * **Note**: currently does not work directly in `on_joinplayer`; use
	--      `minetest.after(0)` in there.
	set_sky = multi_setter("sky"),
	--* `get_sky()`: returns bgcolor, type and a table with the textures
	get_sky = multi_getter("sky"),

	--* `override_day_night_ratio(ratio or nil)`
	--    * `0`...`1`: Overrides day-night ratio, controlling sunlight to a specific amount
	--    * `nil`: Disables override, defaulting to sunlight based on day-night cycle
	override_day_night_ratio = setter("day_night_ratio"),
	--* `get_day_night_ratio()`: returns the ratio or nil if it isn't overridden
	get_day_night_ratio = getter("day_night_ratio", nil),

	--* `set_local_animation(stand/idle, walk, dig, walk+dig, frame_speed=frame_speed)`
	--	set animation for player model in third person view
	--
	--        set_local_animation({x=0, y=79}, -- < stand/idle animation key frames
	--            {x=168, y=187}, -- < walk animation key frames
	--            {x=189, y=198}, -- <  dig animation key frames
	--            {x=200, y=219}, -- <  walk+dig animation key frames
	--            frame_speed=30): -- <  animation frame speed
	set_local_animation = multi_setter("local_animation"),	--
	--* `get_local_animation()`: returns stand, walk, dig, dig+walk tables and frame_speed
	get_local_animation = multi_getter("local_animation"),

	--* `set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})`: defines offset value for camera per player
	--    * in first person view
	--    * in third person view (max. values `{x=-10/10,y=-10,15,z=-5/5}`)
	set_eye_offset = multi_setter("eye_offset"),
	--* `get_eye_offset()`: returns offset_first and offset_third
	get_eye_offset = multi_getter("eye_offset"),

	--* `get_nametag_attributes()`
	--    * returns a table with the attributes of the nametag of the player
	--    * {
	--        color = {a=0..255, r=0..255, g=0..255, b=0..255},
	--      }
	get_nametag_attributes = setter("nametag_attributes"),
	--* `set_nametag_attributes(attributes)`
	--    * sets the attributes of the nametag of the player
	--    * `attributes`:
	--      {
	--        color = ColorSpec,
	--      }
	set_nametag_attributes = getter("nametag_attributes"),
}
setmetatable(mocks.Player, { __index = mocks.ObjectRef })
