Strict

Import xml
Import mojo

Function Main:Int()
	'load xml
	Local error:XMLError
	Local xml:= ParseXML(LoadString("example4.xml"), error)
	If xml = Null Error(error)
	
	Return 0
End