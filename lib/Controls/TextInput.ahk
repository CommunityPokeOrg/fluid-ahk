#Requires AutoHotkey v2.0

; ============================================================================
; FluidTextInput — outlined single-line edit on the dark surface.
;
; 1px border frame that turns indigo on focus, inner padding via
; EM_SETMARGINS, and a cue banner (placeholder) via EM_SETCUEBANNER.
;
;   i := Fluid.TextInput(win, {Placeholder: "Workspace name",
;                              Value: "prod-1",
;                              OnChange: (ctl, text) => Save(text)})
;   i.Value          ; read
;   i.Set("text")
; ============================================================================

class FluidTextInput extends FluidWidget {
    H := 34

    __New(win, opts := {}) {
        this.Win := win
        this.W := FluidOpt(opts, "W", 220)
        this.H := FluidOpt(opts, "H", FluidTheme.CtrlH)
        this.OnChange := FluidOpt(opts, "OnChange", 0)

        this.Frame := win.AddText("+Background" FluidTheme.Border, "")
        this.Edit  := win.AddEdit("-E0x200 -Border +Background" FluidTheme.Field, "")
        this.Edit.SetFont("s" FluidTheme.SizeBody " c" FluidTheme.Text, FluidTheme.Font)

        if ((ph := FluidOpt(opts, "Placeholder", "")) != "")
            SendMessage(0x1501, 1, StrPtr(ph), this.Edit.Hwnd)      ; EM_SETCUEBANNER
        SendMessage(0x00D3, 3, 12 | (12 << 16), this.Edit.Hwnd)     ; EM_SETMARGINS L|R

        if ((v := FluidOpt(opts, "Value", "")) != "")
            this.Edit.Value := v

        this.Edit.OnEvent("Focus",     (*) => this._Frame(FluidTheme.Accent))
        this.Edit.OnEvent("LoseFocus", (*) => this._Frame(FluidTheme.Border))
        this.Edit.OnEvent("Change",    (*) => this._Changed())
        this._Register()
    }

    ; The native Edit keeps its own mouse/keyboard handling — nothing tracked.
    _TrackHwnds() => []

    _Frame(c) => (this.Frame.Opt("+Background" c), this.Frame.Redraw())

    _Changed() {
        if (this.OnChange) {
            cb := this.OnChange
            cb(this, this.Edit.Value)
        }
    }

    Layout(x, y, w, h := 0) {
        this.X := x, this.Y := y
        this.W := w, this.H := h ? h : this.H
        this.Frame.Move(x, y, w, this.H)
        this.Edit.Move(x + 1, y + 1, w - 2, this.H - 2)
        return this
    }

    Value => this.Edit.Value
    Set(v) => (this.Edit.Value := v)

    SetEnabled(on) {
        this._Enabled := !!on
        this.Edit.Enabled := on
        this._Frame(on ? FluidTheme.Border : FluidTheme.SurfaceHi)
        return this
    }
}
