local output = io.open('output.txt', 'w')
print = function(...)
    output:write(...)
    output:write('\n')
end

function string.split(str, delimiter)
    str = tostring(str)
    delimiter = tostring(delimiter)
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

local function parseSlk(filename)
	local slk = { cnt = 0, }
	local file = io.open(filename)
	for line in file:lines() do
		slk[slk.cnt] = string.split(line, '\t')
		slk.cnt = slk.cnt + 1
	end

	slk.name2idx = {}
	for i = 1, #slk[0] do
		slk.name2idx[slk[0][i]] = i
	end

	setmetatable(slk, {
		__index = function(t, k)
			return slk.data[k]
		end
		})

	slk.data = {}
	for i = 1, #slk do
		slk.data[slk[i][1]] = slk[i]

		setmetatable(slk[i], {
			__index = function(t, k)
				return t[slk.name2idx[k]]
			end
			})
	end

	return slk
end

local function dump(t)
	for k, v in pairs(t) do
		print(k, ' : ', v)
	end
end

local item_slk = parseSlk('item.xls')

local item_list = {
    '不朽之守护|深渊之刃|林肯|极限球|疾行鞋',
    '雷霆之怒|大天使之剑|林肯|恶魔之矢|疾行鞋',
    '群星之怒|雷霆之怒|银月长矛|金箍棒|恶魔之矢|疾行鞋',
    '水晶之塔|巫师之冠',
    '远古遗物|深渊之刃|大炮|十字军巨盾|逐日者法典|分身斧|银月长矛|恶魔之矢|疾行鞋'
}

local need_list = {}

local function addNeed(name, cnt)
    if not need_list[name] then
        need_list[name] = 0
    end

    need_list[name] = need_list[name] + (cnt or 1)
end

local function checkItem(name)
    local info = item_slk[name]
    if not info then
        print('can;t find ' .. name)
        return
    end

    if info.combineList ~= '' then
        local items = string.split(info.combineList, '|')
        for _, item in pairs(items) do
            checkItem(item)
        end
    elseif info.piece ~= '' then
        addNeed(name .. '的碎片', tonumber(info.piece))
    else
        addNeed(name)
    end
end

for _, v in pairs(item_list) do
    local items = string.split(v, '|')
    for _, item in pairs(items) do
        checkItem(item)
    end
end

-- print need

for k, v in pairs(need_list) do
    print(k, v)
end

output:flush()
output:close()
