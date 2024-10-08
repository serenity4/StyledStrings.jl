# This file is a part of Julia. License is MIT: https://julialang.org/license

module StyledStrings

using Base: AnnotatedString, AnnotatedChar, annotations, annotate!, annotatedstring
using Base.ScopedValues: ScopedValue, with, @with

export @styled_str
public Face, addface!, withfaces, styled, SimpleColor

include("faces.jl")
include("regioniterator.jl")
include("io.jl")
include("styledmarkup.jl")
include("legacy.jl")

using .StyledMarkup

const HAVE_LOADED_CUSTOMISATIONS = Base.Threads.Atomic{Bool}(false)

"""
    load_customisations!(; force::Bool=false)

Load customisations from the user's `faces.toml` file, if it exists as well as
the current environment.

This function should be called before producing any output in situations where
the user's customisations should be considered.

Unless `force` is set, customisations are only applied when this function is
called for the first time, and subsequent calls are a no-op.
"""
function load_customisations!(; force::Bool=false)
    !force && HAVE_LOADED_CUSTOMISATIONS[] && return
    if !isempty(DEPOT_PATH)
        userfaces = joinpath(first(DEPOT_PATH), "config", "faces.toml")
        isfile(userfaces) && loaduserfaces!(userfaces)
    end
    Legacy.load_env_colors!()
    HAVE_LOADED_CUSTOMISATIONS[] = true
    nothing
end

if Base.generating_output()
    include("precompile.jl")
end

end
