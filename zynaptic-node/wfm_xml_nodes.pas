{$ifdef fpc} {$mode delphi} {$endif}

unit wfm_xml_nodes;

interface
uses
	lib_xml_parser;

type
	TWfmXmlNode = class;
	TWfmXmlNodes = class(TObjectList)
	protected
		function GetItem(Index: Integer): TWfmXmlNode;
		procedure SetItem(Index: Integer; TreeNode: TWfmXmlNode);
	public
		function Add(Node: TWfmXmlNode): Boolean;
		function Remove(TreeNode: TWfmXmlNode): Integer;
		function IndexOf(TreeNode: TWfmXmlNode): Integer;
		procedure Insert(Index: Integer; TreeNode: TWfmXmlNode);
		property Node[Index: Integer]: TWfmXmlNode read GetItem write SetItem; default;

	end;

    // --- //

	TWfmXmlNode = class(TObject)
    private
    	f_parent		: TWfmXmlNode;
    	f_attribs		: TAttrList;
        f_nodeName		: String;
		f_nodeValue		: String;
        f_childNodes	: TWfmXmlNodes;
        f_nodeLevel		: Integer;
        f_nodeIdent		: UInt64;

        f_valBase64		: Boolean;
        f_closeRoot		: Boolean;

        procedure SetNodeName(Value: AnsiString);

        procedure SetNodeValue(Value: AnsiString);
        procedure SetNodeValue64(Value: AnsiString);
        function GetNodeValue(): AnsiString;

    public
    	constructor Create(Parent: TWfmXmlNode = nil; closeRoot: Boolean = true);
        destructor Destroy; override;

        function HasParent(): Boolean;
        function HasChildren(): Boolean;
		function IsLastNode(): Boolean;

        function GetFirstChild(): TWfmXmlNode;
        function GetChildNode(NodeName: String): TWfmXmlNode;
		function GetNextSibling(): TWfmXmlNode;

        // Attrib related functions
		function FindAttribute(AttribName: String): TNvpNode;
        procedure PutAttrib(AttribName: String; AttribValue: String); overload;
        procedure PutAttrib(AttribName: String; AttribValue: Integer); overload;
        function GetAttribAsStr(AttribName: String): String;
        function GetAttribAsint(AttribName: String): Integer;


        function NewChild(): TWfmXmlNode;

        function ToString(SingleQuote: Boolean = false): AnsiString;

        // Properties
        property Parent: TWfmXmlNode read f_parent write f_parent;
        property NodeName: String read f_nodeName write SetNodeName;
        property NodeValue: String read GetNodeValue write f_nodeValue;
        property NodeValue64: String read f_nodeValue write SetNodeValue64;

        property NodeIdent: UInt64 read f_nodeIdent;
        property Attributes: TAttrList read f_attribs write f_attribs;
        property ChildNodes: TWfmXmlNodes read f_childNodes;
		property Level: Integer read f_nodeLevel write f_nodeLevel;

    end;


implementation
uses
	SysUtils, type_def, string_utils;

{*******************************************************************************
*
*	Xml Node Implementation
*
********************************************************************************}
constructor TWfmXmlNode.Create(Parent: TWfmXmlNode = nil; closeRoot: Boolean = true);
begin
	f_parent		:= Parent;
	f_attribs		:= nil;
    f_childNodes	:= TWfmXmlNodes.Create;
    f_nodeLevel		:= 0;
    f_nodeIdent		:= 0;
    f_valBase64		:= false;
    f_closeRoot		:= closeRoot; // Added jun 30

end; // end TWfmXmlNode.Create

destructor TWfmXmlNode.Destroy;
begin
	freeAndNil(f_childNodes);

    // --- //

    inherited Destroy;

end; // end TWfmXmlNode.Destroy

{* Sets the Node Name property and generates a unique numeric Identifier
*}
procedure TWfmXmlNode.SetNodeName(Value: String);
begin
	f_nodeName := Value;
    f_nodeIdent := Unc(f_nodeName);

