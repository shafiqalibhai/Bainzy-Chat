#initclip 10

_global.TextTab = function() {
	super();
	
	this.isCanceled = false;
	this._visible = false;
	
	this.textTarget = null;
	this.settings = null;
	this.language = null;
	
	this._changed = false;
	
	this.selectedTextProperties = new Object();
};

_global.TextTab.prototype = new Object();

//PUBLIC METHODS.

_global.TextTab.prototype.setEnabled = function(inDialogEnabled) {
	
	for(var itm in this)
	{ 
		if( this[itm]._name != undefined )
			if(this[itm]._name.indexOf("combo") == 0 ||
			   this[itm]._name.indexOf("cb")  == 0)
				this[itm].setEnabled(inDialogEnabled);
			
	}
	
};

_global.TextTab.prototype.show = function(init) {
	
	if ( not init )
	{ 
		this._visible = true;
		return;
	}
		
	this.isCanceled = false;
		
	for(var itm in this)
	{ 
		if( this[itm]._name != undefined )
			if(this[itm]._name.indexOf("combo") == 0 )
			{ 
				this[itm].setChangeHandler('process' + this[itm]._name.substring(5), this);
			}
			else if(this[itm]._name.indexOf("cb") == 0)
			{ 
				this[itm].setChangeHandler('process' + this[itm]._name.substring(2), this);
			}
	}
		
	if(this.textTarget.settings.allowLanguage == false)
	{
		this.comboLanguage.setEnabled(false);
		this.comboLanguage._visible = false;
		this.labelLanguage._visible = false;
	}
	
	//--------------------------------------------------------------------------------//
	//trace('INPUT');
	//dbg(this.textTarget.settings.user.text);
	
	this.setTextProperties(this.textTarget.settings.user.text);
	this.readSelectedTextProperties();
	this._visible = true;
};

_global.TextTab.prototype.hide = function() {
	this._visible = false;
}

_global.TextTab.prototype.canceled = function() {
	return this.isCanceled;
};

_global.TextTab.prototype.setTextProperties = function(inTextProperties) {
	this.settings = inTextProperties;
	
	this.cbMyTextColor.setChangeHandler(null);
	this.cbMyTextColor.setValue(this.settings.itemToChange.myTextColor);
	this.cbMyTextColor.setChangeHandler('processMyTextColor', this);
	
	this.comboFontFamily.removeAll();
	this.comboFontSize.removeAll();
	this.comboLanguage.removeAll();
	
	this.fillItemChange();
	
	for(itm in this.settings.fontSize) 
		this.comboFontSize.addItem(this.settings.fontSize[itm]);
		
	for(itm in this.settings.fontFamily) 
		this.comboFontFamily.addItem(this.settings.fontFamily[itm]);
		
	var langInd = 0;
	for(i = 0; i < this.textTarget.languages.length; i++) 
	{ 
		this.comboLanguage.addItem(this.textTarget.languages[i].name, this.textTarget.languages[i]);
		if(this.textTarget.selectedLanguage.id == this.textTarget.languages[i].id) langInd = i;
	}
		
	
	this.comboItemChange.setSelectedIndex(0);
	
	this.comboLanguage.setChangeHandler(null);
	this.comboLanguage.setSelectedIndex(langInd);
	this.comboLanguage.setChangeHandler('processLanguage', this);
};

_global.TextTab.prototype.fillItemChange = function()
{
	var selIndex = this.comboItemChange.getSelectedIndex();
	this.comboItemChange.removeAll();
	
	var tmp_arr = new Array();
	for(var itm in this.settings.itemToChange)
	{
		if(this.settings.itemToChange[itm].presence) 
		{ 
			var tmp_data = new Object();
			tmp_data.name = itm;
			tmp_data.size = this.settings.itemToChange[itm].fontSize;
			tmp_data.font = this.settings.itemToChange[itm].fontFamily;
			tmp_data.presence   = this.settings.itemToChange[itm].presence;
			
			tmp_arr.push({label : this.comboItemChange._items_text[itm], data : tmp_data});
		}
	}
	
	tmp_arr.reverse();
	for(var i = 0; i < tmp_arr.length; i++)
	{
		this.comboItemChange.addItem(tmp_arr[i].label, tmp_arr[i].data);
	}
	
	this.comboItemChange.setChangeHandler(null);
	this.comboItemChange.setSelectedIndex(selIndex);
	this.comboItemChange.setChangeHandler('processItemChange', this);
}

_global.TextTab.prototype.setTextTarget = function(inTextTarget) {
	this.textTarget = inTextTarget;
};

_global.TextTab.prototype.getSelectedTextProperties = function() {
	return (this.selectedTextProperties);
};

_global.TextTab.prototype.getSelectedLanguage = function() {
	return (this.comboLanguage.getSelectedItem().data);
}

_global.TextTab.prototype.applyTextProperty = function(propName, val)
{
	for(var itm in this)
	{ 
		if( this[itm]._name != undefined )
			if ( this[itm]._name.indexOf("label") == 0 ) 
			{ 
				setTextProperty(propName, val, this[itm], true);      
			}
	}
}

