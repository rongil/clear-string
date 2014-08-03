module.exports =
  activate: ->
    atom.workspaceView.command 'clear-string:single-str', ->
      stringCheck('single')
    atom.workspaceView.command 'clear-string:double-str', ->
      stringCheck('double')

  stringCheck: (quoteType, editor) -> stringCheck(quoteType, editor)


stringCheck = (quoteType, editor) ->
  # Unless an editor was provided, get the active editor
  editor = atom.workspace.getActiveEditor() unless editor?
  position = null
  dispBuffer = editor.displayBuffer
  quoteRegex = if quoteType is 'double' then /"/ else /'/
  result = null
  strType = 'string.quoted.' + quoteType

  ###
  Note: If the transact is done at at the end (as I had originally made it),
        later checking must be done to ensure the text in the range does not
        change from the previous modifications.
  ###
  # Make it all one undo step
  editor.transact ->
    # Loop through all selections
    editor.getSelections()
    for selection in editor.getSelections()
      # Get the selection range
      selRange = selection.getBufferRange()
      # Check if the cursor is next to or within a string
      range = dispBuffer.bufferRangeForScopeAtPosition(strType, selRange.start)
      console.log editor.scopesForBufferPosition(selRange.start).toString()
      if range? then result = stringClear(editor, position, quoteRegex, range)
      # Check the rest of the selection for more strings (if not empty)
      unless selection.isEmpty()
        # Keep checking for strings within the selected text
        range = stringSearch(dispBuffer, editor, position, selRange, strType)
        while range?
          break unless result = stringClear(editor, position, quoteRegex, range)
          range = stringSearch(dispBuffer, editor, position, selRange, strType)
        # If there were no results, reset the selection
        unless result?
          selection.setBufferRange(selRange)

stringClear = (editor, position, quoteRegex, range) ->
  # Check if it's a block string or a regular string
  scope = editor.scopesForBufferPosition(range.start).toString()
  blockString = /block/.test(scope)

  # Watch for problems with a string wrapped in multiple lines
  begRange = editor.clipBufferRange([range.start, range.start.add([0,1])])
  endRange = editor.clipBufferRange([range.end.add([0,-1]), range.end])
  # Condition for no selection
  unless begRange.isEqual(endRange) or blockString
    # Check that the characters to be removed are actually quotes
    left = quoteRegex.test(editor.getTextInBufferRange(begRange))
    right = quoteRegex.test(editor.getTextInBufferRange(endRange))
  multi = Boolean(!(left and right))

  # Ignore if a multiline string
  unless multi or blockString
    # Remove the number of characters corresponding to the quotes
    text = editor.getTextInBufferRange(range)[1...-1]
    editor.setTextInBufferRange(range, text)
    # Set variable to show that there was action taken
    return true
  # If searching through results, adjust the position accordingly
  if position?
    # Check for end of line
    EOL = position.isEqual(editor.clipBufferPosition(position.add([0,1])))
    # If it is the end of the line or there is a multiline string, move down
    if EOL or multi
      newPos = range.end.translate([1,-Infinity])
      # Return without any action if the end of the buffer is reached
      return if newPos.row > editor.getLastBufferRow()
      position = editor.clipBufferPosition(newPos)
    # If a block string, move past it
    else if blockString then position = range.end.add([0, 1])
    # Otherwise account for the removed characters
    else position = range.end.add([0,-2])

stringSearch = (displayBuffer, editor, position, selRange, strType) ->
  # Set the position to the start of the selected text,
  # if this is the first time
  position = selRange.start unless position?
  # Loop through the selected text
  until position.isGreaterThanOrEqual(selRange.end)
    # If a string is found, stop looping and return its range
    range = displayBuffer.bufferRangeForScopeAtPosition(
      strType, position)
    if range then return range
    # If you hit the margin, move down
    if position.isEqual(editor.clipBufferPosition(position.add([0,1])))
      newPos = position.translate([1, -Infinity])
      # End the loop if the end of the buffer is reached
      break if newPos.row > editor.getLastBufferRow()
      position = editor.clipBufferPosition(newPos)
    # Otherwise keep moving right
    else position = position.add([0,1])
