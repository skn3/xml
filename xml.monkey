#rem
	MIT License.
	http://opensource.org/licenses/MIT
	
	Copyright (c) 2013 SKN3
	
	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
	documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
	the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
	and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in all copies or substantial portions 
	of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
	TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
	THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
	CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
	DEALINGS IN THE SOFTWARE.
#end

'XML for monkey - Written by skn3 (Jon Pittock)
'A single file xml lib for monkey that supports comments,cdata,self-closing tags,relaxed line breaks,unquoted attributes,attributes without assignment,single + double quotes,
'whitespace trimming.
'The only string manipulation performed is for tag value data (anything outside of a tag) that gets chopped off by a child tag. All other string manipulation is buffered in an
'int array so you will not have a ton of newly created temporary strings. Most text parsing has been designed to compare asc integer values instead of strings.
'Each node will have its document line,column and offset values added to it for each debugging. Error messages will also report correct document details.
'The lib was written from scratch with no reference.

'version 38
' - fixed bug in parsing attributes without quotes, preceeding > caused xml error
'version 37
' - added node.MergeAttributes(node) to let us merge attributes from anotehr node
' - added node.GetAttributes() to fetch all attributes in a stringmap
'version 36
' - AddChild(node) now has second param (defaults to true) to handle recursing into child nodes
'version 35
' - added .AddChild(node) method to allow copying a node object into a parent. 
'version 34
' - reworked internal node code so node.Free() will fully remove self from parent
' - added Remove() so a node can be removed but not freed!
'version 33
' - recent changes had broken self contained tags on export
'version 32
' - improved performance by storing list node pointers when adding/removing xml nodes
' - made it so node.value and node.value = works for text type nodes. Will rebuild parent text value if needed
' - fixed ClearText as it was not properly updating the node pointers so text remained
'version 31
' - casing now remains in provided format for node attributes
'version 30
' - fixed long standing (but apparently no one caught??) errors with setting/getting value of xml node
'version 29
' - xml nodes now keep their original casing, this has changed the behaviour of node.name, it will return the unmodified name
'version 28
' - small tweak so that if a node has no children but a value e.g. <value>SomeText</value> it will be formatted onto a single line.
'version 27
' - small mem ref error when removing path list node
'version 26
' - fixed typo in missing variable
'version 25
' - added so newlines in XML will be included in xml text/values
' - added so XML_STRIP_NEWLINE can now be used in ParseXML to strip any newlines within text/value
'version 24
' - fixed doctype bug (thanks difference, sorry the delay ;)
' - removed left in print satement (thanks difference, sorry the delay ;)
' - added support for text/whitespace characters (the value of a node) to be split into child nodes. This should be transparently working and you can still use node.value
' - added node.text bool to indicate if the node is a text node
' - added text boolean flag to many of the methods. This allows text nodes to be scanned/returned. The text boolean defaults to false, which will ignore text nodes. For example GetChild(true) would return the first child node, GetChild(false) would find the first NON-text node.
' - added AddText() method this will either add a child node or append to teh nodes value (depending on the parse mode used)
' - added example7.monkey demonstrating text nodes
'version 23
' - added tweak/fix to parser to ignore doctype tag (later on can add support) (cheers copper circle)
' - added tweak/fix to parser to allow : in tag/attribute names (later can add support for contexts) (cheers copper circle)
'version 22
' - fixed self closing tags where no space is provided e.g. <tag/> - thanks AdamRedwoods and ComputerCoder
' - moved into jungle solution
' - added test example 5 for testing self closing tags without space
'version 21
' - added value param to AddChild() method to quicker to create children
'version 20
' - renamed internal function HasStringAtOffset to XMLHasStringAtOffset (monkey was showing conflict when same function name used elsewhere even though its private in xml?)
' - fixed typo (thanks computercoder)
'version 19
' - added GetChildren() override to get ALL children (thanks computercoder)
' - added fixes to Export method, thanks computercoder
' - added GetDescendants) override to get all
' - added result param to all GetChildren/GetDescendants methods. This lets you pass in the list that results will be populated in
'version 18
' - added GetAttributeOrAttribute() to XMLNode. This allows you to get attribute by id. If that attribute doesnt exist it looks for second id. If neither exist, default value is returned.
' - fixed null node returns in Get Previous/Next sibling methods
'version 17
' - added simple test for no xml data passed in
'version 16
' - added a new example3 to demonstrate how you would load xml generated by the MakeAtlas tool
'version 15
' - added tweak to stringbuffer size to improve performance/crashes on larger documents, thanks AdamRedwoods
' - made node freeing more effecient by keeping track of list node
'version 14
' - fixed crash bug in creating node with attributes query string, thanks Rushino
' - added XML_STRIP_NEWLINE export flag which will add line feeds to exported data
' - added XML_STRIP_CLOSING_TAGS export flag so that xml nodes with no children would get exported as <tag /> instead of <tag></tag>
'version 13
' - fixed small bug where calling GetChild() on manually created doc was causing null reference. Thanks Difference.
'version 12
' - added CountChildren() to the node class. Allows for counting with tag and also attribute matching
'version 11
' - added support for '-' character in tags and attributes (thanks midimaster)
'version 10
' - renamed the attribute query and stringbuffer classes
'version 9
' - added HasChildren() method to node
'version 8
' - fixed bool to string bug in SetAttribute
' - fixed GetNextSibling and GetPreviousSibling to return nullnode instead of null (make sure to check return object for valid instead of null .. eg while node.valid instead of while node)
'version 7
' - added GetChild() (with no name or attributes) this will allow to get first child of a node
' - added SetAttribute() and GetAttribute() overloads for bool,int,float, string and no value so don't have to do value conversion in user code!
'version 6
' - fix by David (DGuy) to fix unreocgnised tag end when case was different. Also added licenses.
'version 5
' - added GetNextSibling() and GetPreviousSibling() for searching for siblings adjacent that match tag-name and/or attributes.
'version 4
' - changed readonly to valid to make more sense. Can now check for valid nodes like so If doc.GetChild("").valid
'version 3
' - speed improvement repalced string.Find with XMLHasStringAtOffset() for searching for tag starts
'version 2
' - changed Find___ functions to Get___
' - added GetDescendants() for getting all descendants of node
' - add path lookup ability see GetChildAtPath() and GetChildrenAtPath()
' - added default null return nodes so function chaining wont crash app
' - made it so node can be valid, used for the default null node
' - added GetParent() for safe traversal of teh node strucutre
' - added special @value into query string to look for a nodes value
'version 1
' - first release
Strict

Import monkey.list
Import monkey.map

Const XML_STRIP_WHITESPACE:= 1'this will remove whitespace characters from NON attribute data
Const XML_STRIP_NEWLINE:= 2'this will remove new line characters from NON attribute data
Const XML_STRIP_CLOSING_TAGS:= 4'this will remove closing tags when node has no children

Private
Const XML_FORMAT_OPEN:= "<?xml"
Const XML_FORMAT_CLOSE:= "?>"
Const COMMENT_OPEN:= "<!--"
Const COMMENT_CLOSE:= "-->"
Const CDATA_OPEN:= "<![CDATA["
Const CDATA_CLOSE:= "]]>"
Const DOCTYPE_OPEN:= "<!DOCTYPE"
Const DOCTYPE_CLOSE:= ">"

