return {
  "sphamba/smear-cursor.nvim",
  opts = {
	-- Smear cursor when switching buffers or windows.
    smear_between_buffers = true,

    -- Smear cursor when moving within line or to neighbor lines.
    -- Use `min_horizontal_distance_smear` and `min_vertical_distance_smear` for finer control
    smear_between_neighbor_lines = true,

    -- Draw the smear in buffer space instead of screen space when scrolling
    scroll_buffer_space = true,

    -- Set to `true` if your font supports legacy computing symbols (block unicode symbols).
    -- Smears will blend better on all backgrounds.
    legacy_computing_symbols_support = false,

    -- Smear cursor in insert mode.
    -- See also `vertical_bar_cursor_insert_mode` and `distance_stop_animating_vertical_bar`.
    smear_insert_mode = false,

	-- cursor_color = "#ed7014",
	-- stiffness = 0.3,
	-- trailing_stiffness = 0.1,
	-- trailing_exponent = 5,
	-- hide_target_hack = true,
	-- gamma = 1,
	
	-- let it snow!
	cursor_color = "#ed7014",
	gradient_exponent = 0,
	particles_enabled = true,
	particle_spread = 2,
	particles_per_second = 100,
	particles_per_length = 50,
	particle_max_lifetime = 1100,
	particle_max_initial_velocity = 100,
	particle_velocity_from_cursor = 5,
	particle_random_velocity = 300,
	particle_damping = 0.2,
	particle_gravity = 60,
	},
}
