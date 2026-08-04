import QtQuick

QtObject {
  readonly property string fontFamily: "FiraCode Nerd Font"
  readonly property string fontStyle: "Retina"

  readonly property int fontXxs: 9
  readonly property int fontXs: 10
  readonly property int fontSm: 11
  readonly property int fontMd: 12
  readonly property int fontLg: 13
  readonly property int fontXl: 14
  readonly property int fontTitle: 15
  readonly property int fontInput: 16
  readonly property int fontIcon: 18
  readonly property int fontClock: 22

  readonly property color panel: "#11111b"
  readonly property color transparent: "transparent"
  readonly property color surfaceLow: "#181825"
  readonly property color surface: "#1e1e2e"
  readonly property color surfaceRaised: "#242438"
  readonly property color surfaceHigh: "#313244"
  readonly property color surfaceActive: "#3b4252"
  readonly property color border: "#45475a"
  readonly property color borderStrong: "#585b70"

  readonly property color text: "#cdd6f4"
  readonly property color textSoft: "#bac2de"
  readonly property color textMuted: "#9399b2"
  readonly property color textSubtle: "#7f849c"
  readonly property color textDim: "#6c7086"

  readonly property color primary: "#b4befe"
  readonly property color warning: "#f9e2af"
  readonly property color success: "#a6e3a1"
  readonly property color error: "#f38ba8"

  readonly property int spacingXs: 2
  readonly property int spacingSm: 4
  readonly property int spacingMd: 6
  readonly property int spacingButton: 7
  readonly property int spacingLg: 8
  readonly property int spacingXl: 10
  readonly property int spacingXxl: 12

  readonly property int panelMargin: 14
  readonly property int inputInset: 12
  readonly property int rowTextRightInset: 10
  readonly property int dividerHeight: 1

  readonly property int barHeight: 32
  readonly property int barMargin: 10
  readonly property int barItemSize: 22
  readonly property int barIconSize: 18
  readonly property int workspaceWidth: 28
  readonly property int workspaceHeight: 24

  readonly property int searchHeight: 42
  readonly property int searchHeightLarge: 46
  readonly property int listRowHeight: 40
  readonly property int launcherRowHeight: 54
  readonly property int chipHeight: 28

  readonly property int paddingSm: 8
  readonly property int paddingMd: 10
  readonly property int actionHeight: 36
  readonly property int actionMinWidth: 104
  readonly property int controlMenuButtonMinWidth: 68
  readonly property int actionHorizontalPadding: 18
  readonly property int iconButtonPadding: 8
  readonly property int tooltipPaddingX: 9
  readonly property int tooltipPaddingY: 6
  readonly property int rowHeightLg: 52

  readonly property int radiusTiny: 4
  readonly property int radiusSmall: 5
  readonly property int radius: 6
}
