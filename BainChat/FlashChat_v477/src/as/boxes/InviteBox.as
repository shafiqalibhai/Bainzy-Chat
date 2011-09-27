#initclip 10

_global.InviteBox = function() {
	super();

	this.setResizable(true);
	this.isCanceled = false;
	this._visible = false;

	this.lblInclude.autoSize = 'left';

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

	this.roomList = null;
	this.selectedRoom = null;

	this.initialDimensions = super.getSize();
	this.initialTFWidth = this.txtInputText._width;
	this.initialTFHeight = this.txtInputText._height;
	this.initialBTN1X = this.btnSend._x;
	this.initialBTN2X = this.btnCancel._x;
	this.initialBTNY = this.btnSend._y;
};

_global.InviteBox.prototype = new _global.DialogBox();

//PUBLIC METHODS.

_global.InviteBox.prototype.setEnabled = function(inDialogEnabled) {
	super.setEnabled(inDialogEnabled);
	this.btnSend.setEnabled(inDialogEnabled);
	this.btnCancel.setEnabled(inDialogEnabled);
	this.roomChooser.setEnabled(inDialogEnabled);
};

_global.InviteBox.prototype.setRoomList = function(inRoomList) {
	this.roomList = inRoomList;
	this.roomChooser.removeAll();
	for (var i = 0; i < inRoomList.length; i ++) {
		this.roomChooser.addItem(inRoomList[i].label, inRoomList[i]);
	}
};

_global.InviteBox.prototype.setSelectedRoom = function(inSelectedRoom) {
	this.selectedRoom = inSelectedRoom;
	for (var i = 0; i < this.roomChooser.getLength(); i ++) {
		if (this.roomChooser.getItemAt(i).data.id == inSelectedRoom.id) {
			this.roomChooser.setSelectedIndex(i);
			return;
		}
	}
};

_global.InviteBox.prototype.getSelectedRoom = function() {
	return this.roomChooser.getSelectedItem().data;
};

_global.InviteBox.prototype.getEnteredText = function() {
	return this.txtInputText.text;
};

_global.InviteBox.prototype.show = function() {
	this.isCanceled = false;

	this.btnSend.setClickHandler('processSendButton', this);
	this.btnCancel.setClickHandler('processCancelButton', this);
	this.setRoomList(this.roomList);
	this.setSelectedRoom(this.selectedRoom);
	this.txtInputText.text = '';
	this.textValidator();
	Key.addListener(this);
	this._visible = true;
	Selection.setFocus(this.txtInputText);
};

_global.InviteBox.prototype.canceled = function() {
	return this.isCanceled;
};

_global.InviteBox.prototype.initialized = function() {
	return (super.initialized() && (this.btnSend.setEnabled != null));
};

_global.InviteBox.prototype.applyTextProperty = function(propName, val)
{
	setTextProperty(propName, val, this.lblTopLeft);
	setTextProperty(propName, val, this.lblInclude);
	setTextProperty(propName, val, this.txtInputText, true);
	
	var dim = this.getSize();
	this.setSize(dim.width, dim.height);
}

_global.InviteBox.prototype.applyStyle = function(inStyle) {
	super.applyStyle(inStyle);
	this.lblTopLeft.textColor = inStyle.bodyText;
	this.lblInclude.textColor = inStyle.bodyText;
	this.txtInputText.textColor = inStyle.buttonText;
	this.txtInputText._style = inStyle;
	this.txtInputText.borderColor = inStyle.borderColor;
	this.txtInputText.border = true;
	var c = new Color(this.txtInputTextBackground);
	c.setRGB(inStyle.inputBoxBackground);
	this.txtInputTextBackground._alpha = inStyle.uiAlpha;
};

_global.InviteBox.prototype.applyLanguage = function(inLanguage) {
	this.lblTopLeft.text = inLanguage.dialog.invite.inviteto;
	this.lblInclude.text = inLanguage.dialog.invite.includemessage;
	this.btnSend.setLabel(inLanguage.dialog.invite.sendBtn);
	this.btnCancel.setLabel(inLanguage.dialog.common.cancelBtn);
};

