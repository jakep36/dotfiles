--- Tmux terminal provider for Claude Code.
-- Based on PR #50 implementation
-- @module tmux_provider

local M = {}

local active_pane_id = nil

local function is_in_tmux()
  return vim.env.TMUX ~= nil
end

local function get_tmux_pane_width()
  local handle = io.popen("tmux display-message -p '#{window_width}'")
  if not handle then
    return 80
  end
  local result = handle:read("*a")
  handle:close()
  local cleaned = result and result:gsub("%s+", "") or ""
  return tonumber(cleaned) or 80
end

local function calculate_split_size(percentage)
  if not percentage or percentage <= 0 or percentage >= 1 then
    return nil
  end

  local window_width = get_tmux_pane_width()
  return math.floor(window_width * percentage)
end

local function build_split_command(cmd_string, env_table, effective_config)
  local split_cmd = "tmux split-window"

  if effective_config.split_side == "left" then
    split_cmd = split_cmd .. " -bh"
  else
    split_cmd = split_cmd .. " -h"
  end

  local split_size = calculate_split_size(effective_config.split_width_percentage or 0.4)
  if split_size then
    split_cmd = split_cmd .. " -l " .. split_size
  end

  -- Skip environment variables to allow normal Claude Code operation
  -- if env_table then
  --   for key, value in pairs(env_table) do
  --     split_cmd = split_cmd .. " -e '" .. key .. "=" .. value .. "'"
  --   end
  -- end

  split_cmd = split_cmd .. " '" .. cmd_string .. "'"
  return split_cmd
end

local function get_active_pane_id()
  local handle = io.popen("tmux display-message -p '#{pane_id}'")
  if not handle then
    return nil
  end
  local result = handle:read("*a")
  handle:close()
  return result and result:gsub("%s+", "") or nil
end

function M.setup(term_config)
  -- Store config if needed
  M.config = term_config or {}
end

function M.open(cmd_string, env_table, effective_config, focus)
  if not is_in_tmux() then
    vim.notify("Not running in tmux session", vim.log.levels.ERROR)
    return
  end

  -- Check if we already have an active pane
  if active_pane_id then
    local handle = io.popen("tmux list-panes -F '#{pane_id}' | grep '^" .. active_pane_id .. "$'")
    if handle then
      local result = handle:read("*a")
      handle:close()
      if result and result:gsub("%s+", "") == active_pane_id then
        -- Pane still exists, just focus it
        if focus ~= false then
          vim.fn.system("tmux select-pane -t '" .. active_pane_id .. "'")
        end
        return
      end
    end
    active_pane_id = nil
  end

  -- Build and execute split command
  local split_cmd = build_split_command(cmd_string, env_table, effective_config)
  local result = vim.fn.system(split_cmd)

  -- Get the new pane ID
  active_pane_id = get_active_pane_id()

  -- Focus the pane if requested
  if focus ~= false and active_pane_id then
    vim.fn.system("tmux select-pane -t '" .. active_pane_id .. "'")
  end
end

function M.close()
  if active_pane_id then
    vim.fn.system("tmux kill-pane -t '" .. active_pane_id .. "'")
    active_pane_id = nil
  end
end

function M.simple_toggle(cmd_string, env_table, effective_config)
  if active_pane_id then
    -- Check if pane still exists
    local handle = io.popen("tmux list-panes -F '#{pane_id}' | grep '^" .. active_pane_id .. "$'")
    if handle then
      local result = handle:read("*a")
      handle:close()
      if result and result:gsub("%s+", "") == active_pane_id then
        -- Pane exists, close it
        M.close()
        return
      end
    end
    active_pane_id = nil
  end

  -- Pane doesn't exist, open it
  M.open(cmd_string, env_table, effective_config, true)
end

function M.focus_toggle(cmd_string, env_table, effective_config)
  if not active_pane_id then
    M.open(cmd_string, env_table, effective_config, true)
    return
  end

  -- Check if pane is focused
  local handle = io.popen("tmux display-message -p '#{pane_id}'")
  if handle then
    local current_pane = handle:read("*a")
    handle:close()
    current_pane = current_pane and current_pane:gsub("%s+", "") or ""

    if current_pane == active_pane_id then
      -- Currently focused, switch away
      vim.fn.system("tmux last-pane")
    else
      -- Not focused, focus it
      vim.fn.system("tmux select-pane -t '" .. active_pane_id .. "'")
    end
  end
end

function M.get_active_bufnr()
  return nil
end

function M.is_available()
  return is_in_tmux()
end

function M.toggle(cmd_string, env_table, effective_config)
  M.simple_toggle(cmd_string, env_table, effective_config)
end

return M