Class XMLStringBuffer
	Field data:int[]
	Field chunk:Int = 128
	Field count:Int
	Field dirty:Int = False
	Field cache:String
	
	'constructor/destructor
	Method New(chunk:Int = 128)
		Self.chunk = chunk
	End
	
	'properties
	Method value:String() Property
		' --- get the property ---
		'rebuild cache
		If dirty
			dirty = False
			If count = 0
				cache = ""
			Else
				cache = String.FromChars(data[0 .. count])
			EndIf
		EndIf
		
		'return cache
		Return cache
	End
	
	'api
	Method Add:Void(asc:Int)
		' --- add single asc to buffer ---
		'resize
		If count = data.Length data = data.Resize(data.Length + chunk)
		
		'fill data
		data[count] = asc
		
		'move pointer
		count += 1
		
		'flag dirty
		dirty = True
	End
	
	Method Add:Void(text:String)
		' --- add text to buffer ---
		If text.Length = 0 Return
		
		'resize
		If count + text.Length >= data.Length data = data.Resize(data.Length + (chunk * Ceil(Float(text.Length) / chunk)))
		
		'fill data
		For Local textIndex:= 0 Until text.Length
			data[count] = text[textIndex]
			
			'move pointer
			count += 1
		Next
		
		'flag dirty
		dirty = True
	End
	
	Method Add:Void(text:String, offset:Int, suggestedLength:Int = 0)
		' --- add text clipping to buffer ---
		'figure out real length of the import
		Local realLength:= text.Length - offset
		If suggestedLength > 0 And suggestedLength < realLength realLength = suggestedLength
		
		'skip
		If realLength = 0 Return
		
		'resize
		If count + realLength >= data.Length data = data.Resize(data.Length + (chunk * Ceil(Float(realLength) / chunk)))
		
		'fill data
		For Local textIndex:= offset Until offset + realLength
			data[count] = text[textIndex]
			
			'move pointer
			count += 1
		Next
		
		'flag dirty
		dirty = True
	End
	
	Method Clear:Void()
		' --- clear the buffer ---
		count = 0
		cache = ""
		dirty = False
	End
	
	Method Shrink:Void()
		' --- shrink the data ---
		Local newSize:Int
		
		'get new size
		If count = 0
			newSize = chunk
		Else
			newSize = Ceil(float(count) / chunk)
		EndIf
		
		'only bother resizing if its changed
		If newSize <> data.Length data = data.Resize(newSize)
	End
	
	Method Trim:Bool()
		' --- this will trim whitespace from the start and end ---

		'skip
		If count = 0 Return False
		
		'quick trim
		If (count = 1 and (data[0] = 32 or data[0] = 9 or data[0] = 10)) or (count = 2 And (data[0] = 32 or data[0] = 9 or data[0] = 10) And (data[1] = 32 or data[1] = 9 or data[1] = 10))
			Clear()
			Return True
		EndIf
		
		'full trim
		'get start trim
		Local startIndex:Int
		For startIndex = 0 Until count
			If data[startIndex] <> 32 And data[startIndex] <> 9 And data[startIndex] <> 10 Exit
		Next
		
		'check if there was only whitespace
		If startIndex = count
			Clear()
			Return True
		EndIf
		
		'get end trim
		Local endIndex:Int
		For endIndex = count - 1 To 0 Step - 1
			If data[endIndex] <> 32 And data[endIndex] <> 9 and data[endIndex] <> 10 Exit
		Next

		'check for no trim
		If startIndex = 0 And endIndex = count - 1 Return False
		
		'we have to trim so set new length (count)
		count = endIndex - startIndex + 1
		
		'do we need to shift data left?
		If startIndex > 0
			For Local trimIndex:= 0 Until count
				data[trimIndex] = data[trimIndex + startIndex]
			Next
		EndIf
		
		'return that we trimmed
		Return True
	End
	
	Method Length:Int() Property
		' --- return length ---
		Return count
	End
	
	Method Last:Int(defaultValue:Int = -1)
		' --- return the last asc ---
		'skip
		If count = 0 Return defaultValue
		
		'return
		Return data[count - 1]
	End
End

Class XMLAttributeQuery
	Field chunk:Int = 32
	Field items:XMLAttributeQueryItem[]
	Field count:Int
	
	'constructor/destructor
	Method New(query:String)
		' --- this will create a new query object ---
		'query is in the format of 'title1=value1&title2=value2'
		'the = and & character can be escaped with a \ character
		'a value pair can also be shortcut like 'value1&value2&value3'
		Local queryIndex:Int
		Local queryAsc:Int
		
		Local buffer:= New XMLStringBuffer(256)
		
		Local isEscaped:= False
		
		Local processBuffer:= False
		Local processItem:= False
		
		Local hasId:= False
		Local hasValue:= False
		Local hasEquals:= False
		Local hasSepcial:= False
		
		Local itemId:String
		Local itemValue:String
		
		For queryIndex = 0 Until query.Length
			'looking for title
			queryAsc = query[queryIndex]
			
			If isEscaped
				'escaped character
				isEscaped = False
				buffer.Add(queryAsc)
			Else
				'test character
				Select queryAsc
					Case 38'&
						processBuffer = True
						processItem = True
						
					Case 61'=
						processBuffer = True
						hasEquals = True
						
					Case 64'@
						If hasId = False
							'switch on special value
							If buffer.Length = 0 hasSepcial = True
						Else
							'value so just add it
							buffer.Add(queryAsc)
						EndIf
						
					Case 92'\
						isEscaped = True
						
					Default
						'skip character if we are building id and there is not valid alphanumeric
						If hasId or (queryAsc = 45 or queryAsc = 95 or (queryAsc >= 48 and queryAsc <= 57) or (queryAsc >= 65 and queryAsc <= 90) or (queryAsc >= 97 and queryAsc <= 122)) buffer.Add(queryAsc)
				End
			EndIf
			
			'check for end condition
			If queryIndex = query.Length - 1
				processBuffer = True
				processItem = True
				
				'add escape character if it was left over
				If isEscaped And hasId buffer.Add(92)
				
				'check for blank =
				If hasEquals And buffer.Length = 0 hasValue = True
			EndIf
			
			'process the buffer
			If processBuffer
				'unflag process
				processBuffer = False
				
				'check condition
				If hasId = False
					itemId = buffer.value
					buffer.Clear()
					hasId = itemId.Length > 0
				Else
					itemValue = buffer.value
					buffer.Clear()
					hasValue = True
				EndIf
			EndIf
			
			'process the item
			If processItem
				'unflag process
				processItem = False
				
				'check condition
				If hasId
					'insert new value
					'resize
					If count = items.Length items = items.Resize(items.Length + chunk)
					
					'create new item
					items[count] = New XMLAttributeQueryItem(itemId, itemValue, hasValue, hasSepcial)
					
					'increase count
					count += 1
					
					'reset
					itemId = ""
					itemValue = ""
					hasId = False
					hasValue = False
					hasSepcial = False
				EndIf
			EndIf
		Next
	End
	
	'api
	Method Test:Bool(node:XMLNode)
		' --- this will test the given node against the query ---
		Local attribute:XMLAttribute
		
		For Local index:= 0 Until count
			If items[index].special = False
				'attribute comparison
				'get attribute
				attribute = node.GetXMLAttribute(items[index].id)
				
				'check conditions for fail
				If attribute = Null or (items[index].required And attribute.value <> items[index].value) Return False
			Else
				'special query
				Select items[index].id
					Case "value"
						'check conditions for fail
						If (items[index].required And node.fullValue <> items[index].value) Return False
				End
			EndIf
		Next
		
		'success
		Return True
	End
	
	Method Length:Int()
		Return count
	End
End

Class XMLAttributeQueryItem
	Field id:String
	Field value:String
	Field required:Bool
	Field special:Bool
	
	'constructor/destructor
	Method New(id:String, value:String, required:Bool, special:Bool)
		Self.id = id
		Self.value = value
		Self.required = required
		Self.special = special
	End
End

Function XMLHasStringAtOffset:Bool(needle:String, haystack:String, offset:Int)
	' --- quick function for testing a string at given offset ---
	'skip
	If offset + needle.Length > haystack.Length Return False
	
	'scan characters
	For Local index:= 0 Until needle.Length
		If needle[index] <> haystack[offset + index] Return False
	Next
	
	'return success
	Return True
End

Function XMLFindNextAsc:Int(data:String, asc:Int, offset:Int = 0)
	' --- find next asc ---
	Local length:= data.Length
	
	'skip
	If offset >= length Return - 1
	
	'fix negative
	If offset < 0 offset = 0
	
	'scan
	For offset = offset Until length
		If data[offset] = asc Return offset
	Next
	
	'nope
	Return -1
End

Function XMLFindStringNotInQuotes:Int(needle:String, haystack:String, offset:Int)
	' --- find character not in quotes ---
	'get first needle
	Local needlePos:Int
	Repeat
		'check needle pos
		needlePos = haystack.Find(needle, offset)
		If needlePos = -1 Return - 1
	
		'get quote pos
		offset = XMLFindNextAsc(haystack, 34, offset)
	
		'is the needle before quote
		If needlePos < offset or offset = -1 Return needlePos
		
		'this is a quote so find end of quote
		offset = XMLFindNextAsc(haystack, 34, offset + 1)
		If offset = -1 Return - 1
		offset += 1
	Forever
	
	'nope
	Return -1
End
Public

