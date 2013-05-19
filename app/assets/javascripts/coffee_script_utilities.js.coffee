# Creates a namespaced class or method
#
# Example usages:
# namespace 'Foo.Bar', (exports) ->
#   class export.Baz
#     ...
# namespace 'Foo.Baz', (exports) ->
#  exports.alertFoo = ->
#    alert 'foo'

window.namespace = (target, name, block) ->
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
  top    = target
  target = target[item] or= {} for item in name.split '.'
  block target, top