_global.TextTab.prototype.applyStyle = function(inStyle) {
	for(var itm in this)
	{ 
		if( this[itm]._name != undefined )
			if ( this[itm]._name.indexOf("label") == 0 )
				this[itm].textColor = inStyle.bodyText;      
	}
};

_global.TextTab.prototype.applyLanguage = function(inLanguage) {
	this.language = inLanguage;
	
	this.comboItemChange._items_text = new Object();
	
	if(this.language.dialog.text != undefined)
	{ 
		this.labelItemChange.text  = this.language.dialog.text.itemChange;
		this.labelFontSize.text    = this.language.dialog.text.fontSize; 
		this.labelFontFamily.text  = this.language.dialog.text.fontFamily; 
		this.labelLanguage.text    = this.language.dialog.text.language;
		this.labelMyTextColor.text = this.language.dialog.text.mytextcolor;
		
		this.comboItemChange._items_text['mainChat'] = this.language.dialog.text.mainChat;
		this.comboItemChange._items_text['interfaceElements'] = this.language.dialog.text.interfaceElements;
		this.comboItemChange._items_text['title'] = this.language.dialog.text.title;
		
	}
	else
	{
		this.comboItemChange._items_text['mainChat'] = "Main Chat";
		this.comboItemChange._items_text['interfaceElements'] = "Interface Elements";
		this.comboItemChange._items_text['title'] = "Title";
	}
	
	this.fillItemChange();
	
};

_global.TextTab.prototype.readSelectedTextProperties = function() {
	for(var i = 0; i < this.comboItemChange.getLength(); i++)
	{
		var itm = this.comboItemChange.getItemAt(i);
		this.selectedTextProperties[itm.data.name]	= new Object();
		this.selectedTextProperties[itm.data.name].fontSize = itm.data.size;
		this.selectedTextProperties[itm.data.name].fontFamily = itm.data.font;
		this.selectedTextProperties[itm.data.name].presence = itm.data.presence;
	}
	this.selectedTextProperties.myTextColor = this.cbMyTextColor.getValue();
};

_global.TextTab.prototype.processOKButton = function() {
	this.readSelectedTextProperties();
	this._visible = false;
};

_global.TextTab.prototype.processCancelButton = function() {
	if(this._changed)
	{ 
		this.textTarget.applyTextProperties(this.textTarget.settings.user.text.itemToChange, true);	
		this._changed = false;
	}
	
	if(this.textTarget.selectedLanguage.id != this.comboLanguage.getSelectedItem().data.id)
	{ 
		this.textTarget.applyLanguage(this.textTarget.selectedLanguage, true);
	}
	
	this._visible = false;
	this.isCanceled = true;
};

_global.TextTab.prototype.processItemChange = function(inControl) {
	var selItem = inControl.getSelectedItem().data;
	
	for(var fontInd = 0; fontInd < this.comboFontSize.getLength(); fontInd++) 
	{ 
		if(this.comboFontSize.getItemAt(fontInd).label == selItem.size) 
		{ 
			this.comboFontSize.setChangeHandler(null);
			this.comboFontSize.setSelectedIndex(fontInd);	
			this.comboFontSize.setChangeHandler('processFontSize', this);
			break;
		}
	}
	
	for(fontInd = 0; fontInd < this.comboFontFamily.getLength(); fontInd++) 
	{ 
		if(this.comboFontFamily.getItemAt(fontInd).label ==  selItem.font) 
		{ 
			this.comboFontFamily.setChangeHandler(null);
			this.comboFontFamily.setSelectedIndex(fontInd);	
			this.comboFontFamily.setChangeHandler('processFontFamily', this);
			break;
		}
	}
}

_global.TextTab.prototype.processFontSize = function(inControl) {
	var tmp = this.comboItemChange.getSelectedItem().data.size = inControl.getSelectedItem().label;
	
	this.textTarget.setObjectTextProperty('size', inControl.getSelectedItem().label, this.comboItemChange.getSelectedItem().data.name, true);
	this._changed = true;
}

_global.TextTab.prototype.processFontFamily = function(inControl) {
	this.comboItemChange.getSelectedItem().data.font = inControl.getSelectedItem().label;

	this.textTarget.setObjectTextProperty('font', inControl.getSelectedItem().label, this.comboItemChange.getSelectedItem().data.name, true);
	this._changed = true;
}

_global.TextTab.prototype.processLanguage = function(inControl) {
	if(inControl.getSelectedItem().data.loaded == false)
	{ 
		this.textTarget.listener.getLanguage(inControl.getSelectedItem().data.id);
	}
	else
	{ 
		this.textTarget.applyLanguage(inControl.getSelectedItem().data, true);
	}
	
	this.textTarget.callModuleFunc('mOnChangeLang', {langname : inControl.getSelectedItem().data.id}, -1);
}

_global.TextTab.prototype.processMyTextColor = function(inControl) {
	this.textTarget.setColored(null, !inControl.getValue());
}

Object.registerClass('TextTab', _global.TextTab);

#endinitclip
