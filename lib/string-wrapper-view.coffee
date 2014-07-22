{View} = require 'atom'

module.exports =
class StringWrapperView extends View
  @content: ->
    @div class: 'string-wrapper overlay from-top', =>
      @div "The StringWrapper package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "string-wrapper:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "StringWrapperView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
