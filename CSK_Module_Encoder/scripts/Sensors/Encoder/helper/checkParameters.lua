---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- Check if all relevant parameters are available
--**************************************************************************
local nameOfModule = 'CSK_Encoder'

local defaultParameters = require('Sensors/Encoder/Encoder_Parameters')

local function compare(content, defaultTable)
  for key, value in pairs(defaultTable) do
    if type(value) == 'table' then
      if content[key] == nil then
        _G.logger:info(nameOfModule .. ": Created missing parameters table '" .. tostring(key) .. "'")
        content[key] = {}
      end
      content[key] = compare(content[key], defaultTable[key])
    else
      if content[key] == nil then
        _G.logger:info(nameOfModule .. ": Missing parameter '" .. tostring(key) .. "'. Adding default value '" .. tostring(defaultTable[key]) .. "'")
        content[key] = defaultTable[key]
      end
    end
  end
  return content
end

local function checkParameters(params)

  local result
  for key, value in pairs(defaultParameters) do
    if type(value) == 'table' then
      if params[key] == nil then
        _G.logger:info(nameOfModule .. ": Created missing parameters table '" .. tostring(key) .. "'")
        params[key] = {}
      end
      params[key] = compare(params[key], defaultParameters[key])
    elseif params[key] == nil then
      _G.logger:info(nameOfModule .. ": Missing parameter '" .. tostring(key) .. "'. Adding default value '" .. tostring(defaultParameters[key]) .. "'")
      params[key] = defaultParameters[key]
    end
  end

  return params
end

return checkParameters