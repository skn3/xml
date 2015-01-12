Strict

Import os
Import xml
Import reflection

Function Main:Int()
	Local data:= "<?xml version=~q1.0~q encoding=~qutf-8~q?><Doc aName=~qBuild~q someValue=~q4.0~q xmlns=~qhttp://schemas.microsoft.com/developer/msbuild/2003~q><group><SUBITEM>hello world</SUBITEM></group></doc>"
	Local doc:= ParseXML(data)
	Print doc.Export(0)
	Return 0
End