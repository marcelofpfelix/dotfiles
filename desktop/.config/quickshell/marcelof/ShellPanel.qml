import QtQuick
import QtQuick.Layouts

ShellFrame {
  id: panel
  default property alias content: body.data
  property int margin: 12
  property int gap: 10

  ColumnLayout {
    id: body
    anchors.fill: parent
    anchors.margins: panel.margin
    spacing: panel.gap
  }
}
