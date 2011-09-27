#initclip 10

_global.PrivateMessageBox = function() {
	super();
	
	this.setResizable(true);
	this.txtMain.background = false;
	this.user = null;
	this.message = null;
	//set to true in order to clear text field after submitting it on enter key.
	this.clearText = false;
	this.isCanceled = false;
	this.action = null;
	this.state  = null;
	this.minButtonVisible = true;
	this._visible = false;

	this.attachMovie('SmileText', 'log', 10);
	trace('PrivateMessageBox: CTOR: this.log: ' + this.log);
	this.log._x = 10;
	this.log._y = 50;
	
	
	this.log.setSize(270, 90);
		
	this.attachMovie('Image', 'photo', 11);
	trace('PrivateMessageBox: CTOR: this.photo: ' + this.photo);
	this.photo.setHandler('imageLoaded', this);
		
	this.toUserLabel.autoSize = 'left';
	this.txtMain.onChanged = function() {
		this._parent.textValidator();
	};
	this.txtMain.onSetFocus = function() {
		this.borderColor = this._style.bodyText;
	};
	this.txtMain.onKillFocus = function() {
		this.borderColor = this._style.borderColor;
	};
	
	this.setMouseUpHandler('processMouseUpHandler', this);
	
	var size = this.getSize();
	this.setSize(size.width, size.height);
};

_global.PrivateMessageBox.prototype = new DialogBox();

//PUBLIC METHODS.
_global.PrivateMessageBox.prototype.processMouseUpHandler = function() {
	//Selection.setFocus(this.txtMain);
};

_global.PrivateMessageBox.prototype.setMinButtonEnabled = function(inEnabled) {
	this.dbMinTopRight.trBtn.btnMin.setEnabled(inEnabled);
};

_global.PrivateMessageBox.prototype.initializeDialog = function() {
	super.initializeDialog();
	this.dbMinTopRight.trBtn.btnMin.setClickHandler('onMinimize', this);
};

_global.PrivateMessageBox.prototype.setUser = function(inUser) {
	this.user = inUser;
	this.setPhoto();
};

_global.PrivateMessageBox.prototype.setPhoto = function(){
	var imageURL = this.user.getPortrait();
	if(imageURL == '')
	{
		imageURL = this.user.getFCPortrait();
	}	
		
	var filterURL = filterImgUrl(imageURL)+'?t='+getTimer();
	
	//_global.FlashChatNS.chatUI.mc.msgTxt.htmlText += filterURL + '<br>';

	if(imageURL != '')
	{
		this.photo.removeMovieClip();
		this.attachMovie('Image', 'photo', 11);
		this.photo.setHandler('imageLoaded', this);
		
		this.photo.loadImage(filterURL, true);
		
		
		
		
		this.photo.uid = this.user.id;
		this.photo.onRelease = function()
		{
			_global.FlashChatNS.chatUI.listener.requestUserProfileText(this.uid);	
		}
	}
	else if(this.photo.loaded)
	{
		this.photo.clear();
		var size = this.getSize();
		this.setSize(size.width, size.height);	
	}	
};

_global.PrivateMessageBox.prototype.getUser = function() {
	return this.user;
};

_global.PrivateMessageBox.prototype.getMessage = function() {
	return this.message;
};

_global.PrivateMessageBox.prototype.addMessage = function(inLabel, inMessage, inColor, inSender) {
	this.log.addText(inLabel, inMessage, inColor, inSender);
};

_global.PrivateMessageBox.prototype.getFocusTarget = function() {
	return this.txtMain;
};

_global.PrivateMessageBox.prototype.setEnabled = function(inDialogEnabled) {
	super.setEnabled(inDialogEnabled);
	this.setMinButtonEnabled(inDialogEnabled);
	this.btnSend.setEnabled(inDialogEnabled);
	this.txtMain.type = inDialogEnabled ? 'input' : 'dynamic';
	super.setDraggable(inDialogEnabled);
};

_global.PrivateMessageBox.prototype.setSettings = function(inSettings) {
	this.settings = inSettings;
	
	this.txtMain.maxChars = (this.settings.maxMessageSize);
	this.log.setShowSmilies(this.settings.layout.toolbar.smilies != 0);
	this.log.setColored(this.settings.user.userColor, !this.settings.user.text.itemToChange.myTextColor, true);
	
	if (this.settings.layout.showPrivateLog) {
		this.log._visible = false;
		this.log.setEnabled(false);
	} else {
		this.log._visible = true;
		this.log.setEnabled(true);
	}
	this.log.setPatternFilter(this.settings.smiles);
	this.log.setMaxMessageCount(this.settings.maxMessageCount);

	var size = this.getSize();
	this.setSize(size.width, size.height);
};

/*
_global.PrivateMessageBox.prototype.setTextColor = function(inTextColor) {
	//ignore this call. input text color does not depend on user color now.
	//this.txtMain.textColor = inTextColor;
};
*/

