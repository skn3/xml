#TEXT_FILES="*.xml"

Import mojo
'Import monkey
Import xml

Function Main()
	Local XmlError:XMLError = New XMLError
	Local RootXmlNode:XMLDoc = ParseXML(LoadString("example5.xml"), XmlError)
	Local XmlNode:XMLNode     = Null

	If XmlError.error = False
		Local NodeList:List<XMLNode> = RootXmlNode.GetChildren()
		For XmlNode = Eachin NodeList
			Print "node:" + XmlNode.name
		Next
	Else
		Print "error: "+XmlError.ToString()
	EndIf
	
	Print "finished!"
End
