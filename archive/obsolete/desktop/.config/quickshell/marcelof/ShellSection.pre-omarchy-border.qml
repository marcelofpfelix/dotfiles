import QtQuick
import QtQuick.Layouts

Rectangle {
  id: section

  default property alias content: contentColumn.data
  readonly property QtObject theme: ShellTheme {}
  property int padding: theme.paddingMd
  property int gap: theme.spacingXl
  property int minHeight: 0
  property bool fillHeight: false
  property bool bordered: false
  property color sectionColor: theme.surface

  Layout.fillWidth: true
  Layout.fillHeight: fillHeight
  implicitHeight: Math.max(minHeight, contentColumn.implicitHeight + padding * 2)
  radius: theme.radiusSmall
  color: sectionColor
  border.color: bordered ? theme.surfaceHigh : theme.transparent
  border.width: bordered ? theme.dividerHeight : 0

  ColumnLayout {
    id: contentColumn
    anchors.fill: parent
    anchors.margins: section.padding
    spacing: section.gap
  }
}
