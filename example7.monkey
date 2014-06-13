#TEXT_FILES="*.xml"

Import mojo
'Import monkey
Import xml

Function Main()
	Local error:XMLError = New XMLError
	Local doc:XMLDoc = ParseXML(LoadString("data.xml"), error, XML_STRIP_WHITESPACE)
	Local node:XMLNode = Null

	If error.error = False
		Print "without text nodes:"
		OutputNode(doc, 0, False)
		Print ""
		Print ""
		Print "with text nodes:"
		OutputNode(doc, 0, True)
	Else
		Print "error: " + error.ToString()
	EndIf
	
	Print "finished!"
End

Function OutputNode(node:XMLNode, depth:Int = 0, text:Bool = False)
	Local build:String
	For Local index:= 0 Until depth
		build += "-"
	Next
	
	If node.text
		build += " (text) " + node.value
	Else
		build += " (node) " + node.name + " (value=" + node.value+")"
	EndIf
	
	Print build
	
	If text or node.text = False
		Local pointer:= node.GetChild(text)
		While pointer.valid
			If text or pointer.text = False
				OutputNode(pointer, depth + 1, text)
			EndIf
			pointer = pointer.GetNextSibling()
		Wend
	EndIf
End