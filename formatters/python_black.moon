formatter = bundle_load "formatter"

formatter.register
    name: "python-black"
    description: ""
    handler: (code) ->
    file_handler: (file) ->

howl.mode.by_name("python").config.formatter or= "python-black"
