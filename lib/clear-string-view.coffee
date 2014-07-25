{View} = require 'atom'

module.exports =
class ClearStringView extends View
  @content: ->
    @div class: 'clear-string overlay from-top', =>
      @div "The ClearString package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "clear-string:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "ClearStringView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
