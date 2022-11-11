local M = {}

local function get_buffer()
    return vim.api.nvim_create_buf(false, false)
end

local function create_window(buf)
    local gheight = vim.api.nvim_list_uis()[1].height
    local gwidth = vim.api.nvim_list_uis()[1].width
    local width = gwidth - 20
    local height = gheight - 4

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        border = "rounded",

        width = width,
        height = height,
        row = gheight / 2.0 - height / 2.0,
        col = gwidth / 2.0 - width / 2.0,
    })

    return win
end

M.execute_cmd = function(cmd)
    local buf = get_buffer()
    local win = create_window(buf)

    M.running = true

    local job_id = vim.fn.termopen(cmd, {
        on_exit = function(_, exit_code)
            M.running = false
            print("Exit code: " .. exit_code)
        end
    })
    M.currect_job_id = job_id

    vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")
    vim.api.nvim_buf_set_option(buf, "buflisted", false)

    local group_id = vim.api.nvim_create_augroup("scorbunny_group", {
        clear = true
    })

    vim.api.nvim_create_autocmd("BufLeave", {
        group = group_id,
        buffer = buf,

        callback = function()
            if not M.running then
                vim.notify("Not running");
            end

            vim.api.nvim_win_close(win, true)
        end
    });

    vim.api.nvim_create_autocmd("TextChanged", {
        group = group_id,
        buffer = buf,

        callback = function()
            local count = vim.api.nvim_buf_line_count(buf)
            vim.api.nvim_win_set_cursor(win, { count, 0 })
        end
    });
end

return M
