--MIT License
--
--Copyright (c) 2023 SICK AG
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.

---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************

-- If app property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection
_G.availableAPIs = require('Sensors/Encoder/helper/checkAPIs') -- can be used to adjust function scope of the module related on available APIs of the device
-----------------------------------------------------------
-- Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')
_G.logHandle = Log.Handler.create()
_G.logHandle:attachToSharedLogger('ModuleLogger')
_G.logHandle:setConsoleSinkEnabled(false) --> Set to TRUE if CSK_Logger module is not used
_G.logHandle:setLevel("ALL")
_G.logHandle:applyConfig()
-----------------------------------------------------------

-- Loading script regarding encoder_Model
-- Check this script regarding encoder_Model parameters and functions
_G.encoder_Model = require('Sensors/Encoder/Encoder_Model')

-- If using FlowConfig activate following code line
require('Sensors/Encoder/FlowConfig/Encoder_FlowConfig')

if _G.availableAPIs.default == false or _G.availableAPIs.specific == false then
  _G.logger:warning("CSK_Encoder: Relevant CROWN(s) not available on device. Module is not supported...")
end

--**************************************************************************
--**********************End Global Scope ***********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on startup event of the app
local function main()

  ----------------------------------------------------------------------------------------
  -- INFO: Please check if module will eventually load inital configuration triggered via
  --       event CSK_PersistentData.OnInitialDataLoaded
  --       (see internal variable encoderModel.parameterLoadOnReboot)
  --       If so, the app will trigger the "OnDataLoadedOnReboot" event if ready after loading parameters
  --
  -- Can be used e.g. like this
  --[[

  CSK_Encoder.setEncoderInterface('INC1')

  CSK_Encoder.setEncoderSource('ENC1')
  CSK_Encoder.setDecoderInstance('1')
  CSK_Encoder.setDecoderCountMode('FORWARD_MOVEMENT')
  CSK_Encoder.setDecoderHighResoltuion(false)
  CSK_Encoder.setDecoderNumberOfPhases('DUAL_PHASE')

  CSK_Encoder.setConveyorSource('ENC1')

  CSK_Encoder.setEncoderFeatureActive(true)
  CSK_Encoder.setConveyorActive(true)

  CSK_Encoder.setTimerCycle(500)
  CSK_Encoder.setTimerActive(true)

  CSK_Encoder.setConveyorTimeoutMode('DISTANCE')
  CSK_Encoder.setConveyorTimeoutValue(1000)
  CSK_Encoder.setConveyorTimeoutActive(true)

  ]]
  ----------------------------------------------------------------------------------------

  CSK_Encoder.pageCalled() -- Update UI

end
Script.register("Engine.OnStarted", main)

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************
