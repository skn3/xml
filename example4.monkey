Strict

Import xml
Import mojo

Function Main:Int()
	'load xml
	Local error:= New XMLError
	Local xml:= ParseXML(LoadString("example4.xml"), error)
	If xml = Null Error("doh failed!")
	If error.error Error(error)
	
	Return 0
End