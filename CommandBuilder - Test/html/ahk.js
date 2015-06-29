    'use strict';

    goog.provide('Blockly.Blocks.automation');


    //--------------------------------------------------------
    // https://blockly-demo.appspot.com/static/demos/blockfactory/index.html#4kvqb5
    Blockly.Blocks['automation_type_text'] = {
      init: function() {
        this.setHelpUrl('http://www.example.com/');
        this.setColour(225);
        this.appendDummyInput()
            .appendField("Type Text")
            .appendField(new Blockly.FieldTextInput("Hello"), "TEXT");
        this.setPreviousStatement(true);
        this.setNextStatement(true);
        this.setTooltip('Type some text here');
      }
    };

    // https://blockly-demo.appspot.com/static/demos/blockfactory/index.html#bghyo9
    Blockly.Blocks['automation_press_keys'] = {
      init: function() {
        this.setHelpUrl('http://www.example.com/');
        this.setColour(195);
        this.appendDummyInput()
            .appendField("Press Keys")
            .appendField(new Blockly.FieldTextInput("Enter"), "KEYS");
        this.setInputsInline(true);
        this.setPreviousStatement(true);
        this.setNextStatement(true);
        this.setTooltip('Press a hot key or a combination of keys');
        this.setEditable(false);
        this.data = "{Enter}";
      }
    };

    Blockly.Blocks['automation_click'] = {
      init: function() {
        this.setHelpUrl('http://www.example.com/');
        this.setColour(315);
        this.appendDummyInput()
            .appendField("Mouse Click  x =")
            .appendField(new Blockly.FieldTextInput("15"), "X")
            .appendField(" y =")
            .appendField(new Blockly.FieldTextInput("30"), "Y");
        this.setInputsInline(true);
        this.setPreviousStatement(true);
        this.setNextStatement(true);
        this.setTooltip('Click the left mouse button at the screen coordinates specified');
      }
    };

    // https://blockly-demo.appspot.com/static/demos/blockfactory/index.html#ax645w
    Blockly.Blocks['automation_wait'] = {
      init: function() {
        this.setHelpUrl('http://www.example.com/');
        this.setColour(165);
        this.appendDummyInput()
            .appendField("Wait")
            .appendField(new Blockly.FieldTextInput(".5"), "SECONDS")
            .appendField("seconds");
        this.setInputsInline(true);
        this.setPreviousStatement(true);
        this.setNextStatement(true);
        this.setTooltip('Insert some wait time to give the program a chance to respond to your input.\n Can be a fraction of a second');
      }
    };