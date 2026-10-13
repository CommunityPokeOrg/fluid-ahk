#Requires AutoHotkey v2.0

; ============================================================================
; FluidSlider — themed drag slider (track + accent fill + thumb).
;
;   s := Fluid.Slider(win, {Min: 0, Max: 100, Step: 1, Value: 72,
;                           OnChange: (ctl, v) => SetVol(v)})
;   s.Value          ; read
;   s.Set(40)        ; programmatic set
; ============================================================================

class FluidSlider extends FluidWidget {
    H := 26

    __New(win, opts := {}) {
        this.Win := win
        this.Min      := FluidOpt(opts, "Min", 0)
        this.Max      := FluidOpt(opts, "Max", 100)
        this.Step     := FluidOpt(opts, "Step", 1)
        this.Value    := FluidOpt(opts, "Value", this.Min)
        this.OnChange := FluidOpt(opts, "OnChange", 0)
        this.W        := FluidOpt(opts, "W", 200)

        this.Track := win.AddText("+0x100 +Background" FluidTheme.Border, "")
        this.Fill  := win.AddText("+0x100 +Background" FluidTheme.Accent, "")
        this.Thumb := win.AddText("+0x100 +BackgroundFFFFFF", "")
        ; Transparent overlay gives the thin bar a full-height hit region.
        this.Hot   := win.AddText("+0x100 +BackgroundTrans", "")
        this._Register()
    }

    _TrackHwnds() => [this.Track.Hwnd, this.Fill.Hwnd, this.Thumb.Hwnd, this.Hot.Hwnd]

    Layout(x, y, w, h := 0) {
        this.X := x, this.Y := y
        this.W := w, this.H := h ? h : this.H
        this.Track.Move(x, y + (this.H - 4)//2, w, 4)
        this._Paint()
        this.Hot.Move(x - 8, y, w + 16, this.H)
        return this
    }

    _Paint() {
        t := this.Max = this.Min ? 0 : (this.Value - this.Min)/(this.Max - this.Min)
        px := Round(this.X + t*this.W)
        this.Fill.Move(this.X, this.Y + (this.H - 4)//2, Max(px - this.X, 0), 4)
        this.Thumb.Move(px - 8, this.Y + (this.H - 16)//2, 16, 16)
        this.Fill.Redraw(), this.Thumb.Redraw()
    }

    _FromPointer() {
        this._ClientMouse(&mx, &my)
        t := (mx - this.X)/this.W
        t := t < 0 ? 0 : t > 1 ? 1 : t
        v := this.Min + t*(this.Max - this.Min)
        if (this.Step > 0)
            v := Round(v/this.Step)*this.Step
        v := v < this.Min ? this.Min : v > this.Max ? this.Max : v
        if (v != this.Value) {
            this.Value := v
            this._Paint()
            if (this.OnChange) {
                cb := this.OnChange
                cb(this, v)
            }
        }
    }

    ; _PointerMove is only invoked while this widget is the drag target.
    _PointerDown() => this._FromPointer()
    _PointerMove() => this._FromPointer()

    Set(v) {
        v := v < this.Min ? this.Min : v > this.Max ? this.Max : v
        this.Value := v
        this._Paint()
        return this
    }

    _MouseEnter() => this.Thumb.Opt("+BackgroundE0E7FF")    ; indigo-100 hint
    _MouseLeave() => this.Thumb.Opt("+BackgroundFFFFFF")
}
