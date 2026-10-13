#Requires AutoHotkey v2.0

; ============================================================================
; Layout helpers — position controls without manual pixel math.
;
;   col := win.VStack(24, 24, 480, {Gap: 12})
;   col.Add(Fluid.ModernButton(win, "Save", cb))       ; full width, .H height
;   col.Add(anyGuiCtrl, 40)                            ; or an explicit height
;   row := col.Row(36)                                 ; nested HStack row
;   row.Add(Fluid.Badge(win, "Beta"))                  ; intrinsic widths
;
; Stacks accept Fluid widgets (via .Layout/.W/.H) or plain GuiControls.
; ============================================================================

class FluidHStack {
    __New(win, x, y, h, opts := {}) {
        this.Win   := win
        this.X     := x,   this.Y := y, this.H := h
        this.Gap   := FluidOpt(opts, "Gap", FluidTheme.Gap)
        this.Align := FluidOpt(opts, "Align", "center")   ; center | top
        this._cx   := x
        this._rx   := FluidOpt(opts, "X2", 0)             ; right edge for AddRight
    }

    Cursor => this._cx

    _y(itemH) => (this.Align = "top" ? this.Y : this.Y + (this.H - itemH)//2)

    ; Append left-to-right. w = 0 uses the item's intrinsic width.
    Add(item, w := 0) {
        if (item.HasMethod("Layout")) {
            iw := w ? w : item.W
            ih := item.H
            item.Layout(this._cx, this._y(ih), iw, ih)
        } else {
            item.GetPos(&ix, &iy, &iw, &ih)
            iw := w ? w : iw
            item.Move(this._cx, this._y(ih), iw, ih)
        }
        this._cx += iw + this.Gap
        return item
    }

    ; Append right-to-left from the X2 edge given at construction.
    AddRight(item, w := 0) {
        if (!this._rx)
            throw Error("FluidHStack: pass {X2: px} to use AddRight")
        if (item.HasMethod("Layout")) {
            iw := w ? w : item.W
            ih := item.H
        } else {
            item.GetPos(&ix, &iy, &iw, &ih)
            iw := w ? w : iw
        }
        this._rx -= iw
        if (item.HasMethod("Layout"))
            item.Layout(this._rx, this._y(ih), iw, ih)
        else
            item.Move(this._rx, this._y(ih), iw, ih)
        this._rx -= this.Gap
        return item
    }

    Space(n := 0) => (this._cx += (n ? n : this.Gap))
}

class FluidVStack {
    __New(win, x, y, w, opts := {}) {
        this.Win  := win
        this.X    := x,   this.Y := y, this.W := w
        this.Gap  := FluidOpt(opts, "Gap", FluidTheme.Gap)
        this._cy  := y
    }

    ; Current insertion point (px from window client top).
    Cursor => this._cy

    ; Place an item full-width. h = 0 uses the item's own height.
    Add(item, h := 0) {
        if (item.HasMethod("Layout")) {
            ih := h ? h : item.H
            item.Layout(this.X, this._cy, this.W, ih)
        } else {
            item.GetPos(&ix, &iy, &iw, &ih)
            ih := h ? h : ih
            item.Move(this.X, this._cy, this.W, ih)
        }
        this._cy += ih + this.Gap
        return item
    }

    ; Place an item at an explicit width (left-anchored).
    AddW(item, w) {
        if (item.HasMethod("Layout")) {
            item.Layout(this.X, this._cy, w, item.H)
            this._cy += item.H + this.Gap
        } else {
            item.GetPos(&ix, &iy, &iw, &ih)
            item.Move(this.X, this._cy, w, ih)
            this._cy += ih + this.Gap
        }
        return item
    }

    ; Nested horizontal row: returns a FluidHStack at the cursor and advances.
    Row(h, opts := {}) {
        hs := FluidHStack(this.Win, this.X, this._cy, h, opts)
        this._cy += h + this.Gap
        return hs
    }

    ; Advance the cursor by n px (default: one gap).
    Space(n := 0) => (this._cy += (n ? n : this.Gap))
}
