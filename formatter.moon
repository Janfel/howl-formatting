formatters = {}
formatter_names = {}


register = (fmt) ->
  formatters[fmt.name] = fmt
  table.insert formatter_names, {fmt.name, fmt.description}

unregister = (fmt) ->
  formatters[fmt.name] = nil
  table.remove formatter_names, {fmt.name, fmt.description}

by_name = (name) ->
  formatters[name]

by_mode = (mode) ->
  by_name howl.config.get "formatter", "", "mode:"..mode.name

select = ->
  result = howl.interact.select
    items: formatter_names
    columns: {
      {style: "string"}
      {style: "comment"}
    }
  return unless result
  by_name result.selection

{
  :register
  :unregister
  :by_name
  :by_mode
  :select
}
