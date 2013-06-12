Strict

Import xml
Import mojo

Function Main:Int()
	'load xml
	Local error:XMLError
	Local xml:= ParseXML(LoadString("atlas.xml"), error)
	If xml = Null Error("doh!")
	
	'parse xml
	Local sheet:= xml.GetChild("sheets").GetChild("sheet")
	Local item:XMLNode
	
	'iterate sheets
	While sheet.valid
	    'iterate over sheets items
	    item = sheet.GetChild("items").GetChild("item")
	    While item.valid
	        Print item.GetAttribute("name")
	
	        'next item
	        item = item.GetNextSibling("item")
	    Wend
	    
	    'next sheet
	    sheet = sheet.GetNextSibling("sheet")
	Wend
	
	Return 0
End