_global.PrivateMessageBox.prototype.show = function() {
	this.isCanceled = false;
	
	this.btnSend.setClickHandler('processSendButton', this);

	//position input text background.
	this.txtMainBackground._x = this.txtMain._x;
	this.txtMainBackground._y = this.txtMain._y;
	this.txtMainBackground._width = this.txtMain._width;
	this.txtMainBackground._height = this.txtMain._height;
	
	this.textValidator();
	
	var sel = Selection.getFocus();
	if(sel.indexOf('msgTxt') < 0) Selection.setFocus(this.txtMain);
	
	Key.addListener(this);
	Selection.setFocus(this.txtMain);
	
	this._visible = true;
};

_global.PrivateMessageBox.prototype.canceled = function() {
	return this.isCanceled;
};

_global.PrivateMessageBox.prototype.initialized = function() {
	return (super.initialized() && (this.btnSend.setEnabled != null));
};

_global.PrivateMessageBox.prototype.applyTextProperty = function(propName, val, targetObj)
{
	//trace('Name ' + propName + ' val ' + val + ' obj ' + targetObj);
	if(targetObj == 'interfaceElements')
	{ 
		setTextProperty(propName, val, this.toUserLabel, true);
		setTextProperty(propName, val, this.txtMain, true);
	}else if(targetObj == 'mainChat')
	{ 
		setTextProperty(propName, val, this.log.smile_txt, true);
		this.log.setFont(val, propName);
	}
	
	var size = this.getSize();
	this.setSize(size.width, size.height);
}

_global.PrivateMessageBox.prototype.applyStyle = function(inStyle) {
	super.applyStyle(inStyle);
	this.toUserLabel.textColor = inStyle.bodyText;
	
	//input text color does not depend on user color now.
	this.txtMain.textColor = inStyle.buttonText;
	this.txtMain._style = inStyle;
	this.txtMain.borderColor = inStyle.borderColor;
	this.txtMain.border = true;
	c = new Color(this.txtMainBackground);
	c.setRGB(inStyle.inputBoxBackground);
	this.log.setBackgroundColor(inStyle.privateLogBackground, inStyle.uiAlpha);
	this.log.setBorderColor(inStyle.borderColor);
	this.applyBackground(inStyle);
};

_global.PrivateMessageBox.prototype.applyBackground = function(inStyle) {
	super.applyBackground(inStyle);
	this.txtMainBackground._alpha = inStyle.uiAlpha;
	this.log.setBackgroundColor(inStyle.privateLogBackground, inStyle.uiAlpha);
};

_global.PrivateMessageBox.prototype.applyLanguage = function(inLanguage) {
	this.btnSend.setLabel(inLanguage.dialog.privateBox.sendBtn);
	this.toUserLabel.text = this.replace(inLanguage.dialog.privateBox.toUser, 'USER_LABEL', this.user.label);
	
	var dim = testText(this.toUserLabel, this.toUserLabel.text);
	this.log.setMinWidth(dim.width);
};

