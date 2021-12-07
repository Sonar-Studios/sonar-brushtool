local Plugin = script.Parent.Parent.Parent
local Libs = Plugin.Libs
local semver = require(Libs.semver)

local wrapStrictTable = require(Plugin.Core.Util.wrapStrictTable)

local Constants = {}

Constants.BRUSHTOOL_MIN_WIDTH = 320
Constants.BRUSHTOOL_MIN_HEIGHT = 300

Constants.FONT = Enum.Font.SourceSans
Constants.FONT_BOLD = Enum.Font.SourceSansBold
Constants.FONT_SIZE_VERY_SMALL = 12
Constants.FONT_SIZE_SMALL = 14
Constants.FONT_SIZE_MEDIUM = 16
Constants.FONT_SIZE_LARGE = 18

Constants.TAB_HEIGHT = 40
Constants.TAB_WIDTH = 40
Constants.TAB_ICON_SIZE = UDim2.new(0, 32, 0, 32)

Constants.SCROLL_BAR_THICKNESS = 16
Constants.SCROLL_BAR_ARROW_DOWN = "rbxassetid://2756828096"

Constants.INPUT_FIELD_TEXT_PADDING = 4
Constants.INPUT_FIELD_BOX_PADDING = 4
Constants.INPUT_FIELD_LABEL_PADDING = 12
Constants.INPUT_FIELD_INDENT_PER_LEVEL = 12
Constants.INPUT_FIELD_HEIGHT = 24
Constants.INPUT_FIELD_BOX_HEIGHT = 24
Constants.BUTTON_HEIGHT = 24
Constants.FIELD_LABEL_WIDTH = 110

Constants.CHECKBOX_SIZE = 18

Constants.DROPDOWN_ARROW_IMAGE = "rbxasset://textures/StudioToolbox/ArrowDownIconWhite.png"
Constants.DROPDOWN_ENTRY_HEIGHT = 24

Constants.COLLAPSIBLE_SECTION_HEIGHT = 32
Constants.COLLAPSIBLE_ARROW_RIGHT_IMAGE = "rbxassetid://3010958455"
Constants.COLLAPSIBLE_ARROW_DOWN_IMAGE = "rbxassetid://3010958148"
Constants.COLLAPSIBLE_ARROW_SIZE = 10

Constants.CHECK_IMAGE = "rbxassetid://2773796198"

Constants.CLOSE_IMAGE = "rbxasset://textures/AnimationEditor/icon_close.png"

Constants.BRUSH_GRID_PADDING = 4
Constants.BRUSH_GRID_CELL_SIZE = 80

Constants.ADD_IMAGE = "rbxassetid://2779694392"
Constants.INFO_IMAGE = "rbxassetid://2779700055"
Constants.WARNING_IMAGE = "rbxassetid://2779700265"

Constants.MIN_RADIUS = 1
Constants.MAX_RADIUS = 100
Constants.MIN_SPACING = 0.1
Constants.MAX_SPACING = 50
Constants.MIN_ROTATION = -360
Constants.MAX_ROTATION = 360
Constants.MIN_SCALE = 0.1
Constants.MAX_SCALE = 10
Constants.MIN_WOBBLE = 0
Constants.MAX_WOBBLE = 90
Constants.MIN_VERTICAL_OFFSET = -40
Constants.MAX_VERTICAL_OFFSET = 40
Constants.MAX_PLACED_PER_BRUSH = 60

Constants.TOOLBAR_ICON = "rbxassetid://2980991864"
Constants.MAIN_ICON = "rbxassetid://2981019699"

Constants.CLEAR_ICON_HOVER = "rbxasset://textures/StudioToolbox/ClearHover.png"
Constants.CLEAR_ICON = "rbxasset://textures/StudioToolbox/Clear.png"

Constants.OVERRIDE_ICON = "rbxassetid://2821307723"
Constants.OVERRIDE_ICON_HOVER = "rbxassetid://2821307857"

Constants.DELETE_ICON = "rbxassetid://2821308140"
Constants.DELETE_ICON_HOVER = "rbxassetid://2821308022"

Constants.DOUBLE_CLICK_DELAY = 0.5

Constants.ROTATE_CW_IMAGE = "rbxassetid://2788476404"
Constants.ROTATE_CCW_IMAGE = "rbxassetid://2788476215"
Constants.BRUSH_SELECTION_ROTATION_COUNT = 8
Constants.AXIS_MODEL = script.Axis:Clone()
Constants.TINYAXIS_MODEL = script.TinyAxis:Clone()
Constants.TRANSPARENT_CHECKER = "rbxassetid://2795477899"
Constants.NO_IMAGE = "rbxassetid://2795966663"

Constants.ARC_1_PART = script.Arc1:Clone()
Constants.ARC_2_PART = script.Arc2:Clone()
Constants.ARC_4_PART = script.Arc4:Clone()
Constants.ARC_8_PART = script.Arc8:Clone()
Constants.ARC_16_PART = script.Arc16:Clone()
Constants.ARC_32_PART = script.Arc32:Clone()
Constants.ARC_64_PART = script.Arc64:Clone()
Constants.ARC_128_PART = script.Arc128:Clone()

Constants.BRUSH_IMAGE = "rbxassetid://2795928270"
Constants.STAMP_IMAGE = "rbxassetid://2832377277"
Constants.ERASE_IMAGE = "rbxassetid://2815003483"
Constants.MISC_IMAGE = "rbxassetid://2892415605"
Constants.HELP_IMAGE = "rbxassetid://2892492742"

Constants.SOLO_FOLDER_PREFIX = "SOLO_"

Constants.BRUSHED_TAG = "_BrushtoolBrushed"
Constants.BRUSHED_PP_AS_CENTER_TAG = "_BrushtoolPPCenter" -- heh pp

Constants.DROP_SHADOW_TOP_IMAGE = "rbxassetid://2841499866"
Constants.DROP_SHADOW_SLICE_IMAGE = "rbxassetid://2950485059" -- 69x69, Rect(23, 23, 46, 46)
Constants.ENTRY_NOTE_HEIGHT = 42
Constants.ENTRY_NOTE_PADDING = 5

Constants.AUTOSAVE_INTERVAL = 60

Constants.SLIDER_BUTTON_WIDTH = 10
Constants.SLIDER_BUTTON_HEIGHT = 20

Constants.SAVE_IMAGE = "rbxassetid://2950300317"

Constants.PLUGIN_THIS_IS_BETA_CHANNEL = false
Constants.PLUGIN_BETA_CHANNEL_PRODUCT_ID = 2813601401
Constants.PLUGIN_PRODUCT_ID = 2268520847
Constants.PLUGIN_VERSION = semver("2.1.5-sonar")

Constants.STARTER_BRUSHES = {}

Constants.STARTER_STAMPS = {}

Constants.PLUGIN_STORAGE_SCOPE = "Brushtool2_Plugin_Storage"

return Constants
-- Only turn this on for debugging? If the constant
-- is a table, then wrapStrictTable messes with it.
--return wrapStrictTable(Constants, "Constants")