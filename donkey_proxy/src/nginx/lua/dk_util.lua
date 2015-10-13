local tonumber_ = tonumber

function tonumber(v, base)
    return tonumber_(v, base) or 0
end

function toint(v)
    return math.round(tonumber(v))
end

function tobool(v)
    return (v ~= nil and v ~= false)
end

function totable(v)
    if type(v) ~= "table" then v = {} end
    return v
end

function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function class(classname, super)
    local superType = type(super)
    local cls

    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end

    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        if superType == "table" then
            -- copy fields from super
            print ("superTyper is table");
            for k,v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
            cls.ctor = function() end
        end

        cls.__cname = classname
        cls.__ctype = 1

        function cls.new(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k,v in pairs(cls) do instance[k] = v end
            instance.class = cls
            instance:ctor(...)
            return instance
        end

    else
        -- inherited from Lua Object
        if super then
            cls = {}
            setmetatable(cls, {__index = super})
            cls.super = super
        else
            cls = {ctor = function() end}
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls

        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end

    return cls
end

function import(moduleName, currentModuleName)
    local currentModuleNameParts
    local moduleFullName = moduleName
    local offset = 1

    while true do
        if string.byte(moduleName, offset) ~= 46 then -- .
            moduleFullName = string.sub(moduleName, offset)
            if currentModuleNameParts and #currentModuleNameParts > 0 then
                moduleFullName = table.concat(currentModuleNameParts, ".") .. "." .. moduleFullName
            end
            break
        end
        offset = offset + 1

        if not currentModuleNameParts then
            if not currentModuleName then
                local n,v = debug.getlocal(3, 1)
                currentModuleName = v
            end

            currentModuleNameParts = string.split(currentModuleName, ".")
        end
        table.remove(currentModuleNameParts, #currentModuleNameParts)
    end

    return require(moduleFullName)
end

function handler(target, method)
    return function(...) return method(target, ...) end
end

function math.round(num)
    return math.floor(num + 0.5)
end

function io.exists(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

function io.readfile(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

function io.writefile(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        print("file is ok ok ok  ok ok ")
        if file:write(content) == nil then print("file is bad bad bad bad ") return false end
        io.close(file)
        return true
    else
        return false
    end
end

function io.pathinfo(path)
    local pos = string.len(path)
    local extpos = pos + 1
    while pos > 0 do
        local b = string.byte(path, pos)
        if b == 46 then -- 46 = char "."
            extpos = pos
        elseif b == 47 then -- 47 = char "/"
            break
        end
        pos = pos - 1
    end

    local dirname = string.sub(path, 1, pos)
    local filename = string.sub(path, pos + 1)
    extpos = extpos - pos
    local basename = string.sub(filename, 1, extpos - 1)
    local extname = string.sub(filename, extpos)
    return {
        dirname = dirname,
        filename = filename,
        basename = basename,
        extname = extname
    }
end

function io.filesize(path)
    local size = false
    local file = io.open(path, "r")
    if file then
        local current = file:seek()
        size = file:seek("end")
        file:seek("set", current)
        io.close(file)
    end
    return size
end

function table.nums(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function table.keys(t)
    local keys = {}
    if t == nil then
        return keys;
    end
    for k, v in pairs(t) do
        keys[#keys + 1] = k
    end
    return keys
end

function table.values(t)
    local values = {}
    if t == nil then
        return values;
    end
    for k, v in pairs(t) do
        values[#values + 1] = v
    end
    return values
end

function table.containKey( t, key )
    for k, v in pairs(t) do
        if key == k then
            return true;
        end
    end
    return false;
end

function table.containValue( t, value )
    for k, v in pairs(t) do
        if value == v then
            return true;
        end
    end
    return false;
end

function table.getKeyByValue( t, value )
    for k, v in pairs(t) do
        if value == v then
            return k;
        end
    end
end

function table.merge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

function arrayContain( array, value)
    for i=1,#array do
        if array[i] == value then
            return true;
        end
    end
    return false;
end

function string.htmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, k, v)
    end
    return input
end
string._htmlspecialchars_set = {}
string._htmlspecialchars_set["&"] = "&amp;"
string._htmlspecialchars_set["\""] = "&quot;"
string._htmlspecialchars_set["'"] = "&#039;"
string._htmlspecialchars_set["<"] = "&lt;"
string._htmlspecialchars_set[">"] = "&gt;"

function string.nl2br(input)
    return string.gsub(input, "\n", "<br />")
end

function string.text2html(input)
    input = string.gsub(input, "\t", "    ")
    input = string.htmlspecialchars(input)
    input = string.gsub(input, " ", "&nbsp;")
    input = string.nl2br(input)
    return input
end

function string.split(str, delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(str, delimiter, pos, true) end do
        table.insert(arr, string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end

function string.ltrim(str)
    return string.gsub(str, "^[ \t\n\r]+", "")
end

function string.rtrim(str)
    return string.gsub(str, "[ \t\n\r]+$", "")
end

function string.trim(str)
    str = string.gsub(str, "^[ \t\n\r]+", "")
    return string.gsub(str, "[ \t\n\r]+$", "")
end

function string.ucfirst(str)
    return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

--[[--
@ignore
]]
local function urlencodeChar(c)
    return "%" .. string.format("%02X", string.byte(c))
end

function string.urlencode(str)
    -- convert line endings
    str = string.gsub(tostring(str), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    str = string.gsub(str, "([^%w%.%- ])", urlencodeChar)
    -- convert spaces to "+" symbols
    return string.gsub(str, " ", "+")
end

function string.utf8len(str)
    local len  = #str
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(str, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

function string.formatNumberThousands(num)
    local formatted = tostring(tonumber(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

function format_lua_table (lua_table, indent)
   local out = ""
   local func = function(line)
        out = out .. line .. " "
   end
   print_lua_table( lua_table, indent, func )
   return out
end
function print_lua_table (lua_table, indent, _print)
    local _print = _print or print
    indent = indent or 0
    for k, v in pairs(lua_table) do
        if type(k) == "string" then
            k = string.format("%q", k)
        end
        local szSuffix = ""
        if type(v) == "table" then
            szSuffix = "{"
        end
        local szPrefix = string.rep("    ", indent)
        formatting = szPrefix.."["..k.."]".." = "..szSuffix
        if type(v) == "table" then
            _print(formatting)
            print_lua_table(v, indent + 1, _print)
            _print(szPrefix.."},")
        else
            local szValue = ""
            if type(v) == "string" then
                szValue = string.format("%q", v)
            else
                szValue = tostring(v)
            end
            _print(formatting..szValue..",")
        end
    end
end


local function newCounter()
    local i = 0
    return function()     -- anonymous function
       i = i + 1
        return i
    end
end


g_id_generator = newCounter()

function getNextID()
  local nextID 
    nextID = g_id_generator()
    return nextID
end

luautil = {};
function luautil.serialize(tName, t, sort_parent, sort_child)  
    local mark={}  
    local assign={}  
      
    local function ser_table(tbl,parent)  
        mark[tbl]=parent  
        local tmp={}  
        local sortList = {};  
        for k,v in pairs(tbl) do  
            sortList[#sortList + 1] = {key=k, value=v};  
        end  
  
        if tostring(parent) == "ret" then  
            if sort_parent then table.sort(sortList, sort_parent); end  
        else  
            if sort_child then table.sort(sortList, sort_child); end  
        end  
  
        for i = 1, #sortList do  
            local info = sortList[i];  
            local k = info.key;  
            local v = info.value;  
            local key= type(k)=="number" and "["..k.."]" or k;  
            if type(v)=="table" then  
                local dotkey= parent..(type(k)=="number" and key or "."..key)  
                if mark[v] then  
                    table.insert(assign, "\n".. dotkey.."="..mark[v])  
                else  
                    table.insert(tmp, "\n"..key.."="..ser_table(v,dotkey))  
                end  
            else  
                if type(v) == "string" then  
                    table.insert(tmp, "\n".. key..'="'..v..'"');  
                else  
                    table.insert(tmp, "\n".. key.."="..tostring(v) .. "\n");  
                end  
            end  
        end  
  
        return "{"..table.concat(tmp,",").."\n}";  
    end  
   
    return "do local ".. tName .. "= \n\n"..ser_table(t, tName)..table.concat(assign," ").."\n\n return ".. tName .. " end"  
end  
  
function luautil.split(str, delimiter)  
    if (delimiter=='') then return false end  
    local pos,arr = 0, {}  
    -- for each divider found  
    for st,sp in function() return string.find(str, delimiter, pos, true) end do  
        table.insert(arr, string.sub(str, pos, st - 1))  
        pos = sp + 1  
    end  
    table.insert(arr, string.sub(str, pos))  
    return arr  
end  
  
function luautil.writefile(str, file)  
    os.remove(file);  
    local file=io.open(file,"ab");  
  
    local len = string.len(str);  
    local tbl = luautil.split(str, "\n");  
    for i = 1, #tbl do  
        file:write(tbl[i].."\n");  
    end  
    file:close();  
end 

function luautil.readfile( strData )
    local f = loadstring(strData)  
    if f then  
       return f()
    end  
end

function Json2Lua (fileName,filePath, desFilePath)  
    local jsonString = io.readfile(filePath)--myfile:read("*a")  
    t = CJson.decode(jsonString)  
    if t then
        t = luautil.serialize(fileName,t);
    end
    if t then
        luautil.writefile(t, desFilePath) 
    end 
end 

function performWithDelay(callback, delay)
    local handle
    handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
        handle = nil
        callback();
    end , delay , false)
end

-- 参数:待分割的字符串,分割字符
-- 返回:子串表.(含有空串)
function lua_string_split(str, split_char)
    local sub_str_tab = {};
    while (true) do
        local pos = string.find(str, split_char);
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str;
            break;
        end
        local sub_str = string.sub(str, 1, pos - 1);
        sub_str_tab[#sub_str_tab + 1] = sub_str;
        str = string.sub(str, pos + 1, #str);
    end

    return sub_str_tab;
end

--去除扩展名
function stripExtension(filename)
    local idx = filename:match(".+()%.%w+$")
    if(idx) then
        return filename:sub(1, idx-1)
    else
        return filename
    end
end

--获取路径
function stripfilename(filename)
    return string.match(filename, "(.+)/[^/]*%.%w+$") --*nix system
    --return string.match(filename, “(.+)\\[^\\]*%.%w+$”) — windows
end

--获取文件名
function strippath(filename)
    return string.match(filename, ".+/([^/]*%.%w+)$") -- *nix system
    --return string.match(filename, “.+\\([^\\]*%.%w+)$”) — *nix system
end

-- 生产配置文件
function genCfg(  )
    local assets = require("res.Asset")
    local sceneKey = "Scene"
    local commonKey = "common"
    local className = {"textures", "atlas", "sounds", "animations"}
    
    local config = {};

    for i=1,#assets do
        local k = assets[i].k;
        local v = assets[i].v;

        local pathnames = lua_string_split(v, "/");
        local fileName = pathnames[#pathnames];
        local name = stripExtension(fileName);
        local pathType = fileName:match(".+%.(%w+)$");
        local sceneType;
        local commonType;
        local cur;
        for i=1,#pathnames do
            cur = pathnames[i];
             -- 1. 检查该路径是否是场景
            if string.find(cur, sceneKey) then
                sceneType = cur;
                if not config[sceneType] then
                    config[sceneType] = {};
                end
            end

            if string.find(cur, commonKey) then
                commonType = cur;
                if not config[commonType] then
                    config[commonType] = {};
                end
            end

            -- 2. 查找资源类型
            -- 2.1 是场景资源
            if sceneType then
                for n=1,#className do
                    local t = className[n];
                    if cur == t then
                        if not config[sceneType][t] then
                            config[sceneType][t] = {};
                        end

                        if (t == "atlas" and pathType == "plist") then
                            config[sceneType][t][name] = v;
                        end

                        if t == "atlas" and pathType == "ExportJson" then
                            if not config[sceneType]["json"] then
                               config[sceneType]["json"] = {}
                            end
                            config[sceneType]["json"][name] = v;
                        end

                        if (t == "textures") then
                            config[sceneType][t][name] = v;
                        end

                        if (t == "animations" and pathType == "xml") then
                            config[sceneType][t][name] = v;
                        end

                        if (t == "sounds")  then
                            config[sceneType][t][name] = v;
                        end
                    end
                end

            -- 2.2 是公用资源
            elseif commonType then
                for n=1,#className do
                    local t = className[n];
                    if cur == t then
                        if not config[commonType][t] then
                            config[commonType][t] = {};
                        end

                        if (t == "atlas" and pathType == "plist") then
                            config[commonType][t][name] = v;
                        end

                        if t == "atlas" and pathType == "ExportJson" then
                            if not config[commonType]["json"] then
                               config[commonType]["json"] = {}
                            end
                            config[commonType]["json"][name] = v;
                        end

                        if (t == "textures") then
                            config[commonType][t][name] = v;
                        end

                        if (t == "animations" and pathType == "xml") then
                            config[commonType][t][name] = v;
                        end

                        if (t == "sounds")  then
                            config[commonType][t][name] = v;
                        end
                    end
                end

            -- 2.3 贴图资源
            elseif string.find(cur, "textures") then
                if not config["textures"] then
                    config["textures"] = {}
                end
                config["textures"][name] = v;
            -- 2.4 图集资源
            elseif string.find(cur, "atlas") and pathType == "plist" then
                if not config["atlas"] then
                    config["atlas"] = {}
                end
                config["atlas"][name] = v;
            -- 2.5 图集json配置文件
            elseif string.find(cur, "atlas") and pathType == "ExportJson" then
                if not config["json"] then
                    config["json"] = {}
                end
                config["json"][name] = v;
            -- 2.6 声音资源
            elseif string.find(cur, "sounds") then
                if not config["sounds"] then
                    config["sounds"] = {}
                end
                config["sounds"][name] = v;
            -- 2.7 字体资源
            elseif string.find(cur, "fonts") and (pathType == "fnt" or pathType == "ttf" ) then
                if not config["fonts"] then
                    config["fonts"] = {}
                end
                config["fonts"][name] = v;
            -- 2.8 动画资源
            elseif string.find(cur, "animations") and pathType == "xml" then
                if not config["animations"] then
                    config["animations"] = {}
                end
                config["animations"][name] = v;
            end
        end
    end

    return config;
end
