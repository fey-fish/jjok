-- loading files, dont copy this unless you understand allat (i barely do lmao)
local function load_dir(fs_path, mod_path)
    for _, name in ipairs(NFS.getDirectoryItems(fs_path)) do
        local full = fs_path .. name
        if NFS.getInfo(full).type == "directory" then
            load_dir(full .. "/", mod_path .. name .. "/")
        elseif full:match('.lua$') then
            sendInfoMessage("Loading " .. name .. " Question Mark?")
            assert(SMODS.load_file(mod_path .. name))()
        end
    end
end

load_dir(SMODS.current_mod.path .. "items/", "items/")