---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_Encoder'

local encoder_Model = {}

-- Check if CSK_UserManagement module can be used if wanted
encoder_Model.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

-- Check if CSK_PersistentData module can be used if wanted
encoder_Model.persistentModuleAvailable = CSK_PersistentData ~= nil or false

-- Default values for persistent data
-- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
encoder_Model.parametersName = 'CSK_Encoder_Parameter' -- name of parameter dataset to be used for this module
encoder_Model.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

-- Load script to communicate with the encoder_Model interface and give access
-- to the encoder_Model object.
-- Check / edit this script to see/edit functions which communicate with the UI
local setEncoder_ModelHandle = require('Sensors/Encoder/Encoder_Controller')
setEncoder_ModelHandle(encoder_Model)

--Loading helper functions if needed
encoder_Model.helperFuncs = require('Sensors/Encoder/helper/funcs')

-- Create parameters / instances for this module
encoder_Model.styleForUI = 'None' -- Optional parameter to set UI style
encoder_Model.version = Engine.getCurrentAppVersion() -- Version of module
encoder_Model.availableInterfaces = {} -- List of available connectors to connect the encoder
encoder_Model.availableForwardInterfaces = {} -- List of available interfaces to forward encoder data
encoder_Model.forwardAvailable = false -- Status if it is possible to forward encoder data on other interface (needs to be a SerialPort)

