--[[====================================================================
    Chilli Hub 汉化版 v3.2 加载器（小体积版）· 只在《Steal An Egg》里生效
    词典不内嵌：词典从 DICT_URL(GitHub raw)自动拉取并缓存到本地,
    更新词典只需改仓库里的 chilli_dict.lua,脚本和执行码永远不用重新粘贴。
    ------------------------------------------------------------------
    用法（推荐,只需一行,永久不变）：
      把本文件上传到 GitHub 仓库根目录(名字保持 chilli_loader.lua),执行器里粘贴：
      loadstring(game:HttpGet("https://raw.githubusercontent.com/dajsdjalsj/chilli-hanhua/main/chilli_loader.lua"))()
    备用用法：把本文件全部内容粘贴进执行器 → Execute(效果相同)
    ------------------------------------------------------------------
    v3.2 更新（跟进 10-03/10-04 的游戏与 Chilli 更新）：
      · 补全新宠物图鉴全部本体名（前缀组合自动拼译覆盖 ~130 只）
      · Chilli 新增分区全部翻译：蝴蝶绽放、精灵伴侣、进度页、
        自动保存/加载配置；新挂机统计面板（全大写标签）
      · 机甲Boss 多阶段状态行（砸核心/球阶段/追击/击中 N/M）
      · 魔幻森林活动全套（蝴蝶升级、精华、精灵任务、红绿灯）
      · 宠物卡片新格式：收入 ($197/s)、稀有度后缀 [Eternal]
      · 采集文件自动过滤玩家名/图标名/链接等噪音
    ------------------------------------------------------------------
    v3.1 修正（整体复查后）：
      · 名词组合翻译真正落地：前缀(黄金/骸骨/机甲…)+宠物名+"Egg"
        任意组合都能整段拼成中文（"Golden Ice Dragon"→黄金冰龙、
        "Bear Egg (12Kg)"→熊蛋 (12公斤)），不再只翻前缀留英文
      · 修复：搜索框等输入框里打字不再被替换成中文（原来输入
        "Bear"会立刻变成"熊"，游戏内搜索、配置名输入直接失效）
      · 修复：被 <font> 标签拆开的段落（"Auto Steal: "、" selected"）
        现在也能翻；离线收益句不再重复"离线"二字；结尾的
        "5m"/"30s"/"2h" 自动换算成中文单位
      · 措辞修订：防守卫→躲避守卫、自动买扰乱商店→自动购买扰乱商店
        物品、符合条件的蛋只卖一次→一次性卖出、"Boss 还有 12 秒后
        开始"→"Boss 出现倒计时: 12 秒" 等
      · 本体下载失败时汉化器照常启动（原先是整个卡住不动）
      · 半翻译兜底采集：上游更新出了新名词（如新宠物"黄金 Xxx"只翻
        出前缀）时，原文现在也会进采集文件，发回来即可补全词典
    ------------------------------------------------------------------
    v3 改进（基于 v2 采集到的 600+ 条真实界面文本）：
      · 补全全部功能说明（每个开关/滑条下面的灰色小字）
      · 富文本分段翻译：修复 Off/ON、滑条单位(studs/s、%、FPS)
      · 新增动态文本模式规则："12 selected"→已选12项、
        "in 2m 46s"→2分46秒后、Boss 倒计时、重量/售价等
      · 顺带翻译了游戏内高频 HUD（事件横幅、Boss战、商店、图鉴）
      · 删除 "needs→缺" 这条会在句中乱插字的规则
    ------------------------------------------------------------------
    原理：本体是 Luarmor 加密壳改不了字；本脚本在界面渲染出来后按词典
    替换文本，词典没有的英文自动采集到 workspace/chilli_hanhua/dump_sae.txt
====================================================================]]

