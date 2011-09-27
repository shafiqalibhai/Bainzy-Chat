#initclip 10

_global.ThemesTab = function() {	
	
	super();
	
	this.isCanceled = false;
	this._visible = false;

	this.settings = null;
	
	this.language = null;
	this.skinTarget = null;
	this.ignoreColorPicker = false;

	this.selectedSkin = new CSkin();
	this.selectedBigSkin = new CBigSkin();
	
	this.userAction = new Object();
};

_global.ThemesTab.prototype = new Object();

//PUBLIC METHODS.

_global.ThemesTab.prototype.setEnabled = function(inDialogEnabled) {
	//skip color choosers, slider and checkbox. suppose that nothing bad happens if they stay
	//enabled when hidden.
	this.skinChooser.setEnabled(inDialogEnabled);
	this.bigSkinChooser.setEnabled(inDialogEnabled);
};

_global.ThemesTab.prototype.show = function(init) {
	
	this.userAction.skin_changed = false;
	
	if ( not init )
	{ 
		this._visible = true;
		return;
	}
	
	this.isCanceled = false;
	this.ignoreColorPicker = false;
	this.selectedSkin = new CSkin(this.settings.user.skin);
	this.selectedBigSkin = new CBigSkin(this.settings.user.bigSkin);
	
	this.skinChooser.setChangeHandler('processSkinChooser', this);
	this.bigSkinChooser.setChangeHandler('processBigSkinChooser', this);
	
	this.backgroundPicker.setChangeHandler('processCustomSkin', this);
	this.bodyTextPicker.setChangeHandler('processCustomSkin', this);
	this.borderColorPicker.setChangeHandler('processCustomSkin', this);
	this.buttonPicker.setChangeHandler('processCustomSkin', this);
	this.buttonTextPicker.setChangeHandler('processCustomSkin', this);
	this.buttonBorderPicker.setChangeHandler('processCustomSkin', this);
	this.dialogPicker.setChangeHandler('processCustomSkin', this);
	this.dialogTitlePicker.setChangeHandler('processCustomSkin', this);
	this.userListBackgroundPicker.setChangeHandler('processCustomSkin', this);
	this.titleTextPicker.setChangeHandler('processCustomSkin', this);
	
	if (!this.settings.layout.isSingleRoomMode) {
		this.roomPicker.setChangeHandler('processCustomSkin', this);
		this.roomTextPicker.setChangeHandler('processCustomSkin', this);
		this.enterRoomNotifyPicker.setChangeHandler('processCustomSkin', this);
	}
	if (this.settings.layout.showPublicLog) {
		this.publicLogBackgroundPicker.setChangeHandler('processCustomSkin', this);
	}
	//if (this.settings.layout.showPrivateLog) {
		this.privateLogBackgroundPicker.setChangeHandler('processCustomSkin', this);
	//}
	if (this.settings.layout.showInputBox) {
		this.inputBoxBackgroundPicker.setChangeHandler('processCustomSkin', this);
	}
	this.setSettings(this.settings);
	this.readSelectedSkin();
	
	this._visible = true;
};

_global.ThemesTab.prototype.hide = function() {
	this._visible = false;
}
_global.ThemesTab.prototype.canceled = function() {
	return this.isCanceled;
};

