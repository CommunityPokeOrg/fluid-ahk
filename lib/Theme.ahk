#Requires AutoHotkey v2.0

; ============================================================================
; FluidTheme — design tokens for the Fluid dark theme.
; Zinc/slate inspired surface palette, indigo accent, Segoe UI type ramp.
; ============================================================================

class FluidTheme {
    ; -- Surfaces -------------------------------------------------------------
    static Bg        := "0F0F12"   ; window base          (zinc-950)
    static Surface   := "18181B"   ; cards                (zinc-900)
    static SurfaceHi := "27272A"   ; raised / hover       (zinc-800)
    static SurfaceDn := "32323A"   ; pressed surface      (zinc-750)
    static Field     := "1F1F24"   ; input & track fill   (zinc-850)
    static Border    := "3F3F46"   ; hairlines, idle pill (zinc-700)
    static BorderHi  := "52525B"   ; hover hairline       (zinc-600)

    ; -- Text ------------------------------------------------------------------
    static Text      := "FAFAFA"   ; primary              (zinc-50)
    static TextDim   := "A1A1AA"   ; secondary            (zinc-400)
    static TextMuted := "71717A"   ; disabled / caption   (zinc-500)

    ; -- Accent (indigo) --------------------------------------------------------
    static Accent    := "6366F1"   ; indigo-500
    static AccentHi  := "818CF8"   ; indigo-400 (hover)
    static AccentDn  := "4F46E5"   ; indigo-600 (pressed)
    static AccentInk := "312E81"   ; indigo-900 (soft fill)

    ; -- Status -----------------------------------------------------------------
    static Success   := "10B981"   ; emerald-500
    static SuccessInk:= "064E3B"   ; emerald-900
    static Warning   := "F59E0B"   ; amber-500
    static WarningInk:= "451A03"   ; amber-950
    static Danger    := "DC2626"   ; red-600
    static DangerHi  := "EF4444"   ; red-500
    static DangerInk := "450A0A"   ; red-950

    ; -- Typography --------------------------------------------------------------
    static Font      := "Segoe UI"
    static FontMono  := "Cascadia Mono"
    static SizeH1    := 14
    static SizeTitle := 11
    static SizeBody  := 10
    static SizeSmall := 9
    static SizeMicro := 8

    ; -- Spacing ------------------------------------------------------------------
    static Pad       := 20         ; card padding
    static Gap       := 10         ; default stack gap
    static CtrlH     := 34         ; default control height

    ; -- Component skins ------------------------------------------------------------
    ; Button: Bg / Hover / Down / Fg. Empty Bg = rests on the parent surface.
    static Button := Map(
        "primary",   { Bg: "4F46E5", Hover: "6366F1", Down: "4338CA", Fg: "FFFFFF" },
        "secondary", { Bg: "27272A", Hover: "3F3F46", Down: "32323A", Fg: "FAFAFA" },
        "ghost",     { Bg: "",       Hover: "27272A", Down: "3F3F46", Fg: "D4D4D8" },
        "danger",    { Bg: "DC2626", Hover: "EF4444", Down: "B91C1C", Fg: "FFFFFF" }
    )

    ; Badge tones: soft-fill background + readable foreground.
    static Badge := Map(
        "accent",  { Bg: "312E81", Fg: "C7D2FE" },
        "neutral", { Bg: "27272A", Fg: "D4D4D8" },
        "success", { Bg: "064E3B", Fg: "A7F3D0" },
        "warning", { Bg: "451A03", Fg: "FCD34D" },
        "danger",  { Bg: "450A0A", Fg: "FCA5A5" }
    )

    ; ==========================================================================
    ; ApplyChrome — immersive dark title bar + rounded corners via DWM.
    ; DWMWA_USE_IMMERSIVE_DARK_MODE = 20 (Win10 2004+), 19 on older builds.
    ; DWMWA_WINDOW_CORNER_PREFERENCE = 33, DWMWCP_ROUND = 2 (Win11).
    ; ==========================================================================
    static ApplyChrome(hwnd) {
        for attr in [20, 19]
            try DllCall("dwmapi\DwmSetWindowAttribute"
                , "ptr", hwnd, "int", attr, "int*", 1, "uint", 4)
        try DllCall("dwmapi\DwmSetWindowAttribute"
            , "ptr", hwnd, "int", 33, "int*", 2, "uint", 4)
    }
}
