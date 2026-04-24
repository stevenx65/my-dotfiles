-- FZF plugin for Yazi - fuzzy file finder
-- Requirements: fzf, fd or find

local function entry()
    local cmd = "fd --type f --hidden --exclude .git 2>/dev/null || find . -type f 2>/dev/null"
    local output, err = Command("sh")
        :arg({ "-c", cmd .. " | fzf --height 40% --layout=reverse --border --preview 'cat {}'" })
        :stdout(Command.PIPED)
        :stderr(Command.PIPED)
        :output()
    
    if output and output.stdout and output.stdout ~= "" then
        local path = output.stdout:gsub("%s+$", "")
        ya.emit("open", { path })
    end
end

return { entry = entry }
