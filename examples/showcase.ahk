#Requires AutoHotkey v2.0
#Include ..\lib\Fluid.ahk

; ============================================================================
; Fluid showcase — settings panel + live system monitor + interactive controls.
; Run with AutoHotkey v2:  AutoHotkey64.exe examples\showcase.ahk
; ============================================================================

Persistent()

win := Fluid.Window("Fluid — Showcase")
win.OnEvent("Close", (*) => ExitApp())

; ---------------------------------------------------------------- left rail --
side := Fluid.Card(win, {X: 16, Y: 16, W: 212, H: 648, Pad: 16
    , Title: "Fluid", Badge: "v2"})

nav := side.Stack({Gap: 6})
navBtns := []
navLabels := ["Dashboard", "Settings", "System monitor", "Automations", "About"]
for i, label in navLabels {
    b := Fluid.ModernButton(win, {
        Text: label,
        Kind: i = 2 ? "secondary" : "ghost",
        Align: "left",
        W: side.ContentW(),
        H: 38,
        OnClick: NavSelect
    })
    nav.Add(b)
    navBtns.Push(b)
}

NavSelect(btn, *) {
    for b in navBtns
        b.SetKind(b == btn ? "secondary" : "ghost")
}

nav.Space(360)
nav.AddW(Fluid.Badge(win, "dark theme", {Tone: "neutral"}), side.ContentW())

; ------------------------------------------------------------- settings card --
mainX := 244
mainW := 980 - mainX - 16

settings := Fluid.Card(win, {X: mainX, Y: 16, W: mainW, H: 324
    , Title: "Settings", Badge: "auto-save", BadgeTone: "success"})

col := settings.Stack({Gap: 12})
col.Add(Fluid.ToggleSwitch(win, {Text: "Enable notifications", On: true
    , OnChange: (ctl, on) => Dirty()}))
col.Add(Fluid.ToggleSwitch(win, {Text: "Launch at login", On: false
    , OnChange: (ctl, on) => Dirty()}))
col.Add(Fluid.ToggleSwitch(win, {Text: "Hardware acceleration", On: true
    , OnChange: (ctl, on) => Dirty()}))

col.Space(4)
vol := Fluid.Slider(win, {Min: 0, Max: 100, Value: 72
    , OnChange: (ctl, v) => (volBadge.SetText(v "%"), Dirty())})
col.Add(vol)
col.Add(Fluid.Slider(win, {Min: 50, Max: 150, Step: 5, Value: 100
    , OnChange: (ctl, v) => Dirty()}))

row := col.Row(34)
halfW := (settings.ContentW() - 10)//2
row.Add(Fluid.TextInput(win, {Placeholder: "Workspace name", W: halfW}), halfW)
row.Add(Fluid.TextInput(win, {Placeholder: "API endpoint",   W: halfW}), halfW)

; ------------------------------------------------------------- monitor card --
monitor := Fluid.Card(win, {X: mainX, Y: 356, W: mainW, H: 204
    , Title: "System monitor", Badge: "live", BadgeTone: "success"})

mcol := monitor.Stack({Gap: 14})
cpu := Fluid.Progress(win, {Label: "CPU",    ShowValue: true})
mem := Fluid.Progress(win, {Label: "Memory", ShowValue: true, Color: FluidTheme.Success})
gpu := Fluid.Progress(win, {Label: "GPU",    ShowValue: true, Color: FluidTheme.Warning})
mcol.Add(cpu), mcol.Add(mem), mcol.Add(gpu)

SetTimer(UpdateStats, 1000)

UpdateStats() {
    ; Real RAM load via GlobalMemoryStatusEx; CPU/GPU simulated for the demo.
    ms := Buffer(64)
    NumPut("uint", 64, ms)
    try DllCall("kernel32\GlobalMemoryStatusEx", "ptr", ms)
    mem.Set(NumGet(ms, 4, "uint"))

    cpu.Set(Round(38 + 26*Sin(A_TickCount/4200) + Random(-6, 6)))
    gpu.Set(Round(22 + 18*Sin(A_TickCount/7000 + 1.3) + Random(-4, 4)))
    if (cpu.Value > 75)
        cpu.SetColor(FluidTheme.Danger)
    else
        cpu.SetColor(FluidTheme.Accent)
}

; ------------------------------------------------------------------ footer --
foot := win.HStack(mainX, 576, 40, {X2: 964, Gap: 10})
status := Fluid.Badge(win, "no changes", {Tone: "neutral", W: 120})
volBadge := Fluid.Badge(win, "72%", {Tone: "accent", W: 52})
foot.Add(status)
foot.Add(volBadge)
foot.AddRight(Fluid.ModernButton(win, {Text: "Save changes", Kind: "primary",  W: 130, OnClick: Save}))
foot.AddRight(Fluid.ModernButton(win, {Text: "Apply",        Kind: "secondary", W: 90,  OnClick: Save}))
foot.AddRight(Fluid.ModernButton(win, {Text: "Cancel",       Kind: "ghost",     W: 90,  OnClick: Revert}))

Dirty(*)    => status.SetText("unsaved changes").SetTone("warning")
Save(btn, *) => status.SetText("all changes saved").SetTone("success")
Revert(btn,*) => status.SetText("no changes").SetTone("neutral")

win.Show("w980 h680 Center")
