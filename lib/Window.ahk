#Requires AutoHotkey v2.0

; ============================================================================
; FluidWindow — dark-themed Gui subclass.
;
;  * zinc-950 background, Segoe UI defaults
;  * DWM immersive dark title bar + rounded corners (Win11)
;  * one global pointer router shared by every Fluid widget on any window
;
;   win := Fluid.Window("Settings")
;   stack := win.VStack(24, 24, 480)
;   win.Show("w560 h640 Center")
; ============================================================================

class FluidWindow extends Gui {
    ; Pointer routing state (one app-wide hook serves all Fluid windows).
    static HwndMap := Map()        ; child-control HWND -> FluidWidget
    static Hover   := 0            ; widget currently hovered
    static Drag    := 0            ; widget currently being dragged
    static Hooked  := false

    Widgets := []

    __New(title := "Fluid", opts := "") {
        super.__New(opts, title)
        this.BackColor := FluidTheme.Bg
        this.MarginX := 0, this.MarginY := 0
        this.SetFont("s" FluidTheme.SizeBody " c" FluidTheme.Text, FluidTheme.Font)

        if (!FluidWindow.Hooked) {
            OnMessage(0x200, FluidOnMove)   ; WM_MOUSEMOVE
            OnMessage(0x201, FluidOnDown)   ; WM_LBUTTONDOWN
            OnMessage(0x202, FluidOnUp)     ; WM_LBUTTONUP
            FluidWindow.Hooked := true
        }
        FluidTheme.ApplyChrome(this.Hwnd)
    }

    ; Show and (re)assert the dark chrome — some builds re-theme on first show.
    Show(options := "AutoSize Center") {
        super.Show(options)
        FluidTheme.ApplyChrome(this.Hwnd)
        return this
    }

    Register(w) => this.Widgets.Push(w)

    ; Layout helpers — see lib/Layout.ahk.
    VStack(x, y, w, opts := {}) => FluidVStack(this, x, y, w, opts)
    HStack(x, y, h, opts := {}) => FluidHStack(this, x, y, h, opts)
}

; ---------------------------------------------------------------------------
; Pointer router (module-level functions; OnMessage takes Func objects).
; hwnd = the control/window that received the message.
; ---------------------------------------------------------------------------

FluidOnMove(wParam, lParam, msg, hwnd) {
    t := FluidWindow.HwndMap.Get(hwnd, 0)
    if (t != FluidWindow.Hover) {
        if (FluidWindow.Hover)
            try FluidWindow.Hover._MouseLeave()
        FluidWindow.Hover := t
        if (t && t._Enabled)
            try t._MouseEnter()
    }
    if (FluidWindow.Drag)
        try FluidWindow.Drag._PointerMove()
}

FluidOnDown(wParam, lParam, msg, hwnd) {
    t := FluidWindow.HwndMap.Get(hwnd, 0)
    if (t && t._Enabled) {
        FluidWindow.Drag := t
        try t._PointerDown()
    }
}

FluidOnUp(wParam, lParam, msg, hwnd) {
    t := FluidWindow.Drag
    u := FluidWindow.HwndMap.Get(hwnd, 0)
    FluidWindow.Drag := 0
    if (t) {
        try t._PointerUp()
        if (u == t && u._Enabled)
            try u._Clicked()
    }
}
