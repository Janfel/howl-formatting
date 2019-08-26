formatter = bundle_load "formatter"

formatter.register
    name: "python-black"
    description: ""
    handler: (code) ->
    file_handler: (file) ->

with howl.mode.by_name "python"
    unless .config.formatter
        .config.formatter = "python-black"
