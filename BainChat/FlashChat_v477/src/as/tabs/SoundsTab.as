#initclip 10

_global.SoundsTab = function() {
	super();
	
	this.isCanceled = false;
	this._visible = false;

	this.soundProperties = null;
	this.soundTarget = null;
	this.ignoreCheckbox = false;

	this.selectedSoundProperties = new Object();
};

_global.SoundsTab.prototype = new Object();

//PUBLIC METHODS.

_global.SoundsTab.prototype.setEnabled = function(inDialogEnabled) {
	
	for(var itm in this)
	{ 
		if( this[itm]._name != undefined )
		   if( this[itm]._name.indexOf("btn") == 0 )
		       this[itm].enabled = (inDialogEnabled);
		   if( this[itm]._name.indexOf("cb")  == 0 ||
		       this[itm]._name.indexOf("scroller") == 0)
		       this[itm].setEnabled(inDialogEnabled);
	}
	
};

_global.SoundsTab.prototype.show = function(init) {
	
	if ( not init )
	{ 
		this._visible = true;
		return;
	}
		
	this.isCanceled = false;
	this.ignoreCheckbox = false;
		
	for(var itm in this)
	{ 
		if( this[itm]._name != undefined )
		{ 
			if(this[itm]._name.indexOf("btn") == 0 )
			{ 
				//this[itm].useHandCursor = false;
				this[itm].onRelease = function()
				{
					this._parent.btnClick( this );    
				};
			}
		}
		 
	}
		
	//--------------------------------------------------------------------------------//
	this.setSoundProperties(this.soundTarget.settings.user.sound);
	this.readSelectedSoundProperties();
	//Key.addListener(this);
	this._visible = true;
};

_global.SoundsTab.prototype.hide = function() {
	this._visible = false;
}

_global.SoundsTab.prototype.canceled = function() {
	return this.isCanceled;
};

_global.SoundsTab.prototype.setSoundProperties = function(inSoundProperties) {
	//trace("SET SOUND");
	
	this.soundProperties = inSoundProperties;
	
	this.ignoreCheckbox = true;
	this.scrollerVolume.setValue(this.soundProperties.volume);
	this.scrollerPan.setValue(this.soundProperties.pan);
	
	for(var itm in this)
	{ 
		if( this[itm]._name != undefined &&
		    this[itm]._name.indexOf("cb")  == 0 )
		{ 
			this[itm].setValue(!toBool(this.soundProperties['mute' + this[itm]._name.substr(2)]));
		    //trace("ITMSND " + this[itm]._name + " ==> " + !toBool(this.soundProperties['mute' + this[itm]._name.substr(2)]));
		}
	}
	this.cbMuteAll.setValue(toBool(this.soundProperties.muteAll));
	
	this.ignoreCheckbox = false;
};

_global.SoundsTab.prototype.setSoundTarget = function(inSoundTarget) {
	this.soundTarget = inSoundTarget;
};

_global.SoundsTab.prototype.getSelectedSoundProperties = function() {
	this.readSelectedSoundProperties();
	return this.selectedSoundProperties;
};

_global.SoundsTab.prototype.applyTextProperty = function(propName, val)
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

_global.SoundsTab.prototype.applyStyle = function(inStyle) {
	for(var itm in this)
	{ 
		if( this[itm]._name != undefined )
		   if( this[itm]._name.indexOf("cb")  == 0 )
		   { 
		       this[itm].setStyleProperty('background', 0xffffff);
		       this[itm].setStyleProperty('face', 0x000000);
		   }
		   else if ( this[itm]._name.indexOf("Label") >= 0 )
		       this[itm].textColor = inStyle.bodyText;      
	}
};

