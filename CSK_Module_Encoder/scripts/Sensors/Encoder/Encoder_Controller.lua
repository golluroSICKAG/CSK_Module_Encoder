---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the Encoder_Model
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_Encoder'

-- Timer to update UI via events after page was loaded
local tmrEncoder = Timer.create()
tmrEncoder:setExpirationTime(300)
tmrEncoder:setPeriodic(false)

-- Reference to global handle
local encoder_Model

-- ************************ UI Events Start ********************************

Script.serveEvent('CSK_Encoder.OnNewIncrementInfo', 'Encoder_OnNewIncrementInfo')
Script.serveEvent('CSK_Encoder.OnNewConveyorInfo', 'Encoder_OnNewConveyorInfo')
Script.serveEvent('CSK_Encoder.OnConveyorTimeout', 'Encoder_OnConveyorTimeout')

Script.serveEvent('CSK_Encoder.OnNewStatusEncoderFeatureActive', 'Encoder_OnNewStatusEncoderFeatureActive')

Script.serveEvent('CSK_Encoder.OnNewEncoderInterfaceList', 'Encoder_OnNewEncoderInterfaceList')
Script.serveEvent('CSK_Encoder.OnNewStatusEncoderInterface', 'Encoder_OnNewStatusEncoderInterface')

Script.serveEvent('CSK_Encoder.OnNewEncoderIncrementSourceList', 'Encoder_OnNewEncoderIncrementSourceList')
Script.serveEvent('CSK_Encoder.OnNewStatusEncoderSource', 'Encoder_OnNewStatusEncoderSource')

Script.serveEvent('CSK_Encoder.OnNewDecoderInstanceList', 'Encoder_OnNewDecoderInstanceList')
Script.serveEvent('CSK_Encoder.OnNewStatusDecoderInstance', 'Encoder_OnNewStatusDecoderInstance')
Script.serveEvent('CSK_Encoder.OnNewStatusDecoderHighResolution', 'Encoder_OnNewStatusDecoderHighResolution')
Script.serveEvent('CSK_Encoder.OnNewStatusDecoderCountMode', 'Encoder_OnNewStatusDecoderCountMode')
Script.serveEvent('CSK_Encoder.OnNewStatusDecoderPrescaler', 'Encoder_OnNewStatusDecoderPrescaler')
Script.serveEvent('CSK_Encoder.OnNewStatusDecoderNumberOfPhases', 'Encoder_OnNewStatusDecoderNumberOfPhases')

Script.serveEvent('CSK_Encoder.OnNewStatusTimerActive', 'Encoder_OnNewStatusTimerActive')
Script.serveEvent('CSK_Encoder.OnNewStatusTimerCycle', 'Encoder_OnNewStatusTimerCycle')

Script.serveEvent('CSK_Encoder.OnNewStatusConveyorActive', 'Encoder_OnNewStatusConveyorActive')
Script.serveEvent('CSK_Encoder.OnNewConveyorSourceList', 'Encoder_OnNewConveyorSourceList')
Script.serveEvent('CSK_Encoder.OnNewStatusConveyorSource', 'Encoder_OnNewStatusConveyorSource')
Script.serveEvent('CSK_Encoder.OnNewStatusConveyorResolution', 'Encoder_OnNewStatusConveyorResolution')
Script.serveEvent('CSK_Encoder.OnNewStatusConveyorPrescaler', 'Encoder_OnNewStatusConveyorPrescaler')

Script.serveEvent('CSK_Encoder.OnNewStatusConveyorTimeoutActive', 'Encoder_OnNewStatusConveyorTimeoutActive')
Script.serveEvent('CSK_Encoder.OnNewStatusConveyorTimeoutMode', 'Encoder_OnNewStatusConveyorTimeoutMode')
Script.serveEvent('CSK_Encoder.OnNewStatusConveyorTimeoutValue', 'Encoder_OnNewStatusConveyorTimeoutValue')

Script.serveEvent('CSK_Encoder.OnNewStatusModuleIsActive', 'Encoder_OnNewStatusModuleIsActive')
Script.serveEvent("CSK_Encoder.OnNewStatusLoadParameterOnReboot", "Encoder_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_Encoder.OnPersistentDataModuleAvailable", "Encoder_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_Encoder.OnNewParameterName", "Encoder_OnNewParameterName")
Script.serveEvent("CSK_Encoder.OnDataLoadedOnReboot", "Encoder_OnDataLoadedOnReboot")

