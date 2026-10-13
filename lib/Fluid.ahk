#Requires AutoHotkey v2.0

; ============================================================================
; Fluid — a sleek, modular dark-mode GUI component library for AutoHotkey v2.
;
;   #Include <path>\lib\Fluid.ahk
;
;   win := Fluid.Window("Settings")
;   card := Fluid.Card(win, {X:16, Y:16, W:400, H:300, Title:"General"})
;   stack := card.Stack()
;   stack.Add(Fluid.ToggleSwitch(win, {Text:"Notifications", On:true}))
;   stack.Add(Fluid.ModernButton(win, "Save", (b) => Save()))
;   win.Show("AutoSize Center")
; ============================================================================

; Include order matters: a class referenced by name inside another class body
; (e.g. `FluidWindow.HwndMap`, `FluidVStack(...)`) must be declared earlier.
#Include Theme.ahk
#Include Util.ahk
#Include Layout.ahk
#Include Window.ahk
#Include Widget.ahk
#Include Controls\Badge.ahk
#Include Controls\Card.ahk
#Include Controls\ModernButton.ahk
#Include Controls\ToggleSwitch.ahk
#Include Controls\Slider.ahk
#Include Controls\TextInput.ahk
#Include Controls\Progress.ahk

class Fluid {
    static Theme => FluidTheme

    static Window(title := "Fluid", opts := "") => FluidWindow(title, opts)

    static Card(win, opts := {})          => FluidCard(win, opts)
    static CardV(win, x, y, w, h, opts := {}) => (o := opts, o.X := x, o.Y := y, o.W := w, o.H := h, FluidCard(win, o))

    static ModernButton(win, spec := "Button", onClick := 0) => FluidModernButton(win, spec, onClick)
    static Button(win, spec := "Button", onClick := 0)       => FluidModernButton(win, spec, onClick)

    static ToggleSwitch(win, opts := {}) => FluidToggleSwitch(win, opts)
    static Toggle(win, opts := {})       => FluidToggleSwitch(win, opts)

    static Slider(win, opts := {})    => FluidSlider(win, opts)
    static TextInput(win, opts := {}) => FluidTextInput(win, opts)
    static Input(win, opts := {})     => FluidTextInput(win, opts)
    static Badge(win, text := "", opts := {}) => FluidBadge(win, text, opts)
    static Progress(win, opts := {})  => FluidProgress(win, opts)
}
