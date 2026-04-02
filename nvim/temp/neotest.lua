return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "antoinemadec/FixCursorHold.nvim",
    "marilari88/neotest-vitest",
    "nvim-neotest/neotest-go",
  },
  config = function()
    local neotest = require("neotest")

	local colors = vim.cmd.colorscheme(color)
    -- local colors = require("colorscheme")

    -- get neotest namespace (api call creates or returns namespace)
    local neotest_ns = vim.api.nvim_create_namespace("neotest")
    vim.diagnostic.config({
      virtual_text = {
        format = function(diagnostic)
          local message =
              diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
          return message
        end,
      },
    }, neotest_ns)

    require("neotest").setup({
      quickfix = {
        open = false,
        enabled = false,
      },
      status = {
        enabled = true,
        signs = true, -- Sign after function signature
        virtual_text = false
      },
      icons = {
        child_indent = "│",
        child_prefix = "├",
        collapsed = "─",
        expanded = "╮",
        failed = "✘",
        final_child_indent = " ",
        final_child_prefix = "╰",
        non_collapsible = "─",
        passed = "✓",
        running = "",
        running_animated = { "/", "|", "\\", "-", "/", "|", "\\", "-" },
        skipped = "↓",
        unknown = ""
      },
      floating = {
        border = "rounded",
        max_height = 0.9,
        max_width = 0.9,
        options = {}
      },
      summary = {
        open = "botright vsplit | vertical resize 60",
        mappings = {
          attach = "a",
          clear_marked = "M",
          clear_target = "T",
          debug = "d",
          debug_marked = "D",
          expand = { "<CR>", "<2-LeftMouse>" },
          expand_all = "e",
          jumpto = "i",
          mark = "m",
          next_failed = "J",
          output = "o",
          prev_failed = "K",
          run = "r",
          run_marked = "R",
          short = "O",
          stop = "u",
          target = "t",
          watch = "w"
        },
      },
      highlights = {
        adapter_name = "NeotestAdapterName",
        border = "NeotestBorder",
        dir = "NeotestDir",
        expand_marker = "NeotestExpandMarker",
        failed = "NeotestFailed",
        file = "NeotestFile",
        focused = "NeotestFocused",
        indent = "NeotestIndent",
        marked = "NeotestMarked",
        namespace = "NeotestNamespace",
        passed = "NeotestPassed",
        running = "NeotestRunning",
        select_win = "NeotestWinSelect",
        skipped = "NeotestSkipped",
        target = "NeotestTarget",
        test = "NeotestTest",
        unknown = "NeotestUnknown"
      },
      adapters = {
        require('neotest-vitest'),
        require('neotest-go')
      }
    })

    vim.api.nvim_set_hl(0, 'NeotestBorder', { fg = colors.fujiGray })
    vim.api.nvim_set_hl(0, 'NeotestIndent', { fg = colors.fujiGray })
    vim.api.nvim_set_hl(0, 'NeotestExpandMarker', { fg = colors.fujiGray })
    vim.api.nvim_set_hl(0, 'NeotestDir', { fg = colors.fujiGray })
    vim.api.nvim_set_hl(0, 'NeotestFile', { fg = colors.fujiGray })
    vim.api.nvim_set_hl(0, 'NeotestFailed', { fg = colors.samuraiRed })
    vim.api.nvim_set_hl(0, 'NeotestPassed', { fg = colors.springGreen })
    vim.api.nvim_set_hl(0, 'NeotestSkipped', { fg = colors.fujiGray })
    vim.api.nvim_set_hl(0, 'NeotestRunning', { fg = colors.carpYellow })
    vim.api.nvim_set_hl(0, 'NeotestNamespace', { fg = colors.crystalBlue })
    vim.api.nvim_set_hl(0, 'NeotestAdapterName', { fg = colors.oniViolet })

    local map_opts = { noremap = true, silent = true, nowait = true }
    vim.keymap.set(
      "n",
      "<Leader>tf",
      function()
        neotest.run.run(vim.fn.expand("%"))
      end,
      { noremap = true, silent = true, nowait = true, desc = "Run current [t]est [f]ile"}
    )

    vim.keymap.set(
      "n",
      "<Leader>tn",
      function()
        neotest.run.run()
        neotest.summary.open()
      end,
      { noremap = true, silent = true, nowait = true, desc = "[T]est [n]earest test"}
    )

    vim.keymap.set(
      "n",
      "<Leader>ts",
      function()
        neotest.run.stop()
        neotest.summary.open()
      end,
      { noremap = true, silent = true, nowait = true, desc = "[T]est [S]top all"}
    )

    vim.keymap.set(
      "n",
      "<Leader>to",
      function()
        neotest.output.open({ last_run = true, enter = true })
      end,
	  {desc = "Open [t]est [o]utput"}
    )

	vim.keymap.set(
      "n",
      "<Leader>tdn",
      function()
        neotest.run.run({strategy = "dap"})
      end,
	  {desc = "[t]est [D]ebug [n]earest"}
    )

	vim.keymap.set(
      "n",
      "<Leader>ta",
      function()
        neotest.run.run({vim.loop.cwd()})
      end,
	  {desc = "[t]est run [a]ll"}
    )

	-- debug file
	vim.keymap.set(
      "n",
      "<Leader>tdf",
      function()
        neotest.run.run({vim.fn.expand("%"), strategy = "dap"})
      end,
	  {desc = "[t]est [d]ebug current [f]ile"}
    )

    vim.keymap.set(
      "n",
      "<Leader>tt",
      function()
        neotest.summary.toggle()
        -- u.resize_vertical_splits()
      end,
      { noremap = true, silent = true, nowait = true, desc = "[T]oggle [t]est summary"}
    )

    -- vim.keymap.set(
    --   "n",
    --   "<localleader>tn",
    --   neotest.jump.next,
    --   map_opts
    -- )
    --
    -- vim.keymap.set(
    --   "n",
    --   "<localleader>tp",
    --   neotest.jump.prev,
    --   map_opts
    -- )

    vim.keymap.set(
      "n",
      "<Leader>tl",
      function()
        neotest.run.run_last({ enter = true })
        neotest.output.open({ last_run = true, enter = true })
      end,
      { noremap = true, silent = true, nowait = true, desc = "[T]est run [l]ast"}	
    )
  end
}