_global.ThemesTab.prototype.setSettings = function(inSettings) {
	
	this.settings = inSettings;
	
	//this.settings.layout.showPrivateLog = true;
	//trace('this.settings.layout.showPrivateLog: ' + this.settings.layout.showPrivateLog)
	
	this.settings.user.skin.prev_backgroundImage = this.settings.user.skin.backgroundImage; 
	this.settings.user.skin.prev_dialogBackgroundImage = this.settings.user.skin.dialogBackgroundImage;
	this.settings.user.skin.prev_customBg == this.settings.user.skin.customBg;
	
	this.skinChooser.removeAll();
	this.bigSkinChooser.removeAll();
	
	if (this.language != null)
	{
		this.skinChooser.addItem(this.language.dialog.skin.selectskin, null);
		this.bigSkinChooser.addItem(this.language.dialog.skin.selectBigSkin, null);
	} else {
		this.skinChooser.addItem('Select Color Scheme...', null);
		this.bigSkinChooser.addItem('Select Skin...', null);
	}
	
	//fill skinChooser
	for (var i = 0; i < this.settings.skin.preset.length; i ++)
	{
		if(this.settings.skin.preset[i].id == this.settings.user.skin.id || this.settings.user.skin.customBg == 4)
		{ 
			this.settings.skin.preset[i].backgroundImage = this.settings.user.skin.backgroundImage; 
			this.settings.skin.preset[i].dialogBackgroundImage = this.settings.user.skin.dialogBackgroundImage; 
		}
		
		this.skinChooser.addItem(this.settings.skin.preset[i].name, this.settings.skin.preset[i]);
		
		this.settings.skin.preset[i].prev_backgroundImage = this.settings.skin.preset[i].backgroundImage; 
		this.settings.skin.preset[i].prev_dialogBackgroundImage = this.settings.skin.preset[i].dialogBackgroundImage; 
	}
	
	//fill bigSkinChooser
	var foundIdx = 1;
	for (var i = 0; i < this.settings.bigSkin.preset.length; i ++)
	{
		this.bigSkinChooser.addItem(this.settings.bigSkin.preset[i].name, this.settings.bigSkin.preset[i]);
		if (this.settings.bigSkin.preset[i].name == this.settings.user.bigSkin.name)
			foundIdx = i+1;
		
	}
	
	this.bigSkinChooser.setChangeHandler(null);
	this.bigSkinChooser.setSelectedIndex(foundIdx);
	this.bigSkinChooser.setChangeHandler('processBigSkinChooser', this);
	
	this.setSkin(this.settings.user.skin);
	//var yShift = 0;
	//var rowHeight = this.privateLogY - this.publicLogY;

	if (this.settings.layout.isSingleRoomMode) {
		this.roomPicker.setEnabled(false);
		this.roomTextPicker.setEnabled(false);
		this.enterRoomNotifyPicker.setEnabled(false);
	}
	
	if (!this.settings.layout.showPublicLog) {
		this.publicLogBackgroundPicker.setEnabled(false);
	}
	
	//if (!this.settings.layout.showPrivateLog) {
		this.privateLogBackgroundPicker.setEnabled(true);
	//}
	
	if (!this.settings.layout.showInputBox) {
		this.inputBoxBackgroundPicker.setEnabled(false);
	}
};

_global.ThemesTab.prototype.setSkinTarget = function(inSkinTarget) 
{
	//trace("setSkinTargetsetSkinTargetsetSkinTargetsetSkinTargetsetSkinTarget");
	this.skinTarget = inSkinTarget;
};

_global.ThemesTab.prototype.getSelectedSkin = function() {
	this.readSelectedSkin();
	
	return this.selectedSkin;
};

_global.ThemesTab.prototype.getSelectedBigSkin = function() {
	return (this.selectedBigSkin == undefined)? this.settings.user.bigSkin : this.selectedBigSkin;
};

_global.ThemesTab.prototype.applyTextProperty = function(propName, val)
{
	for(var itm in this)
	{ 
		if( this[itm]._name != undefined )
			if ( this[itm]._name.indexOf("Label") >= 0 ) 
			{ 
				setTextProperty(propName, val, this[itm], true);      
			}
	}
}

_global.ThemesTab.prototype.applyStyle = function(inStyle) {
	for(var itm in this)
	{ 
		if( this[itm]._name != undefined )
			if ( this[itm]._name.indexOf("Label") >= 0 ) 
			{ 
				this[itm].textColor = inStyle.bodyText;      
			}
	}
};

