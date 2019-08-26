-- Initialize bundled formatters
bundle_load "formatters.#{f}" for f in *{
    "python_black"
}