Class XMLDoc Extends XMLNode
	Field nullNode:XMLNode
	Field version:String
	Field encoding:String
	Field paths:= New StringMap<List<XMLNode>>
	
	'constructor/destructor
	Method New(name:String, version:String = "", encoding:String = "")
		' --- create node with name ---
		valid = True
		
		'link doc to self so we can reference it in base class xmlnode
		doc = Self
		
		'create null node
		nullNode = New XMLNode("", False)
		nullNode.doc = Self
		
		'fix casing
		Self.nameNormalCase = name
		Self.nameLowerCase = name.ToLower()
		Self.version = version
		Self.encoding = encoding
		
		'setup path
		path = name
		pathList = New List<XMLNode>
		pathListNode = pathList.AddLast(Self)
		paths.Insert(path, pathList)
	End
	
	'api
	Method Export:String(options:Int = XML_STRIP_WHITESPACE | XML_STRIP_NEWLINE | XML_STRIP_CLOSING_TAGS)
		' --- convert the node to a string ---
		'create a buffer
		Local buffer:= New XMLStringBuffer(1024)
		
		'add xml details
		'add open
		buffer.Add(XML_FORMAT_OPEN)
		
		'add version
		If version.Length
			buffer.Add(" version=")
			buffer.Add(34)
			buffer.Add(version)
			buffer.Add(34)
		EndIf
		
		'add encoding
		If encoding.Length
			buffer.Add(" encoding=")
			buffer.Add(34)
			buffer.Add(encoding)
			buffer.Add(34)
		EndIf
		
		'add close
		buffer.Add(XML_FORMAT_CLOSE)
		
		'add new line
		If options & XML_STRIP_NEWLINE = False buffer.Add(10)
		
		'call internal export
		Super.Export(options, buffer, 0)
		
		'return
		Return buffer.value
	End
End

