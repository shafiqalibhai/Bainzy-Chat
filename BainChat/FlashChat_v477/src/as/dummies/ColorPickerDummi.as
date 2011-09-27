#initclip 10

_global.ColorPickerDummi = function() {        
        
	this.init();
	
	this.value = 0;
	
	this.content_mc = null;
	
	this.icon_mc.useHandCursor = false;
	this.icon_mc.onRelease = function() {
		this._parent.onIconOpen();
	};
};

_global.ColorPickerDummi.prototype = new FUIComponentClass();

_global.ColorPickerDummi.prototype.setChangeHandler = function(inFunc, inHandl)
{
	this.handlFunc = inFunc;
	this.handlObj  = inHandl;
};

_global.ColorPickerDummi.prototype.setValue = function(inColor)
{
	this.value = inColor;
	var c = new Color(this.icon_mc.icon_preview);		
	c.setRGB(this.value);
};

_global.ColorPickerDummi.prototype.getValue = function()
{
	if(this.content_mc != null) 
		this.value = this.content_mc.getValue();
	this.setValue(this.value);
	
	return( this.value );
};

_global.ColorPickerDummi.prototype.setEnabled = function(inValue)
{
	this.icon_mc.icon_preview._visible = inValue;
	this.icon_mc.enabled = inValue;
};

_global.ColorPickerDummi.prototype.getEnabled = function()
{
	return (this.icon_mc.enabled);
};

_global.ColorPickerDummi.prototype.onIconOpen = function()
{
	this.icon_mc._visible = false;
	
	this.content_mc = this.pickerHolder.attachMovie('FColorPickerSymbol', 'content_mc', 1, {initColor : this.value});
	this.content_mc.setChangeHandler(this.handlFunc, this.handlObj);
	this.content_mc.setCloseHandler('onIconClose', this);
	
	this.onEnterFrame = function()
	{ 
		delete this.onEnterFrame;
		this.content_mc.open();
	}
};

_global.ColorPickerDummi.prototype.onIconClose = function()
{
	if(this.content_mc != null) 
	{ 
		this.value = this.content_mc.getValue();
		this.content_mc.removeMovieClip();
		delete(this.content_mc);
	}
	
	this.icon_mc._visible = true;
};

Object.registerClass('ColorPickerDummi', _global.ColorPickerDummi);

#endinitclip