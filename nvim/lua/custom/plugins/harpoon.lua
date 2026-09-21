return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  keys = {
      { "<leader>n",    function() require("harpoon"):list():add() end,                        desc = "Harpoon add file" },
      { "<leader>m",    function() local h = require("harpoon"); h.ui:toggle_quick_menu(h:list()) end, desc = "Harpoon quick menu" },
      { "<leader><A-1>", function() require("harpoon"):list():replace_at(1) end },
      { "<leader><A-2>", function() require("harpoon"):list():replace_at(2) end },
      { "<leader><A-3>", function() require("harpoon"):list():replace_at(3) end },
      { "<leader><A-4>", function() require("harpoon"):list():replace_at(4) end },
      { "<leader><A-5>", function() require("harpoon"):list():replace_at(5) end },
      { "<A-1>", function() require("harpoon"):list():select(1) end },
      { "<A-2>", function() require("harpoon"):list():select(2) end },
      { "<A-3>", function() require("harpoon"):list():select(3) end },
      { "<A-4>", function() require("harpoon"):list():select(4) end },
      { "<A-5>", function() require("harpoon"):list():select(5) end },
  },
  config = function()
    local harpoon = require "harpoon"
    harpoon:setup()

    vim.keymap.set("n", "<leader>n", function()
      harpoon:list():add()
    end, {desc = "Harpoon add file"})
    vim.keymap.set("n", "<leader>m", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, {desc = "Harpoon quick menu"})

	vim.keymap.set("n", "<leader><A-1>", function() harpoon:list():replace_at(1) end)
	vim.keymap.set("n", "<leader><A-2>", function() harpoon:list():replace_at(2) end)
	vim.keymap.set("n", "<leader><A-3>", function() harpoon:list():replace_at(3) end)
	vim.keymap.set("n", "<leader><A-4>", function() harpoon:list():replace_at(4) end)
	vim.keymap.set("n", "<leader><A-5>", function() harpoon:list():replace_at(5) end)

    -- Set <space>1..<space>5 be my shortcuts to moving to the files
    for _, idx in ipairs { 1, 2, 3, 4, 5 } do
      vim.keymap.set("n", string.format("<A-%d>", idx), function()
        harpoon:list():select(idx)
      end)
    end
  end,
}
