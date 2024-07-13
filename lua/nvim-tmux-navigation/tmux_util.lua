local util = {}

local tmux_directions = { ['p'] = 'l', ['h'] = 'L', ['j'] = 'D', ['k'] = 'U', ['l'] = 'R', ['n'] = 't:.+' }

-- send the tmux command to the server running on the socket
-- given by the environment variable $TMUX
--
-- the check if tmux is actually running (so the variable $TMUX is
-- not nil) is made before actually calling this function
local function tmux_command(command)
    local tmux_socket = vim.fn.split(vim.env.TMUX, ',')[1]
    return vim.fn.system("tmux -S " .. tmux_socket .. " " .. command)
end

-- check whether the current tmux pane is zoomed
local function is_tmux_pane_zoomed()
    -- the output of the tmux command is "1\n", so we have to test against that
    return tmux_command("display-message -p '#{window_zoomed_flag}'") == "1\n"
end

-- whether tmux should take control over the navigation
function util.should_tmux_control(is_same_winnr, disable_nav_when_zoomed)
    if is_tmux_pane_zoomed() and disable_nav_when_zoomed then
        return false
    end
    return is_same_winnr
end

-- change the current pane according to direction
function util.tmux_change_pane(direction)
    tmux_command("select-pane -" .. tmux_directions[direction])
end

-- capitalization util, only capitalizes the first character of the whole word
function util.capitalize(str)
    local capitalized = str:gsub("(%a)(%a+)", function(a, b)
        return string.upper(a) .. string.lower(b)
    end)

    return capitalized:gsub("_", "")
end

return util

-- -- A. Split pane, then open a new buffer in the new pane
-- local session = "move"
-- local window = "${session}:1"
-- local pane = "${window}.1"
-- -- 1. select-pane -R
-- vim.fn.system("tmux select-pane -R")
-- -- 2. :tabe
-- -- vim.fn.system("tmux send-keys -t " .. "'" .. pane .. "'" .. " C-z 'n .' Enter")
-- -- vim.fn.system("tmux send-keys -t " .. "'" .. pane .. "'" .. " 'n .' Enter")
-- vim.fn.system("tmux send-keys 'nvim " .. name .. "' Enter")

-- local number_of_tmux_panes = vim.fn.system("tmux list-panes | wc -l")
-- print("number_of_tmux_panes: ", vim.inspect(number_of_tmux_panes))
--
-- -- B. To Move B1 to the right
-- local opposite_directions = { L = "R", R = "L", U = "D", D = "U" }
-- local direction = "R"
-- local opposite_direction = opposite_directions[direction]
-- vim.fn.system("tmux select-pane -" .. direction) -- 1. go to the right pane
-- local isNvim = vim.fn.has("nvim") -- TODO: does not work, maybe have to add two separate commands?
-- print("isNvim: ", vim.inspect(isNvim))
-- if isNvim then
-- 	vim.fn.system("tmux send-keys ':tabe' Enter") -- 2.2.1 open new tab
-- 	vim.fn.system("tmux send-keys ':e " .. name .. "'" .. " Enter") -- 2.2.2 if vim open
-- else
-- 	vim.fn.system("tmux send-keys 'nvim " .. name .. "' Enter") -- 2.1 if only tmux
-- end
-- vim.fn.system("tmux select-pane -" .. opposite_direction) -- 3. go back (to clean up)
--
-- local function get_number_of_tabs()
-- 	local number_of_tabs = 0
-- 	for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
-- 		number_of_tabs = number_of_tabs + 1
-- 	end
-- 	return number_of_tabs
-- end
-- local number_of_tabs = get_number_of_tabs()
-- -- local number_of_tabs = 0
-- if number_of_tabs == 1 then
-- 	print("tmux kill")
-- 	vim.fn.system("tmux kill-pane") -- 4.1
-- elseif number_of_tabs > 1 then
-- 	print("vim q")
-- 	pcall(vim.cmd, "q") -- 4.2
-- end
-- vim.fn.system("tmux send-keys Enter") -- 5. Enter to not have "Press Enter or type command to continue"

