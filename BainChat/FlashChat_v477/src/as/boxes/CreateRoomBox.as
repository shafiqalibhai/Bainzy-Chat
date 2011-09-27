#initclip 10

_global.CreateRoomBox = function() {
	super();
	
	this.isCanceled = false;
	this._visible = false;
	
	this.initialDimensions = super.getSize();
	
	this.txtInputPass.password = true;
	this.txtInputPass.background = this.txtInputText.background = false;
	
	this.txtInputText.onChanged = function() {
		this._parent.textValidator();
	};
	this.txtInputPass.onSetFocus = this.txtInputText.onSetFocus = function() {
		this.borderColor = this._style.bodyText;
	};
	this.txtInputPass.onKillFocus = this.txtInputText.onKillFocus = function() {
		this.borderColor = this._style.borderColor;
	};
};

_global.CreateRoomBox.prototype = new DialogBox();

//PUBLIC METHODS.

_global.CreateRoomBox.prototype.setEnabled = function(inDialogEnabled) {
	super.setEnabled(inDialogEnabled);
	this.textValidator();
	this.roomTypePublic.setEnabled(inDialogEnabled);
	this.roomTypePrivate.setEnabled(inDialogEnabled);
};

_global.CreateRoomBox.prototype.show = function() {
	this.isCanceled = false;

	this.btnCreate.setClickHandler('processCreateButton', this);
	this.txtInputText.text = '';
	this.txtInputPass.text = '';
	this.roomTypePublic.setState(true);
	this.textValidator();
	Key.addListener(this);
	this._visible = true;
	Selection.setFocus(this.txtInputText);
};

_global.CreateRoomBox.prototype.canceled = function() {
	return this.isCanceled;
};

_global.CreateRoomBox.prototype.getEnteredText = function() {
	return this.txtInputText.text;
};

_global.CreateRoomBox.prototype.getEnteredPass = function() {
	return this.txtInputPass.text;
};

_global.CreateRoomBox.prototype.isPublic = function() {
	return this.roomTypePublic.getState();
};

_global.CreateRoomBox.prototype.initialized = function() {
	return (super.initialized() && (this.btnCreate.setEnabled != null));
};

_global.CreateRoomBox.prototype.setSize = function(inWidth, inHeight) {
	//if this dialog is not initialized yet - simply call parent method and return.
	if (this.initialDimensions == null) {
		super.setSize(inWidth, inHeight);
		return;
	}
	//check if new size is not smaller than initial dialog dimensions.
	if (inWidth < this.initialDimensions.width) {
		inWidth = this.initialDimensions.width;
	}
	if (inHeight < this.initialDimensions.height) {
		inHeight = this.initialDimensions.height;
	}
	
	var dim = testText(this.lblRoomPass, this.lblRoomPass.text);
	var lines = this.lblRoomPass.bottomScroll - this.lblRoomPass.scroll + this.lblRoomPass.maxscroll;
	var dh = dim.height * lines - 38;
		
	this.txtInputText.text = 'l';
	this.txtInputPass._height = this.txtInputText._height = this.txtInputText.textHeight + 2;
	this.txtInputPassBackground._height = this.txtInputTextBackground._height = this.txtInputText._height;
	this.txtInputText.text = '';
	
	var dim1 = testText(this.roomTypePublic.fLabel_mc.labelField, this.roomTypePublic.getLabel());
	var dim2 = testText(this.roomTypePrivate.fLabel_mc.labelField, this.roomTypePrivate.getLabel());
	var w1 = this.roomTypePublic.fLabel_mc._x + dim1.width;
	var w2 = this.roomTypePrivate.fLabel_mc._x + dim2.width;  

	this.roomTypePublic._x = (inWidth - w1 - w2) / 3;
	this.roomTypePrivate._x = 2*this.roomTypePublic._x + w1;
	
	this.txtInputPass._y = this.txtInputPassBackground._y = 150 + dh;
	this.btnCreate._y = 180 + dh;
	
	super.setSize(inWidth, this.btnCreate._y + this.btnCreate._height + 10);
	
	this.preff_size.width  = this.initialDimensions.width;
	this.preff_size.height = this.initialDimensions.height;
};


