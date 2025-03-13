---@diagnostic disable: redundant-parameter, undefined-global

--***************************************************************
-- Inside of this script, you will find the relevant parameters
-- for this module and its default values
--***************************************************************

local functions = {}

local function getParameters()

  local encoderParameters = {}

  encoderParameters.flowConfigPriority = false -- Status if FlowConfig should have priority for FlowConfig relevant configurations

  encoderParameters.encoderActive = false -- Status if encoder features are active

  encoderParameters.decoderHighResolution = false -- Status if using high resolution or robust mode
  encoderParameters.decoderCountMode = 'POSITIVE_MOVEMENT' -- Select how increments will be counted, 'BIDIRECTIONAL', 'POSITIVE_MOVEMENT', 'NEGATIVE_MOVEMENT', 'FORWARD_MOVEMENT', 'BACKWARD_MOVEMENT'
  encoderParameters.decoderPrescaler = 1 -- Prescaler value for the increment input
  encoderParameters.decoderNumberOfPhases = 'DUAL_PHASE' -- Select 'SINGLE_PHASE' (A_in) / 'DUAL_PHASE' (A_in and B_in)

  encoderParameters.timerActive = false -- Status if encoder data should be pulled periodically
  encoderParameters.timerCycle = 1000 -- Cycle time to get increment values

  encoderParameters.conveyorActive = false -- Status if conveyor featues should be used
  encoderParameters.conveyorResolution = 1 -- Resolution in micrometer/increment
  encoderParameters.conveyorPrescaler = 1 -- Prescaler value for the increment input

  encoderParameters.conveyorTimeoutActive = false -- Status if conveyor timeout should be used
  encoderParameters.conveyorTimeoutValue = 100 -- Can be ticks or mm
  encoderParameters.conveyorTimeoutMode = 'TICKS' -- 'TICKS' or 'DISTANCE'

  encoderParameters.encoderInterface = '' -- Source of connected encoder (e.g. S4, INC, SER1)
  encoderParameters.encoderSource = '' -- Devices identifier of the encoder (e.g. ENC1)
  encoderParameters.decoderInstance = '' -- Instance of decoder to use
  encoderParameters.conveyorSource = '' -- Source of increment source to be used for updating the system increment

  return encoderParameters
end
functions.getParameters = getParameters

return functions