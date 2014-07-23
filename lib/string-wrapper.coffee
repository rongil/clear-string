#StringWrapperView = require './string-wrapper-view'

module.exports =

  editor: atom.workspace.getActiveEditor()

  activate: ->
    atom.workspaceView.command 'string-wrapper:single-str', =>
      @toggleString('single')
    atom.workspaceView.command 'string-wrapper:double-str', =>
      @toggleString('double')

  toggleString: (quotes) ->
    initialPos = @editor.getCursorBufferPosition()
    initialScope = @editor.scopesForBufferPosition(initialPos).toString()
    selection = @editor.getSelection().getText()

    if quotes is 'double'
      if initialScope.match(/string\.quoted\.double/)
        @stringMatch(initialScope, initialPos)
      else
        # Do nothing if nothing was selected, otherwise surround in quotations
        @editor.insertText('"' + selection + '"') unless \
          @editor.getSelection().isEmpty()

    else # if quotes is single
      if initialScope.match(/string\.quoted\.single/)
        @stringMatch(initialScope, initialPos)
      else
        # Do nothing if nothing was selected, otherwise surround in quotations
        @editor.insertText('\'' + selection + '\'') unless \
          @editor.getSelection().isEmpty()

  stringMatch: (initialScope, initialPos) ->
    # Initialize the position variables to the current position
    startPos = endPos = @editor.getCursorBufferPosition()

    # Variable to prevent an infinite loop
    # Used mainly during testing, may be removed later on
    preventInfLoop = 0

    scope = initialScope
    until scope.match(/string\.begin/) or preventInfLoop is 80000
      @editor.moveCursorLeft()
      startPos = @editor.getCursorBufferPosition()
      scope = @editor.scopesForBufferPosition(startPos).toString()
      preventInfLoop++

    preventInfLoop = 0

    scope = initialScope
    until scope.match(/string\.end/) or preventInfLoop is 80000
      @editor.moveCursorRight()
      endPos = @editor.getCursorBufferPosition()
      scope = @editor.scopesForBufferPosition(endPos).toString()
      preventInfLoop++

    # Transact makes it all one undo/redo step
    @editor.transact =>
      @editor.setCursorBufferPosition(startPos)
      @editor.delete()
      @editor.setCursorBufferPosition(endPos)
      # Buffer position ends up differently when going through multiple rows
      if startPos.row is endPos.row
        @editor.backspace()
      else
        @editor.delete()
      # Reset buffer position and account for the deleted character
      @editor.setCursorBufferPosition(initialPos.add([0,-1]))
