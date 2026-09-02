import QtQuick
import qs.Commons as OmarchyCommons
import qs.Ui as OmarchyUi

OmarchyUi.BorderSurface {
  readonly property QtObject theme: ShellTheme {}

  radius: theme.radius
  color: theme.panel
  borderSpec: OmarchyCommons.Border.flat(theme.border, theme.dividerHeight)
}
