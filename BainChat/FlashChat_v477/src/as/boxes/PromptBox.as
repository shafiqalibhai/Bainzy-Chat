#initclip 10

_global.PromptBox = function() {
	super();
	
	this.dialog_name = '';
	
	this.isCanceled = false;
	this._visible = false;
	this.validateRightButton = false;
	
	this.txtLabelText.autoSize = 'left';
	this.txtInputText.password = false;
	
	var fmt = this.txtLabelText.getTextFormat();
	fmt.align = 'left';
	this.txtLabelText.setNewTextFormat(fmt);
	this.txtInputText.onChanged = function() {
		this._parent.textValidator();
	};
	this.txtInputText.background = false;
	this.txtInputText.onSetFocus = function() {
		this.borderColor = this._style.bodyText;
	};
	this.txtInputText.onKillFocus = function() {
		this.borderColor = this._style.borderColor;
	};

	this.leftButtonLabel = null;
	this.rightButtonLabel = null;
	
	super.setResizable(true);
};

_global.PromptBox.prototype = new DialogBox();

_global.PromptBox.prototype.SPACER = 15;

//PUBLIC METHODS.
_global.PromptBox.prototype.getSize = function( isPreff ) {
	var dimensions = new Object();
	dimensions.width = (isPreff)? 0 : this.preff_size.width;
	dimensions.height = (isPreff)? 0 : this.preff_size.height;
	return dimensions;
};

_global.PromptBox.prototype.setResizable = function(inDialogResizable) {
	super.setResizable(inDialogResizable);
	this.txtInputText.multiline = inDialogResizable;
	this.txtInputText.wrap = inDialogResizable;
};

_global.PromptBox.prototype.setEnabled = function(inDialogEnabled) {
	super.setEnabled(inDialogEnabled);
	this.btnLeft.setEnabled(inDialogEnabled);
	this.btnRight.setEnabled(inDialogEnabled);
};

_global.PromptBox.prototype.show = function() {
	this.isCanceled = false;

	this.btnLeft.setClickHandler('processLeftButton', this);
	this.btnRight.setClickHandler('processRightButton', this);
	this.btnLeft.setLabel(this.leftButtonLabel);
	this.btnRight.setLabel(this.rightButtonLabel);
	this.txtInputText.text = '';
	this.textValidator();
	Key.addListener(this);
	this._visible = true;
	Selection.setFocus(this.txtInputText);
};

_global.PromptBox.prototype.canceled = function() {
	return this.isCanceled;
};

_global.PromptBox.prototype.setLabelText = function(inText) {
	this.txtLabelText.htmlText = replaceHTMLSpecChars(inText);
	this.setSize(0, 0);
};

_global.PromptBox.prototype.setLabelTextVisible = function(inLabelTextVisible) {
	this.txtLabelText._visible = inLabelTextVisible;
	this.setSize(0, 0);
};

_global.PromptBox.prototype.setInputTextVisible = function(inInputTextVisible) {
	this.txtInputText._visible = inInputTextVisible;
	this.txtInputTextBackground._visible = inInputTextVisible;
	this.setSize(0, 0);
	this.textValidator();
};

_global.PromptBox.prototype.setRightButtonVisible = function(inRightButtonVisible) {
	this.btnRight._visible = inRightButtonVisible;
	this.setSize(0, 0);
}

_global.PromptBox.prototype.setValidateRightButton = function(inValidateRightButton) {
	this.validateRightButton = inValidateRightButton;
};

_global.PromptBox.prototype.setLeftButtonLabel = function(inLeftButtonLabel) {
	this.leftButtonLabel = inLeftButtonLabel;
	this.btnLeft.setLabel(this.leftButtonLabel);
};

_global.PromptBox.prototype.setRightButtonLabel = function(inRightButtonLabel) {
	this.rightButtonLabel = inRightButtonLabel;
	this.btnRight.setLabel(this.rightButtonLabel);
};

_global.PromptBox.prototype.getEnteredText = function() {
	return this.txtInputText.text;
};

_global.PromptBox.prototype.initialized = function() {
	return (super.initialized() && (this.btnLeft.setEnabled != null) && (this.btnRight.setEnabled != null));
};

_global.PromptBox.prototype.applyTextProperty = function(propName, val)
{
	setTextProperty(propName, val, this.txtLabelText);
	setTextProperty(propName, val, this.txtInputText, true);
	
	this.setSize(0, 0);
}

_global.PromptBox.prototype.applyStyle = function(inStyle) {
	super.applyStyle(inStyle);
	this.txtLabelText.textColor = inStyle.bodyText;
	this.txtInputText.textColor = inStyle.buttonText;
	this.txtInputText._style = inStyle;
	this.txtInputText.borderColor = inStyle.borderColor;
	this.txtInputText.border = true;
	var c = new Color(this.txtInputTextBackground);
	c.setRGB(inStyle.inputBoxBackground);
	this.txtInputTextBackground._alpha = inStyle.uiAlpha;
};

