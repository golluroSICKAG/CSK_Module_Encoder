-- Block namespace
local BLOCK_NAMESPACE = "Encoder_FC.OnNewData"
local nameOfModule = 'CSK_Encoder'

--*************************************************************
--*************************************************************

-- Required to keep track of already allocated resource
local instanceTable = {}

local function register(handle, _ , callback)

  Container.remove(handle, "CB_Function")
  Container.add(handle, "CB_Function", callback)

  local mode = Container.get(handle, 'Mode')

  local function localCallback()
    if callback ~= nil then
      if mode == 'ENCODER' then
        Script.callFunction(callback, 'CSK_Encoder.OnNewIncrementInfo')
      elseif mode == 'CONVEYOR' then
        Script.callFunction(callback, 'CSK_Encoder.OnNewConveyorInfo')
      elseif mode == 'TIMEOUT' then
        Script.callFunction(callback, 'CSK_Encoder.OnConveyorTimeout')
      elseif mode == 'HANDLE_ENCODER' then
        Script.callFunction(callback, 'HANDLE_ENC')
      elseif mode == 'HANDLE_TIMEOUT' then
        Script.callFunction(callback, 'HANDLE_TIM')
      end
    else
      _G.logger:warning(nameOfModule .. ": " .. BLOCK_NAMESPACE .. ".CB_Function missing!")
    end
  end
  Script.register('CSK_FlowConfig.OnNewFlowConfig', localCallback)

  return true
end
Script.serveFunction(BLOCK_NAMESPACE ..".register", register)

--*************************************************************
--*************************************************************
local function create(mode)

  local instanceName = tostring(mode)

  -- Check if same instance is already configured
  if instanceTable[instanceName] ~= nil then
    _G.logger:warning(nameOfModule .. "Instance invalid or already in use, please choose another one")
    return nil
  else
    -- Otherwise create handle and store the restriced resource
    local handle = Container.create()
    instanceTable[instanceName] = instanceTable
    Container.add(handle, 'Mode', mode)
    Container.add(handle, "CB_Function", "")
    return handle
  end
end
Script.serveFunction(BLOCK_NAMESPACE .. ".create", create)

--- Function to reset instances if FlowConfig was cleared
local function handleOnClearOldFlow()
  Script.releaseObject(instanceTable)
  instanceTable = {}
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)