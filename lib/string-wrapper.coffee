#StringWrapperView = require './string-wrapper-view'

_ = require 'underscore-plus'

module.exports =
  activate: ->
    atom.workspaceView.command 'string-wrapper:single-str', => @string('single')
    atom.workspaceView.command 'string-wrapper:double-str', => @string('double')

  string: (quotes) ->
    # Assumes the active pane item is an editor
    editor = atom.workspace.getActiveEditor()
    selection = editor.getSelection().getText()

    curPosition = editor.getCursorBufferPosition()
    scopes = editor.scopesForBufferPosition(curPosition).toString()

    if quotes is 'double'
      if scopes.match(/string\.quoted\.double/)
        preventInfLoop = 0
        # Temporary scope variable
        scope = scopes
        until scope.match(/string\.begin/) or preventInfLoop is 10000
          startPos = editor.getCursorBufferPosition()
          scope = editor.scopesForBufferPosition(startPos).toString()
          editor.moveCursorLeft()
          preventInfLoop += 1

        until scope.match(/string\.end/) or preventInfLoop is 10000
          endPos = editor.getCursorBufferPosition()
          scope = editor.scopesForBufferPosition(endPos).toString()
          editor.moveCursorRight()
          preventInfLoop += 1

        editor.setCursorBufferPosition(startPos)
        editor.delete()
        editor.setCursorBufferPosition(endPos)
        editor.moveCursorLeft()
        editor.delete()

      else
        # Do nothing if nothing was selected
        # Otherwise surround in quotations
        editor.insertText('"' + selection + '"') unless \
          editor.getSelection().isEmpty()

    else # if quotes is double
      if scopes.match(/string\.quoted\.single/)
        preventInfLoop = 0
        # Temporary scope variable
        scope = scopes
        until scope.match(/string\.begin/) or preventInfLoop is 10000
          startPos = editor.getCursorBufferPosition()
          scope = editor.scopesForBufferPosition(startPos).toString()
          editor.moveCursorLeft()
          preventInfLoop += 1

        until scope.match(/string\.end/) or preventInfLoop is 10000
          endPos = editor.getCursorBufferPosition()
          scope = editor.scopesForBufferPosition(endPos).toString()
          editor.moveCursorRight()
          preventInfLoop += 1

        editor.setCursorBufferPosition(startPos)
        editor.delete()
        editor.setCursorBufferPosition(endPos)
        editor.moveCursorLeft()
        editor.delete()

      else
        # Do nothing if nothing was selected
        # Otherwise surround in quotations
        editor.insertText('\'' + selection + '\'') unless \
          editor.getSelection().isEmpty()
