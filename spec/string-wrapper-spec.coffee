{WorkspaceView} = require 'atom'
StringWrapper = require '../lib/string-wrapper'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "StringWrapper", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('string-wrapper')

  describe "when the string-wrapper:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.string-wrapper')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'string-wrapper:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.string-wrapper')).toExist()
        atom.workspaceView.trigger 'string-wrapper:toggle'
        expect(atom.workspaceView.find('.string-wrapper')).not.toExist()
