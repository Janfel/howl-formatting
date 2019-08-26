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
        default: true

format_buffer = (fmt=nil) ->
    buf = howl.app.editor.buffer
    error "(ERROR) => Attempting to format read-only buffer" if buf.read_only

    mode = buf.mode
    fmt or= formatter.by_mode mode

    buf.read_only = true
    ok, result = pcall fmt.handler, buf.text, mode
    unless ok
        buf.read_only = false
        error result

    buf.text = result
    buf.read_only = false

format_file = (fmt=nil) ->
    buf = howl.app.editor.buffer
    error "(ERROR) => Attempting to format read-only buffer" if buf.read_only

    buf.read_only = true
    file = howl.app.editor.buffer.file or error "(ERROR) => No associated file"
    mode = howl.mode.for_file file
    fmt or= formatter.by_mode mode
    error "(ERROR) => File not writeable" unless file.writeable

    backup = file.contents
    ok, result = pcall fmt.file_handler, file, mode
    unless ok
        file.contents = backup
        buf.read_only = false
        error result

    howl.app.editor.buffer.reload()
    buf.read_only = false

cmd_specs = {
    {"format-buffer", "Format the current buffer", format_buffer}
    {"format-buffer-with", "Format the current buffer with a given formatter", format_buffer, formatter.select}
    {"format-file", "Format the current file and reload the buffer", format_file}
    {"format-file-with", "Format the current file with a given formatter and reload the buffer", format_file, formatter.select}
}
for {name, description, handler, input} in *cmd_specs
    howl.commands.register {:name, :description, :handler, :input}

unload_cmds = ->
    howl.commands.unregister name for {name} in *cmd_specs


keymap ={
    editor: alt_f: "format-buffer"
}
howl.bindings.push keymap
unload_keys = -> howl.bindings.remove keymap


signal_handlers = {
    {
        signal: "buffer-saved"
        handler: -> format_file! if howl.config.format_on_save
    }
}
howl.signal.connect sh.signal, sh.handler for sh in *signal_handlers
unload_signals = -> howl.signal.disconnect signal, handler for {:signal, :handler} in *signal_handlers


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

-- commands = {
--     {
--         name: "format-buffer-in-buffer"
--         description: "Format this buffers content in a new buffer"
--         handler: ->
--             mode = howl.app.editor.buffer.mode
--             fmt = formatters[mode.name].stream
--             buf = howl.app.editor.buffer
--             newbuf = Buffer mode
--             newbuf.text = fmt buf.text
--             newbuf.title = buf.title.." (Formatted)"
--             newbuf.modified = false
--             howl.app.editor.buffer = newbuf
--     }
--     {
--         name: "format-selection"
--         description: "Format the current selection"
--         handler: ->
--             mode = howl.app.editor.mode_at_cursor!
--             fmt = formatters[mode.name].stream
--             sel = howl.app.editor.selection
--             sel.text = fmt sel.text
--     }
--     {
--         name: "format-selection-in-buffer"
--         description: "Format the current selection in a new buffer"
--         handler: ->
--             mode = howl.app.editor.mode_at_cursor!
--             fmt = formatters[mode.name].stream
--             sel = howl.app.editor.selection
--             newbuf = Buffer mode
--             newbuf.texf = fmt sel.text
--             newbuf.modified = false
--             howl.app.editor.buffer = newbuf
--     }
-- }
-- howl.command.register cmd for cmd in *commands