-- Check if specific API was loaded via
if _G.availableAPIs.specific then

  local serialPortList = Engine.getEnumValues('SerialPorts') -- List of serial connectors
  local sensorPortList = Engine.getEnumValues('DigitalInPorts') -- List of digital input connectors

  -- Summarize available connectors
  for key, value in ipairs(sensorPortList) do
    local sensorPort = string.sub(value, 1, 2)
    if encoder_Model.availableInterfaces[#encoder_Model.availableInterfaces] ~= sensorPort then
      table.insert(encoder_Model.availableInterfaces, sensorPort)
    end
  end
  for key, value in ipairs(serialPortList) do
    table.insert(encoder_Model.availableInterfaces, value)
    table.insert(encoder_Model.availableForwardInterfaces, value)
  end

  encoder_Model.availableEncoderIncrementSources = Engine.getEnumValues('EncoderIncrementSources') -- Relevant to set encoder source
  encoder_Model.availableDecoderInstances = Engine.getEnumValues('EncoderDecoderInstance') -- Relevant to set instance of decoder
  encoder_Model.availableIncrementSources = Engine.getEnumValues('IncrementSources') -- Relevant for Conveyor

  encoder_Model.flow = Flow.create() -- cFlow to pipe encoder signals to encoder algorithm
  encoder_Model.flow:setType('CFLOW')

  encoder_Model.timer = Timer.create() -- Timer to optionally pull encoder data periodically

  encoder_Model.conveyorTimeout = Conveyor.Timeout.create() -- Handle to optionally use conveyor timeouts

  encoder_Model.encoder = {} -- Handle of encoder
  for key, value in ipairs(encoder_Model.availableEncoderIncrementSources) do
    encoder_Model.encoder[value] = Encoder.create(value)
  end

  -- Parameters to be saved permanently if wanted
  encoder_Model.parameters = {}
  encoder_Model.parameters = encoder_Model.helperFuncs.defaultParameters.getParameters() -- Load default parameters

  encoder_Model.parameters.encoderInterface = encoder_Model.availableInterfaces[1] -- Source of connected encoder (e.g. S4, INC, SER1)

  -- Check if it is possible to forward the encoder data from the interface
  for _, value in ipairs(encoder_Model.availableForwardInterfaces) do
    if encoder_Model.parameters.encoderInterface == value then
      encoder_Model.forwardAvailable = true
    end
  end

  encoder_Model.parameters.forwardInterface = encoder_Model.availableForwardInterfaces[1] -- Interface to optionally forward encoder data
  encoder_Model.parameters.encoderSource = encoder_Model.availableEncoderIncrementSources[1]  -- Devices identifier of the encoder (e.g. ENC1)
  encoder_Model.parameters.decoderInstance = encoder_Model.availableDecoderInstances[1] or '' -- Instance of decoder to use
  encoder_Model.parameters.conveyorSource = encoder_Model.availableIncrementSources[1] or '' -- Source of increment source to be used for updating the system increment
end

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on UI style change
local function handleOnStyleChanged(theme)
  encoder_Model.styleForUI = theme
  Script.notifyEvent("Encoder_OnNewStatusCSKStyle", encoder_Model.styleForUI)
end
Script.register('CSK_PersistentData.OnNewStatusCSKStyle', handleOnStyleChanged)

--- Function to periodically pull increment / conveyor information
local function handleOnTimerExpired()
  local incr, timestamp = encoder_Model.encoder[encoder_Model.parameters.encoderSource]:getCurrentIncrement()
  local incrDirection = encoder_Model.encoder[encoder_Model.parameters.encoderSource]:getDirection()
  local incrTicksPerSec = encoder_Model.encoder[encoder_Model.parameters.encoderSource]:getTicksPerSecond()

  if encoder_Model.parameters.conveyorActive then
    local cIncr = Conveyor.getCurrentIncrement()
    local cIncrTransportMode = Conveyor.getTransportMode()
    local cIncrSpeed = Conveyor.getSpeed()
    Script.notifyEvent('Encoder_OnNewConveyorInfo', "Increment: " .. tostring(cIncr) .. ", TransportMode: " .. tostring(cIncrTransportMode) .. ", Speed: " .. tostring(cIncrSpeed) .. "mm/sec")
  end
  Script.notifyEvent('Encoder_OnNewIncrementInfo', "Increment: " .. tostring(incr) .. ", Direction: " .. tostring(incrDirection) .. ", TicksPerSecond: " .. tostring(incrTicksPerSec))
end
if _G.availableAPIs.specific then
  Timer.register(encoder_Model.timer, 'OnExpired', handleOnTimerExpired)
end

--- Function to configure the timer for periodically pull of encoder / conveyor data
local function setupTimer()
  if encoder_Model.parameters.timerActive and encoder_Model.parameters.encoderActive then
    encoder_Model.timer:stop()
    encoder_Model.timer:setPeriodic(true)
    encoder_Model.timer:setExpirationTime(encoder_Model.parameters.timerCycle)
    encoder_Model.timer:start()
  else
    encoder_Model.timer:stop()
  end
end
encoder_Model.setupTimer = setupTimer

--- Function to restart conveyor timeout
local function restartConveyorTimeout()
  if encoder_Model.parameters.conveyorTimeoutMode == 'TICKS' then
    encoder_Model.conveyorTimeout:startCount(encoder_Model.parameters.conveyorTimeoutValue)
  elseif encoder_Model.parameters.conveyorTimeoutMode == 'DISTANCE' then
    local suc = encoder_Model.conveyorTimeout:startDistance(encoder_Model.parameters.conveyorTimeoutValue)
  end
end

--- Function to notify when conveyor timeout expired and restart it
local function handleOnConveyorTimerExpired()
  restartConveyorTimeout()
  Script.notifyEvent('Encoder_OnConveyorTimeout', DateTime.getTimestamp())
end
if _G.availableAPIs.specific then
  Conveyor.Timeout.register(encoder_Model.conveyorTimeout, 'OnExpired', handleOnConveyorTimerExpired)
end

--- Function to configure conveyor timeout
local function setupConveyorTimeout()
  encoder_Model.conveyorTimeout:stop()
  if encoder_Model.parameters.conveyorTimeoutActive and encoder_Model.parameters.conveyorActive then
    restartConveyorTimeout()
  end
end
encoder_Model.setupConveyorTimeout = setupConveyorTimeout

--- Function to configure conveyor
local function setupConveyor()
  Conveyor.setSource(encoder_Model.parameters.conveyorSource)
  Conveyor.setResolution(encoder_Model.parameters.conveyorResolution)
  Conveyor.setPrescaler(encoder_Model.parameters.conveyorPrescaler)

  setupConveyorTimeout()
end
encoder_Model.setupConveyor = setupConveyor

--- Function to clear latest flow
local function clearFlow()
  if encoder_Model.flow then
    Script.releaseObject(encoder_Model.flow)
    encoder_Model.flow = nil
    collectgarbage()
  end
end
encoder_Model.clearFlow = clearFlow

--- Function to optionally free digital input port so CSK_DigitalIOManager module can manage this again
local function freeDigitalInPort()
  if string.sub(encoder_Model.parameters.encoderInterface, 1, 2) ~= 'SE' and string.sub(encoder_Model.parameters.encoderInterface, 1, 1) == 'S' then
    if CSK_DigitalIOManager then
      local suc1 = CSK_DigitalIOManager.freeSensorPort(encoder_Model.parameters.encoderInterface .. 'DI1')
      local suc2 = CSK_DigitalIOManager.freeSensorPort(encoder_Model.parameters.encoderInterface .. 'DI2')
    end
  end
end
encoder_Model.freeDigitalInPort = freeDigitalInPort

--- Function to setup encoder feature
local function setupEncoder()

  clearFlow()

  if encoder_Model.parameters.encoderActive then

    encoder_Model.flow = Flow.create()
    encoder_Model.flow:setType('CFLOW')

    if string.sub(encoder_Model.parameters.encoderInterface, 1, 2) == 'IN' then
      -- TTL encoder connected on INC port

      encoder_Model.flow:addProviderBlock('IncIn', 'Connector.Increment.OnReceive')
      encoder_Model.flow:setCreationParameter('IncIn', encoder_Model.parameters.encoderInterface)
      -- To extend in future
      --encoder_Model.flow:setInitialParameter('IncIn', 'Termination', encoder_Model.parameters.termination)

      encoder_Model.flow:addProviderBlock('Encoder', 'Encoder.Decoder.decodeIncrement')
      encoder_Model.flow:setCreationParameter('Encoder', encoder_Model.parameters.decoderInstance)
      encoder_Model.flow:setInitialParameter('Encoder', 'HighResolution', tostring(encoder_Model.parameters.decoderHighResolution))
      encoder_Model.flow:setInitialParameter('Encoder', 'CountMode', encoder_Model.parameters.decoderCountMode)
      encoder_Model.flow:setInitialParameter('Encoder', 'Prescaler', tostring(encoder_Model.parameters.decoderPrescaler))
      encoder_Model.flow:setInitialParameter('Encoder', 'NumberOfPhases', encoder_Model.parameters.decoderNumberOfPhases)

      encoder_Model.flow:addLink('IncIn:A_in', 'Encoder:A_in')
      encoder_Model.flow:addLink('IncIn:B_in', 'Encoder:B_in')

      if encoder_Model.parameters.forwardActive == true then
        if encoder_Model.parameters.forwardInterface ~= encoder_Model.parameters.encoderInterface then
          encoder_Model.flow:addProviderBlock('Transmit', 'Connector.Serial.transmit')
          encoder_Model.flow:setCreationParameter('Transmit', encoder_Model.parameters.forwardInterface)

          encoder_Model.flow:addLink('IncIn:A_in', 'Transmit:A_out')
          encoder_Model.flow:addLink('IncIn:B_in', 'Transmit:B_out')
        else
          _G.logger:warning(nameOfModule .. ": Not possible to forward encoder data on this interface.")
        end
      end

      encoder_Model.flow:start()

    elseif string.sub(encoder_Model.parameters.encoderInterface, 1, 2) == 'SE' then
      -- TTL encoder connected on serial port

      encoder_Model.flow:addProviderBlock('SerIn', 'Connector.Serial.OnReceive')
      encoder_Model.flow:setCreationParameter('SerIn', encoder_Model.parameters.encoderInterface)
      -- To extend in future
      --encoder_Model.flow:setInitialParameter('SerIn', 'Termination', encoder_Model.parameters.termination)

      encoder_Model.flow:addProviderBlock('Encoder', 'Encoder.Decoder.decodeIncrement')
      encoder_Model.flow:setCreationParameter('Encoder', encoder_Model.parameters.decoderInstance)
      encoder_Model.flow:setInitialParameter('Encoder', 'HighResolution', tostring(encoder_Model.parameters.decoderHighResolution))
      encoder_Model.flow:setInitialParameter('Encoder', 'CountMode', encoder_Model.parameters.decoderCountMode)
      encoder_Model.flow:setInitialParameter('Encoder', 'Prescaler', tostring(encoder_Model.parameters.decoderPrescaler))
      encoder_Model.flow:setInitialParameter('Encoder', 'NumberOfPhases', encoder_Model.parameters.decoderNumberOfPhases)

      encoder_Model.flow:addLink('SerIn:A_in', 'Encoder:A_in')
      encoder_Model.flow:addLink('SerIn:B_in', 'Encoder:B_in')

      if encoder_Model.parameters.forwardActive == true then
        if encoder_Model.parameters.forwardInterface ~= encoder_Model.parameters.encoderInterface then
          encoder_Model.flow:addProviderBlock('Transmit', 'Connector.Increment.transmit')
          encoder_Model.flow:setCreationParameter('Transmit', encoder_Model.parameters.forwardInterface)

          encoder_Model.flow:addLink('IncIn:A_in', 'Transmit:A_out')
          encoder_Model.flow:addLink('IncIn:B_in', 'Transmit:B_out')
        else
          _G.logger:warning(nameOfModule .. ": Not possible to forward encoder data on this interface.")
        end
      end

      encoder_Model.flow:start()

    elseif string.sub(encoder_Model.parameters.encoderInterface, 1, 1) == 'S' then
      -- HTL encoder connected on sensor port (HTL)

      if CSK_DigitalIOManager then
        local suc1 = CSK_DigitalIOManager.blockSensorPort(encoder_Model.parameters.encoderInterface .. 'DI1')
        local suc2 = CSK_DigitalIOManager.blockSensorPort(encoder_Model.parameters.encoderInterface .. 'DI2')
      end

      encoder_Model.flow:addProviderBlock('DigitalIn1', 'Connector.DigitalIn.OnChange')
      encoder_Model.flow:setCreationParameter('DigitalIn1', encoder_Model.parameters.encoderInterface .. 'DI1')

      -- To extend in future
      --encoder_Model.flow:setInitialParameter('DigitalIn1'..input, 'Logic', digitalIOManager_Model.parameters.inputLogic[input])
      --encoder_Model.flow:setInitialParameter('DigitalIn1'..input, 'DebounceMode', digitalIOManager_Model.parameters.inDebounceMode[input])
      --encoder_Model.flow:setInitialParameter('DigitalIn1'..input, 'DebounceValue', digitalIOManager_Model.parameters.inDebounceValue[input])

      encoder_Model.flow:addProviderBlock('DigitalIn2', 'Connector.DigitalIn.OnChange')
      encoder_Model.flow:setCreationParameter('DigitalIn2', encoder_Model.parameters.encoderInterface .. 'DI2')

      encoder_Model.flow:addProviderBlock('Encoder', 'Encoder.Decoder.decodeIncrement')
      encoder_Model.flow:setCreationParameter('Encoder', encoder_Model.parameters.decoderInstance)
      encoder_Model.flow:setInitialParameter('Encoder', 'HighResolution', tostring(encoder_Model.parameters.decoderHighResolution))
      encoder_Model.flow:setInitialParameter('Encoder', 'CountMode', encoder_Model.parameters.decoderCountMode)
      encoder_Model.flow:setInitialParameter('Encoder', 'Prescaler', tostring(encoder_Model.parameters.decoderPrescaler))
      encoder_Model.flow:setInitialParameter('Encoder', 'NumberOfPhases', encoder_Model.parameters.decoderNumberOfPhases)

      encoder_Model.flow:addLink('DigitalIn1:newState', 'Encoder:A_in')
      encoder_Model.flow:addLink('DigitalIn2:newState', 'Encoder:B_in')

      encoder_Model.flow:start()
    end

    setupTimer()
    if encoder_Model.parameters.conveyorActive then
      setupConveyor()
      setupConveyorTimeout()
    end
  end
end
encoder_Model.setupEncoder = setupEncoder

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************

return encoder_Model
