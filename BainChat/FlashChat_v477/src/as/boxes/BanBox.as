#initclip 10

_global.BanBox = function() {
	super();
	
	this.setResizable(true);
	this.isCanceled = false;
	this._visible = false;

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

	this.initialDimensions = super.getSize();
	this.initialTFWidth = this.txtInputText._width;
	this.initialTFHeight = this.txtInputText._height;
	//initial X and Y coordinates of all controls below resizable input text.
	this.initialRB1X = this.banTypeRoom._x;
	this.initialRB2X = this.banTypeChat._x;
	this.initialRB3X = this.banTypeIP._x;
	this.initialRBY = this.banTypeRoom._y;
	this.initialCBX = this.roomChooser._x;
	this.initialCBY = this.roomChooser._y;
	this.initialBTNX = this.btnBan._x;
	this.initialBTNY = this.btnBan._y;
};

_global.BanBox.prototype = new DialogBox();

//PUBLIC METHODS.

_global.BanBox.prototype.setEnabled = function(inDialogEnabled) {
	super.setEnabled(inDialogEnabled);
	this.btnBan.setEnabled(inDialogEnabled);
	this.banTypeRoom.setEnabled(inDialogEnabled);
	this.banTypeChat.setEnabled(inDialogEnabled);
	this.banTypeIP.setEnabled(inDialogEnabled);
	this.roomChooser.setEnabled(inDialogEnabled);
};

_global.BanBox.prototype.setRoomList = function(inRoomList) {
	this.roomList = inRoomList;
	this.roomChooser.removeAll();
	for (var i = 0; i < inRoomList.length; i ++) {
		this.roomChooser.addItem(inRoomList[i].label, inRoomList[i]);
	}
	
	var room = this.handlerObj.getRoomForUser(this.userData);
	this.roomChooser.setSelectedIndex(room-1);
};

_global.BanBox.prototype.setSelectedRoom = function(inSelectedRoom) {
	this.selectedRoom = inSelectedRoom;
	for (var i = 0; i < this.roomChooser.getLength(); i ++) {
		if (this.roomChooser.getItemAt(i).data.id == inSelectedRoom.id) {
			this.roomChooser.setSelectedIndex(i);
			return;
		}
	}
};

_global.BanBox.prototype.getSelectedRoom = function() {
	return this.roomChooser.getSelectedItem().data;
};

_global.BanBox.prototype.show = function() {
	this.isCanceled = false;

	this.btnBan.setClickHandler('processBanButton', this);
	this.setRoomList(this.roomList);
	this.setSelectedRoom(this.selectedRoom);
	this.txtInputText.text = '';
	this.banTypeRoom.setState(true);
	this.roomChooser.setEnabled(true);
	
	this.banTypeRoom.setChangeHandler('processRoomBtn', this);
	this.banTypeChat.setChangeHandler('processChatIPBtn', this);
	this.banTypeIP.setChangeHandler('processChatIPBtn', this);
	
	this.textValidator();
	Key.addListener(this);
	this._visible = true;
	Selection.setFocus(this.txtInputText);
};

_global.BanBox.prototype.canceled = function() {
	return this.isCanceled;
};

_global.BanBox.prototype.getEnteredText = function() {
	return this.txtInputText.text;
};

_global.BanBox.prototype.getBanType = function() {
	if (this.banTypeRoom.getState()) {
		return 1;
	} else if (this.banTypeChat.getState()) {
		return 2;
	} else {
		return 3;
	}
};

_global.BanBox.prototype.initialized = function() {
	return (super.initialized() && (this.btnBan.setEnabled != null));
};

_global.BanBox.prototype.applyTextProperty = function(propName, val)
{
	setTextProperty(propName, val, this.lblTop);
	setTextProperty(propName, val, this.txtInputText, true);
}

_global.BanBox.prototype.applyStyle = function(inStyle) {
	super.applyStyle(inStyle);
	this.banTypeRoom.setStyleProperty('background', 0xffffff);
	this.banTypeRoom.setStyleProperty('face', 0x000000);
	this.banTypeRoom.setStyleProperty('textColor', inStyle.bodyText, false);
	
	this.banTypeChat.setStyleProperty('background', 0xffffff);
	this.banTypeChat.setStyleProperty('face', 0x000000);
	this.banTypeChat.setStyleProperty('textColor', inStyle.bodyText, false);
	
	this.banTypeIP.setStyleProperty('background', 0xffffff);
	this.banTypeIP.setStyleProperty('face', 0x000000);
	this.banTypeIP.setStyleProperty('textColor', inStyle.bodyText, false);
	
	this.lblTop.textColor = inStyle.bodyText;
	this.txtInputText.textColor = inStyle.buttonText;
	this.txtInputText._style = inStyle;
	this.txtInputText.borderColor = inStyle.borderColor;
	this.txtInputText.border = true;
	var c = new Color(this.txtInputTextBackground);
	c.setRGB(inStyle.inputBoxBackground);
	this.txtInputTextBackground._alpha = inStyle.uiAlpha;
};

