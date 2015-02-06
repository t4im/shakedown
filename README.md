# Minetest mod test (mod_test)
Automatic tests and debug tools for minetest mods.

## additions so far
* The tool `mod_test:metadata_inspector`
* `/protect [on|off|default]` – set protection against actions by the calling player


## mod profiling
Additionally to using _mod_test_ it is recommended to use the mod profiling of minetest.
To activate set
```INI
mod_profiling = true
```
and optionally
```INI
detailed_profiling = true
```
in your `minetest.conf`.

Use `/save_mod_profile` to print out runtime statistics to `stdout` and `debug.txt.`
