import QtQuick
import QtQuick.Layouts

Item {
  id: searchBox

  readonly property QtObject theme: ShellTheme {}
  property alias text: input.text
  property string placeholder: ""
  property int inputHeight: theme.searchHeight

  signal escapePressed()
  signal downPressed()
  signal upPressed()
  signal accepted()
  signal keyPressed(var event)

  Layout.fillWidth: true
  Layout.preferredHeight: inputHeight
  Layout.maximumHeight: inputHeight
  height: inputHeight
  implicitHeight: inputHeight

  function forceActiveFocus() {
    input.forceActiveFocus()
  }

  Rectangle {
    anchors.fill: parent
    color: theme.surface
    border.color: input.activeFocus ? theme.primary : theme.surfaceHigh
    border.width: theme.dividerHeight
    radius: theme.radius

    Text {
      anchors.fill: parent
      anchors.leftMargin: theme.inputInset
      verticalAlignment: Text.AlignVCenter
      color: theme.textDim
      font.family: theme.fontFamily
      font.pixelSize: theme.fontLg
      text: searchBox.placeholder
      visible: searchBox.placeholder.length > 0 && input.text.length === 0
    }

    TextInput {
      id: input
      anchors.fill: parent
      anchors.leftMargin: theme.inputInset
      anchors.rightMargin: theme.inputInset
      verticalAlignment: TextInput.AlignVCenter
      color: theme.text
      selectionColor: theme.border
      selectedTextColor: theme.text
      font.family: theme.fontFamily
      font.styleName: theme.fontStyle
      font.pixelSize: theme.fontInput
      clip: true

      Keys.onEscapePressed: searchBox.escapePressed()
      Keys.onDownPressed: searchBox.downPressed()
      Keys.onUpPressed: searchBox.upPressed()
      Keys.onReturnPressed: searchBox.accepted()
      Keys.onEnterPressed: searchBox.accepted()
      Keys.onPressed: event => searchBox.keyPressed(event)
    }
  }
}
