-- Zoxide plugin for Yazi - directory jumper
-- Requirements: zoxide, fzf

local function entry()
    local output, err = Command("sh")
        :arg({ "-c", "zoxide query --list 2>/dev/null | fzf --no-sort --height 40% --layout=reverse --border" })
        :stdout(Command.PIPED)
        :stderr(Command.PIPED)
        :output()
    
    if output and output.stdout and output.stdout ~= "" then
        local dir = output.stdout:gsub("%s+$", "")
        ya.emit("cd", { dir })
    end
end

return { entry = entry }
