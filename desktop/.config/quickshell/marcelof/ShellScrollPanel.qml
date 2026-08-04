import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ShellFrame {
  id: panel

  default property alias content: body.data
  property int margin: 10
  property int gap: 9

  ScrollView {
    id: scroll
    anchors.fill: parent
    anchors.margins: panel.margin
    clip: true
    ScrollBar.vertical.policy: ScrollBar.AsNeeded

    ColumnLayout {
      id: body
      width: scroll.availableWidth
      spacing: panel.gap
    }
  }
}
