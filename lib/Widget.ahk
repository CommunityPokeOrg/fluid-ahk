#Requires AutoHotkey v2.0

; ============================================================================
; FluidWidget — shared base for every Fluid control.
;
; A widget owns one or more GuiControls and exposes:
;   .W / .H           preferred size used by layout helpers
;   .Layout(x,y,w,h)  position all of its controls (called by stacks)
;   .SetEnabled(bool)
;
; Pointer routing is centralized in FluidWindow: each widget reports the
; HWNDs it owns via _TrackHwnds() and receives _MouseEnter / _MouseLeave /
; _PointerDown / _PointerMove / _PointerUp / _Clicked callbacks.
; ============================================================================

class FluidWidget {
    Win := 0
    X := 0, Y := 0, W := 0, H := 0
    _Enabled := true

    ; HWNDs this widget wants pointer events for (SS_NOTIFY controls only).
    _TrackHwnds() => []

    _Register() {
        this.Win.Register(this)
        for h in this._TrackHwnds()
            FluidWindow.HwndMap[h] := this
    }

    ; Pointer callbacks — override as needed.
    _MouseEnter() {
    }
    _MouseLeave() {
    }
    _PointerDown() {
    }
    _PointerMove() {
    }          ; only invoked while this widget is being dragged
    _PointerUp() {
    }
    _Clicked() {
    }

    ; Cursor position in the owning window's client area.
    _ClientMouse(&mx, &my) {
        pt := Buffer(8)
        DllCall("GetCursorPos", "ptr", pt)
        DllCall("ScreenToClient", "ptr", this.Win.Hwnd, "ptr", pt)
        mx := NumGet(pt, 0, "int"), my := NumGet(pt, 4, "int")
    }

    SetEnabled(on) => (this._Enabled := !!on)
}