local FOLDER0 = "chilli_hanhua"
--====================================================================
-- 一、词典加载（词典不内嵌在脚本里,从网络或本地缓存取,大幅缩小粘贴体积）
--   优先级:DICT_URL 远程(GitHub raw,更新仓库文件即全量更新) → 本地缓存 → 空(仅界面框架)
--====================================================================
local DICT_URL   = "https://raw.githubusercontent.com/dajsdjalsj/chilli-hanhua/main/chilli_dict.lua"
local DICT_CACHE = FOLDER0 .. "/dict.lua"

local EXACT, PARTIAL, PATTERNS, TAB_HEADS = {}, {}, {}, {}

local function loadDictionary()
    local function tryChunk(s)
        if type(s) ~= "string" or s == "" then
            return nil
        end
        local chunk = loadstring(s)
        if not chunk then
            return nil
        end
        local ok, d = pcall(chunk)
        if not ok or type(d) ~= "table" then
            return nil
        end
        return d
    end
    -- 1) 远程词典(设了 DICT_URL 就以它为准,改 pastebin 即刻生效)
    if DICT_URL ~= "" then
        local ok, src = pcall(game.HttpGet, game, DICT_URL)
        local d = ok and tryChunk(src) or nil
        if d then
            pcall(function()
                if makefolder and isfolder and not isfolder(FOLDER0) then
                    makefolder(FOLDER0)
                end
                writefile(DICT_CACHE, src)
            end)
            return d
        end
        warn("[Chilli汉化] 远程词典拉取失败，尝试本地缓存")
    end
    -- 2) 本地缓存(执行器 workspace 的 chilli_hanhua/dict.lua,也可手动放/手动更新)
    local ok2, cached = pcall(function()
        if isfile and isfile(DICT_CACHE) then
            return readfile(DICT_CACHE)
        end
    end)
    local d2 = ok2 and tryChunk(cached) or nil
    if d2 then
        return d2
    end
    warn("[Chilli汉化] 没有可用词典：请在加载器开头填写 DICT_URL(pastebin raw 链接)，"
        .. "或把 chilli_dict.lua 的内容放到 workspace/chilli_hanhua/dict.lua")
    return nil
end

local dict = loadDictionary()
if dict then
    EXACT     = dict.EXACT or {}
    PARTIAL   = dict.PARTIAL or {}
    PATTERNS  = dict.PATTERNS or {}
    TAB_HEADS = dict.TAB_HEADS or {}
end

--====================================================================
-- 名词组合翻译：宠物/蛋名 前缀+本体 任意组合整段拼成中文
--   词组表从 EXACT 自动提取（每个单词首字母大写、只含字母/空格/
--   连字符/撇号的词条），另加少量手写补充。
--   对文本里连续的纯名词片段做"全覆盖"式拼译：片段里只要有任何
--   一个词不认识，整段就原样保留，避免把普通句子翻错
--====================================================================
local NAME_MAP = {
    ["Egg"]         = "蛋",
    ["Experimental"] = "实验",
    ["Unstable DNA"] = "不稳定DNA",
    ["La Vacca Saturno Saturnita"] = "土星牛",
    -- 前缀词（EXACT 里没有单独词条，PARTIAL 里有；加进来才能参与组合拼译）
    ["Skeletal"]   = "骸骨",
    ["Shattered"]  = "破碎",
    ["Luminous"]   = "发光",
    ["Mecha"]      = "机甲",
    ["Mutant"]     = "变异",
    ["Pure"]       = "纯",
    ["Biohazard"]  = "生化",
}
local NAME_SKIP = { ["Sort By"] = true, ["Kills"] = true, ["Steal"] = true }   -- 这些词条参与拼译会产出病句/挡住动态模式

for en, zh in pairs(EXACT) do
    if type(en) == "string" and #en >= 3 and not NAME_SKIP[en]
        and en:match("^%u[%a' %-]*$") then
        local allCap = true
        for w in en:gmatch("%S+") do
            if not w:match("^%u") then
                allCap = false
                break
            end
        end
        if allCap then
            NAME_MAP[en] = zh
        end
    end
