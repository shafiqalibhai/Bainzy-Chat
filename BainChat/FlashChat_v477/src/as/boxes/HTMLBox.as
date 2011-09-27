#initclip 10

_global.HTMLBox = function() {
	super();
	
	this.htmlText = null;
	this.isCanceled = false;
	this._visible = false;
	this.txtMain.background = false;
};

_global.HTMLBox.prototype = new DialogBox();

//PUBLIC METHODS.

_global.HTMLBox.prototype.setEnabled = function(inDialogEnabled) {
	super.setEnabled(inDialogEnabled);
	this.btnOK.setEnabled(inDialogEnabled);
};

_global.HTMLBox.prototype.show = function() {
	this.isCanceled = false;

	this.btnOK.setClickHandler('processOKButton', this);
	this.setHTMLText(this.htmlText);
	Key.addListener(this);
	this._visible = true;
};

_global.HTMLBox.prototype.setHTMLText = function(inHTMLText) {
	this.htmlText = inHTMLText;
	if (this.style != null) {
		//convert int color to hex string.
		var numColor = new Number(this.style.bodyText);
		var strColor = numColor.toString(16);
		while (strColor.length < 6) {
			strColor = '0' + strColor;
		}
		this.txtMain.htmlText = '<font color="#' + strColor + '">' + this.htmlText + '</font>';
	} else {
		this.txtMain.htmlText = this.htmlText;
	}
	this.txtMain.scroll = 1;
};

_global.HTMLBox.prototype.canceled = function() {
	return this.isCanceled;
};

_global.HTMLBox.prototype.initialized = function() {
	return (super.initialized() && (this.btnOK.setEnabled != null));
};

_global.HTMLBox.prototype.applyTextProperty = function(propName, val)
{
	setTextProperty(propName, val, this.txtMain, true);
}

_global.HTMLBox.prototype.applyStyle = function(inStyle) {
	super.applyStyle(inStyle);
	this.txtMain.borderColor = inStyle.borderColor;
	this.setHTMLText(this.htmlText);
	var c = new Color(this.txtMainBackground);
	c.setRGB(inStyle.inputBoxBackground);
	this.txtMainBackground._alpha = inStyle.uiAlpha;
};

_global.HTMLBox.prototype.applyLanguage = function(inLanguage) {
	this.btnOK.setLabel(inLanguage.dialog.common.okBtn);
};

//PRIVATE METHODS.

_global.HTMLBox.prototype.onKeyDown = function() {
	if(this.handlerObj.isSpecialLanguage())
	{ 
		if(Key.isDown(Key.CONTROL) && Key.isDown(Key.ENTER))
		{ 
			this.processOKButton();
		}
	}
	else if (Key.isDown(Key.ENTER))
	{
		this.processOKButton();
	}
	
	if (Key.isDown(Key.ESCAPE)) {
		this.onClose();
	}
};

_global.HTMLBox.prototype.onClose = function() {
	this.isCanceled = true;
	this._visible = false;
	Key.removeListener(this);
	this.handlerObj[this.handlerFunctionName](this);
};

_global.HTMLBox.prototype.processOKButton = function() {
	this._visible = false;
	Key.removeListener(this);
	this.handlerObj[this.handlerFunctionName](this);
};

Object.registerClass('HTMLBox', _global.HTMLBox);

#endinitclip
