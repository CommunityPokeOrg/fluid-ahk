#Requires AutoHotkey v2.0

; ============================================================================
; FluidProgress — track + accent fill bar, optional caption row.
;
;   p := Fluid.Progress(win, {Label: "CPU", ShowValue: true, Color: "6366F1"})
;   p.Set(42)            ; 0-100
;   p.SetColor("EF4444") ; recolor the fill (e.g. thresholds)
;   p.Value
; ============================================================================

class FluidProgress extends FluidWidget {
    H := 6
    _v := 0
    _barY := 0

    __New(win, opts := {}) {
        this.Win := win
        this.Label     := FluidOpt(opts, "Label", "")
        this.Surface   := FluidOpt(opts, "Surface", FluidTheme.Surface)
        this.Color     := FluidOpt(opts, "Color", FluidTheme.Accent)
        this.ShowValue := FluidOpt(opts, "ShowValue", false)
        this.W         := FluidOpt(opts, "W", 200)
        this._v        := FluidOpt(opts, "Value", 0)

        if (this.Label != "" || this.ShowValue) {
            this.H := 30
            this.Lbl := win.AddText("+0x200 +Background" this.Surface, this.Label)
            this.Lbl.SetFont("s" FluidTheme.SizeSmall " c" FluidTheme.TextDim)
            this.Val := win.AddText("+0x200 Right +Background" this.Surface, "")
            this.Val.SetFont("s" FluidTheme.SizeSmall " w600 c" FluidTheme.TextDim)
        }
        this.Track := win.AddText("+Background" FluidTheme.Field, "")
        this.Fill  := win.AddText("+Background" this.Color, "")
        this._Register()
    }

    Layout(x, y, w, h := 0) {
        this.X := x, this.Y := y, this.W := w
        if this.HasProp("Lbl") {
            this.Lbl.Move(x, y, w//2, 16)
            this.Val.Move(x + w//2, y, w - w//2, 16)
            this._barY := y + 22
        } else {
            this._barY := y
        }
        this.Track.Move(x, this._barY, w, 6)
        this._Paint()
        return this
    }

    _Paint() {
        t := this._v < 0 ? 0 : this._v > 100 ? 100 : this._v
        this.Fill.Move(this.X, this._barY, Max(Round(t/100*this.W), 0), 6)
        this.Fill.Redraw()
        if this.HasProp("Val")
            this.Val.Text := Round(t) "%"
    }

    Set(v) {
        this._v := v
        this._Paint()
        return this
    }

    Value => this._v

    SetColor(c) {
        this.Color := c
        this.Fill.Opt("+Background" c)
        this.Fill.Redraw()
        return this
    }
}
