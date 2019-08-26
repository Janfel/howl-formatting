--
formatters = setmetatable {},{
    __index: (t, k) -> error "Formatter not found: "..k
}
formatter_names = {}


register = (fmt) ->
    formatters[fmt.name] = fmt
    formatter_names[fmt.name] = fmt.description

unregister = (fmt) ->
    formatters[fmt.name] = nil
    formatter_names[fmt.name] = nil

by_name = (name) ->
    if not name or name == ""
        name = select!
        return unless name
    formatters[name]

by_mode = (mode) ->
    by_name howl.config.get "formatter", "", "mode:"..mode.name

select = ->
    {:selection} = howl.interact.select
        items: formatter_names
        columns: {"Formatter", "Description"}
    by_name selection

{
    :register
    :unregister
    :by_name
    :by_mode
    :select
}
