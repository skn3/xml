Import mojo
Import xml

'--- test program---
Class TestApp Extends App
	Method OnCreate:Int()
		Local error:= New XMLError
		
		'create a doc
		Local doc:= New XMLDoc("root_element", "1.0", "utf8")
		
		'create a group
		Local group:= doc.AddChild("group")
		
		'add some items
		For Local index:= 1 To 10
			group.AddChild("item", "id=item_" + index)
		Next
		
		'print then resulting XML
		Print doc.Export(XML_STRIP_CLOSING_TAGS)
		
		'quit the app
		Error ""
		Return True
	End
End

Function Main:Int()
	New TestApp
	Return True
End