    'use strict';
    var pretty;


    //--------------------------------------------------------
    function save() {
      document.getElementById("save").innerHTML = "Save pressed";
     }

    //--------------------------------------------------------
    function cancel() {
     document.getElementById("save").innerHTML = "Cancel pressed";
    }


    //--------------------------------------------------------
    function load() {
      document.getElementById("test").innerHTML = "Load pressed";
      var xml = Blockly.Xml.textToDom(pretty);
      Blockly.Xml.domToWorkspace(workspace, xml);
    }



   //---------------------------------------------------------
     function inject ()
    {
      var workspace = Blockly.inject('blocklyDiv', { 
        toolbox: document.getElementById('toolbox'),
        comments: true
      });
      return workspace;
    }

    //--------------------------------------------------------
    function showAhk() {
      // Generate JavaScript code and display it.
  //    console.log(Blockly.ahk);
      Blockly.ahk.INFINITE_LOOP_TRAP = null;
      var code = Blockly.ahk.workspaceToCode(workspace);
      
      document.getElementById("ahk").innerHTML = code;

    }

 