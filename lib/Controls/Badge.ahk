#Requires AutoHotkey v2.0

; ============================================================================
; FluidBadge — small status pill (soft-fill bg + readable fg).
;
;   b := Fluid.Badge(win, "Live", {Tone: "success"})
;   b.SetText("3 new") / b.SetTone("warning")
;
; Tones: accent | neutral | success | warning | danger  (FluidTheme.Badge)
; ============================================================================

class FluidBadge extends FluidWidget {
    H := 20

    __New(win, text := "", opts := {}) {
        this.Win  := win
        this.Tone := FluidOpt(opts, "Tone", "accent")
        this.W    := FluidOpt(opts, "W", 0)
        if (this.W <= 0)
            this.W := StrLen(text)*7 + 14

        s := FluidTheme.Badge.Get(this.Tone, FluidTheme.Badge["neutral"])
        this.Ctrl := win.AddText("+0x200 Center +Background" s.Bg, text)
        this.Ctrl.SetFont("s" FluidTheme.SizeMicro " w700 c" s.Fg)
        this._Register()
    }

    Layout(x, y, w, h := 0) {
        this.X := x, this.Y := y
        this.W := w, this.H := h ? h : this.H
        this.Ctrl.Move(x, y, w, this.H)
        return this
    }

    SetText(t) {
        this.Ctrl.Text := t
        return this
    }

    SetTone(tone) {
        this.Tone := tone
        s := FluidTheme.Badge.Get(tone, FluidTheme.Badge["neutral"])
        this.Ctrl.Opt("+Background" s.Bg " +c" s.Fg)
        this.Ctrl.Redraw()
        return this
    }
}
