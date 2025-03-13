# Changelog
All notable changes to this project will be documented in this file.

## Release 1.0.0

### New features
- Supports FlowConfig to forward encoder data to other modules
- Check if persistent data to load provides all relevant parameters. Otherwise add default values
- Provide version of module via 'OnNewStatusModuleVersion'
- Function 'getParameters' to provide PersistentData parameters
- Check if features of module can be used on device and provide this via 'OnNewStatusModuleIsActive' event / 'getStatusModuleActive' function

### Improvements
- Now compatible with CSK_Module_DigitalIOManager version >= 3.7.0  (if using DigitalIn port as encoder interface)
- New UI design available (e.g. selectable via CSK_Module_PersistentData v4.1.0 or higher), see 'OnNewStatusCSKStyle'
- 'loadParameters' returns its success
- 'sendParameters' can control if sent data should be saved directly by CSK_Module_PersistentData
- Added UI icon
- Changed log level of some messages from 'info' to 'fine'

## Release 0.2.0

### Improvements
- Hide UI content if CROWN is not supported on device
- Renamed 'OnNewStatusDecoderCounterMode' to 'OnNewStatusDecoderCountMode' and 'setDecoderCounterMode' to 'setDecoderCountMode'
- Using recursive helper functions to convert Container <-> Lua table
- Update to EmmyLua annotations
- Usage of lua diagnostics
- Documentation updates

## Release 0.1.0
- Initial commit