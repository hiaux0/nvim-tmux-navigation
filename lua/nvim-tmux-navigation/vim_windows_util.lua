---@diagnostic disable: param-type-mismatch
local util = {}

function util.is_farthest_right_bottom_most()
	local current_win = vim.api.nvim_get_current_win()
	-- local current_tabpage = vim.api.nvim_get_current_tabpage()
	local function traverse_layout(layout)
		local max_col = -1
		local max_row = -1
		local current_win_col = -1
		local current_win_row = -1
		local function traverse(node, row, col)
			if node[1] == "leaf" then
				local winid = node[2]
				if winid == current_win then
					current_win_row = row
					current_win_col = col
				end
				if col > max_col then
					max_col = col
				end
				if row > max_row then
					max_row = row
				end
			else
				for i, child in ipairs(node[2]) do
					if node[1] == "row" then
						traverse(child, row, col + i - 1)
					else
						traverse(child, row + i - 1, col)
					end
				end
			end
		end
		traverse(layout, 0, 0)
		return current_win_row, current_win_col, max_row, max_col
	end
	local win_layout = vim.fn.winlayout()
	local current_win_row, current_win_col, max_row, max_col = traverse_layout(win_layout)
	local is_farthest_right = current_win_col == max_col
	local is_bottom_most = current_win_row == max_row
	return is_farthest_right, is_bottom_most
end

function util.smoother_next(direction)
	local is_farthest_right, is_bottom_most = util.is_farthest_right_bottom_most()
	print("1. right, bottom ", is_farthest_right, is_bottom_most)
	-- [][() (x)]
	if is_farthest_right then
		util.tmux_change_pane(direction)
		pcall(vim.cmd, "wincmd w")
		-- [][(x) ()]
	elseif not is_farthest_right then
		pcall(vim.cmd, "wincmd w")
		-- [][() (x)]
		-- [][() ( )]
	elseif is_farthest_right and not is_bottom_most then
		pcall(vim.cmd, "wincmd w")
		-- [][() ( )]
		-- [][() (x)]
	elseif is_farthest_right and is_bottom_most then
		print("farthest right and bottom most")
		util.tmux_change_pane(direction)
		-- vim.fn.system("tmux -S " .. tmux_socket .. " " .. command)
		pcall(vim.cmd, "wincmd p")
		print("go to first after")
	else
		pcall(vim.cmd, "wincmd w")
	end
end

return util
