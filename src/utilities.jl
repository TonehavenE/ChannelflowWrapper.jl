# This file includes utilities to help with the main Channelflow wrappers.

using DelimitedFiles: readdlm
"""
    myreaddlm(filename, cc='%')

Read matrix or vector from a file, dropping comments marked with cc.
"""
function myreaddlm(filename, cc='%')
    X = readdlm(filename, comments=true, comment_char=cc)
    if size(X, 2) == 1
        X = X[:, 1]
    end
    X
end

"""
    verify_file(file)

Throws an error if `file` doesn't exist. Better to have Julia error instead of a downstream binary.
"""
function verify_file(file::AbstractString)
    if !ispath(file)
        throw(ArgumentError("File $file does not exist!"))
    end
end

"""
    kwargs_to_flags(kwargs)

Converts a list of keyword arguments to a string of flags to pass into a Channelflow binary.
"""
function kwargs_to_flags(kwargs)
    # Convert keyword arguments into a vector of strings
    flags = String[]
    for (key, value) in kwargs
        # Use the key as the flag (e.g., :Nx -> "-Nx")
        flag_name = "-$(key)"

        if value isa Bool
            # Handle boolean flags: only add the flag if true
            value && push!(flags, flag_name)
        else
            # Handle key-value pairs (e.g., "-Nx", "64")
            push!(flags, flag_name, string(value))
        end
    end
    return flags
end

"""

"""
function ijkl2file(ijkl, filebase)
    filename = occursin(".asc", filebase) ? filebase : filebase * ".asc"
    io = open(filename, "w")
    M, N = size(ijkl)
    N == 4 || error("ijkl matrix should have 4 cols, but it has N=$N")
    println(io, "% $M")
    for n = 1:M
        #i,j,k,l = ijkl[n,:]
        println(io, "$(ijkl[n,1]) $(ijkl[n,2]) $(ijkl[n,3]) $(ijkl[n,4])")
    end
    close(io)
end

function save(A::Matrix, filebase)
    filename = occursin(".asc", filebase) ? filebase : filebase * ".asc"
    io = open(filename, "w")
    M, N = size(A)
    println(io, "% $M $N")
    for i = 1:M, j = 1:N
        print(io, A[i, j], j < N ? ' ' : '\n')
    end
    close(io)
end

function save(x::Vector, filebase)
    filename = occursin(".asc", filebase) ? filebase : filebase * ".asc"
    io = open(filename, "w")
    N = length(x)
    println(io, "% $N")
    for i = 1:N
        print(io, x[i], '\n')
    end
    close(io)
end