end; // end TWfmXmlNode.SetNodeName


procedure TWfmXmlNode.SetNodeValue(Value: AnsiString);
begin
	f_valBase64 := false;
    f_nodeValue := Value;

end; // end TWfmXmlNode.SetNodeValue

procedure TWfmXmlNode.SetNodeValue64(Value: AnsiString);
begin
	f_valBase64 := false;
	f_nodeValue := Encode64(Value);

end; // end TWfmXmlNode.SetNodeValue64

function TWfmXmlNode.GetNodeValue(): AnsiString;
begin
	if (f_valBase64) then
		Result := Decode64(f_nodeValue)
    else
    	Result := f_nodeValue;

end; // end TWfmXmlNode.GetNodeValue



function TWfmXmlNode.HasParent(): Boolean;
begin
	Result := (f_parent<>nil);

end; // end TWfmXmlNode.HasParent


function TWfmXmlNode.HasChildren(): Boolean;
begin
	Result := (GetFirstChild<>nil);

end; // end TWfmXmlNode.HasChildren

function TWfmXmlNode.IsLastNode(): Boolean;
var
	myIdx: Integer;
begin
	Result := true;
    if (Parent<>nil) then
    begin
    	myIdx := Parent.ChildNodes.IndexOf(Self);
        if (myIdx<Parent.ChildNodes.Count-1) then
            Result := false;

    end; // end if
end;


function TWfmXmlNode.GetFirstChild(): TWfmXmlNode;
begin
	Result := nil;

    if (f_childNodes.Count>0) then
    	Result := f_childNodes[0];

end; // end TWfmXmlNode.GetChildNode

function TWfmXmlNode.GetChildNode(NodeName: AnsiString): TWfmXmlNode;
var
	i: Integer;
    tmpNode: TWfmXmlNode;
begin
	Result := nil;
	for i := 0 to ChildNodes.Count-1 do
    begin
		tmpNode := ChildNodes[i];
        if (tmpNode.NodeName=NodeName) then
        begin
            Result := tmpNode;
            Break;

        end; // end if

    end; // end for loop

end; // end TWfmXmlNode.GetChildNode

function TWfmXmlNode.GetNextSibling(): TWfmXmlNode;
var
	myIdx: Integer;
begin
	Result := nil;
    if (Parent<>nil) then
    begin
    	myIdx := Parent.ChildNodes.IndexOf(Self);
        if (myIdx>-1) and (myIdx+1<=Parent.ChildNodes.Count-1) then
            Result := Parent.ChildNodes[myIdx+1];

    end; // end if


end; // end TWfmXmlNode.GetNextSibling




// Attrib related functions
function TWfmXmlNode.FindAttribute(AttribName: String): TNvpNode;
begin
	Result := nil;
    if (Attributes<>nil) then
    	Result := Attributes.Find(AttribName);

end; // end TWfmXmlNode.FindAttribute


procedure TWfmXmlNode.PutAttrib(AttribName: String; AttribValue: String);
begin
	if (f_attribs=nil) then
    	f_attribs := TAttrList.Create;

	f_attribs.Add(
				TNvpNode.Create(AttribName, AttribValue)
    		);

end; // end TWfmXmlNode.PutAttrib

procedure TWfmXmlNode.PutAttrib(AttribName: String; AttribValue: Integer);
begin
	if (f_attribs=nil) then
    	f_attribs := TAttrList.Create;

	f_attribs.Add(
				TNvpNode.Create(AttribName, IntToStr(AttribValue))
    		);

end; // end TWfmXmlNode.PutAttrib


function TWfmXmlNode.GetAttribAsStr(AttribName: String): String;
var
	tmpNode: TNvpNode;
begin
	Result := '';
	tmpNode := FindAttribute(AttribName);
    if (tmpNode<>nil) then
    	Result := tmpNode.Value;

end; // end TWfmXmlNode.GetAttribAsStr

