#initclip 10

_global.AboutTab = function() {
	super();
	
	this.Target = null;
	this.isCanceled = false;
	this._visible = false;
	
	this.labelFlashChat.autoSize = 'left';
	this.labelVersion.autoSize = 'left';
};

_global.AboutTab.prototype = new Object();

//PUBLIC METHODS.

_global.AboutTab.prototype.setEnabled = function(inDialogEnabled) {
	
};

_global.AboutTab.prototype.show = function(init) {
	//set current version
	this.labelVersion.text = this.Target.settings.version;
	//do some alignment
	this.labelVersion._x = this.labelFlashChat._x + this.labelFlashChat._width + 10;
	this.labelVersion._y = this.labelFlashChat._y + (this.labelFlashChat._height - this.labelVersion._height) * 0.7;
	
	if ( not init )
	{ 
		this._visible = true;
		return;
	}
		
	this.isCanceled = false;
	this._visible = true;
};

_global.AboutTab.prototype.hide = function() {
	this._visible = false;
}

_global.AboutTab.prototype.setTarget = function(inTarget) {
	this.Target = inTarget;
};

_global.AboutTab.prototype.canceled = function() {
	return this.isCanceled;
};

_global.AboutTab.prototype.applyLanguage = function(inLanguage) {
	
};

_global.AboutTab.prototype.applyTextProperty = function(propName, val)
{
	for(var itm in this)
	{ 
		if( this[itm]._name != undefined )
			if ( this[itm]._name.indexOf("label") == 0 && propName == 'font') 
			{ 
				setTextProperty(propName, val, this[itm], true);      
			}
	}
}

_global.AboutTab.prototype.applyStyle = function(inStyle) {
	for(var itm in this)
	{ 
		if( this[itm]._name != undefined )
		   if ( this[itm]._name.indexOf("label") == 0 )
		   { 
			this[itm].textColor = inStyle.bodyText;      
		   }
	}
};

_global.AboutTab.prototype.processOKButton = function() {
	this._visible = false;
};

_global.AboutTab.prototype.processCancelButton = function() {
	this._visible = false;
	this.isCanceled = true;
};

Object.registerClass('AboutTab', _global.AboutTab);

#endinitclip