_global.ThemesTab.prototype.applyLanguage = function(inLanguage) {
	this.language = inLanguage;
	
	if (this.skinChooser.getLength() > 0) {
		this.skinChooser.replaceItemAt(0, this.language.dialog.skin.selectskin);
	}
	
	if (this.bigSkinChooser.getLength() > 0) {
		this.bigSkinChooser.replaceItemAt(0, this.language.dialog.skin.selectBigSkin);
	}
	
	this.backgroundLabel.text = this.language.dialog.skin.background;
	
	
	this.bodyTextLabel.text = this.language.dialog.skin.bodyText;
	this.borderColorLabel.text = this.language.dialog.skin.borderColor;
	this.buttonLabel.text = this.language.dialog.skin.button;
	this.buttonTextLabel.text = this.language.dialog.skin.buttonText;
	this.buttonBorderLabel.text = this.language.dialog.skin.buttonBorder;
	this.dialogLabel.text = this.language.dialog.skin.dialog;
	this.dialogTitleLabel.text = this.language.dialog.skin.dialogTitle;
	this.userListBackgroundLabel.text = this.language.dialog.skin.userListBackground;
	this.roomLabel.text = this.language.dialog.skin.room;
	this.roomTextLabel.text = this.language.dialog.skin.roomText;
	this.enterRoomNotifyLabel.text = this.language.dialog.skin.enterRoomNotify;
	this.publicLogBackgroundLabel.text = this.language.dialog.skin.publicLogBackground;
	this.privateLogBackgroundLabel.text = this.language.dialog.skin.privateLogBackground;
	this.inputBoxBackgroundLabel.text = this.language.dialog.skin.inputBoxBackground;
	this.titleTextLabel.text = this.language.dialog.skin.titleText;
};

//PRIVATE METHODS.
_global.ThemesTab.prototype.setSkin = function(inSkin) {
	//try to set skin chooser name.
	if (inSkin.name != null) {
		var foundIdx = null;
		for (var i = 0; i < this.skinChooser.getLength(); i ++) {
			var itm = this.skinChooser.getItemAt(i).data;
			if (itm.name == inSkin.name) {
				foundIdx = i;
				_global.FlashChatNS.selectedSkin = itm.id;
				break;
			}
		}
		if (foundIdx != null) {
			this.skinChooser.setChangeHandler(null);
			this.skinChooser.setSelectedIndex(foundIdx);
			this.skinChooser.setChangeHandler('processSkinChooser', this);
		}
	}
	this.ignoreColorPicker = true;
	this.backgroundPicker.setValue(inSkin.background);
	this.bodyTextPicker.setValue(inSkin.bodyText);
	this.borderColorPicker.setValue(inSkin.borderColor);
	this.publicLogBackgroundPicker.setValue(inSkin.publicLogBackground);
	this.privateLogBackgroundPicker.setValue(inSkin.privateLogBackground);
	this.inputBoxBackgroundPicker.setValue(inSkin.inputBoxBackground);
	this.buttonPicker.setValue(inSkin.button);
	this.buttonTextPicker.setValue(inSkin.buttonText);
	this.buttonBorderPicker.setValue(inSkin.buttonBorder);
	this.dialogPicker.setValue(inSkin.dialog);
	this.dialogTitlePicker.setValue(inSkin.dialogTitle);
	this.userListBackgroundPicker.setValue(inSkin.userListBackground);
	this.roomPicker.setValue(inSkin.roomBackground);
	this.roomTextPicker.setValue(inSkin.roomText);
	this.enterRoomNotifyPicker.setValue(inSkin.enterRoomNotify);
	this.titleTextPicker.setValue(inSkin.titleText);
	this.ignoreColorPicker = false;
};

