#Requires AutoHotkey v2.0

; ============================================================================
; FluidOpt — read an option from an Object literal or a Map, with a default.
;   FluidOpt({W: 200}, "W", 100)        -> 200
;   FluidOpt(Map("W", 200), "W", 100)   -> 200
;   FluidOpt({}, "W", 100)              -> 100
; ============================================================================

FluidOpt(opts, name, default) {
    if (Type(opts) = "Map")
        return opts.Has(name) ? opts[name] : default
    return (IsObject(opts) && opts.HasOwnProp(name)) ? opts.%name% : default
}
