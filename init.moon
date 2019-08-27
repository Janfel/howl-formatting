formatter = bundle_load "formatter"


with howl.config
    .define
        name: "formatter"
        description: "Which text formatter to use"
        type_of: "string"

    .define
        name: "format_on_save"
        description: "Whether to run format-current-file on save"
        type_of: "boolean"
        default: false

    .define
        -- Implement predefined positive-integer type
        name: "line_length"
        description: "The maximum line length formatters should output"
        convert: (value) -> tonumber(value) or tonumber(tostring value) or value
        -- Check if positive integer
        validate: (value) -> type(value) == "number" and not tostring(value)\find("%.") and value >= 0
        default: 80

buffer_format = (args) ->
    {:fmt, :ok} = args
    return unless ok

    buf = howl.app.editor.buffer
    error "Attempting to format read-only buffer" if buf.read_only

    mode = buf.mode
    fmt or= formatter.by_mode mode
    error "No formatter for mode '#{mode.name}' " unless fmt

    buf.read_only = true
    ok, result = pcall fmt.handler, buf.text, mode
    unless ok
        buf.read_only = false
        error result

    buf.read_only = false
    buf.text = result

file_format = (args) ->
    {:fmt, :ok} = args
    return unless ok

    buf = howl.app.editor.buffer
    error "Attempting to format read-only buffer" if buf.read_only

    buf.read_only = true
    file = howl.app.editor.buffer.file or error "No file associated with buffer '#{buf}'"
    error "File not writeable" unless file.writeable

    mode = howl.mode.for_file file
    fmt or= formatter.by_mode mode
    error "No formatter for mode '#{mode.name}' " unless fmt

    backup = file.contents
    ok, result = pcall fmt.file_handler, file, mode
    unless ok
        file.contents = backup
        buf.read_only = false
        error result

    buf.read_only = false
    howl.app.editor.buffer.reload()


cmd_specs = {
    {"buffer-format", "Format the current buffer", buffer_format, (opts) -> fmt: nil, ok: true}
    {"buffer-format-with", "Format the current buffer with a given formatter"
    buffer_format, (opts) ->
        selection = formatter.select!
        fmt: selection, ok: selection
    }
    {"file-format", "Format the current file and reload the buffer", file_format, (opts) -> fmt: nil, ok: true}
    {"file-format-with", "Format the current file with a given formatter and reload the buffer"
    file_format, (opts) ->
        selection = formatter.select!
        fmt: selection, ok: selection
    }
}
for {name, description, handler, input} in *cmd_specs
    howl.command.register {:name, :description, :handler, :input}

unload_cmds = ->
    howl.command.unregister name for {name} in *cmd_specs


keymap ={
    editor: alt_f: "buffer-format"
}
howl.bindings.push keymap
unload_keys = -> howl.bindings.remove keymap


signal_handlers = {
    {
        signal: "buffer-saved"
        handler: -> file_format! if howl.config.format_on_save
    }
}
howl.signal.connect sh.signal, sh.handler for sh in *signal_handlers
unload_signals = -> howl.signal.disconnect signal, handler for {:signal, :handler} in *signal_handlers


bundle_load "formatters" -- Initialize bundled formatters

unload = ->
    unload_cmds!
    unload_keys!
    unload_signals!

import register, unregister, by_name, by_mode, select from formatter
{
    :register
    :unregister
    :by_name
    :by_mode
    :select
    --
    info:
        author: "Copyright 2019 Jan Felix Langenbach"
        description: "Code formatting engine"
        license: "MIT"
    :unload
}