_global.SoundsTab.prototype.applyLanguage = function(inLanguage) {
	
	this.volumeLabel.text = inLanguage.dialog.sound.volume;
	this.panLabel.text = inLanguage.dialog.sound.pan;
	this.leaveRoomLabel.text = inLanguage.dialog.sound.leaveroom;
	this.receiveMessageLabel.text = inLanguage.dialog.sound.reveivemessage;
	this.submitMessageLabel.text = inLanguage.dialog.sound.submitmessage;
	this.muteAllLabel.text = inLanguage.dialog.sound.muteall;
	
	if(inLanguage.dialog.sound.initiallogin != undefined)
	{ 
		this.initialLoginLabel.text = inLanguage.dialog.sound.initiallogin;
		this.otherUserEntersLabel.text = inLanguage.dialog.sound.otheruserenters;
		this.logoutLabel.text = inLanguage.dialog.sound.logout;
		this.privateMessageReceivedLabel.text = inLanguage.dialog.sound.privatemessagereceived;
		this.invitationReceivedLabel.text = inLanguage.dialog.sound.invitationreceived;
		this.comboListOpenCloseLabel.text = inLanguage.dialog.sound.combolistopenclose;
		this.userBannedBootedLabel.text = inLanguage.dialog.sound.userbannedbooted;
		this.userMenuMouseOverLabel.text = inLanguage.dialog.sound.usermenumouseover;
		this.roomOpenCloseLabel.text = inLanguage.dialog.sound.roomopenclose;
		this.popupWindowOpenLabel.text = inLanguage.dialog.sound.popupwindowopen;
		this.popupWindowCloseMinLabel.text = inLanguage.dialog.sound.popupwindowclosemin;
		this.pressButtonLabel.text = inLanguage.dialog.sound.pressbutton;  
		this.enterRoomLabel.text = inLanguage.dialog.sound.enterroom;
	}
	
	/*
	//template for checkboxes
	this.cbInitialLogin
	this.cbLogout
	this.cbPrivateMessageReceived
	this.cbInvitationReceived
	this.cbComboListOpenClose
	this.cbUserBannedBooted
	this.cbUserMenuMouseOver
	this.cbRoomOpenClose
	this.cbPopupWindowOpen
	this.cbPopupWindowCloseMin
     */
};

//PRIVATE METHODS.
/*
_global.SoundsTab.prototype.onKeyDown = function() {
	if (Key.isDown(Key.ENTER)) {
		this.processOKButton();
	}
	if (Key.isDown(Key.ESCAPE)) {
		this.processCancelButton();
	}
};
*/

_global.SoundsTab.prototype.readSelectedSoundProperties = function() {
	this.selectedSoundProperties.volume = this.scrollerVolume.getValue();
	this.selectedSoundProperties.pan = this.scrollerPan.getValue();
	
	for(var itm in this)
	{ 
		if( this[itm]._name != undefined &&
		    this[itm]._name.indexOf("cb") == 0 )
		    this.selectedSoundProperties['mute' + this[itm]._name.substr(2)] =  !this[itm].getValue();
	}
	
	this.selectedSoundProperties.muteAll = this.cbMuteAll.getValue();
	
};

/*
_global.SoundsTab.prototype.onClose = function() {
	this.processCancelButton();
};
*/
_global.SoundsTab.prototype.processOKButton = function() {
	this._visible = false;
	this.processSoundVolumePanProperties();
	//Key.removeListener(this);
	//this.handlerObj[this.handlerFunctionName](this);
};

_global.SoundsTab.prototype.processCancelButton = function() {
	this._visible = false;
	this.isCanceled = true;
	this.soundTarget.applySoundProperties(this.soundProperties);
	
	//Key.removeListener(this);
};

_global.SoundsTab.prototype.btnClick = function( obj ) {
	var btn_name = obj._name;
	this.processSoundVolumePanProperties();
	
	if (btn_name == 'btnTest')
	{ 
		this.soundTarget.soundObj.attachSound('LeaveRoom', true);
		return;
	}
		
	this.soundTarget.soundObj.attachSound(btn_name.substr(3), true);
};

_global.SoundsTab.prototype.processSoundVolumePanProperties = function() {
	this.selectedSoundProperties.volume = this.scrollerVolume.getValue();
	this.selectedSoundProperties.pan = this.scrollerPan.getValue();
	this.soundTarget.applySoundProperties(this.selectedSoundProperties);	
}

Object.registerClass('SoundsTab', _global.SoundsTab);

#endinitclip
