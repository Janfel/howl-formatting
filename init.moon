import formatters, register, unregister from bundle_load "formatting"
import Buffer from howl

-- TODO
    --     "format-buffer"
    --     "format-buffer-in-buffer"
    --     "format-selection"
    --     "format-selection-in-buffer"
    --     "format-file"
    --     "format-current-file"
    --     "format-file-in-buffer"
    --     "format-file-as"

commands = {
    {
        name: "format-buffer"
        description: "Format the current buffer"
        handler: ->
            mode = howl.app.editor.buffer.mode
            fmt = formatters[mode].stream
            with howl.app.editor.buffer
                .text = fmt .text
    }
    {
        name: "format-buffer-in-buffer"
        description: "Format this buffers content in a new buffer"
        handler: ->
            mode = howl.app.editor.buffer.mode
            fmt = formatters[mode.name].stream
            buf = howl.app.editor.buffer
            newbuf = Buffer mode
            newbuf.text = fmt buf.text
            newbuf.title = buf.title.." (Formatted)"
            newbuf.modified = false
            howl.app.editor.buffer = newbuf
    }
    {
        name: "format-selection"
        description: "Format the current selection"
        handler: ->
            mode = howl.app.editor.mode_at_cursor!
            fmt = formatters[mode.name].stream
            sel = howl.app.editor.selection
            sel.text = fmt sel.text
    }
    {
        name: "format-selection-in-buffer"
        description: "Format the current selection in a new buffer"
        handler: ->
            mode = howl.app.editor.mode_at_cursor!
            fmt = formatters[mode.name].stream
            sel = howl.app.editor.selection
            newbuf = Buffer mode
            newbuf.texf = fmt sel.text
            newbuf.modified = false
            howl.app.editor.buffer = newbuf
    }
    {
        name: "format-current-file"
        description: "Formats the current file and reloads the buffer"
        handler: ->
            file = howl.app.editor.buffer.file
            error "(ERROR) => No associated file" unless file
            mode = howl.mode.for_file file
            fmt = formatters[mode.name].inline
            fmt file
            howl.app.editor.buffer.reload!
    }
}
howl.command.register cmd for cmd in *commands


keymap = {
    editor:
        alt_f: "format-buffer"
}
howl.bindings.push keymap


howl.config.define
    name: "format_on_save"
    description: "Whether to run format-current-file on save"
    type_of: "boolean"
    default: true


signal_handlers = {
    {
        signal: "buffer-saved"
        handler: -> howl.command.run "format-current-file" if howl.config.format_on_save
    }
}
howl.signal.connect sh.signal, sh.handler for sh in *signal_handlers


unload = ->
    howl.bindings.remove keymap
    howl.command.unregister cmd.name for cmd in commands
    howl.signal.disconnect sh.signal, sh.handler for sh in *signal_handlers

return {
    :register
    :unregister
    --
    info:
        author: "Copyright 2019 Jan Felix Langenbach"
        description: "Code formatting engine"
        license: "MIT"
    :unload
}
