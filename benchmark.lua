local utf8 = require("utf8_validator")


local repeat_time = 1000000

local function benchmark_resty(func_name, func, str)
    ngx.update_time()
    local start_time = ngx.now()

    for i = 1, repeat_time do
        func(str)
    end

    ngx.update_time()
    ngx.say(string.format("- %s took %fms", func_name, (ngx.now() - start_time) * 1000))
end

local benchmark, socket = benchmark_resty

local function benchmark_lua(func_name, func, str)
    local start_time = socket.gettime()

    for i = 1, repeat_time do
        func(str)
    end

    ngx.say(string.format("- %s took %fms", func_name, (socket.gettime() - start_time) * 1000))
end

if not ngx then
    ngx = {
        say = print
    }
    benchmark = benchmark_lua
    socket = require("socket")
end



local test_cases = {
    { desc = 'plain ascii', str = 'Hello word',        valid = true },
    { desc = 'utf8 stuff',  str = '¢€𤭢',              valid = true },
    { desc = 'mixed stuff', str = 'Pay in €. Thanks.', valid = true },
}

for _, case in ipairs(test_cases) do
    ngx.say(string.format("benchmark for %s, string %s", case.desc, case.str))
    benchmark("validate", utf8.validate, case.str)
    benchmark("validate2", utf8.validate2, case.str)
end
