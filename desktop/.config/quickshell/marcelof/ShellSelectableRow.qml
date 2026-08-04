import QtQuick

Rectangle {
  id: row

  default property alias content: contentItem.data
  readonly property QtObject theme: ShellTheme {}
  property bool selected: false
  property int rowHeight: theme.listRowHeight

  signal hovered()
  signal clicked(var mouse)

  height: rowHeight
  radius: theme.radiusTiny
  color: selected ? theme.surfaceHigh : theme.transparent

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: row.hovered()
    onClicked: mouse => row.clicked(mouse)
  }

  Item {
    id: contentItem
    anchors.fill: parent
  }
}
