local M = {}
M.opts = {
    zindex = 49,
    notify = true,
}

M.setup = function(opts)
    if not opts then
        return
    end

    if opts.zindex then
        M.opts.zindex = opts.zindex
    end

    if opts.notify ~= nil then
        M.opts.notify = opts.notify
    end
end

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

        style = "minimal",
        zindex = M.opts.zindex,
    })

    return win
end

local function delete_buffer()
    if M.job.buf and vim.api.nvim_buf_is_valid(M.job.buf) then
        vim.api.nvim_buf_delete(M.job.buf, {
            force = true
        })
    end

    M.job.buf = nil
end

local function close_window()
    vim.api.nvim_win_close(M.job.win, true)
    M.job.win = nil
end

local function notify(msg, err)
    if M.opts.notify then
        if err then
            vim.notify(msg, vim.log.levels.ERROR)
        else
            vim.notify(msg)
        end
    end
end

M.execute_cmd = function(cmd)
    if M.job then
        if not M.job.done then
            notify("Job still running")
            return
        end

        delete_buffer()
    end

    local buf = get_buffer()
    local win = create_window(buf)

    M.job = {}

    M.job.buf = buf
    M.job.win = win

    local job_id = vim.fn.termopen(cmd, {
        on_exit = function(_, exit_code)
            M.job.done = true
            M.job.exit_code = exit_code

            -- TODO(patrik): When the exit_code is not 0 then we should
            -- notify with error
            notify("Job exited with code: " .. M.job.exit_code, M.job.exit_code ~= 0)
        end
    })
    M.job.id = job_id

    vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")
    vim.api.nvim_buf_set_option(buf, "buflisted", false)

    local bufopts = { noremap = true, silent = true, buffer = buf }
    vim.keymap.set("n", "<esc>", function() close_window() end, bufopts)

    local group_id = vim.api.nvim_create_augroup("scorbunny_group", {
        clear = true
    })

    vim.api.nvim_create_autocmd("BufLeave", {
        group = group_id,
        buffer = buf,

        callback = function()
            close_window()
        end
    });

    vim.api.nvim_create_autocmd("TextChanged", {
        group = group_id,
        buffer = buf,

        callback = function()
            local count = vim.api.nvim_buf_line_count(M.job.buf)
            vim.api.nvim_win_set_cursor(M.job.win, { count, 0 })
        end
    });
end

M.open_window = function()
    if not M.job then
        -- TODO(patrik): Should this be included with M.opts.notify?
        vim.notify("No job running", vim.log.levels.ERROR);
        return
    end

    if M.job.win then
        return
    end

    local win = create_window(M.job.buf);
    M.job.win = win
end

M.kill = function()
    if not M.job then
        notify("No job running")
        return
    end

    if M.job.done then
        notify("Job already done")
        return
    end

    vim.fn.jobstop(M.job.id)
end

return M
