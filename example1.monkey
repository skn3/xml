Import mojo
Import skn3.xml

'--- test program---
Class TestApp Extends App
	Method OnCreate:Int()
		Local error:= New XMLError
		Local ms:Int = Millisecs()
		Local doc:= ParseXML(LoadString("test2.xml"), error)
		Print "took " + (Millisecs() -ms)
		
		If doc = Null and error.error
			'error
			Print error.ToString()
		Else
			'success
			'get all books
			Print "[get title of all books]"
			Local nodes:= doc.GetDescendants("title")
			For Local node:= EachIn nodes
				Print node.value
			Next
			Print ""
			
			'get all fantasy books
			Print "[get all fantasy books]"
			nodes = doc.GetDescendants("genre", "@value=Fantasy")
			For Local node:= EachIn nodes
				Print node.GetParent().GetChild("title").value
			Next
			Print ""
			
			'get null book
			Print "[get null attribute from null node]"
			Print doc.GetChild("this_doesnt_exist").GetAttribute("some_value", "default_value")
			Print ""
			
			'print node paths for all books by Corets, Eva
			Print "[get paths to all books by Corets, Eva]"
			nodes = doc.GetDescendants("author", "@value=Corets, Eva")
			For Local node:= EachIn nodes
				Print node.GetParent().GetChild("title").value + " at '" + node.GetParent().path + "'"
			Next
			Print ""
			
			'get node at path
			Print "[get description of first book at path book/description]"
			Print doc.GetChildAtPath("book/description").value
			Print ""
			
			'get node at path with attributes
			Print "[get title of first book at path book/genre where genre value is Fantasy]"
			Print doc.GetChildAtPath("book/genre", "@value=Fantasy").GetParent().GetChild("title").value
			Print ""
		EndIf
		
		'quit the app
		Error ""
		Return True
	End
End

Function Main:Int()
	New TestApp
	Return True
End