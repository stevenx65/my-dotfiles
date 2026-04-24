-- Clipboard plugin for Yazi - system clipboard integration
-- Supports Wayland (wl-copy/wl-paste) and X11 (xclip/xsel)

local function get_clipboard_cmd()
    local session_type = os.getenv("XDG_SESSION_TYPE")
    local wayland_display = os.getenv("WAYLAND_DISPLAY")
    
    if wayland_display or session_type == "wayland" then
        return { copy = "wl-copy", paste = "wl-paste" }
    else
        return { copy = "xclip -selection clipboard", paste = "xclip -selection clipboard -o" }
    end
end

local function copy_paths()
    local paths = {}
    for _, u in pairs(cx.active.selected) do
        paths[#paths + 1] = tostring(u)
    end
    if #paths == 0 and cx.active.current.hovered then
        paths[1] = tostring(cx.active.current.hovered.url)
    end
    
    if #paths == 0 then
        ya.notify({ title = "Clipboard", content = "No file selected", timeout = 3 })
        return
    end
    
    local cmd = get_clipboard_cmd()
    local input = table.concat(paths, "\n")
    
    local child = Command("sh")
        :arg({ "-c", cmd.copy })
        :stdin(Command.PIPED)
        :spawn()
    
    if child then
        child:write_all(input)
        child:wait()
        ya.notify({ title = "Clipboard", content = #paths .. " path(s) copied", timeout = 3 })
    end
end

local function copy()
    ya.emit("yank", {})
    copy_paths()
end

local function cut()
    ya.emit("yank", { cut = true })
    copy_paths()
end

local function paste()
    ya.emit("paste", {})
end

local function entry(_, _)
    -- Interactive mode - show options
    ya.notify({ title = "Clipboard", content = "Use 'C' to copy, 'X' to cut, 'P' to paste", timeout = 5 })
end

return { entry = entry, copy = copy, cut = cut, paste = paste }
