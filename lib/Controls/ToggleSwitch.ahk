#Requires AutoHotkey v2.0

; ============================================================================
; FluidToggleSwitch — flat on/off pill with an optional side label.
;
;   t := Fluid.ToggleSwitch(win, {Text: "Notifications", On: true,
;                                 OnChange: (ctl, on) => Log(on)})
;   t.Value          ; read state
;   t.Set(true)      ; set state (fires OnChange)
;   t.Toggle()
; ============================================================================

class FluidToggleSwitch extends FluidWidget {
    W := 46, H := 26
    _on := false

    __New(win, opts := {}) {
        this.Win := win
        o := Type(opts) = "String" ? {Text: opts} : opts

        this.Text     := FluidOpt(o, "Text", "")
        this.OnChange := FluidOpt(o, "OnChange", 0)
        this.Surface  := FluidOpt(o, "Surface", FluidTheme.Surface)
        this._on      := !!FluidOpt(o, "On", false)

        this.Track := win.AddText("+0x100 +Background" this._TrackColor(), "")
        this.Thumb := win.AddText("+0x100 +BackgroundFFFFFF", "")

        if (this.Text != "") {
            this.Lbl := win.AddText("+0x100 +0x200 +Background" this.Surface, this.Text)
            this.Lbl.SetFont("s" FluidTheme.SizeBody " c" FluidTheme.Text)
            this.W := 46 + 10 + StrLen(this.Text)*7
        }
        this._Register()
    }

    _TrackHwnds() {
        hs := [this.Track.Hwnd, this.Thumb.Hwnd]
        if this.HasProp("Lbl")
            hs.Push(this.Lbl.Hwnd)
        return hs
    }

    Value => this._on

    _TrackColor(hover := false) => (
        this._on
            ? (hover ? FluidTheme.AccentHi : FluidTheme.Accent)
            : (hover ? FluidTheme.BorderHi : FluidTheme.Border)
    )

    Layout(x, y, w, h := 0) {
        this.X := x, this.Y := y
        this.Track.Move(x, y, 46, 26)
        this._PlaceThumb()
        if this.HasProp("Lbl")
            this.Lbl.Move(x + 56, y, w - 56 > 0 ? w - 56 : 0, 26)
        return this
    }

    _PlaceThumb() {
        tx := this._on ? this.X + 26 : this.X + 4
        this.Thumb.Move(tx, this.Y + 5, 16, 16)
    }

    _Paint(hover := false) {
        this.Track.Opt("+Background" this._TrackColor(hover))
        this.Track.Redraw()
        this._PlaceThumb()
    }

    ; ---- runtime API ---------------------------------------------------------
    Set(v, fire := true) {
        v := !!v
        if (v = this._on)
            return this
        this._on := v
        this._Paint()
        if (fire && this.OnChange) {
            cb := this.OnChange
            cb(this, v)
        }
        return this
    }

    Toggle(fire := true) => this.Set(!this._on, fire)

    SetEnabled(on) {
        this._Enabled := !!on
        this.Track.Opt("+Background" (on ? this._TrackColor() : FluidTheme.SurfaceHi))
        this.Thumb.Opt("+Background" (on ? "FFFFFF" : FluidTheme.TextMuted))
        this.Track.Redraw(), this.Thumb.Redraw()
        return this
    }

    ; ---- pointer callbacks -------------------------------------------------
    _Clicked()    => this.Toggle()
    _MouseEnter() => this._Paint(true)
    _MouseLeave() => this._Paint(false)
}
