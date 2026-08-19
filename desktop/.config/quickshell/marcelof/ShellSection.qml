import QtQuick
import QtQuick.Layouts
import qs.Commons as OmarchyCommons
import qs.Ui as OmarchyUi

OmarchyUi.BorderSurface {
  id: section

  default property alias content: contentColumn.data
  readonly property QtObject theme: ShellTheme {}
  property int gap: theme.spacingXl
  property int minHeight: 0
  property bool fillHeight: false
  property bool bordered: false
  property color sectionColor: theme.surface

  Layout.fillWidth: true
  Layout.fillHeight: fillHeight
  padding: theme.paddingMd
  implicitHeight: Math.max(minHeight, contentColumn.implicitHeight + padding * 2)
  radius: theme.radiusSmall
  color: sectionColor
  borderSpec: bordered ? OmarchyCommons.Border.flat(theme.surfaceHigh, theme.dividerHeight) : OmarchyCommons.Border.none()

  ColumnLayout {
    id: contentColumn
    anchors.fill: parent
    anchors.margins: section.padding
    spacing: section.gap
  }
}