Class XMLNode
	Field text:Bool
	Field valid:Bool
	Private
	Field nameNormalCase:String
	Field nameLowerCase:String
	Field fullValue:String
	Public
	Field path:String
	Field doc:XMLDoc
	Field parent:XMLNode
	Field nextSibling:XMLNode
	Field previousSibling:XMLNode
	Field firstChild:XMLNode
	Field lastChild:XMLNode
	Field line:Int
	Field column:Int
	Field offset:Int
	Field children:= New List<XMLNode>
	Field attributes:= New StringMap<XMLAttribute>
	
	Private
	Field parentListNode:list.Node<XMLNode>
	Field pathList:List<XMLNode>
	Field pathListNode:list.Node<XMLNode>
	Public
	
	'constructor/destructor
	Method New(name:String, valid:Bool = True)
		' --- create node with name ---
		If name.Length
			Self.nameNormalCase = name
			Self.nameLowerCase = name.ToLower()'fix casing
		EndIf
		Self.valid = valid
	End
	
	Method Free:Void()
		' --- used when the node is removed the doc ---
		'remove from paths list
		if pathListNode
			pathListNode.Remove()
			pathListNode = Null
		EndIf
		
		'recurse
		If firstChild
			Local child:= firstChild
			While child
				child.Free()
				child = child.nextSibling
			Wend
		EndIf
		
		'process remove in parent
		Remove()
	End
	
	'internal
	Private
	Method Export:Void(options:Int, buffer:XMLStringBuffer, depth:Int)
		' --- convert the node to a string ---
		'make sure there is a buffer to work with
		If buffer = Null buffer = New XMLStringBuffer(1024)
		
		Local index:Int
		Local hasNonTextNodes:Bool
		
		'text node?
		If text
			'yup text node
			For index = 0 Until fullValue.Length
				buffer.Add(fullValue[index])
			Next
		Else
			'nope normal node
			'add opening tag
			'ident
			If options & XML_STRIP_WHITESPACE = False
				For index = 0 Until depth
					buffer.Add(9)
				Next
			EndIf
			
			buffer.Add(60)
			buffer.Add(nameNormalCase)
			
			'add attributes
			Local attribute:XMLAttribute
			For Local id:= EachIn attributes.Keys()
				attribute = attributes.Get(id)
				buffer.Add(32)
				buffer.Add(attribute.idNormalCase)
				buffer.Add(61)
				buffer.Add(34)
				buffer.Add(attribute.value)
				buffer.Add(34)
			Next
			
			'has children need to do opening tag only
			hasNonTextNodes = HasChildren()
			
			'check for short tag
			If not hasNonTextNodes and fullValue.Length() = 0 And options & XML_STRIP_CLOSING_TAGS
				'no children so short tag
				'finish opening tag
				buffer.Add(32)
				buffer.Add(47)
				buffer.Add(62)
				
				'add new line
				If options & XML_STRIP_NEWLINE = False buffer.Add(10)
	
			Else
				'finish opening tag
				buffer.Add(62)
				
				'add new line
				If options & XML_STRIP_NEWLINE = False and hasNonTextNodes buffer.Add(10)
				
				'add children
				'has mix of nodes/text
				For Local child:= Eachin children
					child.Export(options, buffer, depth + 1)
				Next
				
				'add closing tag
				'ident
				If options & XML_STRIP_WHITESPACE = False and hasNonTextNodes
					For index = 0 Until depth
						buffer.Add(9)
					Next
				Endif
				
				'tag
				buffer.Add(60)
				buffer.Add(47)
				buffer.Add(nameNormalCase)
				buffer.Add(62)
				
				'add new line
				If options & XML_STRIP_NEWLINE = False buffer.Add(10)
			EndIf
		EndIf
	End
	
	Method GetXMLAttribute:XMLAttribute(id:String)
		' --- get attribute object ---
		Return attributes.Get(id.ToLower())
	End
	
	Method GetDescendants:Void(result:List<XMLNode>, name:string, text:Bool)
		' --- internal method for recurse ---
		'scan children
		Local child:= firstChild
		While child
			'test
			If child.nameLowerCase = name And (text or child.text = False) result.AddLast(child)
			
			'recurse
			If child.firstChild And child.text = False child.GetDescendants(result, name, text)
			
			'next child
			child = child.nextSibling
		Wend
	End
	
	Method GetDescendants:Void(result:List<XMLNode>, name:string, query:XMLAttributeQuery, text:Bool)
		' --- internal method for recurse ---
		'scan children
		Local child:= firstChild
		While child
			'test
			If (name.Length = 0 or child.nameLowerCase = name) And (text or child.text = False) And query.Test(child) result.AddLast(child)
			
			'recurse
			If child.firstChild And child.text = False child.GetDescendants(result, name, query, text)
			
			'next child
			child = child.nextSibling
		Wend
	End
	
	Method RebuildValue:Void()
		Local buffer:= New XMLStringBuffer()
			
		'scan text siblings
		Local pointer:= firstChild
		While pointer
			If pointer.text
				buffer.Add(pointer.fullValue)
			EndIf
			pointer = pointer.nextSibling
		Wend
			
		'save value
		fullValue = buffer.value
	End
	
	Method ProcessRemovedChild:Void(child:XMLNode)
		'skip
		If child.parent = Null Return
		
		'update first/last pointers
		If lastChild = child lastChild = child.previousSibling
		If firstChild = child firstChild = child.nextSibling
		
		'update sibling pointers
		If child.previousSibling child.previousSibling.nextSibling = child.nextSibling
		If child.nextSibling child.nextSibling.previousSibling = child.previousSibling
		
		'dettach from doc and parent
		child.previousSibling = Null
		child.nextSibling = Null
		child.parent = Null
		child.doc = Null
		
		'remove from list
		child.parentListNode.Remove()
		child.parentListNode = Null
		
		'do we need to rebuild the value
		If child.text
			RebuildValue()
		EndIf
	End
	Public
	
	'properties
	Method name:String() Property
		Return nameNormalCase
	End
	
	Method name:Void(newName:string) Property
		nameNormalCase = newName
		nameLowerCase = newName.ToLower()
	End
	
	Method value:String() Property
		Return fullValue
	End
	
	Method value:Void(newValue:String) Property
		If text
			fullValue = newValue
			If parent
				parent.RebuildValue()
			EndIf
		Else
			ClearText()
			AddText(newValue)
		EndIf
	End
	
	'child api
	Method HasChildren:Bool(text:Bool = False)
		' --- returns true if has children ---
		If firstChild = Null Return False
		If text Return True
		
		'scan children
		Local child:= firstChild
		While child
			'test
			If child.text = False Return True
			
			'next child
			child = child.nextSibling
		Wend
		
		'nope
		Return False
	End
	
	Method AddChild:XMLNode(name:String, attributes:String = "", value:String = "")
		' --- add a child node ---
		'skip
		If valid = False or text Return Null
		
		'create child
		Local child:= New XMLNode(name)
		child.doc = doc
		child.parent = Self
		child.AddText(value)
		
		'setup path
		child.path = path + "/" + child.nameLowerCase
		child.pathList = doc.paths.Get(child.path)
		If child.pathList = Null
			'create new path list
			child.pathList = New List<XMLNode>
			doc.paths.Set(child.path, child.pathList)
		EndIf
		child.pathListNode = child.pathList.AddLast(child)
		
		'any attributes to add?
		If attributes.Length
			Local query:= New XMLAttributeQuery(attributes)
			If query.Length() > 0
				For Local index:= 0 Until query.Length()
					child.SetAttribute(query.items[index].id, query.items[index].value)
				Next
			EndIf
		EndIf
		
		'setup link nodes
		If lastChild
			'not first child
			'set previously last child to point next to new child
			lastChild.nextSibling = child
			
			'set new child previous to last child
			child.previousSibling = lastChild
			
			'update this last child to the new child
			lastChild = child
		Else
			'first child
			firstChild = child
			lastChild = child
		EndIf
		
		'add to self
		child.parentListNode = children.AddLast(child)
		
		'return it
		Return child
	End

	Method AddChild:XMLNode(node:XMLNode, recurse:Bool = True)
		' --- copy a child node ---
		'skip
		If valid = False or node.valid = False Return Null
		
		'handle text node
		If node.text
			'its text so add text
			Return AddText(node.value)
		EndIf
		
		'create child
		Local child:= New XMLNode(node.name)
		child.doc = doc
		child.parent = Self
		
		'setup path
		child.path = path + "/" + child.nameLowerCase
		child.pathList = doc.paths.Get(child.path)
		If child.pathList = Null
			'create new path list
			child.pathList = New List<XMLNode>
			doc.paths.Set(child.path, child.pathList)
		EndIf
		child.pathListNode = child.pathList.AddLast(child)
		
		'any attributes to add?
		If node.attributes.IsEmpty() = False
			For Local attribute:= EachIn node.attributes.Values()
				child.SetAttribute(attribute.idNormalCase, attribute.value)
			Next
		EndIf
		
		'setup link nodes
		If lastChild
			'not first child
			'set previously last child to point next to new child
			lastChild.nextSibling = child
			
			'set new child previous to last child
			child.previousSibling = lastChild
			
			'update this last child to the new child
			lastChild = child
		Else
			'first child
			firstChild = child
			lastChild = child
		EndIf
		
		'add to self
		child.parentListNode = children.AddLast(child)
		
		'add children
		If recurse And node.firstChild
			Local nodeChild:= node.firstChild
			While nodeChild
				child.AddChild(nodeChild, True)
				nodeChild = nodeChild.nextSibling
			Wend
		Else
			child.AddText(node.value)
		EndIf
		
		'return it
		Return child
	End

	Method AddText:XMLNode(data:String)
		' --- add a text node ---
		'skip
		If valid = False or text Return Null
		
		'always add to the value
		fullValue += data
		
		'create text node
		Local child:= New XMLNode(nameNormalCase)
		child.text = True
		child.doc = doc
		child.parent = Self
		child.fullValue = data
		
		'setup link nodes
		If lastChild
			'not first child
			'set previously last child to point next to new child
			lastChild.nextSibling = child
			
			'set new child previous to last child
			child.previousSibling = lastChild
			
			'update this last child to the new child
			lastChild = child
		Else
			'first child
			firstChild = child
			lastChild = child
		EndIf
		
		'add to self
		child.parentListNode = children.AddLast(child)
		
		Return child
	End
	
	Method Remove:Void()
		If parent parent.ProcessRemovedChild(Self)
	End
	
	Method RemoveChild:Void(child:XMLNode)
		' --- remove child ---
		'skip
		If valid = False or firstChild = Null or child = Null or child.parent <> Self Return
		
		'call child to be freed
		child.Free()
	End
	
	Method ClearChildren:Void(text:Bool = False)
		' --- clears all children ---
		'skip
		If valid = False or firstChild = Null Return
		
		'iterate
		Local child:= firstChild
		Local nextChild:XMLNode
		While child
			'remember next child
			nextChild = child.nextSibling
			
			'call child to be freed
			If text or child.text = False
				child.Free()
			EndIf
			
			'next child
			child = nextChild
		Wend
		
		'reset value
		If text
			fullValue = ""
		EndIf
		
		'reset lists
		children.Clear()
		firstChild = Null
		lastChild = Null
	End
	
	Method ClearText:Void()
		' --- clear text from node ---
		'reset teh value
		fullValue = ""
		
		'clear all text nodes
		Local pointer:= firstChild
		Local nextPointer:XMLNode
		While pointer
			nextPointer = pointer.nextSibling
			If pointer.text
				pointer.Free()
			EndIf
			pointer = nextPointer
		Wend
	End
	
	Method GetNextSibling:XMLNode(name:String = "", text:Bool = False)
		' --- search for next sibling with matching tag name ---
		'skip
		If nextSibling = Null Return doc.nullNode
		
		'quick
		If name.Length = 0 Return nextSibling
		
		'fix casing
		name = name.ToLower()
		
		'scan siblings
		Local pointer:= nextSibling
		While pointer
			If pointer.nameLowerCase = name And (text or pointer.text = False) Return pointer
			pointer = pointer.nextSibling
		Wend
		
		'not found
		Return doc.nullNode
	End
	
	Method GetNextSibling:XMLNode(name:String, attributes:String, text:Bool = False)
		' --- search for next sibling with matching tag name ---
		'skip
		If nextSibling = Null Return doc.nullNode
		
		'quick
		If name.Length = 0 and attributes.Length = 0 Return nextSibling
		
		'fix casing
		name = name.ToLower()
		
		'parse the query
		Local query:= New XMLAttributeQuery(attributes)
		
		'scan siblings
		Local pointer:= nextSibling
		While pointer
			If (name.Length = 0 or pointer.nameLowerCase = name) and query.Test(pointer) Return pointer
			pointer = pointer.nextSibling
		Wend
		
		'not found
		Return doc.nullNode
	End
	
	Method GetPreviousSibling:XMLNode(name:String = "", text:Bool = False)
		' --- search for previous sibling with matching tag name ---
		'skip
		If previousSibling = Null Return doc.nullNode
		
		'quick
		If name.Length = 0 Return previousSibling
		
		'fix casing
		name = name.ToLower()
		
		'scan siblings
		Local pointer:= previousSibling
		While pointer
			If pointer.nameLowerCase = name Return pointer
			pointer = pointer.previousSibling
		Wend
		
		'not found
		Return doc.nullNode
	End
	
	Method GetPreviousSibling:XMLNode(name:String, attributes:String, text:Bool = False)
		' --- search for previous sibling with matching tag name ---
		'skip
		If previousSibling = Null Return doc.nullNode
		
		'quick
		If name.Length = 0 and attributes.Length = 0 Return previousSibling
		
		'fix casing
		name = name.ToLower()
		
		'parse the query
		Local query:= New XMLAttributeQuery(attributes)
		
		'scan siblings
		Local pointer:= previousSibling
		While pointer
			If (name.Length = 0 or pointer.nameLowerCase = name) and query.Test(pointer) Return pointer
			pointer = pointer.previousSibling
		Wend
		
		'not found
		Return doc.nullNode
	End
	
	Method GetChild:XMLNode(text:Bool = False)
		' --- gets the first child ---
		'skip
		If firstChild = Null Return doc.nullNode
		
		'return quickly
		If text or firstChild.text = False
			Return firstChild
		EndIf
		
		'scan children
		Local child:= firstChild
		While child
			'test
			If child.text = False Return child
			
			'next child
			child = child.nextSibling
		Wend
		
		'nope
		Return doc.nullNode
	End
	
	Method GetChild:XMLNode(name:String, text:Bool = False)
		' --- get first child by name ---
		'skip
		If firstChild = Null Return doc.nullNode
		
		'fix casing
		name = name.ToLower()
		
		'scan children
		Local child:= firstChild
		While child
			'test
			If child.nameLowerCase = name And (text or child.text = False) Return child
			
			'next child
			child = child.nextSibling
		Wend
		
		'return null node for chaining
		Return doc.nullNode
	End
	
	Method GetChild:XMLNode(name:String, attributes:String, text:Bool = False)
		' --- get first child by name with matching attributes ---
		'skip
		If firstChild = Null Return doc.nullNode
		
		'fix casing
		name = name.ToLower()
		
		'parse the query
		Local query:= New XMLAttributeQuery(attributes)
		
		'scan children
		Local child:= firstChild
		While child
			'test
			If child.nameLowerCase = name And (text or child.text = False) And query.Test(child) Return child
			
			'next child
			child = child.nextSibling
		Wend
		
		'return null node for chaining
		Return doc.nullNode
	End
	
	Method GetChildren:List<XMLNode>(result:List<XMLNode> = Null, text:Bool = False)
		' --- get all children ---
		If result = Null result = New List<XMLNode>
		
		'skip
		If firstChild = Null Return result
		
		'scan children
		If firstChild <> Null
			Local child:= firstChild
			While child
				'Add child
				If text or child.text = False result.AddLast(child)
				
				'next child
				child = child.nextSibling
			Wend
		Endif
		
		'return the result
		Return result
	End
	
	Method GetChildren:List<XMLNode>(name:String, result:List<XMLNode> = Null, text:Bool = False)
		' --- get children with name ---
		If result = Null result = New List<XMLNode>
		
		'skip
		If firstChild = Null or name.Length = 0 Return result
		
		'fix casing
		name = name.ToLower()
		
		'scan children
		If firstChild <> Null
			Local child:= firstChild
			While child
				'test
				If child.nameLowerCase = name And (text or child.text = False) result.AddLast(child)
				
				'next child
				child = child.nextSibling
			Wend
		EndIf
		
		'return the result
		Return result
	End
		
	Method GetChildren:List<XMLNode>(name:String, attributes:String, result:List<XMLNode> = Null, text:Bool = False)
		' --- get children with name ---
		If result = Null result = New List<XMLNode>
		
		'skip
		If firstChild = Null or (name.Length = 0 And attributes.Length = 0) Return result
		
		'fix casing
		name = name.ToLower()
		
		'parse the query
		Local query:= New XMLAttributeQuery(attributes)
		
		'scan children
		If firstChild <> Null
			Local child:= firstChild
			While child
				'test
				If (name.Length = 0 or child.nameLowerCase = name) And (text or child.text = False) And query.Test(child) result.AddLast(child)
				
				'next child
				child = child.nextSibling
			Wend
		EndIf
		
		'return the result
		Return result
	End

	Method GetDescendants:List<XMLNode>(result:List<XMLNode> = Null, text:Bool = False)
		' --- get all descendants ---		
		If result = Null result = New List<XMLNode>
		
		'skip
		If firstChild = Null Return result
		
		'call internal recursive method
		GetDescendants(result, text)
		
		'return result
		Return result
	End
			
	Method GetDescendants:List<XMLNode>(name:String, result:List<XMLNode> = Null, text:Bool = False)
		' --- get all descendants that match name ---		
		If result = Null result = New List<XMLNode>
		
		'skip
		If firstChild = Null or name.Length = 0 Return result
		
		'fix casing
		name = name.ToLower()
		
		'call internal recursive method
		GetDescendants(result, name, text)
		
		'return result
		Return result
	End
	
	Method GetDescendants:List<XMLNode>(name:String, attributes:String, result:List<XMLNode> = Null, text:Bool = False)
		' --- get all descendants that match name ---		
		If result = Null result = New List<XMLNode>
		
		'skip
		If firstChild = Null or name.Length = 0 Return result
		
		'fix casing
		name = name.ToLower()
		
		'parse the query
		Local query:= New XMLAttributeQuery(attributes)
		
		'call internal recursive method
		GetDescendants(result, name, query, text)
		
		'return result
		Return result
	End
	
	Method GetChildAtPath:XMLNode(path:String)
		' --- get the node at the given path, path is relative to this node ---
		'skip
		If path.Length = 0 Return doc.nullNode
		
		'search for path or return null node if none
		Local pathList:= doc.paths.Get(Self.path + "/" + path)
		If pathList = Null or pathList.IsEmpty() Return doc.nullNode
		
		'return first path in list
		Return pathList.First()
	End
	
	Method GetChildAtPath:XMLNode(path:String, attributes:String)
		' --- get the node at the given path, path is relative to this node ---
		'skip
		If path.Length = 0 Return doc.nullNode
		
		'parse the query
		Local query:= New XMLAttributeQuery(attributes)
		
		'search for path or return null node if none
		Local pathList:= doc.paths.Get(Self.path + "/" + path)
		If pathList = Null or pathList.IsEmpty() Return doc.nullNode
		
		'scan paths in list
		For Local node:= EachIn pathList
			'check for matching attributes
			If query.Test(node) Return node
			
			'next node
			node = node.nextSibling
		Next
		
		'return nothing as nothing was found
		Return doc.nullNode
	End
	
	Method GetChildrenAtPath:List<XMLNode>(path:String)
		' --- get the node at the given path, path is relative to this node ---
		Local result:= New List<XMLNode>
		
		'skip
		If path.Length = 0 Return result
		
		'search for path or return null node if none
		Local pathList:= doc.paths.Get(Self.path + "/" + path)
		If pathList = Null or pathList.IsEmpty() Return result
		
		'copy all nodes into result
		For Local node:= EachIn pathList
			result.AddLast(node)
		Next
		
		'finish :)
		Return result
	End
	
	Method GetChildrenAtPath:List<XMLNode>(path:String, attributes:String)
		' --- get the node at the given path, path is relative to this node ---
		Local result:= New List<XMLNode>
		
		'skip
		If path.Length = 0 Return result
		
		'parse the query
		Local query:= New XMLAttributeQuery(attributes)
		
		'search for path or return null node if none
		Local pathList:= doc.paths.Get(Self.path + "/" + path)
		If pathList = Null or pathList.IsEmpty() Return result
		
		'copy all nodes into result
		For Local node:= EachIn pathList
			If query.Test(node) result.AddLast(node)
		Next
		
		'finish :)
		Return result
	End
	
	Method CountChildren:Int(text:Bool = False)
		' --- count all children in node ---
		'skip
		If firstChild = Null Return 0
		
		'count
		If text
			Return children.Count()
		EndIf
		
		'scan children
		Local total:Int
		Local child:= firstChild
		While child
			'test
			If child.text = False total += 1
			
			'next child
			child = child.nextSibling
		Wend
		Return total
	End
	
	Method CountChildren:Int(name:String, text:Bool = False)
		' --- count all children with matching tag ---
		'skip
		If firstChild = Null Return 0
		
		'quick
		If name.Length = 0 Return children.Count()
		
		'fix casing
		name = name.ToLower()
		
		'count matching children
		Local total:Int
		Local child:= firstChild
		While child
			'add to count
			If child.nameLowerCase = name And (text or child.text = False) total += 1
		
			'next child
			child = child.nextSibling
		Wend
		
		'return
		Return total
	End
	
	Method CountChildren:Int(name:String, attributes:String, text:Bool = False)
		' --- count all children with matching tag and attributes ---
		'skip
		If firstChild = Null Return 0
		
		'quick
		If name.Length = 0 and attributes.Length = 0 Return children.Count()
		
		'fix casing
		name = name.ToLower()
		
		'parse the query
		Local query:= New XMLAttributeQuery(attributes)
		
		'count matching children
		Local total:Int
		Local child:= firstChild
		While child
			'add to count
			If (name.Length = 0 or child.nameLowerCase = name) And (text or child.text = False) And query.Test(child) total += 1
			
			'next child
			child = child.nextSibling
		Wend
		
		'return
		Return total
	End
	
	'parent api
	Method GetParent:XMLNode()
		' --- safe way to get parent ---
		If parent = Null Return doc.nullNode
		Return parent
	End
	
	'attribute api
	Method HasAttribute:Bool(id:String)
		' --- check if has attribute ---
		'fix id casing
		id = id.ToLower()
		
		'return true if the attribute exists
		Return attributes.Get(id) <> Null
	End
	
	Method SetAttribute:Void(id:String)
		' --- add new attribute to the node ---
		'skip
		If valid = False Return
		
		'fix id casing
		Local lowerId:= id.ToLower()
		
		'see if the attribute exists already
		Local attribute:= attributes.Get(lowerId)
		If attribute = Null
			'create new attribute
			attributes.Insert(lowerId, New XMLAttribute(id, ""))
		Else
			'set existing attribute
			attribute.idNormalCase = id
			attribute.value = ""
		EndIf
	End
	
	Method SetAttribute:Void(id:String, value:Bool)
		' --- add new attribute to the node ---
		'skip
		If valid = False Return
		
		'fix id casing
		Local lowerId:= id.ToLower()
		
		'see if the attribute exists already
		Local attribute:= attributes.Get(lowerId)
		If attribute = Null
			'create new attribute
			attributes.Insert(lowerId, New XMLAttribute(id, String(int(value))))
		Else
			'set existing attribute
			attribute.idNormalCase = id
			attribute.value = String(int(value))
		EndIf
	End
	
	Method SetAttribute:Void(id:String, value:Int)
		' --- add new attribute to the node ---
		'skip
		If valid = False Return
		
		'fix id casing
		Local lowerId:= id.ToLower()
		
		'see if the attribute exists already
		Local attribute:= attributes.Get(lowerId)
		If attribute = Null
			'create new attribute
			attributes.Insert(lowerId, New XMLAttribute(id, String(value)))
		Else
			'set existing attribute
			attribute.idNormalCase = id
			attribute.value = String(value)
		EndIf
	End
	
	Method SetAttribute:Void(id:String, value:Float)
		' --- add new attribute to the node ---
		'skip
		If valid = False Return
		
		'fix id casing
		Local lowerId:= id.ToLower()
		
		'see if the attribute exists already
		Local attribute:= attributes.Get(lowerId)
		If attribute = Null
			'create new attribute
			attributes.Insert(lowerId, New XMLAttribute(id, String(value)))
		Else
			'set existing attribute
			attribute.idNormalCase = id
			attribute.value = String(value)
		EndIf
	End
	
	Method SetAttribute:Void(id:String, value:String)
		' --- add new attribute to the node ---
		'skip
		If valid = False Return
		
		'fix id casing
		Local lowerId:= id.ToLower()
		
		'see if the attribute exists already
		Local attribute:= attributes.Get(lowerId)
		If attribute = Null
			'create new attribute
			attributes.Insert(lowerId, New XMLAttribute(id, value))
		Else
			'set existing attribute
			attribute.idNormalCase = id
			attribute.value = value
		EndIf
	End
	
	Method GetAttributes:StringMap<String>(output:StringMap<String> = Null)
		' --- return all of the attributes at once ---
		'make sure we have output
		If output = Null
			output = New StringMap<string>()
		EndIf
		
		For Local attribute:= EachIn attributes.Values()
			output.Insert(attribute.idLowercase, attribute.value)
		Next
		
		'done
		Return output
	End
	
	Method GetAttribute:String(id:String)
		' --- get attribute value ---
		'fix id casing
		id = id.ToLower()
		
		'check if it exists
		Local attribute:= attributes.Get(id)
		
		'no value so return default string
		If attribute = Null Return ""
		
		'return real value
		Return attribute.value
	End
		
	Method GetAttribute:Bool(id:String, defaultValue:Bool)
		' --- get attribute value ---
		'fix id casing
		id = id.ToLower()
		
		'check if it exists
		Local attribute:= attributes.Get(id)
		
		'use default value as doesn't exist
		If attribute = Null Return defaultValue
		
		'return real value
		Return attribute.value = "true" or Int(attribute.value) = True
	End
	
	Method GetAttribute:Int(id:String, defaultValue:Int)
		' --- get attribute value ---
		'fix id casing
		id = id.ToLower()
		
		'check if it exists
		Local attribute:= attributes.Get(id)
		
		'use default value as doesn't exist
		If attribute = Null Return defaultValue
		
		'return real value
		Return Int(attribute.value)
	End
	
	Method GetAttribute:Float(id:String, defaultValue:Float)
		' --- get attribute value ---
		'fix id casing
		id = id.ToLower()
		
		'check if it exists
		Local attribute:= attributes.Get(id)
		
		'use default value as doesn't exist
		If attribute = Null Return defaultValue
		
		'return real value
		Return Float(attribute.value)
	End
	
	Method GetAttribute:String(id:String, defaultValue:String)
		' --- get attribute value ---
		'fix id casing
		id = id.ToLower()
		
		'check if it exists
		Local attribute:= attributes.Get(id)
		
		'use default value as doesn't exist
		If attribute = Null Return defaultValue
		
		'return real value
		Return attribute.value
	End
	
	Method GetAttributeOrAttribute:String(id1:String, id2:String)
		' --- get attribute value or another attribute if other doesn't exist ---
		'fix id casing
		id1 = id1.ToLower()
		
		'check if it exists
		Local attribute:= attributes.Get(id1)
		
		'lookup other attribute?
		If attribute = Null
			id2 = id2.ToLower()
			attribute = attributes.Get(id2)
		EndIf
		
		'default value?
		If attribute = Null Return ""
		
		'return real value
		Return attribute.value
	End
	
	Method GetAttributeOrAttribute:Bool(id1:String, id2:String, defaultValue:Bool)
		' --- get attribute value or another attribute if other doesn't exist ---
		'fix id casing
		id1 = id1.ToLower()
		
		'check if it exists
		Local attribute:= attributes.Get(id1)
		
		'lookup other attribute?
		If attribute = Null
			id2 = id2.ToLower()
			attribute = attributes.Get(id2)
		EndIf
		
		'default value?
		If attribute = Null Return defaultValue
		
		'return real value
		Return attribute.value = "true" or Int(attribute.value) = True
	End
	
	Method GetAttributeOrAttribute:Int(id1:String, id2:String, defaultValue:Int)
		' --- get attribute value or another attribute if other doesn't exist ---
		'fix id casing
		id1 = id1.ToLower()
		
		'check if it exists
		Local attribute:= attributes.Get(id1)
		
		'lookup other attribute?
		If attribute = Null
			id2 = id2.ToLower()
			attribute = attributes.Get(id2)
		EndIf
		
		'default value?
		If attribute = Null Return defaultValue
		
		'return real value
		Return Int(attribute.value)
	End
	
	Method GetAttributeOrAttribute:Float(id1:String, id2:String, defaultValue:Float)
		' --- get attribute value or another attribute if other doesn't exist ---
		'fix id casing
		id1 = id1.ToLower()
		
		'check if it exists
		Local attribute:= attributes.Get(id1)
		
		'lookup other attribute?
		If attribute = Null
			id2 = id2.ToLower()
			attribute = attributes.Get(id2)
		EndIf
		
		'default value?
		If attribute = Null Return defaultValue
		
		'return real value
		Return Float(attribute.value)
	End
	
	Method GetAttributeOrAttribute:String(id1:String, id2:String, defaultValue:String)
		' --- get attribute value or another attribute if other doesn't exist ---
		'fix id casing
		id1 = id1.ToLower()
		
		'check if it exists
		Local attribute:= attributes.Get(id1)
		
		'lookup other attribute?
		If attribute = Null
			id2 = id2.ToLower()
			attribute = attributes.Get(id2)
		EndIf
		
		'default value?
		If attribute = Null Return defaultValue
		
		'return real value
		Return attribute.value
	End
	
	Method RemoveAttribute:Void(id:String)
		' --- remove particular attribute ---
		'skip
		If valid = False Return
		
		attributes.Remove(id)
	End
	
	Method ClearAttributes:Void()
		' --- clear all attributes ---
		'skip
		If valid = False Return
		
		attributes.Clear()
	End
	
	Method MergeAttributes:Void(source:XMLNode, overwrite:Bool = False)
		' --- apply multiple attributes from anotehr node ---
		For Local id:= EachIn source.attributes.Keys()
			If overwrite Or attributes.Contains(id) = False
				SetAttribute(id, source.GetAttribute(id))
			EndIf
		Next
	End
	
	'api
	Method Export:String(options:Int = XML_STRIP_WHITESPACE)
		' --- convert the node to a string ---
		'create a buffer
		Local buffer:= New XMLStringBuffer(1024)
		
		'call internal export
		Export(options, buffer, 0)
		
		'return
		Return buffer.value
	End