_global.PromptBox.prototype.setSize = function(inWidth, inHeight) 
{	
	//find minimum allowable width and height depending on components visibility.
	var  minWidth = 2 * this.SPACER + this.btnLeft._width;
	var minHeight = 2 * this.SPACER + this.btnLeft._height + this.dbTop._height;
	
	if (this.btnRight._visible) {
		minWidth += this.btnRight._width + this.SPACER;
	}
	if (this.txtLabelText._visible) {
		var txt_width = 0;
		if(this.dialog_name == 'ignorebox')
		{
			var dim = testText(this.txtLabelText, this.txtLabelText.text);
			txt_width = dim.width;
		}
		else txt_width = this.txtLabelText.textWidth;
		
		minWidth = Math.max(minWidth, 2 * this.SPACER + txt_width);
		minHeight += this.SPACER + this.txtLabelText._height;
	}
	
	if (this.txtInputText._visible) {
		//assuming minimum input text height is 2 x spacer.
		minHeight += this.txtInputText.textHeight + 2 + 1 * this.SPACER;
		
	}
	
	var lines = this.txtLabelText.bottomScroll - this.txtLabelText.scroll + this.txtLabelText.maxscroll;
	if(
		this.txtLabelText._visible && !this.btnRight._visible && !this.txtInputText._visible &&
		this.txtLabelText.textWidth != 0 && lines  == 1 
	  )
	{
		minWidth = Math.max(3 * this.SPACER + this.txtLabelText.textWidth, 380);
		
		var fmt = this.txtLabelText.getTextFormat();
		fmt.align = 'center';
		this.txtLabelText.setTextFormat(fmt);
	}
	else
	{ 
		if(this.dialog_name != 'ignorebox' || (inWidth+inHeight) == 0) minWidth = Math.max(minWidth, 380);
		
		var fmt = this.txtLabelText.getTextFormat();
		fmt.align = 'left';
		this.txtLabelText.setTextFormat(fmt);
	}
	
	//if this dialog is resizable, just check if width/height are greater than minimum values.
	//otherwise, ignore arguments and use minimum values as effective dialog size.
	if (this.resizable) {
		if (inWidth < minWidth) {
			inWidth = minWidth;
		}
		if (inHeight < minHeight) {
			inHeight = minHeight;
		}
	} else {
		inWidth = minWidth;
		inHeight = minHeight;
	}
	super.setSize(inWidth, inHeight);
	
	this.preff_size.width  = minWidth;
	this.preff_size.height = minHeight;
	
	var currY = this.dbTop._height + this.SPACER;
	
	if (this.txtLabelText._visible) {
		this.txtLabelText._x = this.SPACER;
		this.txtLabelText._y = currY;
		this.txtLabelText._width = inWidth - 2 * this.SPACER;
		currY = this.txtLabelText._y + this.txtLabelText._height + this.SPACER;
	}

	if (this.txtInputText._visible) {
		this.txtInputText._x = this.SPACER;
		this.txtInputText._y = currY;
		
		this.txtInputText._width = inWidth - 2 * this.SPACER;
		this.txtInputTextBackground._x = this.txtInputText._x;
		this.txtInputTextBackground._y = this.txtInputText._y;
		this.txtInputTextBackground._width = this.txtInputText._width;
	}

	if (this.btnRight._visible) {
		this.btnLeft._x = inWidth / 2 - this.btnLeft._width - this.SPACER / 2;
		this.btnRight._x = inWidth / 2 + this.SPACER / 2;
	} else {
		this.btnLeft._x = inWidth / 2 - this.btnLeft._width / 2;
	}
	this.btnLeft._y = inHeight - this.btnLeft._height - this.SPACER;
	this.btnRight._y = this.btnLeft._y;

	if (this.txtInputText._visible) {
		this.txtInputText._height = Math.max(this.txtInputText.textHeight+2, this.btnLeft._y - this.txtInputText._y - this.SPACER);
		this.txtInputTextBackground._height = this.txtInputText._height;
	}
};

//PRIVATE METHODS.

_global.PromptBox.prototype.onKeyDown = function() {
	if (!Key.isDown(Key.SHIFT) && this.btnLeft.getEnabled())
	{
		if(this.handlerObj.isSpecialLanguage())
		{ 
			if(Key.isDown(Key.CONTROL) && Key.isDown(Key.ENTER))
			{ 
				this.processLeftButton();
			}
		}
		else	if(Key.isDown(Key.ENTER))
				this.processLeftButton();
	}
	if (Key.isDown(Key.ESCAPE) && this.btnRight._visible && this.btnRight.getEnabled()) {
		this.processRightButton();
	}
};

_global.PromptBox.prototype.onClose = function() {
	this.processRightButton();
};

_global.PromptBox.prototype.processLeftButton = function() {
	this._visible = false;
	Key.removeListener(this);
	this.handlerObj[this.handlerFunctionName](this);
};

_global.PromptBox.prototype.processRightButton = function() {
	this.isCanceled = true;
	this._visible = false;
	Key.removeListener(this);
	this.handlerObj[this.handlerFunctionName](this);
};

_global.PromptBox.prototype.textValidator = function() {
	/*
	var buttonsEnabled = (this.txtInputText.text.length > 0) || !this.txtInputText._visible;
	this.btnLeft.setEnabled(buttonsEnabled);
	if (this.validateRightButton) {
		this.btnRight.setEnabled(buttonsEnabled);
	} else {
		this.btnRight.setEnabled(true);
	}
	*/
};

Object.registerClass('PromptBox', _global.PromptBox);

#endinitclip
