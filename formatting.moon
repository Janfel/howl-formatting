-- Stream: code -> code
-- Print: file -> code
-- Inline: file -> changed? (reload after)
-- Copy: ifile, ofile -> changed?
-- fop = File operation
-- tmp = Tempfile
-- Should at least have stream and print

import File from howl.io -- update when my PR gets merged

-- x to stream

-- 1 fop 1 tmp
print_to_stream = (print_f) -> (code) ->
    local result
    File.with_tmpfile (file) ->
        file.contents = code
        result = print_f file
    result

-- 2 fops 1 tmp
inline_to_stream = (inline_f) -> (code) ->
    local result
    File.with_tmpfile (file) ->
        file.contents = code
        inline_f file
        result = file.contents
    result

-- 4 fops 2 tmps
copy_to_stream = (copy_f) ->
    log.warn "(WARNING) => Converting copy formatter to stream formatter"
    (code) ->
        tmp1 = File.tmpfile!
        tmp2 = File.tmpfile!
        tmp1.contents = code
        copy_f tmp1 tmp2
        result = tmp2.contents
        tmp1.delete!
        tmp2.delete!
        result

-- x to print

-- 1 fop 0 efops
stream_to_print = (stream_f) -> (file) ->
    stream_f file.contents

-- 1 efop 1 tmp
copy_to_print = (copy_f) -> (ifile) ->
    local result
    File.with_tmpfile (tfile) ->
        copy_f ifile tfile
        result = tfile.contents
    result

-- 3 efops 1 tmp
inline_to_print = (inline_f) ->
    log.warn "(WARNING) => Converting inline formatter to print formatter"
    (ifile) ->
        local result
        File.with_tmpfile (tfile) ->
            tfile.contents = ifile.contents
            inline_f tfile
            result = tfile.contents
        result

-- x to inline

-- 1 fop 0 efops
print_to_inline = (print_f) -> (file) ->
    file.contents = print_f file

-- 2 fops 0 efops
stream_to_inline = (stream_f) -> (file) ->
    file.contents = stream_f file.contents

-- 2 efops 1 tmp
copy_to_inline = (copy_f) -> (ifile) ->
    File.with_tmpfile (tfile) ->
        tfile.contents = ifile.contents
        copy_f tfile ifile

-- x to copy

-- 1 fop 0 efops
print_to_copy = (print_f) -> (ifile, ofile) ->
    ofile.contents = print_f ifile

-- 2 fops
stream_to_copy = (stream_f) -> (ifile, ofile) ->
    ofile.contents = stream_f ifile.contents

-- 2 fops
inline_to_copy = (inline_f) -> (ifile, ofile) ->
    ofile.contents = ifile.contents
    inline_f ofile

formatters_sub_mt =
    __newindex: (t, k, v) -> t.___[k] = v
    __index: (t, k) -> with t.___
        result = switch k
            when "stream"
                if     .stream then                  .stream
                elseif .print  then print_to_stream  .print
                elseif .inline then inline_to_stream .inline
                elseif .copy   then copy_to_stream   .copy
            when "print"
                if     .print  then                  .print
                elseif .stream then stream_to_print  .stream
                elseif .copy   then copy_to_print    .print
                elseif .inline then inline_to_print  .inline
            when "inline"
                if     .inline then                  .inline
                elseif .print  then print_to_inline  .print
                elseif .stream then stream_to_inline .stream
                elseif .copy   then copy_to_inline   .copy
            when "copy"
                if     .copy   then                  .copy
                elseif .print  then print_to_copy    .print
                elseif .stream then stream_to_copy   .stream
                elseif .inline then inline_to_copy   .inline

        result or error "No #{k} formatter found"

formatters_mt = __index: -> setmetatable ___: {}, formatters_sub_mt

formatters = setmetatable {}, formatters_mt

register = (formatter) ->
    {:mode, :type, :handler} = formatter
    formatters[mode][type] = handler

unregister = (mode, type) ->
    formatters[mode][type] = nil

{
    :formatters
    :register
    :unregister
}
