{stringCheck} = require '../lib/clear-string'

describe "ClearString", ->
  describe "stringCheck()", ->

    editor = null

    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage('language-python')

      runs ->
        testString = """
          'This is Test1'
          "This is Test2"
          This is 'Test3'
          This is "Test4"
          'This'\n'is'\n'Test5'
          "This"\n"is"\n"Test6"
          'This' "really" 'is' "Test7"
          '''This is''' \"""Test8\"""
        """
        buffer = atom.project.buildBufferSync()
        editor = atom.project.buildEditorForBuffer(buffer)
        editor.setGrammar(atom.syntax.selectGrammar('.py'))
        editor.setText(testString)

    describe "when the cursor is within a single quoted string", ->
      describe "when the single quote command is called", ->
        it "removes the quotes", ->
          editor.setCursorBufferPosition([0,1])
          stringCheck('single', editor)
          expect(editor.lineForBufferRow(0)).toBe "This is Test1"
      describe "when the double quote command is called", ->
        it "does nothing", ->
          editor.setCursorBufferPosition([0,1])
          stringCheck('double', editor)
          expect(editor.lineForBufferRow(0)).toBe "'This is Test1'"

    describe "when the cursor is within a double quoted string", ->
      describe "when the single quote command is called", ->
        it "does nothing", ->
          editor.setCursorBufferPosition([1,1])
          stringCheck('single', editor)
          expect(editor.lineForBufferRow(1)).toBe "\"This is Test2\""
      describe "when the double quote command is called", ->
        it "removes the quotes", ->
          editor.setCursorBufferPosition([1,1])
          stringCheck('double', editor)
          expect(editor.lineForBufferRow(1)).toBe "This is Test2"

    describe "when the text highlighted contains a single quoted string", ->
      describe "when the single quote command is called", ->
        it "removes the quotes from the single quoted text", ->
          editor.setCursorBufferPosition([2,0])
          editor.setSelectedBufferRange([[2,0], [2,15]])
          stringCheck('single', editor)
          expect(editor.lineForBufferRow(2)).toBe "This is Test3"
      describe "when the double quote command is called", ->
        it "does nothing", ->
          editor.setSelectedBufferRange([[2,0], [2,15]])
          stringCheck('double', editor)
          expect(editor.lineForBufferRow(2)).toBe "This is 'Test3'"

    describe "when the text highlighted contains a double quoted string", ->
      describe "when the single quote command is called", ->
        it "does nothing", ->
          editor.setSelectedBufferRange([[3,0], [3,15]])
          stringCheck('single', editor)
          expect(editor.lineForBufferRow(3)).toBe "This is \"Test4\""
      describe "when the double quote command is called", ->
        it "removes the quotes from the double quoted text", ->
          editor.setSelectedBufferRange([[3,0], [3,15]])
          stringCheck('double', editor)
          expect(editor.lineForBufferRow(3)).toBe "This is Test4"

    describe "when the text highlighted has multiple single quoted strings", ->
      describe "when the single quote command is called", ->
        it "removes the quotes from all the single quoted strings", ->
          editor.setSelectedBufferRange([[4,0], [6,7]])
          stringCheck('single', editor)
          expect(editor.lineForBufferRow(4)).toBe "This"
          expect(editor.lineForBufferRow(5)).toBe "is"
          expect(editor.lineForBufferRow(6)).toBe "Test5"
      describe "when the double quote command is called", ->
        it "does nothing", ->
          editor.setSelectedBufferRange([[4,0], [6,7]])
          stringCheck('double', editor)
          expect(editor.lineForBufferRow(4)).toBe "'This'"
          expect(editor.lineForBufferRow(5)).toBe "'is'"
          expect(editor.lineForBufferRow(6)).toBe "'Test5'"

    describe "when the text highlighted has multiple double quoted strings", ->
      describe "when the single quote command is called", ->
        it "does nothing", ->
          editor.setSelectedBufferRange([[7,0], [9,7]])
          stringCheck('single', editor)
          expect(editor.lineForBufferRow(7)).toBe "\"This\""
          expect(editor.lineForBufferRow(8)).toBe "\"is\""
          expect(editor.lineForBufferRow(9)).toBe "\"Test6\""
      describe "when the double quote command is called", ->
        it "removes the quotes from all the double quoted strings", ->
          editor.setSelectedBufferRange([[7,0], [9,7]])
          stringCheck('double', editor)
          expect(editor.lineForBufferRow(7)).toBe "This"
          expect(editor.lineForBufferRow(8)).toBe "is"
          expect(editor.lineForBufferRow(9)).toBe "Test6"

    describe "when the text highlighted contains both types of string", ->
      describe "when the single quote command is called", ->
        it "removes the quotes from all the single quoted strings", ->
          editor.setSelectedBufferRange([[10,0],[10,28]])
          stringCheck('single', editor)
          expect(editor.lineForBufferRow(10)).toBe \
            "This \"really\" is \"Test7\""
      describe "when the double quote command is called", ->
        it "removes the quotes from all the double quoted strings", ->
          editor.setSelectedBufferRange([[10,0],[10,28]])
          stringCheck('double', editor)
          expect(editor.lineForBufferRow(10)).toBe \
            "'This' really 'is' Test7"

    describe "when there are block strings in range", ->
      describe "when the single quote command is called", ->
        it "does nothing", ->
          editor.setSelectedBufferRange([[11,0], [11,19]])
          stringCheck('single', editor)
          expect(editor.lineForBufferRow(11)).toBe \
            "'''This is''' \"\"\"Test8\"\"\""
      describe "when the double quote command is called", ->
        it "does nothing", ->
          editor.setSelectedBufferRange([[11,0], [11,19]])
          stringCheck('double', editor)
          expect(editor.lineForBufferRow(11)).toBe \
            "'''This is''' \"\"\"Test8\"\"\""
