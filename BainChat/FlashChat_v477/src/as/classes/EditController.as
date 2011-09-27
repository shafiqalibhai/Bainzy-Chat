#initclip 0

//----------------------------------------------------------------------
// EditController Class
//----------------------------------------------------------------------

var c = _global.EditController = function(obj)
{	
	this.init(obj);
}

var p = c.prototype = new Object();

//----------------------------------------------------------------------
// Initialization / Configuration
//----------------------------------------------------------------------

p.init = function(obj)
{
	this.parentObj = obj;
	this.updating = false;  
	this.wysiwyg = true;
	this.toolList = new Object();
	this.tags = new Object();
	this.insideFont = false;
	
	//setInterval(this,"updateSelection",700);
}

var tf = p.sourceTextFormat = new TextFormat();
tf.font = "Courier New";
tf.size = 12;
tf.color = 0x000000;
tf.bold = false;
tf.italic = false;
tf.underline = false;
tf.align = "left";
tf.bullet = false;

//----------------------------------------------------------------------
// Public Methods
//----------------------------------------------------------------------

p.setValue = function(value)
{
	if(this.wysiwyg){
		this.inputField.htmlText = value;
	} else {
		this.inputField.text = value;	
	}
}
p.getValue = function()
{	
	return this.formatSource(false);	
}
p.setEnabled = function(b)
{
	super.setEnabled(b);
	this.inputField.selectable = b;
	this.inputField.type = b ? "input" : "dynamic";
	this.setTextToolsEnabled(b);
}
p.getData = function()
{	return this.wysiwyg ? this.inputField.htmlText : this.inputField.text;
}
p.setTargetTextField = function(ref)
{
	this.inputField = ref;
	ref.html = true;
	ref.tabEnabled = false;
	ref.controller = this;
	ref.onSetFocus = function()
	{	
		this.controller.onTextFieldSetFocus();			
	}
	ref.onKillFocus = function()
	{	
		updateSelection();
		this.controller.onTextFieldKillFocus();
	}
	ref.onChanged = function()
	{	this.controller.sendChangeEvent("onTextChanged");
	}
	this.setEditMode(this.wysiwyg)
}
	

p.bindComponent = function(component,textProp,toolType, subProps)
{
	this.toolList[textProp] = component;
	component.textProp = textProp;
	component.toolType = toolType;
	component.subProps = subProps;
	if(toolType == 'Button') component.setClickHandler("onTextToolChanged",this);
	else component.setChangeHandler("onTextToolChanged",this);
	return component;
}

p.unbindComponent = function(textProp)
{
	this.toolList[textProp].setChangeHandler(null);
	delete this.toolList[textProp];
}

p.allowTag = function(tagName,noEmpty,_newLine)
{
	var tag = this.tags[tagName] = new Object();
	tag.attributes = new Object();
	tag.noEmpty = noEmpty;
	tag._newLine = _newLine;
}

p.allowAttribute = function(tagName,attrName,_default)
{
	var tag = this.tags[tagName];
	if(typeof(tag)!="object"){
		this.allowTag(tagName);	
	}
	tag.attributes[attrName] = {_default:_default};	
}

p.setEditMode = function(bool)
{
	var scrollperc = this.inputField.scroll / this.inputField.maxscroll;
	if(!bool){
		var data = this.formatSource(true);
		this.inputField.setTextFormat(this.sourceTextFormat);
		this.inputField.setNewTextFormat(this.sourceTextFormat);
		this.inputField.html = false;
		this.inputField.text = data;
	} else if(bool){
		var data = this.formatSource(false);
		this.inputField.html = true;
		this.inputField.htmlText = data;	
	}
	this.setTextToolsEnabled(bool);
	this.inputField.scroll = Math.floor(this.inputField.maxscroll * scrollperc);
	this.wysiwyg = bool;
}

//----------------------------------------------------------------------
// Source Manipulation Methods
//----------------------------------------------------------------------
p.validateSource = function()
{
	var tree = new XML();
	tree.parseXML(this.getValue());
	return tree.status == 0;
}

p.formatSource = function(white)
{
	var tree = new XML();
	tree.ignoreWhite = true;
	tree.parseXML(this.getData());
	var value = this.nodeToString(tree,white);
	this.insideFont = false;
	return value;
}

p.nodeToString = function(n,white,sibling)
{
	if(n.nodeType == 3){
		return this.trim(n.nodeValue);// + (white ? "\n" : "");
	} else {
		
		var nn = n.nodeName.toLowerCase();
		var curTag = this.tags[nn];
		var tagAllowed = curTag != null;
		
		var notLink = true;
		
		if (this.showLinks && nn == "font" && n.firstChild.attributes.href == "*!REMOVE_ME!*"){
			notLink = false;
		}
		
		if (this.showLinks && nn == "u" && n.parentNode.attributes.href == "*!REMOVE_ME!*"){
			notLink = false;	
		}
		
		if(tagAllowed && n.attributes.href != "*!REMOVE_ME!*" && notLink){			
			var openTag = "<"+nn;
			var closeTag = "</"+nn+">";
			var numAttr = 0;
			for(var i in n.attributes){
				var an = i.toLowerCase();
				var attr = curTag.attributes[an];
				if(typeof(attr)=="object"){
					var val = n.attributes[i];
					if(val.toLowerCase() != attr._default){
						openTag += " "+an+"=\""+val+"\"";
						numAttr++;
					}
				}
			}
			openTag += ">";	
			if(sibling && white && curTag._newLine)openTag = "\n" + openTag;
		}
		
		var max = n.childNodes.length;
		for(var i=0, tagContent="", l=max; i<l; i++){
			tagContent += this.nodeToString(n.childNodes[i],white,((i > 0) || (sibling && !tagAllowed)));	
		}
		this.insideFont = false;
		
		if(tagAllowed){
			if(tagContent == ""){
				return curTag.noEmpty ? "" : openTag + closeTag;	
			} else if(white && curTag._newLine){
				return openTag + "\n" + tagContent + "\n" + closeTag;	
			} else {
				return openTag + tagContent + closeTag;
			}
			
		} else {
			return tagContent;
		}
	}
}

