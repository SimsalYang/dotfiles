-- ============================================================
--  Neovim 基础配置（Windows）
--  插件管理：lazy.nvim
-- ============================================================

-- 空格作为 Leader 键（必须在加载插件前设置）
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ---------------- 基础选项 ----------------
local opt = vim.opt

opt.number = true                   -- 行号
opt.relativenumber = true           -- 相对行号（方便用数字+jk 跳转）
opt.cursorline = true               -- 高亮当前行
opt.signcolumn = "yes"              -- 始终显示标记列（诊断图标）
opt.scrolloff = 8                   -- 上下至少留 8 行
opt.wrap = false                    -- 不折行

opt.tabstop = 4                     -- Tab 显示宽度
opt.shiftwidth = 4                  -- 缩进宽度
opt.expandtab = true                -- Tab 转空格
opt.smartindent = true

opt.ignorecase = true               -- 搜索忽略大小写
opt.smartcase = true                -- 有大写字母时精确匹配
opt.updatetime = 250                -- 更快的诊断/光标停留响应
opt.undofile = true                 -- 持久化撤销
opt.splitright = true               -- 垂直分屏在右侧
opt.splitbelow = true               -- 水平分屏在下方
opt.termguicolors = true            -- 24 位真彩色
opt.clipboard = "unnamedplus"       -- 与系统剪贴板互通
opt.completeopt = { "menu", "menuone", "noselect" }
opt.fillchars = { eob = " " }       -- 去掉文件末尾的 ~

-- 中文友好：能正确识别各种历史编码的文本文件
opt.encoding = "utf-8"
opt.fileencodings = "utf-8,ucs-bom,gb18030,gbk,gb2312,cp936,default,latin1"
opt.fileencoding = "utf-8"

vim.g.have_nerd_font = true         -- 已安装 Nerd Font（图标显示）

-- GUI（Neovide 等）字体
opt.guifont = "JetBrainsMono Nerd Font:h11"

-- 让内置终端用 PowerShell 7（如果有）
if vim.fn.executable("pwsh") == 1 then
  opt.shell = "pwsh"
  opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
  opt.shellquote = ""
  opt.shellxquote = ""
end

-- ---------------- 快捷键 ----------------
local map = vim.keymap.set

-- Ctrl+hjkl 在窗口间切换
map("n", "<C-h>", "<C-w>h", { desc = "切到左侧窗口" })
map("n", "<C-j>", "<C-w>j", { desc = "切到下方窗口" })
map("n", "<C-k>", "<C-w>k", { desc = "切到上方窗口" })
map("n", "<C-l>", "<C-w>l", { desc = "切到右侧窗口" })

-- Esc 清除搜索高亮
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "清除搜索高亮" })

-- 诊断跳转
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "上一个诊断" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "下一个诊断" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "查看当前行诊断" })

vim.diagnostic.config({ virtual_text = true, severity_sort = true })

-- LSP 附加到缓冲区时的按键
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local o = { buffer = ev.buf }
    map("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", o, { desc = "跳转定义" }))
    map("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", o, { desc = "查找引用" }))
    map("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", o, { desc = "悬浮文档" }))
    map("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", o, { desc = "重命名符号" }))
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", o, { desc = "代码操作" }))
    -- 格式化：Python 文件优先用 ruff，其他用任意可用服务器
    map("n", "<leader>cf", function()
      local fmt_clients = vim.lsp.get_clients({ bufnr = ev.buf, method = "textDocument/formatting" })
      local has_ruff = false
      for _, fc in ipairs(fmt_clients) do
        if fc.name == "ruff" then has_ruff = true break end
      end
      vim.lsp.buf.format({
        filter = function(c)
          if has_ruff then return c.name == "ruff" end
          return true
        end,
      })
    end, vim.tbl_extend("force", o, { desc = "格式化" }))
  end,
})

-- ---------------- 插件 ----------------
-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ---------------- LSP 服务器配置（必须放在 lazy.setup 之外） ----------------
-- 新增语言：先 :MasonInstall 装服务器，再在这里加一行 vim.lsp.enable("xx")
vim.lsp.config("lua_ls", {
  settings = { Lua = { telemetry = { enable = false } } },
})
vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",  -- 改成 "strict" 获得更严格的类型检查
      },
    },
  },
})
-- ruff：Python linter + 格式化（规则优先读项目的 pyproject.toml / ruff.toml）
vim.lsp.config("ruff", {
  init_options = {
    settings = {
      lint = { enable = true },
    },
  },
})
vim.lsp.enable({ "lua_ls", "pyright", "ruff" })

require("lazy").setup({
  -- 主题
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function() vim.cmd.colorscheme("tokyonight-night") end,
  },

  -- 语法高亮 / 代码解析
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter",
    opts = {
      ensure_installed = {
        "lua", "python", "javascript", "typescript", "tsx",
        "html", "css", "json", "yaml", "toml", "markdown",
        "bash", "c", "cpp", "rust", "go",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- LSP：安装器 + 预置配置
  { "mason-org/mason.nvim", opts = {} },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "lua_ls", "pyright", "ruff" },  -- 想加别的语言在这里加，如 "ts_ls"
    },
  },

  -- 自动补全
  {
    "saghen/blink.cmp",
    version = "1.*",
    opts = {
      keymap = { preset = "default" },
      appearance = { nerd_font_variant = "mono" },
      completion = { documentation = { auto_show = true } },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      signature = { enabled = true },
    },
  },

  -- 模糊查找（依赖 ripgrep / fd，已随 scoop 安装）
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "查找文件" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>",  desc = "全文搜索" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>",    desc = "打开过的文件" },
      { "<leader>fs", "<cmd>Telescope grep_string<CR>", desc = "搜索光标下单词" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>",  desc = "搜索帮助" },
    },
  },

  -- 文件树
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { view = { width = 34 } },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "文件树开关" },
    },
  },

  -- Git 标记（行增删）
  { "lewis6991/gitsigns.nvim", opts = {} },

  -- 状态栏
  {
    "nvim-lualine/lualine.nvim",
    opts = { options = { theme = "tokyonight" } },
  },

  -- 缩进参考线
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

  -- 自动配对括号
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- 诊断侧边栏（全项目问题清单，与文件树互补）
  {
    "folke/trouble.nvim",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>",              desc = "全项目诊断列表" },
      { "<leader>xw", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "当前文件诊断" },
      { "<leader>cs", "<cmd>Trouble symbols toggle<CR>",                desc = "符号大纲" },
    },
  },

  -- 快捷键提示（按 Leader 键会弹出提示框）
  { "folke/which-key.nvim", opts = {} },
})
