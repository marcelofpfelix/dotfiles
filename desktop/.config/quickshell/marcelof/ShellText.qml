import QtQuick

Text {
  id: shellText

  readonly property QtObject theme: ShellTheme {}
  property string role: "body"

  color: ({
    body: theme.text,
    soft: theme.textSoft,
    muted: theme.textMuted,
    subtle: theme.textSubtle,
    dim: theme.textDim,
    title: theme.text,
    heading: theme.text,
    strong: theme.text,
    section: theme.textSubtle,
    softStrong: theme.textSoft,
    primary: theme.primary,
    warning: theme.warning,
    success: theme.success,
    error: theme.error,
    icon: theme.text
  })[role] ?? theme.text

  font.family: theme.fontFamily
  font.styleName: role === "title" || role === "heading" || role === "strong" || role === "softStrong" ? theme.fontStyle : ""
  font.pixelSize: ({
    tiny: theme.fontXs,
    small: theme.fontSm,
    body: theme.fontMd,
    soft: theme.fontMd,
    muted: theme.fontSm,
    subtle: theme.fontSm,
    dim: theme.fontSm,
    title: theme.fontTitle,
    heading: theme.fontLg,
    strong: theme.fontMd,
    section: theme.fontSm,
    softStrong: theme.fontMd,
    input: theme.fontInput,
    icon: theme.fontXl,
    large: theme.fontLg,
    xlarge: theme.fontXl,
    clock: theme.fontClock
  })[role] ?? theme.fontMd
}
