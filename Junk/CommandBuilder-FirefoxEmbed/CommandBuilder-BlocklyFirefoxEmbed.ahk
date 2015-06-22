#INCLUDE com.ahk 
width=350
height=250
DWFFILE = \\Server\path\DWFs\TA-A015-Toilet-Paper Dispenser-Semi-Recessed.dwf
SplitPath, DWFFILE, name

Gosub, WriteHTM
url = %HTMLFile%

Gui, +LastFound +Resize ;-VScroll -HScroll
Gui, Show, w%width% h%height% Center, %name%

  
COM_Init()
COM_AtlAxWinInit()
pwb:= COM_AtlAxGetControl(COM_AtlAxCreateContainer(WinExist(),top,left,width,height, "Shell.Explorer") )
   if pwb
   {
      COM_Invoke(pwb, "Navigate",url) ; url,dest,TargetFrameName) ;replace this(url,dest,TargetFrameName) with some valid information or omit all but the url
      Loop
      {
         Sleep,500 ; short pause between cycles
             ReadyState:=COM_Invoke(pwb, "ReadyState") == "4"         
 if ReadyState
            break
         else
            continue       
      }
}
Return
GuiClose:
	Gui, Destroy	
      COM_AtlAxWinTerm()
      ExitApp
WriteHTM:
HTMLFile = %A_Temp%\RFA_Explorer_DWF.htm
HTML=
(	  
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>	   
  <head>		     
    <title>%name%     
    </title>	     
  </head>	   
  <body>                                            
    <object classid="clsid:665D847D-4345-4EE6-ABC1-5D4C5382A498" style="width: 300px; height: 200px">      
      <param name="src" value="\%DWFFILE%"/>      
      <param name="TopColor" value="#F2F4F8"/>      
      <param name="BottomColor" value="#CDCED2"/>      
      <param name="AmbientColor" value="#333333"/>      
      <param name="ModelIndex" value="0"/>      
      <param name="RenderMode" value="1"/>      
      <param name="SoftwareRendering" value="1"/>      
      <param name="LODMode" value="0"/>      
      <embed type="application/x-seek3d-plugin" width=200 height=100 src="http://seek.autodesk.com/content/extracted/9084/BDC7/C1D3/1033/B6CA/E604/F599/B684/3925/98B0/3d-C1D31033B6CAE604F599B684392598B0-A4F64632265E3EF5EC4628A9248851F9-3DView-View1.dwf?_viewerProps=VG9wQ29sb3I9I0YyRjRGOCZCb3R0b21Db2xvcj0jQ0RDRUQyJkFtYmllbnRDb2xvcj0jMzMzMzMzJk1vZGVsSW5kZXg9MCZSZW5kZXJNb2RlPTEmU29mdHdhcmVSZW5kZXJpbmc9MSZMT0RNb2RlPTAmQ2FtZXJhPTEuNDI3NTc4LCA2LjAwMDAwMCwgMC45NDI2NzMsIDAuMDAwMDAwLCA2LjAwMDAwMCwgLTAuMjU1MjA4LCAwLjAwMDAwMCwgMS4wMDAwMDAsIDAuMDAwMDAwLCAwLjc0NTQyOSwgMC43NDU0MjksIHBlcnNwZWN0aXZl" />    
    </object>           
  </body>
)
FileDelete %HTMLFile%
FileAppend, %HTML%, %HTMLFile%

Return