_global.PrivateMessageBox.prototype.setSize = function(inWidth, inHeight) {
	if (this.settings == null) {
		return;
	}
	
	var left_indent = this.toUserLabel._x;
	var top_indent  = this.toUserLabel._y;
	
	var dim1 = testText(this.toUserLabel, this.toUserLabel.text);
	var val = 2*left_indent + dim1.width;
	
	var image_w   = 0;
	var image_h   = 0;
	var max_img_w = 0;
	var max_img_h = 0;
	
	if(this.photo.loaded)
	{
		max_img_w = 150;
		max_img_h = 150;
		
		var diff = 5 + dim1.height + 15 + this.btnSend._height;
		var log_h = inHeight - (top_indent + dim1.height + diff);
		var h = log_h + dim1.height + 5;
		
		if(this.photo.w2h > 1)
		{
			var w = max_img_w;
			if(this.photo.image_mc._width < max_img_w)
			{
				w = this.photo.image_mc._width;
			}
		
			this.photo.image_mc._width  = w;
			this.photo.image_mc._height = 1/this.photo.w2h * w;	
		}
		else if(this.photo.w2h <= 1)
		{
			var h = max_img_h;
			if(this.photo.image_mc._height < max_img_h)
			{
				h = this.photo.image_mc._height;
			}
		
			this.photo.image_mc._width  = this.photo.w2h * h;
			this.photo.image_mc._height = h;
		}
			
		image_w = this.photo.image_mc._width + left_indent;
		image_h = this.photo.image_mc._height;
		
		if((val - image_w) < 230)
		{
			val = image_w + 230;
		}
	}
	
	if (inWidth < val) {
		inWidth = val;
	}
	
	var val1 = val;
	
	if (!this.settings.layout.showPrivateLog) {
		var dim2 = testText(this.log.smile_txt, 'l');
		
		this.log._x = left_indent;
		this.log._y = top_indent + dim1.height;
		
		var diff = 5 + dim1.height + 15 + this.btnSend._height;
		var log_or_photo = Math.max(2*dim2.height, image_h - (5 + dim1.height));
		val = this.log._y + log_or_photo + diff;
			
		if (inHeight < val) {
			inHeight = val;
		}
		
		var log_h = inHeight - (this.log._y + diff);
		this.log.setSize(inWidth - 2*left_indent - image_w, log_h);
		
		this.txtMain._height = dim1.height;
		this.txtMain._y = this.log._y + this.log._height + 5;
		
		this.photo._x = this.log._x + this.log._width + left_indent;
		this.photo._y = this.log._y;
	} else {
		
		this.txtMain._y = top_indent + dim1.height;
		
		var diff = this.btnSend._height + 15;
		val = this.txtMain._y + dim1.height + diff;
		
		if (inHeight < val) {
			inHeight = val;
		}
		
		this.txtMain._height = inHeight - (this.txtMain._y + diff);
	}
	
	this.btnSend._x = (inWidth - this.btnSend._width) / 2;
	this.btnSend._y = inHeight - 30;
	
	
	
	this.txtMain._x = left_indent;
	this.txtMain._width = inWidth - 2*left_indent - image_w;
	this.txtMainBackground._x = this.txtMain._x;
	this.txtMainBackground._y = this.txtMain._y;
	this.txtMainBackground._width = this.txtMain._width;
	this.txtMainBackground._height = this.txtMain._height;
	
	this.photo._x = this.txtMain._x + this.txtMain._width + 5;
	this.photo._y = this.log._y;

	
	super.setSize(inWidth, inHeight);
	
	this.preff_size.width  = val1;
	this.preff_size.height = val;
};

//PRIVATE METHODS.
_global.PrivateMessageBox.prototype.onKeyDown = function() {
	if (Selection.getFocus() == ''+ this.txtMain) {
		if (!Key.isDown(Key.SHIFT) && this.btnSend.getEnabled()) {
			
			if(this.handlerObj.privateBoxHandlerObj.isSpecialLanguage())
			{ 
				if(Key.isDown(Key.CONTROL) && Key.isDown(Key.ENTER))
				{ 
					this.processSendButton();
					this.clearText = true;
				}
			}
			else if(Key.isDown(Key.ENTER))
			{ 
				this.processSendButton();
				this.clearText = true;
			}
		} else if (Key.isDown(Key.ESCAPE)) {
			this.onClose();
		}
	}
};

_global.PrivateMessageBox.prototype.onClose = function() {
	this.isCanceled = true;
	this.action = 'close';
	this._visible = false;
	Key.removeListener(this);
	this.handlerObj[this.handlerFunctionName](this);
};

_global.PrivateMessageBox.prototype.onMinimize = function() {
	this.isCanceled = false;
	this.action = 'minimize';
	this._visible = false;
	Key.removeListener(this);
	this.handlerObj[this.handlerFunctionName](this);
};

_global.PrivateMessageBox.prototype.processSendButton = function() {
	if(this.txtMain.text.trim().length != 0)
	{ 
		this.message = this.txtMain.text;
		this.txtMain.text = '';
		this.handlerObj[this.handlerFunctionName](this);
	}
	else 	
	{ 
		this.txtMain.text = '';
		this.btnSend.setEnabled(this.handlerObj.privateBoxHandlerObj.isSpecialLanguage());
	}
	
	Selection.setFocus(this.txtMain);
};

_global.PrivateMessageBox.prototype.textValidator = function() {
	var is_sp = this.handlerObj.privateBoxHandlerObj.isSpecialLanguage();
	this.btnSend.setEnabled((this.getEnabled() && (this.txtMain.text.length > 0)) || is_sp);
	if (this.clearText) {
		this.txtMain.text = '';
		this.btnSend.setEnabled(is_sp);
		this.clearText = false;
	}
};

//avu: this method is copied from ChatUI. should be in one place...
_global.PrivateMessageBox.prototype.replace = function(inStr, inSearchStr, inReplaceStr) {
	var tokenList = inStr.split(inSearchStr);
	var res = '';
	for (var i = 0; i < tokenList.length - 1; i ++) {
		res += tokenList[i] + inReplaceStr;
	}
	res += tokenList[tokenList.length - 1];
	return res;
};

_global.PrivateMessageBox.prototype.imageLoaded = function()
{
	if(this.photo.image_mc.error)
	{
		this.photo.clear();
	}
		
	this.photo.w2h = this.photo.image_mc._width / this.photo.image_mc._height;
	
	var size = this.getSize();
	this.setSize(size.width, size.height);
};

Object.registerClass('PrivateMessageBox', _global.PrivateMessageBox);

#endinitclip