_global.InviteBox.prototype.setSize = function(inWidth, inHeight) {
	//if this dialog is not initialized yet - simply call parent method and return.
	/*
	if (this.initialDimensions == null) {
		super.setSize(inWidth, inHeight);
		return;
	}
	*/
	
	//check if new size is not smaller than initial dialog dimensions.
	
	this.txtInputText.text = (this.txtInputText.text == '')? 'l' : this.txtInputText.text;
	var preferedHeight =  this.txtInputText._y + this.txtInputText.textHeight + this.btnSend._height + 18;
	this.initialTFHeight = this.txtInputText.textHeight + 2;
	this.initialBTNY = preferedHeight - 30;
	this.txtInputText.text = (this.txtInputText.text == 'l')? '' : this.txtInputText.text;
	
	var preferedWidth = this.roomChooser._x + this.roomChooser._width + this.txtInputText._x;
	var dim = testText(this.lblInclude, this.lblInclude.text);
	if(preferedWidth < (2*this.lblInclude._x + dim.width))
	{
		preferedWidth = 2*this.lblInclude._x + dim.width;
		this.initialTFWidth = dim.width;
	}
	else
	{
		this.initialTFWidth = this.roomChooser._x + this.roomChooser._width - this.txtInputText._x;	
	}
		
	var diff = this.initialBTN2X - this.initialBTN1X;  
	this.initialBTN1X = (preferedWidth - this.btnCancel._width - diff) / 2;
	this.initialBTN2X = this.initialBTN1X + diff;
	
	if (inWidth < preferedWidth) {
		inWidth = preferedWidth;
	}
	if (inHeight < preferedHeight) {
		inHeight = preferedHeight;
	}
	
	super.setSize(inWidth, inHeight);
	//adjust size of the input text and coordinates of all controls.
	var widthDiff = inWidth - preferedWidth;
	var heightDiff = inHeight - preferedHeight;
	
	this.txtInputText._width = this.initialTFWidth + widthDiff;
	this.txtInputText._height = this.initialTFHeight + heightDiff;
	this.txtInputTextBackground._width = this.txtInputText._width;
	this.txtInputTextBackground._height = this.txtInputText._height;
	this.btnSend._x = this.initialBTN1X + widthDiff / 2;
	this.btnCancel._x = this.initialBTN2X + widthDiff / 2;
	this.btnSend._y = this.initialBTNY + heightDiff;
	this.btnCancel._y = this.btnSend._y;
	
	this.preff_size.width  = preferedWidth;
	this.preff_size.height = preferedHeight;
};

//PRIVATE METHODS.

_global.InviteBox.prototype.onKeyDown = function() {
	if(!Key.isDown(Key.SHIFT) && this.btnSend.getEnabled())
	{ 
		if(this.handlerObj.isSpecialLanguage())
		{ 
			if(Key.isDown(Key.CONTROL) && Key.isDown(Key.ENTER))
			{ 
				this.processSendButton();
			}
		}
		else if (Key.isDown(Key.ENTER)) {
			this.processSendButton();
		}
	}
	if (Key.isDown(Key.ESCAPE)) {
		this.processCancelButton();
	}
};

_global.InviteBox.prototype.onClose = function() {
	this.processCancelButton();
};

_global.InviteBox.prototype.processSendButton = function() {
	this._visible = false;
	Key.removeListener(this);
	this.handlerObj[this.handlerFunctionName](this);
};

_global.InviteBox.prototype.processCancelButton = function() {
	this._visible = false;
	Key.removeListener(this);
	this.isCanceled = true;
	this.handlerObj[this.handlerFunctionName](this);
};

_global.InviteBox.prototype.textValidator = function() {
	//this.btnSend.setEnabled(this.txtInputText.text.length > 0);
};

Object.registerClass('InviteBox', _global.InviteBox);

#endinitclip
