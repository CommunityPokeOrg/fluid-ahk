#Requires AutoHotkey v2.0

; ============================================================================
; FluidCard — elevated surface container.
;
;   card := Fluid.Card(win, {X: 16, Y: 16, W: 320, H: 300,
;                            Title: "Settings", Badge: "3 new", BadgeTone: "accent"})
;   stack := card.Stack()          ; VStack clipped to the card's content area
;   card.ContentX/Y/W()            ; inner geometry if you position manually
;
; Note: position the card first, then add contents — children are not
; reparented if the card is moved later.
; ============================================================================

class FluidCard extends FluidWidget {
    H := 96

    __New(win, opts := {}) {
        this.Win   := win
        this.X     := FluidOpt(opts, "X", 0)
        this.Y     := FluidOpt(opts, "Y", 0)
        this.W     := FluidOpt(opts, "W", 320)
        this.H     := FluidOpt(opts, "H", 96)
        this.Pad   := FluidOpt(opts, "Pad", FluidTheme.Pad)
        this.Title := FluidOpt(opts, "Title", "")
        this.Color := FluidOpt(opts, "Color", FluidTheme.Surface)

        this.Bg := win.AddText(Format("x{1} y{2} w{3} h{4} +Background{5}"
            , this.X, this.Y, this.W, this.H, this.Color), "")

        if (this.Title != "") {
            this.Hdr := win.AddText(Format("x{1} y{2} w{3} h20 +0x200 +Background{4}"
                , this.X + this.Pad, this.Y + 13, this.W - 2*this.Pad, this.Color), this.Title)
            this.Hdr.SetFont("s" FluidTheme.SizeTitle " w600 c" FluidTheme.Text)
        }

        if ((bt := FluidOpt(opts, "Badge", "")) != "") {
            b := FluidBadge(win, bt, {Tone: FluidOpt(opts, "BadgeTone", "accent")})
            b.Layout(this.X + this.W - this.Pad - b.W, this.Y + 14, b.W, b.H)
            this.CornerBadge := b
        }

        this._Register()
    }

    ; Geometry of the content region (inside padding, below the header).
    ContentX() => this.X + this.Pad
    ContentY() => this.Y + this.Pad + (this.Title != "" ? 26 : 0)
    ContentW() => this.W - 2*this.Pad
    ContentH() => this.H - (this.ContentY() - this.Y) - this.Pad

    ; A VStack covering the content region.
    Stack(opts := {}) => FluidVStack(this.Win, this.ContentX(), this.ContentY(), this.ContentW(), opts)

    Layout(x, y, w, h := 0) {
        this.X := x, this.Y := y
        this.W := w, this.H := h ? h : this.H
        this.Bg.Move(x, y, w, this.H)
        if this.HasProp("Hdr")
            this.Hdr.Move(x + this.Pad, y + 13, w - 2*this.Pad, 20)
        if this.HasProp("CornerBadge")
            this.CornerBadge.Layout(x + w - this.Pad - this.CornerBadge.W, y + 14
                , this.CornerBadge.W, this.CornerBadge.H)
        return this
    }
}