_global.ThemesTab.prototype.readSelectedSkin = function() {
	this.selectedSkin.background = this.backgroundPicker.getValue();
	this.selectedSkin.bodyText = this.bodyTextPicker.getValue();
	this.selectedSkin.borderColor = this.borderColorPicker.getValue();
	this.selectedSkin.publicLogBackground = this.publicLogBackgroundPicker.getValue();
	this.selectedSkin.privateLogBackground = this.privateLogBackgroundPicker.getValue();
	this.selectedSkin.inputBoxBackground = this.inputBoxBackgroundPicker.getValue();
	this.selectedSkin.button = this.buttonPicker.getValue();
	this.selectedSkin.buttonText = this.buttonTextPicker.getValue();
	this.selectedSkin.buttonBorder = this.buttonBorderPicker.getValue();
	this.selectedSkin.userListBackground = this.userListBackgroundPicker.getValue();
	this.selectedSkin.roomBackground = this.roomPicker.getValue();
	this.selectedSkin.roomText = this.roomTextPicker.getValue();
	this.selectedSkin.enterRoomNotify = this.enterRoomNotifyPicker.getValue();
	this.selectedSkin.dialog = this.dialogPicker.getValue();
	this.selectedSkin.dialogTitle = this.dialogTitlePicker.getValue();
	this.selectedSkin.titleText = this.titleTextPicker.getValue();
	
	
	var chooserSkin = this.skinChooser.getSelectedItem().data;
	if (chooserSkin != null) {
		this.selectedSkin.id   = chooserSkin.id;
		this.selectedSkin.name = chooserSkin.name;
		
		//!!! add line for new property from skin !!!
		this.selectedSkin.customBg = this.settings.user.skin.customBg;
		this.selectedSkin.backgroundImage = chooserSkin.backgroundImage;
		this.selectedSkin.dialogBackgroundImage = chooserSkin.dialogBackgroundImage;
		this.selectedSkin.showBackgroundImagesOnLogin = chooserSkin.showBackgroundImagesOnLogin;
		this.selectedSkin.recommendedUserColor = chooserSkin.recommendedUserColor;
		
		//extra options (see CSkin.as)
		this.selectedSkin.scrollBG = chooserSkin.scrollBG;
		this.selectedSkin.scrollerBG = chooserSkin.scrollerBG;
		this.selectedSkin.scrollBGPress = chooserSkin.scrollBGPress;
		this.selectedSkin.scrollBorder = chooserSkin.scrollBorder;
		this.selectedSkin.closeButton = chooserSkin.closeButton;
		this.selectedSkin.closeButtonPress = chooserSkin.closeButtonPress;
		this.selectedSkin.closeButtonBorder = chooserSkin.closeButtonBorder;
		this.selectedSkin.closeButtonArrow = chooserSkin.closeButtonArrow;
		this.selectedSkin.minimizeButton = chooserSkin.minimizeButton;
		this.selectedSkin.minimizeButtonPress = chooserSkin.minimizeButtonPress;
		this.selectedSkin.minimizeButtonBorder = chooserSkin.minimizeButtonBorder;
		this.selectedSkin.buttonPress = chooserSkin.buttonPress;
		this.selectedSkin.check = chooserSkin.check;
		this.selectedSkin.headline = chooserSkin.headline;
		this.selectedSkin.userListItem = chooserSkin.userListItem;
		this.selectedSkin.controlsBackground = chooserSkin.controlsBackground;
	}
};

_global.ThemesTab.prototype.processOKButton = function() {
	this._visible = false;
	this.isCanceled = false;	
};

_global.ThemesTab.prototype.processCancelButton = function() {
	if(this.settings.user.skin.name != this.selectedSkin.name || this.userAction.skin_changed)
	{ 
		this.skinTarget.applySkin(this.settings.user.skin);
		for(var itm in this.userAction)
			this.userAction[itm] = false;
	}
	else
	{
		for(var itm in this.userAction)
		{
			if(this.userAction[itm] == true)
			{ 
				this.chooseCustomSkinAction(itm, this.settings.user.skin);
				this.userAction[itm] = false;
			}
		}
	}
	
	if(this.settings.user.bigSkin.swf_name != this.bigSkinChooser.getSkinName())
	{ 
		this.skinTarget.applyBigSkin(this.settings.user.bigSkin);	
		this.skinTarget.applySkin(this.settings.user.skin);
	}
	
	for (var i = 0; i < this.settings.skin.preset.length; i ++)
	{
		this.settings.skin.preset[i].backgroundImage = this.settings.skin.preset[i].prev_backgroundImage; 
		this.settings.skin.preset[i].dialogBackgroundImage = this.settings.skin.preset[i].prev_dialogBackgroundImage; 
	}
	
	if(this.settings.user.skin.backgroundImage != this.settings.user.skin.prev_backgroundImage ||
		this.settings.user.skin.dialogBackgroundImage != this.settings.user.skin.prev_dialogBackgroundImage)
	{ 
		this.settings.user.skin.backgroundImage = this.settings.user.skin.prev_backgroundImage; 
		this.settings.user.skin.dialogBackgroundImage = this.settings.user.skin.prev_dialogBackgroundImage; 

		this.chooseCustomSkinAction('applyBackground', this.settings.user.skin);
		
		_global.FlashChatNS.selectedSkin = this.settings.user.skin.id;
	}
	
	if(this.settings.user.skin.prev_customBg != this.settings.user.skin.customBg)  
		this.settings.user.skin.customBg = this.settings.user.skin.prev_customBg;
	
	this._visible = false;
	this.isCanceled = true;
};