function TWfmXmlNode.GetAttribAsint(AttribName: String): Integer;
var
	tmpNode: TNvpNode;
begin
	Result := -1;
	tmpNode := FindAttribute(AttribName);
    if (tmpNode<>nil) then
		try
    		Result := StrToInt(tmpNode.Value);

        except
        	// The value does not qualify as an integer
        end;

end; // end TWfmXmlNode.GetAttribAsint


{* This function creates a new node which is returned aswell as
 * adds it as a child node
*}
function TWfmXmlNode.NewChild(): TWfmXmlNode;
begin
	Result := TWfmXmlNode.Create();
	Result.Parent := Self;
	f_childNodes.Add(Result);

end; // end TWfmXmlNode.NewChild


{* This function returns a string (XML) representation of the
 * node and it's children
*}
function TWfmXmlNode.ToString(SingleQuote: Boolean = false): AnsiString;
var
	Node,
    PrevNode: TWfmXmlNode;
    Quote: Char;

	procedure ProcessNode(Node: TWfmXmlNode; var XmlString: AnsiString);
	var
		i: Integer;
    	tmpAttrib: TNvpNode;
	begin
		if (Node = nil) then Exit;

        // Create the xml from the node
		XmlString := XmlString + '<' + Node.NodeName;

        if (Node.Attributes<>nil) then
			for i := 0 to Node.Attributes.Count-1 do
			begin
				tmpAttrib := TNvpNode(Node.Attributes[i]);
    	        Result := Result + ' ' + tmpAttrib.Name + '='
        			+ Quote + tmpAttrib.Value + Quote;

			end; // end for


        // Close the node
        if (not Node.HasChildren) and (Node.NodeValue<>'') then
        	XmlString := XmlString + '>' + Node.NodeValue + '</' + Node.NodeName + '>'

        else if (Node.HasChildren) then
        	XmlString := XmlString + '>'

        else if (not Node.HasChildren) and (Node.NodeValue='') then // Empty node
        	XmlString := XmlString + ' />';

        // --- //

		// Child Nodes
		Node := Node.GetFirstChild;
        PrevNode := nil;

		while (Node<>nil) do
		begin
			ProcessNode(Node, XmlString);
            PrevNode := Node;
			Node := Node.GetNextSibling();

		end; // end while

       // if (PrevNode.IsLastNode) and (PrevNode<>nil) then
		if (PrevNode<>nil) then
			if (PrevNode.Parent<>nil) then
				XmlString := XmlString + '</' + PrevNode.Parent.NodeName + '>';


	end;

begin
    // Single or double quoting
    Quote := '"';
    if (SingleQuote) then
    	Quote := D_DELIM;

	Node := Self;

	while (Node<> nil) do
	begin
		ProcessNode(Node, Result);
		Node := Node.GetNextSibling();

	end; // end while


end; // end TWfmXmlNode.PutAttrib


{*******************************************************************************
*
*	Xml Nodes Implementation
*
********************************************************************************}
function TWfmXmlNodes.Add(Node: TWfmXmlNode): Boolean;
begin
	Result := true;
    //Node.Parent := Self;
    inherited Add(Node);

end; // end TWfmXmlNodes.Add

function TWfmXmlNodes.GetItem(Index: Integer): TWfmXmlNode;
begin
	Result := TWfmXmlNode(inherited Items[Index]);
end;

function TWfmXmlNodes.IndexOf(TreeNode: TWfmXmlNode): Integer;
begin
	Result := inherited IndexOf(TreeNode);
end;

procedure TWfmXmlNodes.Insert(Index: Integer; TreeNode: TWfmXmlNode);
begin
	inherited Insert(Index, TreeNode);
end;

function TWfmXmlNodes.Remove(TreeNode: TWfmXmlNode): Integer;
begin
	Result := inherited Remove(TreeNode);
end;

procedure TWfmXmlNodes.SetItem(Index: Integer; TreeNode: TWfmXmlNode);
begin
	inherited Items[Index] := TreeNode;
end;



end.
