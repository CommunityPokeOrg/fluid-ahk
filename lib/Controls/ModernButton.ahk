#Requires AutoHotkey v2.0

; ============================================================================
; FluidModernButton — flat button with hover / pressed / disabled states.
;
;   Fluid.ModernButton(win, "Save changes", (btn) => Save())
;   Fluid.ModernButton(win, {Text: "Cancel", Kind: "ghost", W: 120,
;                            Align: "left", OnClick: cb})
;
; Kinds: primary | secondary | ghost | danger   (see FluidTheme.Button)
; Align: center | left | right
;
; Implemented as two layered Text controls (background + label) so the
; surface can be fully themed — native AHK buttons can't be recolored.
; ============================================================================

class FluidModernButton extends FluidWidget {
    H := 34
    _pressed := false

    __New(win, spec := "Button", onClick := 0) {
        this.Win := win
        o := Type(spec) = "String" ? {Text: spec} : spec

        this.Text    := FluidOpt(o, "Text", "Button")
        this.Kind    := FluidOpt(o, "Kind", "primary")
        this.OnClick := onClick ? onClick : FluidOpt(o, "OnClick", 0)
        this.W       := FluidOpt(o, "W", 0)
        this.H       := FluidOpt(o, "H", FluidTheme.CtrlH)
        this.Align   := FluidOpt(o, "Align", "center")     ; left | center | right
        this.Surface := FluidOpt(o, "Surface", FluidTheme.Surface)
        this.Size    := FluidOpt(o, "Size", FluidTheme.SizeBody)
        this.Weight  := FluidOpt(o, "Weight", 600)
        if (this.W <= 0)
            this.W := 28 + StrLen(this.Text)*8

        align := this.Align = "center" ? "Center" : this.Align = "right" ? "Right" : ""
        this.Bg  := win.AddText("+0x100 +Background" this._Bg(), "")
        this.Lbl := win.AddText("+0x100 +0x200 " align " +Background" this._Bg(), this.Text)
        this.Lbl.SetFont("s" this.Size " w" this.Weight " c" this._Fg())
        this._Register()
    }

    _Skin() => FluidTheme.Button.Get(this.Kind, FluidTheme.Button["secondary"])

    _Bg(state := "normal") {
        s := this._Skin()
        if (!this._Enabled)
            return FluidTheme.SurfaceHi
        bg := state = "down" ? s.Down : state = "hover" ? s.Hover : s.Bg
        return bg = "" ? this.Surface : bg        ; ghost rests on the parent surface
    }

    _Fg() => this._Enabled ? this._Skin().Fg : FluidTheme.TextMuted

    _Paint(state := "normal") {
        bg := this._Bg(state), fg := this._Fg()
        this.Bg.Opt("+Background" bg)
        this.Lbl.Opt("+Background" bg " +c" fg)
        this.Bg.Redraw(), this.Lbl.Redraw()
    }

    Layout(x, y, w, h := 0) {
        this.X := x, this.Y := y
        this.W := w, this.H := h ? h : this.H
        this.Bg.Move(x, y, w, this.H)
        if (this.Align = "left")
            this.Lbl.Move(x + 14, y, w - 14, this.H)
        else if (this.Align = "right")
            this.Lbl.Move(x, y, w - 14, this.H)
        else
            this.Lbl.Move(x, y, w, this.H)
        return this
    }

    ; ---- pointer callbacks -------------------------------------------------
    _MouseEnter()  => this._Paint(this._pressed ? "down" : "hover")
    _MouseLeave()  => this._Paint("normal")
    _PointerDown() => (this._pressed := true,  this._Paint("down"))
    _PointerUp()   => (this._pressed := false, this._Paint("hover"))

    _Clicked() {
        if (this.OnClick) {
            cb := this.OnClick
            cb(this)
        }
    }

    ; ---- runtime API ---------------------------------------------------------
    SetEnabled(on) {
        this._Enabled := !!on
        this._Paint("normal")
        return this
    }
    SetKind(kind) {
        this.Kind := kind
        this._Paint("normal")
        return this
    }
    SetText(t) {
        this.Text := t
        this.Lbl.Text := t
        return this
    }

    _TrackHwnds() => [this.Bg.Hwnd, this.Lbl.Hwnd]
}
