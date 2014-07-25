#ClearStringView = require './clear-string-view'

module.exports =

  editor: atom.workspace.getActiveEditor()

  activate: ->
    atom.workspaceView.command 'clear-string:single-str', =>
      @stringCheck('single')
    atom.workspaceView.command 'clear-string:double-str', =>
      @stringCheck('double')

  stringCheck: (quoteType) ->
    @allRanges = []
    @transact = false
    displayBuffer = @editor.displayBuffer
    strType = 'string.quoted.' + quoteType

    # Loop through all selections
    for selection in @editor.getSelections()
      # Get the selection range
      selRange = selection.getBufferRange()
      # Check if the cursor is next to or within a string
      range = displayBuffer.bufferRangeForScopeAtPosition(
        strType, selRange.start)
      if range then @stringClear(range, false) else
        # Otherwise, if there is something selected in one line...
        if selection.isSingleScreenLine() and not selection.isEmpty()
          # Check if there is a string within the selected text
          range = @stringSearch(displayBuffer, selRange, strType)
          if range then @stringClear(range, false) else
            selection.setBufferRange(selRange)

    # After loop, check if any results
    if @transact
      @stringClear(null, true)

  stringClear: (newRange, loopDone) ->
    # Set variable to show that at least one range was found
    @transact = true
    # Once the loop is done, remove the strings as a single step
    if loopDone then @editor.transact =>
      for rangeData in @allRanges
        # Remove the number of characters corresponding to the quotes
        # rangeData[0] is the actual range
        # rangeData[1] is the number of quotes (1 or 3)
        text = @editor.getTextInBufferRange(rangeData[0])
          .slice(rangeData[1], -(rangeData[1]))
        @editor.setTextInBufferRange(rangeData[0], text)
    # If still looping, add the new range
    else
      # Check if it's a block string or a regular string
      scope = @editor.scopesForBufferPosition(newRange.start).toString()
      numQuotes = if /block/.test(scope) then 3 else 1
      @allRanges.push([newRange, numQuotes])


  stringSearch: (displayBuffer, selRange, strType) ->
    # Set the position to the start of the selected text
    position = selRange.start
    # Loop through the selected text
    until position.isEqual(selRange.end)
      # If a string is found, stop looping and return its range
      range = displayBuffer.bufferRangeForScopeAtPosition(
        strType, position)
      if range then return range
      # Otherwise keep moving right
      position = position.add([0,1])
