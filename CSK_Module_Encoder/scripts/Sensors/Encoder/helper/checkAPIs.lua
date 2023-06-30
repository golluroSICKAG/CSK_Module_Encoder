---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- Load all relevant APIs for this module
--**************************************************************************

local availableAPIs = {}

local function loadAPIs()
  CSK_Encoder = require 'API.CSK_Encoder'

  Container = require 'API.Container'
  DateTime = require 'API.DateTime'
  Engine = require 'API.Engine'
  Flow = require 'API.Flow'
  Log = require 'API.Log'
  Log.Handler = require 'API.Log.Handler'
  Log.SharedLogger = require 'API.Log.SharedLogger'
  Object = require 'API.Object'
  Timer = require 'API.Timer'

  -- Check if related CSK modules are available to be used
  local appList = Engine.listApps()
  for i = 1, #appList do
    if appList[i] == 'CSK_Module_PersistentData' then
      CSK_PersistentData = require 'API.CSK_PersistentData'
    elseif appList[i] == 'CSK_Module_UserManagement' then
      CSK_UserManagement = require 'API.CSK_UserManagement'
    end
  end
end

local function loadSpecificAPIs()
  -- If you want to check for specific APIs/functions supported on the device the module is running, place relevant APIs here
  -- e.g.:
  Conveyor = require 'API.Conveyor'
  Conveyor.Timeout = require 'API.Conveyor.Timeout'
  Encoder = require 'API.Encoder'
end

local function checkRelatedAPIs()
  CSK_DigitalIOManager = require 'API.CSK_DigitalIOManager'
end

availableAPIs.default = xpcall(loadAPIs, debug.traceback) -- TRUE if all default APIs were loaded correctly
availableAPIs.specific = xpcall(loadSpecificAPIs, debug.traceback) -- TRUE if all specific APIs were loaded correctly
availableAPIs.relations = xpcall(checkRelatedAPIs, debug.traceback) -- TRUE if all specific APIs were loaded correctly

return availableAPIs
--**************************************************************************