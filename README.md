# Fluid

A sleek, modular **dark-mode GUI component library for AutoHotkey v2**.

Flat zinc/slate surfaces, an indigo accent, DWM dark title bars, and layout
helpers that free you from hand-placing `x y w h` on every control.

```ahk
#Requires AutoHotkey v2.0
#Include path\to\fluid-ahk\lib\Fluid.ahk

win  := Fluid.Window("Settings")
card := Fluid.Card(win, {X: 16, Y: 16, W: 420, H: 300, Title: "General"})
col  := card.Stack()

col.Add(Fluid.ToggleSwitch(win, {Text: "Notifications", On: true}))
col.Add(Fluid.Slider(win, {Min: 0, Max: 100, Value: 72}))
col.Add(Fluid.TextInput(win, {Placeholder: "Workspace name"}))
col.Add(Fluid.ModernButton(win, "Save changes", (b) => Save()))

win.Show("w460 h360 Center")
```

## Requirements

- **AutoHotkey v2.0+** (strict v2 syntax throughout)
- Windows 10 1809+; dark title bar needs 1903+ (falls back silently),
  rounded window corners need Windows 11

## Components

| Class | What it is |
|---|---|
| `Fluid.Window` | `Gui` subclass — zinc-950 surface, DWM dark titlebar, rounded corners, pointer router for all widgets |
| `Fluid.Card` | Elevated `Surface` container with optional `Title` + corner `Badge`; `card.Stack()` returns a `VStack` clipped to its padding |
| `Fluid.ModernButton` | Flat button, `Kind: primary/secondary/ghost/danger`, hover + pressed states, `Align: left/center/right` |
| `Fluid.ToggleSwitch` | On/off pill with optional `Text` label; `.Value`, `.Set(v)`, `.Toggle()` |
| `Fluid.Slider` | Drag slider — `Min/Max/Step/Value`, live `OnChange` |
| `Fluid.TextInput` | Outlined single-line edit — placeholder cue banner, inner margins, indigo focus ring |
| `Fluid.Badge` | Status pill — `Tone: accent/neutral/success/warning/danger` |
| `Fluid.Progress` | Track + fill bar, optional `Label` + percent readout, `SetColor()` for thresholds |
| `VStack` / `HStack` | Layout helpers: `stack.Add(widget)` auto-places; `col.Row(h)` nests an `HStack`; `row.AddRight()` right-aligns from `X2` |

## Usage

```ahk
win := Fluid.Window("My App")            ; opts forwarded to Gui() e.g. "+Resize"

; ---- cards & stacks --------------------------------------------------------
card := Fluid.Card(win, {X: 16, Y: 16, W: 640, H: 300, Title: "Settings", Badge: "new"})
col  := card.Stack({Gap: 12})            ; VStack inside the card

; ---- toggle ----------------------------------------------------------------
t := Fluid.ToggleSwitch(win, {
    Text: "Enable notifications",
    On: true,
    OnChange: (ctl, on) => Apply(on)
})
col.Add(t)

; ---- slider ------------------------------------------------------------------
s := Fluid.Slider(win, {Min: 0, Max: 100, Step: 5, Value: 40,
                        OnChange: (ctl, v) => SetLevel(v)})
col.Add(s)

; ---- inputs side-by-side ------------------------------------------------------
row := col.Row(34)                       ; nested HStack
row.Add(Fluid.TextInput(win, {Placeholder: "Name"}), 300)
row.Add(Fluid.TextInput(win, {Placeholder: "Email"}), 300)

; ---- buttons ------------------------------------------------------------------
foot := win.HStack(16, 560, 40, {X2: 964, Gap: 10})
foot.Add(Fluid.Badge(win, "draft", {Tone: "warning"}))
foot.AddRight(Fluid.ModernButton(win, {Text: "Save",   Kind: "primary",   W: 120, OnClick: Save}))
foot.AddRight(Fluid.ModernButton(win, {Text: "Cancel", Kind: "ghost",     W: 90,  OnClick: Revert}))

win.Show("w980 h680 Center")
```

Every factory also has a short alias: `Fluid.Button`, `Fluid.Toggle`,
`Fluid.Input`. Options accept an object literal or a `Map`.

### Runtime API (shared)

- `widget.Layout(x, y, w)` — called by stacks; call it yourself for manual placement
- `widget.SetEnabled(bool)` — dims the control and swallows clicks
- `control.Value` — current value (`ToggleSwitch`, `Slider`, `TextInput`, `Progress`)
- `ModernButton.SetKind/SetText`, `ToggleSwitch.Toggle`, `Progress.Set/SetColor`, `Badge.SetText/SetTone`

## Design tokens

| Token | Value | Use |
|---|---|---|
| `Bg` | `#0F0F12` | window base |
| `Surface` | `#18181B` | cards |
| `SurfaceHi` / `SurfaceDn` | `#27272A` / `#32323A` | hover / pressed |
| `Field` | `#1F1F24` | inputs, tracks |
| `Border` / `BorderHi` | `#3F3F46` / `#52525B` | hairlines |
| `Text` / `TextDim` / `TextMuted` | `#FAFAFA` / `#A1A1AA` / `#71717A` | type ramp |
| `Accent` family | `#6366F1` / `#818CF8` / `#4F46E5` | indigo accent |
| `Success` `Warning` `Danger` | `#10B981` `#F59E0B` `#DC2626` | status |
| Font | Segoe UI, `s8`–`s14`, weights 400–700 | typography |
| `Pad` / `Gap` / `CtrlH` | 20 / 10 / 34 | spacing |

## How it works

- **Dark title bar** — `DwmSetWindowAttribute(hwnd, 20|19, dark)` plus
  `DWMWA_WINDOW_CORNER_PREFERENCE` for rounded corners on Windows 11.
- **Themed controls** — AHK can't recolor native buttons/sliders, so Fluid
  composites them from layered `Text` controls (`SS_NOTIFY` for hit-testing)
  and routes `WM_MOUSEMOVE`/`WM_LBUTTON*` through one shared dispatcher
  (`FluidWindow.HwndMap`). `TextInput` wraps a real `Edit` for native typing.
- **Layout** — stacks hold a cursor and call `Layout()`/`Move()` on each
  item; widgets report preferred `.W`/`.H`, so you declare rows and columns,
  not coordinates.

## Layout

```
fluid-ahk/
├── lib/
│   ├── Fluid.ahk            ; single include + Fluid facade
│   ├── Theme.ahk            ; palette, fonts, button/badge skins, DWM chrome
│   ├── Util.ahk             ; FluidOpt option reader
│   ├── Widget.ahk           ; FluidWidget base (pointer callbacks, hit map)
│   ├── Window.ahk           ; FluidWindow (Gui) + global message router
│   ├── Layout.ahk           ; FluidVStack / FluidHStack
│   └── Controls/            ; Card, ModernButton, ToggleSwitch, Slider,
│                            ;   TextInput, Badge, Progress
└── examples/
    └── showcase.ahk         ; settings panel + live monitor + buttons
```

## Notes & limitations

- Position a `Card` before adding its contents; children don't follow the card.
- Widgets are flat rects — per-control rounded corners would need GDI+ owner-draw.
- `ModernButton` is not keyboard-focusable (it's a styled `Text`, not a `Button`);
  bind a `Hotkey` if you need an accelerator.
- Windows are fixed-layout; pass `"+Resize"` knowing controls won't reflow yet.
