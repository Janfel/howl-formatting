formatter = bundle_load "formatter"
import Process from howl.io

formatter.register
    name: "python-black"
    description: ""
    handler: (code, mode) ->
        line_length = mode.config.line_length
        out, err, proc = Process.execute {
            "python", "-m"
            "black", "-q"
            "-l", tostring line_length
            "-"
        }, {stdin: code}

        error err unless proc.successful
        out

    file_handler: (file, mode) ->
        line_length = mode.config.line_length
        out, err, proc = Process.execute {
            "python", "-m"
            "black", "-q"
            "-l", line_length
            file
        }

        error err unless proc.successful
        out

howl.mode.by_name("python").config.formatter or= "python-black"
