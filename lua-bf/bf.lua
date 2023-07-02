local math = require 'math'
local module = {
  memory_size = 30000,
  memory_overflow = 254,
  memory_signed = false
}

local create_bf = function (content, input, output)
  -- Check that the options have been set correctly
  if not module.memory_size and module.memory_overflow == nil then
    error("To use memory_size, memory_overflow must be set")
  end

  -- Memory management
  local mem = {}
  local ptr = 0

  local inc_mem = function ()
    ptr = ptr + 1

    -- Out of bounds check
    if ptr > module.memory_size then
      ptr = 0
    end

    -- Initialize uninitialized memory
    if mem[ptr] == nil then
      mem[ptr] = 0
    end
  end

  local dec_memory = function ()
    ptr = ptr - 1

    -- Out of bounds check
    if ptr < 0 then
      ptr = module.memory_size
    end

    -- Initialize uninitialized memory
    if mem[ptr] == nil then
      mem[ptr] = 0
    end
  end

  -- Cell manipulation
  local increment = function ()
    mem[ptr] = mem[ptr] + 1

    if module.memory_overflow ~= nil and mem[ptr] > module.memory_overflow then
      mem[ptr] = 0

    end
  end

  local decrement = function ()
    mem[ptr] = mem[ptr] - 1
    if not module.memory_signed and mem[ptr] < 0 then
      mem[ptr] = module.memory_overflow
    end
  end

  -- IO
  local input = function ()
    local value = input()
    if not module.memory_signed then
      value = math.abs(value)
    end

    if module.memory_overflow ~= nil and value > module.memory_overflow then
      value = value % module.memory_overflow
    end

    mem[ptr] = value
  end

  local output = function ()

  end
end

setmetatable(module, {
  __call = function (_, content, input, output)
    return create_bf(content, input, output)
  end
})


