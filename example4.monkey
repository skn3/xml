Strict

Import xml
Import mojo

Function Main:Int()
	'load xml
	Local error:= New XMLError
	Local data:String = LoadString("example4.xml")
	Print data
	Local xml:= ParseXML(data, error)
	If xml = Null Error("doh failed!")
	If error.error Error(error)
	
	Return 0
End