_global.BanBox.prototype.applyLanguage = function(inLanguage) {
	this.lblTop.text = inLanguage.dialog.ban.banText;
	this.banTypeRoom.setLabel(inLanguage.dialog.ban.fromRoom);
	this.banTypeChat.setLabel(inLanguage.dialog.ban.fromChat);
	this.banTypeIP.setLabel(inLanguage.dialog.ban.byIP);
	this.btnBan.setLabel(inLanguage.dialog.ban.banBtn);
};

_global.BanBox.prototype.setSize = function(inWidth, inHeight) {
	//if this dialog is not initialized yet - simply call parent method and return.
	if (this.initialDimensions == null) {
		super.setSize(inWidth, inHeight);
		return;
	}
	//check if new size is not smaller than initial dialog dimensions.
	if (inWidth < this.initialDimensions.width) {
		inWidth = this.initialDimensions.width;
	}
	if (inHeight < this.initialDimensions.height - 40) {
		inHeight = this.initialDimensions.height - 40;
	}
	
	super.setSize(inWidth, inHeight);
	//adjust size of the input text and coordinates of all controls.
	var widthDiff = inWidth - this.initialDimensions.width;
	var heightDiff = inHeight - this.initialDimensions.height;
	
	var dim1 = testText(this.banTypeRoom.fLabel_mc.labelField, this.banTypeRoom.getLabel());
	var dim2 = testText(this.banTypeChat.fLabel_mc.labelField, this.banTypeChat.getLabel());
	var dim3 = testText(this.banTypeIP.fLabel_mc.labelField, this.banTypeIP.getLabel());
	var w1 = this.banTypeRoom.fLabel_mc._x + dim1.width;
	var w2 = this.banTypeChat.fLabel_mc._x + dim2.width;  
	var w3 = this.banTypeIP.fLabel_mc._x + dim3.width;  
	
	this.banTypeRoom._x = (inWidth - w1 - w2 - w3) / 4;
	this.banTypeChat._x = 2*this.banTypeRoom._x + w1;
	this.banTypeIP._x = 3*this.banTypeRoom._x + w1 + w2;
	
	this.banTypeRoom._y = this.initialRBY + heightDiff;
	this.banTypeChat._y = this.banTypeRoom._y;
	this.banTypeIP._y = this.banTypeRoom._y;
	
	this.txtInputText._width = this.initialTFWidth + widthDiff;
	this.txtInputText._height = this.initialTFHeight + heightDiff;
	this.txtInputTextBackground._width = this.txtInputText._width;
	this.txtInputTextBackground._height = this.txtInputText._height;
	
	this.roomChooser._x = this.initialCBX + widthDiff / 2;
	this.roomChooser._y = this.initialCBY + heightDiff;
	this.btnBan._x = this.initialBTNX + widthDiff / 2;
	this.btnBan._y = this.initialBTNY + heightDiff;
	
	this.preff_size.width  = this.initialDimensions.width;
	this.preff_size.height = this.initialDimensions.height - 40;
};

//PRIVATE METHODS.

_global.BanBox.prototype.onKeyDown = function() {
	if (!Key.isDown(Key.SHIFT) && this.btnBan.getEnabled()) {
		if(this.handlerObj.isSpecialLanguage())
		{ 
			if(Key.isDown(Key.CONTROL) && Key.isDown(Key.ENTER))
			{ 
				this.processBanButton();
			}
		}
		else	if(Key.isDown(Key.ENTER))
				this.processBanButton();
	}
	
	if (Key.isDown(Key.ESCAPE)) {
		this.onClose();
	}
};

_global.BanBox.prototype.onClose = function() {
	this.isCanceled = true;
	this._visible = false;
	Key.removeListener(this);
	this.handlerObj[this.handlerFunctionName](this);
};

_global.BanBox.prototype.processRoomBtn = function(inCtrl){
	this.roomChooser.setEnabled(true);
};

_global.BanBox.prototype.processChatIPBtn = function(inCtrl){
	this.roomChooser.setEnabled(false);
};

_global.BanBox.prototype.processBanButton = function() {
	this._visible = false;
	Key.removeListener(this);
	this.handlerObj[this.handlerFunctionName](this);
};

_global.BanBox.prototype.textValidator = function() {
	//this.btnBan.setEnabled(this.txtInputText.text.length > 0);
};

Object.registerClass('BanBox', _global.BanBox);

#endinitclip