Script.serveEvent('CSK_Encoder.OnUserLevelOperatorActive', 'Encoder_OnUserLevelOperatorActive')
Script.serveEvent('CSK_Encoder.OnUserLevelMaintenanceActive', 'Encoder_OnUserLevelMaintenanceActive')
Script.serveEvent('CSK_Encoder.OnUserLevelServiceActive', 'Encoder_OnUserLevelServiceActive')
Script.serveEvent('CSK_Encoder.OnUserLevelAdminActive', 'Encoder_OnUserLevelAdminActive')

-- ************************ UI Events End **********************************

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("Encoder_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("Encoder_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("Encoder_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("Encoder_OnUserLevelAdminActive", status)
end

--- Function to get access to the encoder_Model object
---@param handle handle Handle of encoder_Model object
local function setEncoder_Model_Handle(handle)
  encoder_Model = handle
  if encoder_Model.userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)
end

--- Function to update user levels
local function updateUserLevel()
  if encoder_Model.userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("Encoder_OnUserLevelAdminActive", true)
    Script.notifyEvent("Encoder_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("Encoder_OnUserLevelServiceActive", true)
    Script.notifyEvent("Encoder_OnUserLevelOperatorActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrEncoder()

  updateUserLevel()

  Script.notifyEvent("Encoder_OnNewStatusModuleIsActive", encoder_Model.moduleActive)

  if encoder_Model.moduleActive then

    Script.notifyEvent("Encoder_OnNewStatusEncoderFeatureActive", encoder_Model.parameters.encoderActive)

    Script.notifyEvent("Encoder_OnNewEncoderInterfaceList", encoder_Model.helperFuncs.createStringListBySimpleTable(encoder_Model.availableInterfaces))
    Script.notifyEvent("Encoder_OnNewStatusEncoderInterface", encoder_Model.parameters.encoderInterface)

    Script.notifyEvent("Encoder_OnNewEncoderIncrementSourceList", encoder_Model.helperFuncs.createStringListBySimpleTable(encoder_Model.availableEncoderIncrementSources))
    Script.notifyEvent("Encoder_OnNewStatusEncoderSource", encoder_Model.parameters.encoderSource)

    Script.notifyEvent("Encoder_OnNewDecoderInstanceList", encoder_Model.helperFuncs.createStringListBySimpleTable(encoder_Model.availableDecoderInstances))
    Script.notifyEvent("Encoder_OnNewStatusDecoderInstance", encoder_Model.parameters.decoderInstance)
    Script.notifyEvent("Encoder_OnNewStatusDecoderHighResolution", encoder_Model.parameters.decoderHighResolution)
    Script.notifyEvent("Encoder_OnNewStatusDecoderCountMode", encoder_Model.parameters.decoderCountMode)
    Script.notifyEvent("Encoder_OnNewStatusDecoderPrescaler", encoder_Model.parameters.decoderPrescaler)
    Script.notifyEvent("Encoder_OnNewStatusDecoderNumberOfPhases", encoder_Model.parameters.decoderNumberOfPhases)

    Script.notifyEvent("Encoder_OnNewStatusTimerActive", encoder_Model.parameters.timerActive)
    Script.notifyEvent("Encoder_OnNewStatusTimerCycle", encoder_Model.parameters.timerCycle)

    Script.notifyEvent("Encoder_OnNewConveyorSourceList", encoder_Model.helperFuncs.createStringListBySimpleTable(encoder_Model.availableIncrementSources))
    Script.notifyEvent("Encoder_OnNewStatusConveyorSource", encoder_Model.parameters.conveyorSource)
    Script.notifyEvent("Encoder_OnNewStatusConveyorActive", encoder_Model.parameters.conveyorActive)
    Script.notifyEvent("Encoder_OnNewStatusConveyorResolution", encoder_Model.parameters.conveyorResolution)
    Script.notifyEvent("Encoder_OnNewStatusConveyorPrescaler", encoder_Model.parameters.conveyorPrescaler)

    Script.notifyEvent("Encoder_OnNewStatusConveyorTimeoutActive", encoder_Model.parameters.conveyorTimeoutActive)
    Script.notifyEvent("Encoder_OnNewStatusConveyorTimeoutMode", encoder_Model.parameters.conveyorTimeoutMode)
    Script.notifyEvent("Encoder_OnNewStatusConveyorTimeoutValue", encoder_Model.parameters.conveyorTimeoutValue)

    Script.notifyEvent("Encoder_OnNewStatusLoadParameterOnReboot", encoder_Model.parameterLoadOnReboot)
    Script.notifyEvent("Encoder_OnPersistentDataModuleAvailable", encoder_Model.persistentModuleAvailable)
    Script.notifyEvent("Encoder_OnNewParameterName", encoder_Model.parametersName)
  end
end
Timer.register(tmrEncoder, "OnExpired", handleOnExpiredTmrEncoder)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrEncoder:start()
  return ''
end
Script.serveFunction("CSK_Encoder.pageCalled", pageCalled)

local function getEncoderHandle()
  if encoder_Model.encoder[encoder_Model.parameters.encoderSource] then
    return encoder_Model.encoder[encoder_Model.parameters.encoderSource]
  else
    return nil
  end
end
Script.serveFunction('CSK_Encoder.getEncoderHandle', getEncoderHandle)

local function setEncoderFeatureActive(status)
  _G.logger:info(nameOfModule .. ": Set encoder features status to " .. tostring(status))
  encoder_Model.parameters.encoderActive = status
  if status == false then
    -- Check if digital input port needs to be freed for CSK_DigitalIOManager module
    encoder_Model.freeDigitalInPort()
  end
  encoder_Model.setupEncoder()
  handleOnExpiredTmrEncoder()
end
Script.serveFunction('CSK_Encoder.setEncoderFeatureActive', setEncoderFeatureActive)

local function setEncoderInterface(interface)
  _G.logger:info(nameOfModule .. ": Set encoder interface to " .. interface)
  encoder_Model.freeDigitalInPort()
  encoder_Model.parameters.encoderInterface = interface
  encoder_Model.setupEncoder()
  handleOnExpiredTmrEncoder()
end
Script.serveFunction('CSK_Encoder.setEncoderInterface', setEncoderInterface)

local function setEncoderSource(source)
  _G.logger:info(nameOfModule .. ": Set encoder source to " .. source)
  encoder_Model.parameters.encoderSource = source
  encoder_Model.setupEncoder()
  handleOnExpiredTmrEncoder()
end
Script.serveFunction('CSK_Encoder.setEncoderSource', setEncoderSource)

local function setDecoderInstance(instance)
  _G.logger:info(nameOfModule .. ": Set decoder instance to " .. instance)
  encoder_Model.parameters.decoderInstance = instance
  encoder_Model.setupEncoder()
  handleOnExpiredTmrEncoder()
end
Script.serveFunction('CSK_Encoder.setDecoderInstance', setDecoderInstance)

local function setDecoderHighResoltuion(status)
  _G.logger:info(nameOfModule .. ": Set decoder high resolution status to " .. tostring(status))
  encoder_Model.parameters.decoderHighResolution = status
  encoder_Model.setupEncoder()
  handleOnExpiredTmrEncoder()
end
Script.serveFunction('CSK_Encoder.setDecoderHighResoltuion', setDecoderHighResoltuion)

local function setDecoderCountMode(mode)
  _G.logger:info(nameOfModule .. ": Set decoder count mode to " .. mode)
  encoder_Model.parameters.decoderCountMode = mode
  encoder_Model.setupEncoder()
  handleOnExpiredTmrEncoder()
end
Script.serveFunction('CSK_Encoder.setDecoderCountMode', setDecoderCountMode)

local function setDecoderPrescaler(prescaler)
  _G.logger:info(nameOfModule .. ": Set decoder prescaler to " .. tostring(prescaler))
  encoder_Model.parameters.decoderPrescaler = prescaler
  encoder_Model.setupEncoder()
  handleOnExpiredTmrEncoder()
end
Script.serveFunction('CSK_Encoder.setDecoderPrescaler', setDecoderPrescaler)

local function setDecoderNumberOfPhases(phases)
  _G.logger:info(nameOfModule .. ": Set decoder numberOfPhases to " .. phases)
  encoder_Model.parameters.decoderNumberOfPhases = phases
  encoder_Model.setupEncoder()
  handleOnExpiredTmrEncoder()
end
Script.serveFunction('CSK_Encoder.setDecoderNumberOfPhases', setDecoderNumberOfPhases)

local function setTimerActive(status)
  _G.logger:info(nameOfModule .. ": Set cycle timer status to " .. tostring(status))
  encoder_Model.parameters.timerActive = status
  encoder_Model.setupTimer()
  handleOnExpiredTmrEncoder()
end
Script.serveFunction('CSK_Encoder.setTimerActive', setTimerActive)

local function setTimerCycle(time)
  _G.logger:info(nameOfModule .. ": Set cycle time to " .. tostring(time))
  encoder_Model.parameters.timerCycle = time
  encoder_Model.setupTimer()
  handleOnExpiredTmrEncoder()
end
Script.serveFunction('CSK_Encoder.setTimerCycle', setTimerCycle)

local function setConveyorActive(status)
  _G.logger:info(nameOfModule .. ": Set conveyor status to " .. tostring(status))
  encoder_Model.parameters.conveyorActive = status
  encoder_Model.setupConveyor()
  handleOnExpiredTmrEncoder()
end
Script.serveFunction('CSK_Encoder.setConveyorActive', setConveyorActive)

local function setConveyorSource(source)
  _G.logger:info(nameOfModule .. ": Set conveyor source to " .. source)
  encoder_Model.parameters.conveyorSource = source
  encoder_Model.setupConveyor()
  handleOnExpiredTmrEncoder()
end
Script.serveFunction('CSK_Encoder.setConveyorSource', setConveyorSource)

local function setConveyorResolution(resolution)
  _G.logger:info(nameOfModule .. ": Set conveyor resolution to " .. tostring(resolution))
  encoder_Model.parameters.conveyorResolution = resolution
  encoder_Model.setupConveyor()
  handleOnExpiredTmrEncoder()
end
Script.serveFunction('CSK_Encoder.setConveyorResolution', setConveyorResolution)

local function setConveyorPrescaler(prescaler)
  _G.logger:info(nameOfModule .. ": Set conveyor prescaler to " .. tostring(prescaler))
  encoder_Model.parameters.conveyorPrescaler = prescaler
  encoder_Model.setupConveyor()
  handleOnExpiredTmrEncoder()
end
Script.serveFunction('CSK_Encoder.setConveyorPrescaler', setConveyorPrescaler)

local function getConveyorTimeoutHandle()
  if encoder_Model.conveyorTimeout then
    return encoder_Model.conveyorTimeout
  else
    return nil
  end
end
Script.serveFunction('CSK_Encoder.getConveyorTimeoutHandle', getConveyorTimeoutHandle)

local function setConveyorTimeoutActive(status)
  _G.logger:info(nameOfModule .. ": Set conveyor timeout active status to " .. tostring(status))
  encoder_Model.parameters.conveyorTimeoutActive = status
  encoder_Model.setupConveyorTimeout()
  handleOnExpiredTmrEncoder()
end
Script.serveFunction('CSK_Encoder.setConveyorTimeoutActive', setConveyorTimeoutActive)

local function setConveyorTimeoutMode(mode)
  _G.logger:info(nameOfModule .. ": Set conveyor timeout mode to " .. mode)
  encoder_Model.parameters.conveyorTimeoutMode = mode
  encoder_Model.setupConveyorTimeout()
  handleOnExpiredTmrEncoder()
end
Script.serveFunction('CSK_Encoder.setConveyorTimeoutMode', setConveyorTimeoutMode)

local function setConveyorTimeoutValue(value)
  _G.logger:info(nameOfModule .. ": Set conveyor timeout value to " .. tostring(value))
  encoder_Model.parameters.conveyorTimeoutValue = value
  encoder_Model.setupConveyorTimeout()
  handleOnExpiredTmrEncoder()
end
Script.serveFunction('CSK_Encoder.setConveyorTimeoutValue', setConveyorTimeoutValue)

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:info(nameOfModule .. ": Set parameter name: " .. tostring(name))
  encoder_Model.parametersName = name
end
Script.serveFunction("CSK_Encoder.setParameterName", setParameterName)

local function sendParameters()
  if encoder_Model.persistentModuleAvailable then
    CSK_PersistentData.addParameter(encoder_Model.helperFuncs.convertTable2Container(encoder_Model.parameters), encoder_Model.parametersName)
    CSK_PersistentData.setModuleParameterName(nameOfModule, encoder_Model.parametersName, encoder_Model.parameterLoadOnReboot)
    _G.logger:info(nameOfModule .. ": Send Encoder parameters with name '" .. encoder_Model.parametersName .. "' to CSK_PersistentData module.")
    CSK_PersistentData.saveData()
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_Encoder.sendParameters", sendParameters)

local function loadParameters()
  if encoder_Model.persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(encoder_Model.parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters from CSK_PersistentData module.")
      encoder_Model.parameters = encoder_Model.helperFuncs.convertContainer2Table(data)
      encoder_Model.setupEncoder()
      CSK_Encoder.pageCalled()
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_Encoder.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  encoder_Model.parameterLoadOnReboot = status
  _G.logger:info(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_Encoder.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  _G.logger:info(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')
  if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

    _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

    encoder_Model.persistentModuleAvailable = false
  else

    local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule)

    if parameterName then
      encoder_Model.parametersName = parameterName
      encoder_Model.parameterLoadOnReboot = loadOnReboot
    end

    if encoder_Model.parameterLoadOnReboot then
      loadParameters()
    end
    Script.notifyEvent('Encoder_OnDataLoadedOnReboot')
  end
end
if CSK_DigitalIOManager then
  Script.register('CSK_DigitalIOManager.OnDataLoadedOnReboot', handleOnInitialDataLoaded)
else
  Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)
end

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return setEncoder_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