end

local function sweepNames(s)
    local changed = false
    local out = s:gsub("[A-Za-z][A-Za-z' %-]*", function(run)
        -- 保留词串结尾的空格（如 "Bear Egg (12Kg)" 里 '(' 前面的空格）
        local tail = run:match("%s+$") or ""
        local core = tail ~= "" and run:sub(1, #run - #tail) or run
        if #core < 3 then
            return nil
        end
        local words = {}
        for w in core:gmatch("%S+") do
            words[#words + 1] = w
        end
        -- 词串贪婪匹配会把紧贴数字的单位字母吞进来（如 "x2000" 的 x、
        -- "500K" 的 K），先把这个短词踢出去再试
        local dropped = nil
        if #words >= 2 and #words[#words] <= 2 then
            dropped = words[#words]
            words[#words] = nil
        end
        local parts, i, n = {}, 1, #words
        while i <= n do
            local hit = false
            -- 贪心：优先匹配更长的词组（最多 5 个词）
            for k = math.min(5, n - i + 1), 1, -1 do
                local zh = NAME_MAP[table.concat(words, " ", i, i + k - 1)]
                if zh then
                    parts[#parts + 1] = zh
                    i = i + k
                    hit = true
                    break
                end
            end
            if not hit then
                return nil
            end
        end
        changed = true
        local joined = table.concat(parts)
        if dropped then
            joined = joined .. " " .. dropped
        end
        return joined .. tail
    end)
    if changed then
        return out
    end
    return nil
end

--====================================================================
-- 二、运行时界面翻译器（下面的代码一般不用动）
--====================================================================
local FOLDER    = "chilli_hanhua"
local DUMP_FILE = FOLDER .. "/dump_sae.txt"
local LOG_FILE  = FOLDER .. "/log.txt"
local MAX_DUMP  = 3000

-- ---- 词典预处理 ----
local PARTIAL_LIST = {}
for en, zh in pairs(PARTIAL) do
    table.insert(PARTIAL_LIST, { en, zh })
end
table.sort(PARTIAL_LIST, function(a, b)
    return #a[1] > #b[1]
end)

local function escapePattern(s)
    return (s:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
end

local function escapeReplace(s)
    return (s:gsub("%%", "%%%%"))
end

-- 单段文本翻译（不含标签的一段）
local function translateSegment(s)
    local zh = EXACT[s]
    if zh then
        return zh
    end
    -- "Farm Tab  >  xxx"：页名 + 分区名 组合翻译
    local head, rest = s:match("^(%S+ Tab)%s+>%s+(.+)$")
    if head and TAB_HEADS[head] then
        local rr = EXACT[rest]
        if rr then
            return TAB_HEADS[head] .. "  >  " .. rr
        end
    end
    local out, changed = s, false
    -- 名词组合翻译："Golden Ice Dragon"→黄金冰龙、"Bear Egg"→熊蛋
    local swept = sweepNames(s)
    if swept then
        out, changed = swept, true
    end
    for _, pair in ipairs(PARTIAL_LIST) do
        local en, z = pair[1], pair[2]
        if #en >= 4 and out:find(en, 1, true) then
            out = out:gsub(escapePattern(en), escapeReplace(z))
            changed = true
        end
    end
    for _, rule in ipairs(PATTERNS) do
        local out2, n = out:gsub(rule[1], rule[2])
        if n > 0 then
            out = out2
            changed = true
        end
    end
    -- 子串/模式替换后再扫一遍剩余的纯名词片段
    -- （如 "A Secret RazorFang Egg spawned in Demons!" 的宠物名/区域名）
    local swept2 = sweepNames(out)
    if swept2 then
        out = swept2
    end
    if changed then
        return out
    end
    return nil
end

-- 富文本：按 <font>…</font> 分段，只翻译文字段，标签原样保留
local function translateRich(val)
    local parts, pos, changed = {}, 1, false
    while pos <= #val do
        local s, e = val:find("</?%a+[^>]*>", pos)
        if s then
            local seg = val:sub(pos, s - 1)
            if seg ~= "" then
                local t = translateSegment(seg)
                if t then
                    parts[#parts + 1] = t
                    changed = true
                else
                    parts[#parts + 1] = seg
                end
            end
            parts[#parts + 1] = val:sub(s, e)
            pos = e + 1
        else
            local seg = val:sub(pos)
            if seg ~= "" then
                local t = translateSegment(seg)
                if t then
                    parts[#parts + 1] = t
                    changed = true
                else
                    parts[#parts + 1] = seg
                end
            end
            pos = #val + 1
        end
    end
    if changed then
        return table.concat(parts)
    end
    return nil
end

local function hasTags(val)
    return val:find("</?%a+[^>]*>") ~= nil
end

-- ---- 中文判断（手写 UTF-8 扫描，不依赖 utf8 库）----
local function hasCJK(s)
    local i, n = 1, #s
    while i <= n do
        local b = s:byte(i)
        if b >= 0xE0 and b < 0xF0 and i + 2 <= n then
            local cp = (b % 0x20) * 0x1000
                + ((s:byte(i + 1) or 0) % 0x40) * 0x40
                + ((s:byte(i + 2) or 0) % 0x40)
            if (cp >= 0x4E00 and cp <= 0x9FFF)
                or (cp >= 0x3400 and cp <= 0x4DBF)
                or (cp >= 0xF900 and cp <= 0xFAFF) then
                return true
            end
            i = i + 3
        elseif b >= 0xF0 then
            i = i + 4
        elseif b >= 0xC0 then
            i = i + 2
        else
            i = i + 1
        end
    end
    return false
end

-- ---- 计数（给屏幕提示条用）----
local translatedCount, dumpedCount = 0, 0

-- ---- 英文串采集 ----
local dumpList, dumpSet = {}, {}
local dumpDirty = false
local dumpFileOK = nil

-- 采集噪音过滤：玩家名、图标名、链接、调试信息不进采集文件
local DUMP_SKIP = {
    ["Label"] = true, ["Button"] = true, ["ButtonSelect"] = true, ["Backquote"] = true,
    ["Roblox"] = true, ["from"] = true, [": Players"] = true, ["Esc"] = true,
    ["This is a popup"] = true, ["Panel title"] = true, ["Bubble pop-up description?"] = true,
    ["Toggle the backpack."] = true,
    ["Generic message w00t!"] = true, ["Report"] = true, ["Panel"] = true, ["Tab"] = true,
}
local NOISE_PREFIX = {
    "Server Channel: ", "Server Version: ", "Client Version: ",
    "Client CoreScript Version: ", "Place Version: ", "PlayerScripts: ",
    "The players to teleport",
}

local function isDumpNoise(s)
    if DUMP_SKIP[s] then
        return true
    end
    if s:find("@", 1, true) then
        return true
    end
    if s:match("^https?://") or s:find("discord.gg", 1, true)
        or s:find("rbxassetid", 1, true) then
        return true
    end
    for _, p in ipairs(NOISE_PREFIX) do
        if s:sub(1, #p) == p then
            return true
        end
    end
    if not s:find(" ") then
        -- 单词串：全小写 = 图标名；含数字/下划线 = 玩家名
        if not s:match("%u") then
            return true
        end
        if s:match("[%d_]") then
            return true
        end
    end
    return false
end

local function addDump(s)
    if #dumpList >= MAX_DUMP then
        return
    end
    s = s:gsub("[\r\n]+", " ")
    s = s:gsub("^%s+", ""):gsub("%s+$", "")
    if s == "" or dumpSet[s] or isDumpNoise(s) then
        return
    end
    dumpSet[s] = true
    table.insert(dumpList, s)
    dumpedCount = dumpedCount + 1
    dumpDirty = true
    print("[汉化采集] " .. s)
end

local function loadDump()
    pcall(function()
        if isfile and isfile(DUMP_FILE) then
            local content = readfile(DUMP_FILE)
            for line in content:gmatch("[^\r\n]+") do
                line = line:gsub("^%s+", ""):gsub("%s+$", "")
                if line ~= "" and not dumpSet[line] then
                    dumpSet[line] = true
                    table.insert(dumpList, line)
                end
            end
        end
    end)
end

local function saveDump()
    if not dumpDirty then
        return
    end
    local ok = pcall(function()
        if makefolder and isfolder and not isfolder(FOLDER) then
            makefolder(FOLDER)
        end
        writefile(DUMP_FILE, table.concat(dumpList, "\n"))
    end)
    if ok then
        dumpDirty = false
        if dumpFileOK == nil then
            dumpFileOK = true
        end
    else
        if dumpFileOK == nil or dumpFileOK == true then
            dumpFileOK = false
            print("[汉化采集] 执行器不支持写文件，改为 45 秒后把采集结果复制到剪贴板")
        end
    end
end

local function dumpToClipboard()
    if dumpFileOK == false and #dumpList > 0 then
        pcall(function()
            setclipboard("Chilli汉化采集结果：\n" .. table.concat(dumpList, "\n"))
        end)
        print("[汉化采集] 已复制到剪贴板，请粘贴发回")
    end
end

-- ---- 启动标记 ----
local function markStarted()
    pcall(function()
        if makefolder and isfolder and not isfolder(FOLDER) then
            makefolder(FOLDER)
        end
        writefile(LOG_FILE, "hanhua started at " .. os.date("%Y-%m-%d %H:%M:%S"))
    end)
end

-- ---- 半翻译兜底采集 ----
-- 上游更新出现新名词时（比如新宠物名），"Golden NewPet" 只会翻出"黄金 NewPet"，
-- 原逻辑认为"已翻译"就不再采集，导致永远补不全词典；这里把这类原文也采集进来。
-- KEEP_EN 是有意保留英文的词，不算"没翻到"
local KEEP_EN = {
    Discord = true, Webhook = true, everyone = true, JSON = true,
    Boss = true, Roblox = true, Sammy = true,
}

local function hasUnknownEnglish(s)
    s = s:gsub("</?%a+[^>]*>", "")   -- 去掉富文本标签，标签名/属性不算英文残留
    for word in s:gmatch("[A-Za-z][A-Za-z']+") do
        if #word >= 4 and not KEEP_EN[word] then
            return true
        end
    end
    return false
end

-- ---- 文本控件处理 ----
local seenObj = setmetatable({}, { __mode = "k" })

local function processProp(inst, prop)
    local ok, val = pcall(function()
        return inst[prop]
    end)
    if not ok or type(val) ~= "string" or val == "" then
        return
    end
    -- 游戏文本里夹的不可见私用区字符（U+E000-U+F8FF，如 U+E002）
    -- 会卡住整句/模式匹配，先剥掉（它们本身不可见，剥掉不影响显示）
    val = val:gsub("\239[\128-\163][\128-\191]", "")
    if val == "" then
        return
    end
    if hasCJK(val) then
        return -- 已经是中文，跳过
    end
    local zh
    if hasTags(val) then
        zh = translateRich(val)
    else
        zh = translateSegment(val)
    end
    if zh and zh ~= val then
        pcall(function()
            inst[prop] = zh
        end)
        translatedCount = translatedCount + 1
        -- 结果里还残留未翻英文（半翻译）时，把原文采集起来便于补全词典；
        -- 数字统一折成 #，避免带数值的动态文本刷屏
        if hasUnknownEnglish(zh) then
            local forDump = val
            if hasTags(val) then
                forDump = val:gsub("</?%a+[^>]*>", "")
            end
            addDump(forDump:gsub("%d[%d%,%.]*", "#"))
        end
    elseif not zh then
        -- 采集：富文本只记录去掉标签后的文字
        local forDump = val
        if hasTags(val) then
            forDump = val:gsub("</?%a+[^>]*>", "")
        end
        local letters = forDump:gsub("%A", "")
        if #letters >= 3 then
            addDump(forDump)
        end
    end
end

local function handle(inst)
    if seenObj[inst] then
        return
    end
    local okIsA, isText = pcall(function()
        return inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox")
    end)
    if not okIsA or not isText then
        return
    end
    seenObj[inst] = true
    -- TextBox 只翻译占位提示，不动输入内容：
    -- 否则玩家在搜索框/输入框里打的英文会被替换成中文，搜索和输入功能直接失效
    local isBox = false
    pcall(function()
        isBox = inst:IsA("TextBox")
    end)
    if isBox then
        processProp(inst, "PlaceholderText")
    else
        processProp(inst, "Text")
        pcall(function()
            inst:GetPropertyChangedSignal("Text"):Connect(function()
                processProp(inst, "Text")
            end)
        end)
    end
end

-- ---- 扫描范围：CoreGui / gethui / PlayerGui，跳过 Roblox 自带界面 ----
local BLACKLIST = {
    ["RobloxGui"]        = true,
    ["Chat"]             = true,
    ["PlayerList"]       = true,
    ["PlayerListMaster"] = true,
    ["Backpack"]         = true,
    ["Health"]           = true,
    ["MainMenu"]         = true,
    ["SettingsHub"]      = true,
    ["DevConsoleMaster"] = true,
    ["TeleportGui"]      = true,
    ["RobloxPromptGui"]  = true,
    ["PurchasePrompt"]   = true,
    ["TopBar"]           = true,
    ["VirtualCursor"]    = true,
}

local function getRoots()
    local roots = {}
    local function add(r)
        if r and not table.find(roots, r) then
            table.insert(roots, r)
        end
    end
    pcall(function()
        if gethui then
            add(gethui())
        end
    end)
    pcall(function()
        add(game:GetService("CoreGui"))
    end)
    pcall(function()
        add(game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui"))
    end)
    return roots
end

local function scanRoot(root)
    pcall(function()
        for _, top in ipairs(root:GetChildren()) do
            if not BLACKLIST[top.Name] then
                handle(top)
                for _, d in ipairs(top:GetDescendants()) do
                    handle(d)
                end
            end
        end
    end)
end

local watched = {}

local function watchRoot(root)
    if watched[root] then
        return
    end
    watched[root] = true
    pcall(function()
        root.DescendantAdded:Connect(function(d)
            local top = d
            while top.Parent ~= nil and top.Parent ~= root do
                top = top.Parent
            end
            if not BLACKLIST[top.Name] then
                handle(d)
            end
        end)
    end)
end

-- ---- 屏幕提示条：确认汉化在运行，12 秒后自动消失 ----
local function showHint()
    task.spawn(function()
        pcall(function()
            local g = Instance.new("ScreenGui")
            g.Name = "CNBHanhuaHint"
            g.ResetOnSpawn = false
            local okP, parent = pcall(function()
                if gethui then
                    return gethui()
                end
                return game:GetService("CoreGui")
            end)
            if not okP or not parent then
                parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
            end
            g.Parent = parent
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0, 420, 0, 34)
            lbl.Position = UDim2.new(0, 12, 1, -46)
            lbl.BackgroundColor3 = Color3.fromRGB(20, 60, 20)
            lbl.BackgroundTransparency = 0.25
            lbl.TextColor3 = Color3.fromRGB(120, 255, 120)
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 16
            lbl.Text = "Chilli 汉化 v3.2 运行中…"
            lbl.Parent = g
            for _ = 1, 12 do
                task.wait(1)
                lbl.Text = "Chilli 汉化 v3.2 运行中 · 已翻译 " .. translatedCount
                    .. " · 已采集 " .. dumpedCount
            end
            pcall(function()
                g:Destroy()
            end)
        end)
    end)
end

-- ---- 启动 ----
local function startHanhua()
    markStarted()
    loadDump()
    showHint()
    for _, root in ipairs(getRoots()) do
        scanRoot(root)
        watchRoot(root)
    end
    task.spawn(function()
        while true do
            task.wait(2)
            for _, root in ipairs(getRoots()) do
                scanRoot(root)
                watchRoot(root)
            end
        end
    end)
    task.spawn(function()
        while true do
            task.wait(3)
            saveDump()
        end
    end)
    task.spawn(function()
        task.wait(45)
        dumpToClipboard()
    end)
    print("[Chilli汉化] v3.2 界面翻译器已启动：词典 "
        .. (function() local c = 0 for _ in pairs(EXACT) do c = c + 1 end return c end)()
        .. " 条整句 + "
        .. (function() local c = 0 for _ in pairs(PARTIAL) do c = c + 1 end return c end)()
        .. " 条子串 + "
        .. #PATTERNS
        .. " 条动态模式")
end

--====================================================================
-- 三、Chilli 原版分发逻辑（原样保留；只有 Steal An Egg 分支会追加汉化）
--====================================================================
local SAE = "https://api.luarmor.net/files/v4/loaders/d70c93187f4801ff5b907707597a24be.lua"
local RAP = "https://api.luarmor.net/files/v4/loaders/0dbcaa9e992477523d38a8284d7dbdef.lua"
local JFA = "https://raw.githubusercontent.com/tienkhanh1/Chilli-Hub-Script/refs/heads/main/JumpForAnimals"
local SAB = "https://raw.githubusercontent.com/tienkhanh1/spicy/refs/heads/main/Steal-a-Brainrot"
local MM2 = "https://api.luarmor.net/files/v4/loaders/2bf348894416e1d3deee40be756d42ff.lua"
local BROOK = "https://api.luarmor.net/files/v4/loaders/89190a03fd337349cef140d576357ba3.lua"

local byGameId = {
    [10563114921] = SAE,
    [10035204815] = RAP,
    [10690360998] = JFA,
    [7709344486] = SAB,
    [66654135] = MM2,
    [1686885941] = BROOK,
}

local byPlaceId = {
    [107778070777162] = SAE,
    [124216119978534] = RAP,
    [126870639873289] = JFA,
    [109983668079237] = SAB,
    [142823291] = MM2,
    [4924922222] = BROOK,
}

local gameId = game.GameId
while gameId == 0 and game.PlaceId == 0 do
    task.wait()
    gameId = game.GameId
end

local url = byGameId[gameId] or byPlaceId[game.PlaceId]
if not url then
    print("[Chilli汉化] 当前游戏不在 Chilli 支持列表里，脚本退出")
    return
end

local isSAE = (gameId == 10563114921) or (game.PlaceId == 107778070777162)

-- 先启动翻译器，再下载本体（本体下载失败/卡住/报错都不影响汉化）
if isSAE then
    task.spawn(startHanhua)
end

for _ = 1, 3 do
    local ok, source = pcall(game.HttpGet, game, url)
    if ok and type(source) == "string" and source ~= "" then
        local chunk = loadstring(source)
        if chunk then
            local okRun, err = pcall(chunk)
            if not okRun then
                warn("[Chilli汉化] Chilli 本体运行出错（汉化不受影响）：" .. tostring(err))
            end
        else
            warn("[Chilli汉化] Chilli 本体编译失败（汉化不受影响）")
        end
        return
    end
    task.wait(0.5)
end
warn("[Chilli汉化] 下载 Chilli 本体失败（请检查网络后重试）；游戏界面汉化仍在运行")
