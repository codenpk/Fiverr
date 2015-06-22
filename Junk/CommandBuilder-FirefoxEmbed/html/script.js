var ctr = document.getElementById("ahk");
// on IE, keyCode different for RU and EN; keyIdentifier, too

//----------------------------------------------------------
document.body.onkeydown = function(event) {

if (typeof String.prototype.startsWith != 'function') {
String.prototype.startsWith = function (str){
return this.indexOf(str) === 0;       
}
}

var pretty = ""; // User-friendly key mnemonics, e.g. "Ctrl+Alt+F2"
var ahk = "";    // Autohotkey format for the key, e.g. "^!{F2}"

if (event.ctrlKey)
{
pretty += "Ctrl+"
ahk += "^";
}

if (event.altKey)
{
pretty += "Alt+";
ahk += "!";
}

if (event.shiftKey)
{
pretty += "Shift+";
ahk += "+";
}

var mainKey = "";

// Make sure this is not just some combination Ctrl, Alt, and Shift with no other keys
// In retrospect, I should have used a library for this, instead of reinventing the wheel.
// I only need this to work in Chrome (because I sometimes use it for debugging) and IE
// (if we decide to only use IE in Production). Will worry about Mac and Windows 10 later.

// TODO refactor the ugly if-elses into a separate function
if (event.keyCode != 16 && event.keyCode != 17 && event.keyCode != 18)
{
/*   keyIdentifier exists in Chrome but not in IE */
if (event.keyIdentifier)
{
if (event.keyIdentifier.startsWith("U+"))
mainKey += String.fromCharCode(event.keyCode);
else
mainKey += event.keyIdentifier;  
} 

else
{
// TODO: this does not work well if a user has international keyboard.
// Try event.which or event.keyCode
mainKey += event.key;
}

console.log("down");
console.log(event);
}
pretty += mainKey;
ahk += "{" + mainKey + "}";

ctrl.innerHTML = pretty;

// The currently highlighted block, if any
var block = Blockly.selected;

if (block && block.getFieldValue('KEYS'))
{
block.setFieldValue(pretty, 'KEYS');
block.data = ahk; 
// If this is a block that accepts hot keys, no further processing of 
// the hot key is needed
// TODO: this "if" should be way up, to save unnecessary processing
// TODO refactor this whole thing and remove it from the HTML file
return false;
}

// We did not process this key. Let's see if someone else will.
return true;
} 

//----------------------------------------------------------
var workspace = inject();
//----------------------------------------------------------

//-----------------------------------------------------------
function myUpdateFunction() {
// var code = Blockly.awt.workspaceToCode(workspace);
// document.getElementById('textarea').value = code;
showAhk();
}
workspace.addChangeListener(myUpdateFunction);

var isButtonPressed = false;

// TODO all of this needs refactoring
//-------------------------------------------------------------
function savePressed() {
isButtonPressed = true;
save();
}

//-------------------------------------------------------------
function cancelPressed() {
isButtonPressed = true;
cancel();
}