End

Class XMLAttribute
	Field idLowercase:String
	Field idNormalCase:String
	Field value:String
	
	'constructor/destructor
	Method New(id:String, value:String)
		Self.idLowercase = id.ToLower()
		Self.idNormalCase = id
		Self.value = value
	End
End

Class XMLError
	Field error:Bool = False
	Field message:String
	Field line:Int
	Field column:Int
	Field offset:Int
	
	'api
	Method Reset:Void()
		' --- reset error object ---
		error = False
		message = ""
		line = -1
		column = -1
		offset = -1
	End
	
	Method Set:Void(message:String, line:Int = -1, column:Int = -1, offset:Int = -1)
		' --- set an error ---
		error = True
		Self.message = message
		Self.line = line
		Self.column = column
		Self.offset = offset
	End

	Method ToString:String()
		' --- make a string out of this object ---
		If error = False Return ""
		Local buffer:= New XMLStringBuffer(256)
		buffer.Add("XMLError: ")
		
		'add message
		If message.Length
			buffer.Add(message)
		Else
			buffer.Add("unknown error")
		EndIf
		
		'add line
		buffer.Add(" [line:")
		If line > - 1
			buffer.Add(String(line))
		Else
			buffer.Add("??")
		EndIf
		
		'add column
		buffer.Add("  column:")
		If column > - 1
			buffer.Add(String(column))
		Else
			buffer.Add("??")
		EndIf
		
		'add offset
		buffer.Add("  offset:")
		If offset > - 1
			buffer.Add(offset + "]")
		Else
			buffer.Add("??]")
		EndIf
		
		'finish and return
		Return buffer.value
	End
