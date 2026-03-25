import QtQuick

// Kanagawa theme — derived from Ghostty palette
// palette 0-15  : normal + bright terminal colors
// Extra         : background, foreground, selection, cursor
//
// Usage: instantiate once in shell.qml as  Theme { id: theme }
// then reference via  theme.colBg, theme.brightBlue, etc.
QtObject {
    // ── Raw palette ────────────────────────────────────────────
    readonly property color black:        "#090E13"  // 0
    readonly property color red:          "#c4746e"  // 1
    readonly property color green:        "#8a9a7b"  // 2
    readonly property color yellow:       "#c4b28a"  // 3
    readonly property color blue:         "#8ba4b0"  // 4
    readonly property color purple:       "#a292a3"  // 5
    readonly property color cyan:         "#8ea4a2"  // 6
    readonly property color white:        "#a4a7a4"  // 7
    readonly property color brightBlack:  "#5C6066"  // 8
    readonly property color brightRed:    "#e46876"  // 9
    readonly property color brightGreen:  "#87a987"  // 10
    readonly property color brightYellow: "#e6c384"  // 11
    readonly property color brightBlue:   "#7fb4ca"  // 12
    readonly property color brightPurple: "#938aa9"  // 13
    readonly property color brightCyan:   "#7aa89f"  // 14
    readonly property color brightWhite:  "#c5c9c7"  // 15

    // ── Special ────────────────────────────────────────────────
    readonly property color background:  "#090E13"
    readonly property color foreground:  "#c5c9c7"
    readonly property color cursor:      "#c5c9c7"
    readonly property color selectionBg: "#22262D"
    readonly property color selectionFg: "#c5c9c7"

    // ── Semantic aliases (used across widgets/modules) ─────────
    readonly property color colBg:     background   // main background
    readonly property color colFg:     foreground   // main foreground / text
    readonly property color colBorder: brightBlack  // borders / dimmed text
    readonly property color colRed:    red          // errors, low battery, logout
    readonly property color colGreen:  brightGreen  // ok states, charging
    readonly property color colBlue:   brightBlue   // time, volume, selected
    readonly property color colYellow: yellow       // wifi, brightness, focused ws
    readonly property color colPurple: purple       // launcher accent
}
