formatter = bundle_load "formatter"
import Process from howl.io

formatter.register
  name: "python-black"
  description: "The uncompromising Python code formatter"
  handler: (code, mode) ->
    line_length = mode.config.line_length
    out, err, proc = Process.execute {
      "python", "-m"
      "black", "-q"
      "-l", tostring line_length
      "-"
    }, {stdin: code}

    assert proc.successful, err
    out

  file_handler: (file, mode) ->
    line_length = mode.config.line_length
    out, err, proc = Process.execute {
      "python", "-m"
      "black", "-q"
      "-l", line_length
      file
    }

    assert proc.successful, err
    out

howl.mode.by_name("python").config.formatter or= "python-black"