_global.CreateRoomBox.prototype.applyTextProperty = function(propName, val)
{
	setTextProperty(propName, val, this.lblTop);
	setTextProperty(propName, val, this.lblRoomPass);
	setTextProperty(propName, val, this.txtInputPass, true);
	setTextProperty(propName, val, this.txtInputText, true);
	
	this.setSize(0, 0);
}

_global.CreateRoomBox.prototype.applyStyle = function(inStyle) {
	super.applyStyle(inStyle);
	this.roomTypePublic.setStyleProperty('background', 0xffffff);
	this.roomTypePublic.setStyleProperty('face', 0x000000);
	this.roomTypePublic.setStyleProperty('textColor', inStyle.bodyText, false);
	
	this.roomTypePrivate.setStyleProperty('background', 0xffffff);
	this.roomTypePrivate.setStyleProperty('face', 0x000000);
	this.roomTypePrivate.setStyleProperty('textColor', inStyle.bodyText, false);
	
	this.lblTop.textColor = inStyle.bodyText;
	this.lblRoomPass.textColor = inStyle.bodyText;
	
	this.txtInputText.textColor = inStyle.buttonText;
	this.txtInputText._style = inStyle;
	this.txtInputText.borderColor = inStyle.borderColor;
	this.txtInputText.border = true;
	c = new Color(this.txtInputTextBackground);
	c.setRGB(inStyle.inputBoxBackground);
	this.txtInputTextBackground._alpha = inStyle.uiAlpha;
	
	this.txtInputPass.textColor = inStyle.buttonText;
	this.txtInputPass._style = inStyle;
	this.txtInputPass.borderColor = inStyle.borderColor;
	this.txtInputPass.border = true;
	c = new Color(this.txtInputPassBackground);
	c.setRGB(inStyle.inputBoxBackground);
	this.txtInputPassBackground._alpha = inStyle.uiAlpha;
};

_global.CreateRoomBox.prototype.applyLanguage = function(inLanguage) {
	this.lblTop.text = inLanguage.dialog.createroom.entername;
	this.lblRoomPass.text = inLanguage.dialog.createroom.enterpass;
	this.roomTypePublic.setLabel(inLanguage.dialog.createroom["public"]);
	this.roomTypePrivate.setLabel(inLanguage.dialog.createroom["private"]);
	this.btnCreate.setLabel(inLanguage.dialog.createroom.createBtn);
};

//PRIVATE METHODS.

_global.CreateRoomBox.prototype.onKeyDown = function() {
	if (this.btnCreate.getEnabled()) {
		if(this.handlerObj.isSpecialLanguage())
		{ 
			if(Key.isDown(Key.CONTROL) && Key.isDown(Key.ENTER))
			{ 
				this.processCreateButton();
			}
		}
		else if(Key.isDown(Key.ENTER))
				this.processCreateButton();
	}
	if (Key.isDown(Key.ESCAPE)) {
		this.onClose();
	}
};

_global.CreateRoomBox.prototype.onClose = function() {
	this.isCanceled = true;
	this._visible = false;
	Key.removeListener(this);
	this.handlerObj[this.handlerFunctionName](this);
};

_global.CreateRoomBox.prototype.processCreateButton = function() {
	var str = this.txtInputText.text.trim();
	if(str.length != 0)
	{ 
		this._visible = false;
		Key.removeListener(this);
		this.handlerObj[this.handlerFunctionName](this);
	}
};

_global.CreateRoomBox.prototype.textValidator = function() {
	this.btnCreate.setEnabled(this.getEnabled() && (this.txtInputText.text.length > 0));
};

Object.registerClass('CreateRoomBox', _global.CreateRoomBox);

#endinitclip