End

Function ParseXML:XMLDoc(raw:String, error:XMLError = Null, options:Int = XML_STRIP_WHITESPACE)
	' --- this will parse xml into node structure ---
	Local rawLine:Int = 1
	Local rawColumn:Int = 1
	Local rawIndex:Int
	Local rawAsc:Int
	Local rawPos:Int
	Local rawChunkStart:Int
	Local rawChunkLength:Int
	Local rawChunkEnd:Int
	Local rawChunk:String
	Local rawChunkIndex:Int
	Local rawChunkAsc:Int
	Local rawChunkExit:Bool
	
	Local doc:XMLDoc
	Local parent:XMLNode
	Local current:XMLNode
	Local textNode:XMLNode
	
	Local whitespaceBuffer:= New XMLStringBuffer(1024)
	Local attributeBuffer:= New XMLStringBuffer(1024)
	
	Local processAttributeBuffer:Bool
	Local processTag:= False
	
	Local tagName:String
	
	Local formatVersion:String
	Local formatEncoding:String
	
	Local attributeId:String
	Local attributeValue:String
	
	Local inTag:= False
	Local inQuote:= False
	Local inFormat:= False
	
	Local isCloseSelf:= False
	Local isSingleAttribute:= False
	
	Local hasFormat:= False
	Local hasTagName:= False
	Local hasTagClose:= False
	Local hasAttributeId:= False
	Local hasAttributeValue:= False
	Local hasEquals:= False
	
	Local waitTagClose:= False
	
	Local stack:= New List<XMLNode>
	
	Local quoteAsc:Int
	
	'reset the error
	If error error.Reset()
	
	'check for no data
	If raw.Length = 0
		'error
		If error error.Set("no xml data")
		Return Null
	EndIf
	
	'scan the raw text
	For rawIndex = 0 Until raw.Length
		rawAsc = raw[rawIndex]
		
		If inTag = False
			Select rawAsc
				Case 9, 32'<tab><space>
					If whitespaceBuffer.Length or (parent And parent.fullValue.Length)
						'check for skipping duplicate whitespace
						Local lastAsc:Int = whitespaceBuffer.Last()
						If options & XML_STRIP_WHITESPACE = False or (whitespaceBuffer.Length And lastAsc <> 9 And lastAsc <> 32)
							'make sure we are not adding whitespace to nothing
							If parent = Null
								'error
								If error error.Set("illegal character", rawLine, rawColumn, rawIndex)
								Return Null
							EndIf
							
							'whitespace
							whitespaceBuffer.Add(rawAsc)
						EndIf
					EndIf
					
					'update line and column
					rawColumn += 1
					
				Case 10'<line feed>
					'update line and column
					rawLine += 1
					rawColumn = 1
					
					'add to whitespace?
					If options & XML_STRIP_NEWLINE = False
						whitespaceBuffer.Add(rawAsc)
					EndIf
					
				Case 13'<carriage return>
					'ignore stupid char
					
				Case 60'<
					'tag start
					
					'do we need to add text
					If parent And whitespaceBuffer.Length
						'trim the whitespace
						If options & XML_STRIP_WHITESPACE = True
							whitespaceBuffer.Trim()
						EndIf
						
						'add it
						If whitespaceBuffer.Length
							textNode = parent.AddText(whitespaceBuffer.value)
							whitespaceBuffer.Clear()
						EndIf
					EndIf
					
					'check for special tags
					If XMLHasStringAtOffset(XML_FORMAT_OPEN, raw, rawIndex)
						'start of a xml tag
						'check for format already existing
						If hasFormat
							'error
							If error error.Set("duplicate xml format", rawLine, rawColumn, rawIndex)
							Return Null
						EndIf
						
						'check for doc already started
						If doc <> Null
							'error
							If error error.Set("doc format should be defined before root node", rawLine, rawColumn, rawIndex)
							Return Null							
						EndIf
						
						'setup details
						inTag = True
						inFormat = True
						
						'progress the raw line and column
						rawColumn += XML_FORMAT_OPEN.Length
						
						'move the raw index on
						rawIndex = rawPos + XML_FORMAT_OPEN.Length - 1
						
					ElseIf XMLHasStringAtOffset(DOCTYPE_OPEN, raw, rawIndex)
						'ignore doctype
						'look for end of comment so we can skip ahead
						rawPos = XMLFindStringNotInQuotes(DOCTYPE_CLOSE, raw, rawIndex + DOCTYPE_OPEN.Length)

						If rawPos = -1
							'error
							If error error.Set("doctype not closed", rawLine, rawColumn, rawIndex)
							Return Null
						EndIf
						
						'get the chunk of data
						rawChunkStart = rawIndex + DOCTYPE_OPEN.Length
						rawChunkLength = rawPos - (rawIndex + DOCTYPE_OPEN.Length)
						rawChunkEnd = rawChunkStart + rawChunkLength
						
						'progress the raw line and column
						For rawChunkIndex = rawChunkStart Until rawChunkEnd
							rawChunkAsc = raw[rawChunkIndex]
							If rawChunkAsc = 10
								rawLine += 1
								rawColumn = 1
							Else
								rawColumn += 1
							EndIf
						Next
						
						'move the raw index on
						rawIndex = rawPos + DOCTYPE_CLOSE.Length - 1
						
					ElseIf XMLHasStringAtOffset(COMMENT_OPEN, raw, rawIndex)
						'start of a comment
						'look for end of comment so we can skip ahead
						rawPos = raw.Find(COMMENT_CLOSE, rawIndex + COMMENT_OPEN.Length)
						If rawPos = -1
							'error
							If error error.Set("comment not closed", rawLine, rawColumn, rawIndex)
							Return Null
						EndIf
						
						'get the chunk of data
						rawChunkStart = rawIndex + COMMENT_OPEN.Length
						rawChunkLength = rawPos - (rawIndex + COMMENT_OPEN.Length)
						rawChunkEnd = rawChunkStart + rawChunkLength

						'progress the raw line and column
						For rawChunkIndex = rawChunkStart Until rawChunkEnd
							rawChunkAsc = raw[rawChunkIndex]
							If rawChunkAsc = 10
								rawLine += 1
								rawColumn = 1
							Else
								rawColumn += 1
							EndIf
						Next
						
						'move the raw index on
						rawIndex = rawPos + COMMENT_CLOSE.Length - 1
						
					ElseIf XMLHasStringAtOffset(CDATA_OPEN, raw, rawIndex)
						'start of cdata
						'look for end of cdata so we can skip ahead
						rawPos = raw.Find(CDATA_CLOSE, rawIndex + CDATA_OPEN.Length)
						If rawPos = -1
							'error
							If error error.Set("cdata not closed", rawLine, rawColumn, rawIndex)
							Return Null
						EndIf
						
						'we now have some cdata so we should add it to the current parent
						If parent = Null
							'error
							If error error.Set("unexepcted cdata", rawLine, rawColumn, rawIndex)
							Return Null
						EndIf
						
						'get the chunk of data
						rawChunkStart = rawIndex + CDATA_OPEN.Length
						rawChunkLength = rawPos - (rawIndex + CDATA_OPEN.Length)
						rawChunkEnd = rawChunkStart + rawChunkLength

						'progress the raw line and column
						For rawChunkIndex = rawChunkStart Until rawChunkEnd
							rawChunkAsc = raw[rawChunkIndex]
							If rawChunkAsc = 10
								rawLine += 1
								rawColumn = 1
							Else
								rawColumn += 1
							EndIf
						Next
						
						'add it to the parent value
						whitespaceBuffer.Add(raw, rawChunkStart, rawChunkLength)
						
						'do we need to add text
						If parent And whitespaceBuffer.Length
							textNode = parent.AddText(whitespaceBuffer.value)
							whitespaceBuffer.Clear()
						EndIf
						
						'move the raw index on
						rawIndex = rawPos + CDATA_CLOSE.Length - 1
						
					Else
						'start of a tag
						inTag = True
						
						'need to dummp any whitespace into the parent
						If whitespaceBuffer.Length
							'trim the whitespace
							If options & XML_STRIP_WHITESPACE = True
								whitespaceBuffer.Trim()
							EndIf
							
							'add whitespace if need
							If whitespaceBuffer.Length
								'trim the whitespace
								If options & XML_STRIP_WHITESPACE = True
									whitespaceBuffer.Trim()
								EndIf
								
								'add it
								If whitespaceBuffer.Length
									textNode = parent.AddText(whitespaceBuffer.value)
									whitespaceBuffer.Clear()
								EndIf
							EndIf
						EndIf
						
						'update line and column
						rawColumn += 1
					EndIf
					
				Case 62'>
					'error
					If error error.Set("unexpected close bracket", rawLine, rawColumn, rawIndex)
					Return Null
					
				Default
					'make sure we are not adding whitespace to nothing
					If parent = Null
						'error
						If error error.Set("illegal character", rawLine, rawColumn, rawIndex)
						Return Null
					EndIf
					
					'whitespace
					whitespaceBuffer.Add(rawAsc)
					
					'update line and column
					rawColumn += 1
			End
		Else
			'we are in a tag so now we do tag parsing
			If waitTagClose
				'tag is waiting to close so lets process that!
				Select rawAsc
					Case 9'<tab>
						'update line and column
						rawColumn += 1
					Case 10'<line feed>
						'update line and column
						rawLine += 1
						rawColumn = 1
						
					Case 13'<carriage return>
						'just ignore this stupid character
						
					Case 32'<space>
						'update line and column
						rawColumn += 1
						
					Case 62'>
						'this is the end of a tag woo hoo
						waitTagClose = False
						processTag = True
						
					Default
						'error
						If error error.Set("unexpected character", rawLine, rawColumn, rawIndex)
						Return Null
				End
			Else
				If inQuote = False
					'we are not in a quote so we need to be selective as to what we are parsing!
					Select rawAsc
						Case 9'<tab>
							'update line and column
							rawColumn += 1
							
							'set if we need to process the attribute buffer
							If attributeBuffer.Length processAttributeBuffer = True
						
						Case 10'<line feed>
							'new line
							'update line and column
							rawLine += 1
							rawColumn = 1
							
							'set if we need to process the attribute buffer
							If attributeBuffer.Length processAttributeBuffer = True
							
						Case 13'<carriage return>
							'just ignore this stupid character
							
						Case 32'<space>
							'update line and column
							rawColumn += 1
							
							'set if we need to process the attribute buffer
							If attributeBuffer.Length processAttributeBuffer = True
														
						Case 34, 39'" '
							'quote
							quoteAsc = rawAsc
							inQuote = True
							
							'check for invalid value
							If hasTagClose or (hasTagName = False And inFormat = False) or hasEquals = False or attributeBuffer.Length
								'error
								If error error.Set("unexpected quote", rawLine, rawColumn, rawIndex)
								Return Null
							End
							
							'update line and column
							rawColumn += 1
							
							'set if we need to process the attribute buffer
							If attributeBuffer.Length processAttributeBuffer = True
							
						Case 47'/
							'close tag
							If hasTagClose or hasEquals
								'error
								If error error.Set("unexpected slash", rawLine, rawColumn, rawIndex)
								Return Null
							EndIf
							
							'flag processing of attribute if there is one
							If attributeBuffer.Length processAttributeBuffer = True
							
							'check if the tag has actually been opened yet?
							If hasTagName = False
								'check for tag closing self
								If processAttributeBuffer
									'closing self but tag hasnt been opened yet
									isCloseSelf = True
									waitTagClose = True
								Else
									'close tag
									hasTagClose = True
								EndIf
							Else
								'tag is open, so now close self
								hasTagClose = True
								isCloseSelf = True
								waitTagClose = True
							EndIf
							
							'update line and column
							rawColumn += 1
							
						Case 61'=
							'attribute assignment
							'update line and column
							rawColumn += 1
							
							If hasTagClose or (hasTagName = False And inFormat = False) or hasEquals or hasAttributeId or attributeBuffer.Length = 0
								'error
								If error error.Set("unexpected equals", rawLine, rawColumn, rawIndex)
								Return Null
							EndIf
							
							'set if we need to process the attribute buffer
							processAttributeBuffer = True
							hasEquals = True
							
						Case 62'>
							'close tag
							
							If (hasEquals or hasTagName = False) And attributeBuffer.Length = 0
								'error
								If error error.Set("unexpected close bracket", rawLine, rawColumn, rawIndex)
								Return Null
							EndIf
							
							'flag processing of attribute if there is one
							If attributeBuffer.Length processAttributeBuffer = True
							
							'end the creation of the tag
							processTag = True
							
							'update line and column
							rawColumn += 1
							
						Case 63'?
							'close format
							'check ahead for closing character
							If inFormat = False or rawIndex = raw.Length - 1 or raw[rawIndex + 1] <> 62'>
								'error
								If error error.Set("unexpected questionmark", rawLine, rawColumn, rawIndex)
								Return Null
							EndIf
							
							'end the creation of the tag
							processTag = True
							
							'skip ahead column and index
							rawIndex += 1
							rawColumn += 1
							
						Default
							'no speciffic so check generic
							If rawAsc = 45 or rawAsc = 58 or rawAsc = 95 or (rawAsc >= 48 and rawAsc <= 57) or (rawAsc >= 65 and rawAsc <= 90) or (rawAsc >= 97 and rawAsc <= 122)
								If hasTagClose = True And hasTagName = True
									'error
									If error error.Set("unexpected character", rawLine, rawColumn, rawIndex)
									Return Null
								EndIf
								
								'need to check for value with no assignment
								If hasAttributeId and hasEquals = False
									'we will add the rawAsc after processing it
									isSingleAttribute = True
									processAttributeBuffer = True
								Else
									'valid character
									attributeBuffer.Add(rawAsc)
								EndIf
								
								'update line and column
								rawColumn += 1
							Else
								'error
								If error error.Set("illegal character", rawLine, rawColumn, rawIndex)
								Return Null
							EndIf
					End
				Else
					'we are in a quote so we should accept anything apart from the quote that started it
					If rawAsc = quoteAsc
						'end of quote
						inQuote = False
						
						'flag for attribute to be processed
						processAttributeBuffer = True
					Else
						'append value for quote
						attributeBuffer.Add(rawAsc)
					EndIf
				EndIf
				
				'look at processing the attribute buffer
				If processAttributeBuffer
					'unflag attribute process
					processAttributeBuffer = False
					
					'so what does teh attribute buffer contain?
					If hasTagName = False And inFormat = False
						'tag name
						If hasTagClose = False
							'this is an opening tag
							tagName = attributeBuffer.value
							
							'create the current tag
							If parent = Null
								If doc = Null
									'create root node
									doc = New XMLDoc(tagName, formatVersion, formatEncoding)
									doc.doc = doc
									doc.parent = Null
									doc.line = rawLine
									doc.column = rawColumn
									doc.offset = rawIndex
									
									current = XMLNode(doc)
								Else
									'error
									If error error.Set("duplicate root", rawLine, rawColumn, rawIndex)
									Return Null
								EndIf
							Else
								'there is a parent so we should add this new node to it
								current = parent.AddChild(tagName)
								current.line = rawLine
								current.column = rawColumn
								current.offset = rawIndex
							EndIf
							
							'set some stuff
							hasTagName = True
						Else
							'this is a closing tag
							tagName = attributeBuffer.value.ToLower()
							
							'check for mismatch
							If parent = Null or tagName <> parent.nameLowerCase
								'error
								If error error.Set("mismatched end tag", rawLine, rawColumn, rawIndex)
								Return Null
							EndIf
							
							'set some stuff
							waitTagClose = True
							hasTagName = True
						EndIf
					Else
						If hasAttributeId = False
							'attribute id
							attributeId = attributeBuffer.value
							hasAttributeId = True
						Else
							'attribute value
							attributeValue = attributeBuffer.value
							hasAttributeValue = True
						EndIf
						
						'see if we need to add the attribute to the tag
						If (processTag And hasAttributeId) or (hasAttributeId And hasAttributeValue) or isSingleAttribute or hasTagClose
							'check on operation
							If inFormat = False
								'set attribute of node
								current.SetAttribute(attributeId, attributeValue)
							Else
								'set attribute of doc
								Select attributeId
									Case "version"
										formatVersion = attributeValue
									Case "encoding"
										formatEncoding = attributeValue
								End
							EndIf
							
							'reset some stuff
							attributeId = ""
							attributeValue = ""
							hasAttributeId = False
							hasAttributeValue = False
							hasEquals = False
						EndIf
					EndIf
					
					'reset the attribute buffer
					attributeBuffer.Clear()
				EndIf
				
				'add the single char back onto attribute buffer
				If isSingleAttribute
					isSingleAttribute = False
					attributeBuffer.Add(rawAsc)
				EndIf
			EndIf
							
			'look at processing a tag, this is delayed until the end so that possible processattributebuffer has a chance to run
			If processTag
				processTag = False
				
				'check for tag operation
				If inFormat = False
					'normal tags
					'check for open
					If hasTagClose = False And isCloseSelf = False
						'open tag has finished
						'setup node pointers
						parent = current
						current = Null
					
						'add parent to stack
						stack.AddLast(parent)
					EndIf
					
					'instant close
					If isCloseSelf hasTagClose = True
					
					'check for closed
					If hasTagClose = True
						'close tag has finished
						If isCloseSelf = False
							'the tag does not close itself
							'need to dummp any whitespace into the closing tag
							If whitespaceBuffer.Length
								'trim the whitespace
								If options & XML_STRIP_WHITESPACE = True
									whitespaceBuffer.Trim()
								EndIf
								
								'add it
								If whitespaceBuffer.Length
									parent.AddText(whitespaceBuffer.value)
									whitespaceBuffer.Clear()
								EndIf
							EndIf
						
							'remove from stack
							stack.RemoveLast()
							If stack.IsEmpty()
								parent = Null
							Else
								parent = stack.Last()
							EndIf
						Else
							'just unflag this
							isCloseSelf = False
						EndIf
					EndIf
				Else
					'initial format tags (top of document)
					hasFormat = True
					inFormat = False
				EndIf
				
				'reset some stuff
				inTag = False
				hasTagClose = False
				hasTagName = False
				waitTagClose = False
				tagName = ""
			EndIf
		EndIf
	Next
	
	'check for fail!
	If inTag or parent or doc = Null
		'error
		If error error.Set("unexpected end of xml", rawLine, rawColumn, rawIndex)
		Return Null
	EndIf
	
	Return doc
End