p.ltrim = function(s)
{
	if(s.charCodeAt(0) == 13){
		return s.substring(1,s.length);	
	} else {
		return s;	
	}
}

p.rtrim = function(s)
{
	if(s.charCodeAt(s.length-1) == 13){
		return s.substring(0,s.length-1);	
	} else {
		return s;	
	}
}

p.trim = function(s)
{	return this.ltrim(this.rtrim(s));	
}

//----------------------------------------------------------------------
// Private Methods
//----------------------------------------------------------------------

p.setTextToolsEnabled = function(b)
{
	for(var i in this.toolList)
	{
		this.toolList[i].setEnabled(b);	
	}
}

//
p.setNewFormatProp = function(prop,value)
{
	var ntf = this.inputField.getTextFormat(this.beginIndex-1);
	ntf[prop] = value;
	this.inputField.setTextFormat(this.beginIndex,this.beginIndex+1,ntf);
	this.inputField.setNewTextFormat(ntf);
}

// Fired when a tool bar item is changed, is there is text selected it will 
// change the property of that text, else it will set a new text format property.
p.onTextToolChanged = function(c, force)
{	
	if(this.updating)return;
	
	updateSelection();
	
	var s = this.inputField.textfield_txt.scroll;
	if(this.beginIndex != this.endIndex)
	{		
		var tf = new TextFormat();
		tf[c.textProp] = c.getValue();
		for (var p in c.subProps){
			tf[p] = c.subProps[p];	
		}
		if (force != null){
			this.toolList["target"].setEnabled(force);	
		}
		
		this.setSelectedTextFormat(tf);
	} 
	else 
	{	
		this.setNewFormatProp(c.textProp,c.getValue());
		for (var p in c.subProps){
			this.setNewFormatProp(p, c.subProps[p]);	
		}
	//	this.toolList["target"].setEnabled(c.subProps.url != null && c.subProps.url != "");
	}
	
	
	var id = setInterval(function(c,s,but)
	{		
		c.restoreSelection();
		c.inputField.textfield_txt.scroll = s;
		clearInterval(id);
		//but.setEnabled( true );
	},20,this,s,c);
	
	//this.scrollbar.onTextChanged();
}

// updates all toolbar items according to the the selected text or caret index
p.updateTextTools = function()
{
	if(this.beginIndex != this.endIndex){
		var tf = this.getSelectedTextFormat();		
		this.toolList["target"].setEnabled(tf.url != null && tf.url !="");
		this.toolList["url"].setEnabled(true);
	} else 
	{
		var tf = this.inputField.getNewTextFormat();
		this.toolList["url"].setEnabled(false);		
	}
		
	this.updating = true;	
	for(var i in tf)
	{
		var c = this.toolList[i];
		if(c.toolType == undefined) continue;
		
		this["update"+c.toolType](c,tf[i]);			
	}	
	this.updating = false;
}


p.updateSelection = function(notTools)
{    
	//trace(Selection.getFocus() +"-"+this.inputField.textfield_txt);
	if( Selection.getFocus() != ""+this.inputField.textfield_txt)return;
	//trace("update sel");
	//if(this.wysiwyg)
	{
		this.beginIndex = Selection.getBeginIndex();
		this.endIndex = Selection.getEndIndex();		
		if(!notTools)this.updateTextTools();
	}
}

p.restoreSelection = function()
{	
	//if (this.parentObj.keyFocus)
	{		
		Selection.setFocus(this.inputField.textfield_txt);
		Selection.setSelection(1000,1000);//this.beginIndex, this.endIndex);
	}
}

p.getSelectedTextFormat = function()
{
	return this.inputField.textfield_txt.getTextFormat(this.beginIndex,this.endIndex);
}

p.setSelectedTextFormat = function(tf)
{
	this.inputField.textfield_txt.setTextFormat(this.beginIndex, this.endIndex, tf);
}

/*
p.onTextFieldSetFocus = function()
{	
	Key.addListener(this);
	Mouse.addListener(this);
}
p.onTextFieldKillFocus = function()
{
	Key.removeListener(this);
	Mouse.removeListener(this);
}
p.onKeyUp = p.onKeyDown = function()
{
	var kc = Key.getCode();
	this.updateSelection(!(kc >= 33 && kc <= 40));
	trace("mouse up");
}
p.onMouseUp = p.onMouseDown = function()
{
	this.updateSelection();	
}*/


p.updateIconButton = function(c,v)
{
	if(v === true){
		c.setValue(true);
		c.getIcon()._alpha = 100;
	} else if(v === false){
		c.setValue(false);
		c.getIcon()._alpha = 100;
	} else {
		c.setValue(true);
		c.getIcon()._alpha = 50;	
	}	
}

p.updateButton = function(c,v)
{
	if(v === true){
		c.setValue(true);
		c.getIcon()._alpha = 100;
	} else if(v === false){
		c.setValue(false);
		c.getIcon()._alpha = 100;
	} else {
		c.setValue(true);
		c.getIcon()._alpha = 50;	
	}	
}


delete p;

#endinitclip