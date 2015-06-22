
'use strict';

goog.provide('Blockly.ahk');
goog.require('Blockly.Generator');

// TODO is this necessary?
Blockly.ahk = new Blockly.Generator("ahk");


// Grrr... blocky documentation does not say you must have 
// this function, but you do
//------------------------------------------------------------
Blockly.ahk.init = function() {
}

// Ditto
//------------------------------------------------------------
Blockly.ahk.finish = function(code) {
  return code;
}

//------------------------------------------------------------
Blockly.ahk['automation_press_keys'] = function(block) {

//  var keys = block.getFieldValue('KEYS');
  var ahk = block.data;

 // keys = keys.replace(/Ctrl\+/, '^');
 // keys = keys.replace(/Alt\+/, '!');
 // keys = keys.replace(/Shift\+/, '+');
  return "Send, " + ahk + "\n";
}


//------------------------------------------------------------
Blockly.ahk['automation_type_text'] = function(block) {
  var text = block.getFieldValue('TEXT');
  // TODO: sanitize in other instances as well to avoid security hazard of XSS.
  text = removeTags(text); 

  var code = "Send, " + text + "\n";
  return code;
};

// TODO: only allow numbers
//------------------------------------------------------------
Blockly.ahk['automation_click'] = function(block) {
  var x = Number(block.getFieldValue('X'));
  var y = Number(block.getFieldValue('Y'));

  var code = "Click, " + x + ", " + y + "\n";
  return code;
};

// TODO: only allow numbers
//------------------------------------------------------------
Blockly.ahk['automation_wait'] = function(block) {
  var seconds = Number(block.getFieldValue('SECONDS'));

  var code = "Sleep, " + (seconds * 1000) + "\n";
  return code;
};

//---------------------------------------------------------------------
// TODO there must be a standard function for that, I have it written 
// down in http://theBrain.com
function removeTags(html) {
  html = html.replace(/\</g, '&lt;');
  html = html.replace(/\>/g, '&gt;');
  return html;
}

/**
 * Common tasks for generating JavaScript from blocks.
 * Handles comments for the specified block and any connected value blocks.
 * Calls any statements following this block.
 * @param {!Blockly.Block} block The current block.
 * @param {string} code The JavaScript code created for this block.
 * @return {string} JavaScript code with comments and subsequent blocks added.
 * @this {Blockly.CodeGenerator}
 * @private
 * TODO - I copied & pasted this function from Javascript generator source code,
 * changing a few bits. Make sure it makes sense.
 */
//------------------------------------------------------------
Blockly.ahk.scrub_ = function(block, code) {
  if (code === null) {
    // Block has handled code generation itself.
    return '';
  }
  var commentCode = '';
  // Only collect comments for blocks that aren't inline.
  if (!block.outputConnection || !block.outputConnection.targetConnection) {
    // Collect comment for this block.
    var comment = block.getCommentText();
    if (comment) {
      commentCode += this.prefixLines(comment, '; ') + '\n';
    }
    // Collect comments for all value arguments.
    // Don't collect comments for nested statements.
    for (var x = 0; x < block.inputList.length; x++) {
      if (block.inputList[x].type == Blockly.INPUT_VALUE) {
        var childBlock = block.inputList[x].connection.targetBlock();
        if (childBlock) {
          var comment = this.allNestedComments(childBlock);
          if (comment) {
            commentCode += this.prefixLines(comment, '; ');
          }
        }
      }
    }
  }
  var nextBlock = block.nextConnection && block.nextConnection.targetBlock();
  var nextCode = this.blockToCode(nextBlock);
  return commentCode + code + nextCode;
};

/*
// TODO, hook this up
var dictionary = { 
  ["PageUp", "PgUp"],
  ["PageDown", "PgDn"]
};
*/