_global.ThemesTab.prototype.processSkinChooser = function() {
	var chooserSkin = this.skinChooser.getSelectedItem().data;
	
	if (chooserSkin != null) //&& chooserSkin.name != this.selectedSkin.name) {
	{
		this.setSkin(chooserSkin);
		this.readSelectedSkin();
		
		this.skinTarget.applySkin(this.selectedSkin, true);
		
		this.userAction.skin_changed = true;
	}
};

_global.ThemesTab.prototype.processBigSkinChooser = function() {
	var tmp = this.bigSkinChooser.getSelectedItem().data;
	if(tmp != undefined) this.selectedBigSkin = tmp;
	
	if (this.selectedBigSkin != null)// && this.selectedBigSkin.swf_name != this.bigSkinChooser.getSkinName()) {
	{ 
		//if (this.selectedBigSkin.swf_name == 'xp_skin') this.setActiveColorScheme('xp');
		this.readSelectedSkin();
		this.skinTarget.applyBigSkin(this.selectedBigSkin);
		this.skinTarget.applySkin(this.selectedSkin);
		
		//-------------------------------------------------------------------------------------------------//
		//call module function
		//-------------------------------------------------------------------------------------------------//
		this.skinTarget.callModuleFunc('mOnChangeSkin', {skin : this.selectedBigSkin.swf_name}, -1);
		//-------------------------------------------------------------------------------------------------//
	}
};

_global.ThemesTab.prototype.setActiveColorScheme = function(inCS)
{
	for(var i = 0; i < this.skinChooser.getLength(); i++)
	{
		if(this.skinChooser.getItemAt(i).label == inCS) 
		{ 
			this.skinChooser.setSelectedIndex(i);
			break;
		}
	}
}

_global.ThemesTab.prototype.chooseCustomSkinAction = function(inName, inSkin) {
	switch(inName)
		{
			case 'titleTextPicker' : 
				this.skinTarget.applyTitleStyle(inSkin);
			break;
			
			case 'inputBoxBackgroundPicker' : 
			case 'privateLogBackgroundPicker' :
			case 'publicLogBackgroundPicker' :
			case 'applyBackground' :
				this.skinTarget.applyBackground(inSkin);
			break;	
			
			case 'dialogTitlePicker' :	
				this.skinTarget.applyDialogStyle(inSkin);
			break;		
			
			case 'bodyTextPicker' :
				this.skinTarget.applyLogNOptionPanelStyle(inSkin);
				this.skinTarget.applyDialogStyle(inSkin);
			break;	
			
			case 'borderColorPicker' :
				this.skinTarget.applyLogNOptionPanelStyle(inSkin);
				this.skinTarget.applyUserListStyle(inSkin);
			break;
			
			case 'roomPicker' :
			case 'userListBackgroundPicker' :
			case 'roomTextPicker' :
			case 'enterRoomNotifyPicker' :
				this.skinTarget.applyUserListStyle(inSkin);
			break;
			
			case 'backgroundPicker' :
				this.skinTarget.applyBackgroundColor(inSkin);
				this.skinTarget.applyUserListStyle(inSkin);
				this.skinTarget.applyControlsBackground(inSkin);
			break;
			
			case 'dialogPicker' :
				this.skinTarget.applyDialogStyle(inSkin);
			break;
			
			default:
				this.skinTarget.applySkin(inSkin);
				this.userAction.skin_changed = true;
			break;
		}
}

_global.ThemesTab.prototype.processCustomSkin = function(inControl) {
	if (!this.ignoreColorPicker) {
		this.readSelectedSkin();
		this.userAction[inControl._name] = true;
		this.chooseCustomSkinAction(inControl._name, this.selectedSkin);
		
		this._parent.setPropTbvSkin( this.dialogPicker.getValue() );
	}
};

Object.registerClass('ThemesTab', _global.ThemesTab);

#endinitclip
