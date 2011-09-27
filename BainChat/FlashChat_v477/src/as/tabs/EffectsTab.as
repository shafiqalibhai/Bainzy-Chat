#initclip 10

_global.EffectsTab = function() {
	super();
	
	this.isCanceled = false;
	this._visible = false;
	
	this.effectsTarget = null;
	this.settings = null;
	this.language = null;
	
	this.selectedEffectsProperties = new Object();
	this.selectedEffectsProperties.mainchat = new Object();
	this.selectedEffectsProperties.room = new Object();
	
	this.selectedSkin = new Object();
	
	var user = this._parent.parent.getUser(this._parent.parent.selfUserId);
	
	this.nick_image = '';
	this.custom_image = '';
};

_global.EffectsTab.prototype = new Object();

//PUBLIC METHODS.

_global.EffectsTab.prototype.setEnabled = function(inDialogEnabled) {
	
	for(var itm in this)
	{ 
		if( this[itm]._name != undefined )
			if(this[itm]._name.indexOf("combo") == 0)
				this[itm].setEnabled(inDialogEnabled);
			if( this[itm]._name.indexOf("btn") == 0)
			     this[itm].enabled = (inDialogEnabled);
			if( this[itm]._name.indexOf("cb")  == 0)
			     this[itm].setEnabled(inDialogEnabled);
			if( this[itm]._name.indexOf("sb")  == 0)
			     this[itm].setEnabled(inDialogEnabled);     
	}
};

_global.EffectsTab.prototype.show = function(init) {
	
	if ( not init )
	{ 
		this.cbMainchat.setChangeHandler('processMainchat', this);
		this.cbRoomlist.setChangeHandler('processRoomlist', this);
		this._visible = true;
		return;
	}
		
	this.isCanceled = false;
	
	if(this.settings.layout.toolbar.smilies == 0)
	{ 
		this.cbMainchat.setEnabled(false);
		this.cbRoomlist.setEnabled(false);
		this.comboMainchat.setEnabled(false);
		this.comboRoomlist.setEnabled(false);
	}
	else
		for(var itm in this)
		{ 
			if( this[itm]._name != undefined )
				if(this[itm]._name.indexOf("combo") == 0 )
				{ 	
					this[itm].setItemSymbol('SmileDropDownCustomItem');
					this[itm].setItemSymbolOnTop(true);
					var parent = this._parent.parent;
					parent.fillSmieDropdown(parent.settings.smiles, this[itm], false);
				}
		}
	
	
	this.selectedSkin = this.settings.user.skin;
	if(this._parent.tabs[0] != undefined)
	{
		this.selectedSkin = this._parent.tabs[0].getSelectedSkin();
		this.selectedSkin.showBackgroundImages = this.settings.user.skin.showBackgroundImages;
		this.selectedSkin.uiAlpha = this.settings.user.skin.uiAlpha;
	}
	
	this.setTransparency(this.selectedSkin);
	
	this.cbShowBackgroundImages.setChangeHandler('processCustomAlpha', this);
	this.cbSplashWindow.setValue(this.settings.splashWindow);
	this.cbSplashWindow.setChangeHandler('processSplashWindow', this);
	
	this.sbUiAlpha.setChangeHandler('processCustomAlpha', this);
	
	if(this.settings.layout.allowCustomBackground)
	{
		this.btnCustom.setClickHandler('processCustom', this);
		this.btnClearCustom.setClickHandler('processClearCustom', this);
	}	
	else
	{
		this.btnCustom._visible = false;
		this.btnClearCustom._visible = false;
	}
	
	
	this.cbMainchat.setValue(this.settings.user.avatars.mainchat.default_state);
	this.cbRoomlist.setValue(this.settings.user.avatars.room.default_state);
	
	this.cbMainchat.setChangeHandler('processMainchat', this);
	this.cbRoomlist.setChangeHandler('processRoomlist', this);
	
	var mainchatInd = 0, roomlistInd = 0;
	var len = Math.max(this.comboMainchat.getLength(), this.comboRoomlist.getLength());
	for(var i = 0; i<len; i++)
	{
		var mc_data = this.comboMainchat.getItemAt(i).data;
		
		if(mc_data.patternIcon == this.settings.user.avatars.mainchat.default_value)
			mainchatInd = i;
		
		var rl_data = this.comboRoomlist.getItemAt(i).data; 	
		if(rl_data.patternIcon == this.settings.user.avatars.room.default_value)
			roomlistInd = i;	
	}
	
	this.comboMainchat.setSelectedIndex(mainchatInd);
	this.comboRoomlist.setSelectedIndex(roomlistInd);
	
	
	if(this.settings.user.avatars.mainchat.allow_override != true)
	{
		this.comboMainchat.setEnabled(false);
		this.cbMainchat.setEnabled(false);
	}
	if(this.settings.user.avatars.room.allow_override != true)
	{
		this.comboRoomlist.setEnabled(false);//cbRoomlist
		this.cbRoomlist.setEnabled(false);
	}
	
	this.comboMainchat.setChangeHandler('processMainchat', this);
	this.comboRoomlist.setChangeHandler('processRoomlist', this);	
	
	//--------------------------------------------------------------------------------//
	if(this.settings.allowPhoto)
	{
		this.photo.image_mc.setHandler('imageLoaded', this);
		this.btnPhoto.setClickHandler('processPhoto', this);
		this.btnClearPhoto.setClickHandler('processClearPhoto', this);
	}
	else
	{
		this.photo._visible = false;
		this.btnPhoto._visible = false;
		this.btnClearPhoto._visible = false;
		this.labelPhoto._visible = false;
	}
	//--------------------------------------------------------------------------------//
	this.readSelectedEffectsProperties();
	
	this._visible = true;
};

_global.EffectsTab.prototype.hide = function() {
	this.cbMainchat.setChangeHandler(null);
	this.cbRoomlist.setChangeHandler(null);
	this._visible = false;
}

_global.EffectsTab.prototype.canceled = function() {
	return this.isCanceled;
};

_global.EffectsTab.prototype.setTransparency = function(inSkin) {
	if ((inSkin.backgroundImage == null) || (inSkin.backgroundImage == '')) {
		this.cbShowBackgroundImages.setEnabled(true);
		this.sbUiAlpha.setEnabled(true);
		this.cbShowBackgroundImages.setValue(false);
		this.sbUiAlpha.setValue(inSkin.uiAlpha); //100
		this.cbShowBackgroundImages.setEnabled(false);
		this.sbUiAlpha.setEnabled(false);
	} else {
		this.cbShowBackgroundImages.setEnabled(true);
		this.sbUiAlpha.setEnabled(true);
		this.cbShowBackgroundImages.setValue(inSkin.showBackgroundImages);
		this.sbUiAlpha.setValue(inSkin.uiAlpha);
	}
};

_global.EffectsTab.prototype.setSettings = function(inSettings) {
	this.settings = inSettings;
	this.nick_image = this.settings.user.profile.nick_image;
};

_global.EffectsTab.prototype.setEffectsTarget = function(inEffectsTarget) {
	this.effectsTarget = inEffectsTarget;
};

_global.EffectsTab.prototype.getSelectedSkin = function() {
	return this.selectedSkin;
};

_global.EffectsTab.prototype.getSelectedEffectsProperties = function() {
	return this.selectedEffectsProperties;
};

_global.EffectsTab.prototype.applyTextProperty = function(propName, val)
{
	for(var itm in this)
	{ 
		if( this[itm]._name != undefined )
			if ( this[itm]._name.indexOf("label") == 0 ) 
			{ 
				var setVal = val;
				if(
					this[itm]._name == 'labelAvatars'    ||
					this[itm]._name == 'labelBackground' ||
					this[itm]._name == 'labelPhoto'
				  )
				{
					if(propName == 'size') setVal = 20;
				}
				
				setTextProperty(propName, setVal, this[itm], true);
			}
	}
	
	var max_width = Math.max(this.labelMainchat.textWidth, this.labelRoomlist.textWidth);
	var new_x = this.labelMainchat._x + max_width + 10;
	var dim   = this._parent.getSize();
	if((new_x + this.comboMainchat._width) < (dim.width - 10))
		this.comboMainchat._x = this.comboRoomlist._x = new_x;
	else 
		this.comboMainchat._x = this.comboRoomlist._x = dim.width - this.comboMainchat._width - 20;
		
	if(this.settings.allowPhoto)
	{
		var all_back_width = 135; 
		var new_x2 = ((dim.width - 10) - all_back_width + this.comboMainchat._x + this.comboMainchat._width) / 2;
	
		this.labelPhoto._x = this.btnPhoto._x = new_x2;
		this.btnClearPhoto._x = this.btnPhoto._x + this.btnPhoto._width + 10;
		this.btnPhoto._y = this.labelPhoto._y + this.labelPhoto._height + 10;
		this.btnClearPhoto._y = this.btnPhoto._y + (this.btnPhoto._height - this.btnClearPhoto._height)/2;
		
		this.photo._x = new_x2;
		this.photo._y = this.btnPhoto._y + this.btnPhoto._height + 5;
		
		this.doLoadImage(this.settings.user.profile.nick_image);
	}	
	else
	{
		var all_back_width = this.cbShowBackgroundImages._width + 10 + this.labelUiAlpha.textWidth + 10 + this.labelMinus._width + this.sbUiAlpha._width + this.labelPlus._width;; 
		var new_x2 = ((dim.width - 10) - all_back_width + this.comboMainchat._x + this.comboMainchat._width) / 2;
		
		this.labelBackground._x = this.cbShowBackgroundImages._x = this.cbSplashWindow._x = new_x2;
		var new_x3 = new_x2 + this.cbShowBackgroundImages._width + 3.5;
		this.labelShowBackgroundImages._x = this.labelUiAlpha._x = this.btnCustom._x = this.labelSplashWindow._x = new_x3;
		this.btnClearCustom._x = this.btnCustom._x + this.btnCustom._width + 10;
		
		if( !this.settings.layout.allowCustomBackground )
		{
			this.cbSplashWindow._y = this.labelSplashWindow._y = this.btnCustom._y;
			this.cbSplashWindow._y += 3.5; 
		}
	
		this.labelMinus._x = this.labelUiAlpha._x + this.labelUiAlpha.textWidth + 10;
		this.sbUiAlpha._x  = this.labelMinus._x + this.labelMinus._width;
		this.labelPlus._x  = this.sbUiAlpha._x + this.sbUiAlpha._width;
		
		var dy = 104.5 - this.labelAvatars._y;
		this.labelBackground._y = 110.0 - dy;
		this.cbShowBackgroundImages._y = 146.5 - dy;
		this.labelShowBackgroundImages._y = 141.5 - dy;
		this.labelUiAlpha._y = 168.6 - dy;
		this.labelMinus._y = 167.4 - dy;
		this.sbUiAlpha._y = 173.8 - dy;
		this.labelPlus._y = 169.4 - dy;
		this.btnCustom._y = 199.0 - dy;
		this.btnClearCustom._y = this.btnCustom._y + (this.btnCustom._height - this.btnClearCustom._height)/2;
		this.cbSplashWindow._y = 230.5 - dy;
		this.labelSplashWindow._y = 227.0 - dy;
	}
};

_global.EffectsTab.prototype.applyStyle = function(inStyle) {
	this.cbShowBackgroundImages.setStyleProperty('background', 0xffffff);
	this.cbShowBackgroundImages.setStyleProperty('face', 0x000000);
	
	this.cbSplashWindow.setStyleProperty('background', 0xffffff);
	this.cbSplashWindow.setStyleProperty('face', 0x000000);
	
	for(var itm in this)
	{ 
		if( this[itm]._name != undefined )
			if ( this[itm]._name.indexOf("label") == 0 )
				this[itm].textColor = inStyle.bodyText;      
	}
};

_global.EffectsTab.prototype.applyLanguage = function(inLanguage) {
	this.language = inLanguage;
	
	if(this.language.dialog.effects != undefined)
	{ 
		this.labelShowBackgroundImages.text = this.language.dialog.effects.showBackgroundImages;
		this.labelSplashWindow.text = this.language.dialog.effects.splashWindow;
		this.labelUiAlpha.text = this.language.dialog.effects.uiAlpha;
		this.labelAvatars.text    = this.language.dialog.effects.avatars;
		this.labelPhoto.text    = this.language.dialog.effects.photo;
		this.labelMainchat.text   = this.language.dialog.effects.mainchat;
		this.labelRoomlist.text   = this.language.dialog.effects.roomlist;
		this.labelBackground.text = this.language.dialog.effects.background;
		this.btnCustom.setLabel(this.language.dialog.effects.custom);
		this.btnPhoto.setLabel(this.language.dialog.effects.custom);
	}
};

_global.EffectsTab.prototype.readSelectedEffectsProperties = function() {
	this.selectedSkin.showBackgroundImages = this.cbShowBackgroundImages.getValue();
	this.selectedSkin.uiAlpha = this.sbUiAlpha.getValue();
	
	this.selectedEffectsProperties.splashWindow =  this.cbSplashWindow.getValue();
	
	this.selectedEffectsProperties.role   = this.settings.user.avatars.role;
	this.selectedEffectsProperties.gender = this.settings.user.avatars.gender;
	
	this.selectedEffectsProperties.mainchat.allow_override = this.settings.user.avatars.mainchat.allow_override;
	this.selectedEffectsProperties.room.allow_override = this.settings.user.avatars.room.allow_override;
	
	this.selectedEffectsProperties.mainchat.default_state = (this.cbMainchat.getEnabled())? this.cbMainchat.getValue() : false;
	this.selectedEffectsProperties.room.default_state = (this.cbRoomlist.getEnabled())? this.cbRoomlist.getValue() : false;
	
	var mc_data = (this.comboMainchat.getEnabled())? this.comboMainchat.getSelectedItem().data.patternIcon : this.settings.user.avatars.mainchat.default_value;
	this.selectedEffectsProperties.mainchat.default_value = mc_data;
	var rl_data = (this.comboRoomlist.getEnabled())? this.comboRoomlist.getSelectedItem().data.patternIcon : this.settings.user.avatars.room.default_value;
	this.selectedEffectsProperties.room.default_value = rl_data;
};

_global.EffectsTab.prototype.processOKButton = function() {
	this._visible = false;
};

_global.EffectsTab.prototype.processCancelButton = function() {
	this.selectedSkin = this.settings.user.skin;
	this.effectsTarget.applyBackground(this.selectedSkin);
	
	if(this.settings.user.avatars.mainchat.default_value != this.selectedEffectsProperties.mainchat.default_value || 
	   this.settings.user.avatars.mainchat.default_state != this.selectedEffectsProperties.mainchat.default_state)
	{ 
		this._parent.parent.setMainchatAvatar(this.settings.user.avatars.mainchat.default_value, this.settings.user.avatars.mainchat.default_state); 
	}
	if(this.settings.user.avatars.room.default_value != this.selectedEffectsProperties.room.default_value ||
	   this.settings.user.avatars.room.default_state != this.selectedEffectsProperties.room.default_state)
	{ 
		this._parent.parent.setRoomlistAvatar(this.settings.user.avatars.room.default_value, this.settings.user.avatars.room.default_state);
	}
	
	this._visible = false;
	this.isCanceled = true;
};

_global.EffectsTab.prototype.processSplashWindow = function(inControl) {
	this.selectedEffectsProperties.splashWindow =  this.cbSplashWindow.getValue();
};

_global.EffectsTab.prototype.processCustomAlpha = function(inControl) {
	/*
	if (!this.cbShowBackgroundImages.getValue() && this.sbUiAlpha.getEnabled()) {
		this.sbUiAlpha.setEnabled(false);
	}
	if (this.cbShowBackgroundImages.getValue() && !this.sbUiAlpha.getEnabled()) {
		this.sbUiAlpha.setEnabled(true);
	}
	*/
	
	this.readSelectedEffectsProperties();
	this.effectsTarget.applyBackground(this.selectedSkin);
};

_global.EffectsTab.prototype.processCustom = function(inControl) {
	var parent  = this._parent.parent;
	var the_url = _root._url.substr(0, _root._url.lastIndexOf('/')) + '/';
	var lang    =  parent.selectedLanguage['id'];
	
	if(this._parent.textTab != null) 
		lang = this._parent.textTab.comboLanguage.getSelectedItem().data.id;
	
	var arg = 'userid=' + parent.selfUserId + '&lang=' + lang + '&connid=' + parent.listener.connid;
	
	getURL("javascript:openWindow('"+the_url+"load_avatar_bg.php?"+arg+"', 'loadAvartarBGWindow', '', 490, 230)");
};

_global.EffectsTab.prototype.processMainchat = function(inControl){ 
	this.readSelectedEffectsProperties();
	
	this._parent.parent.setMainchatAvatar(this.selectedEffectsProperties.mainchat.default_value, this.selectedEffectsProperties.mainchat.default_state); 
};

_global.EffectsTab.prototype.processRoomlist = function(inControl){ 
	this.readSelectedEffectsProperties();
	
	this._parent.parent.setRoomlistAvatar(this.selectedEffectsProperties.room.default_value, this.selectedEffectsProperties.room.default_state);
};

_global.EffectsTab.prototype.processPhoto = function()
{
	var parent  = this._parent.parent;
	var the_url = _root._url.substr(0, _root._url.lastIndexOf('/')) + '/';
	var lang    = parent.selectedLanguage['id'];
	
	if(this._parent.textTab != null) 
		lang = this._parent.textTab.comboLanguage.getSelectedItem().data.id;
	
	var arg = 'userid=' + parent.selfUserId + '&lang=' + lang + '&connid=' + parent.listener.connid;
		
	getURL("javascript:openWindow('"+the_url+"load_photo.php?"+arg+"', 'loadPhoto', '', 490, 180)");
};

_global.EffectsTab.prototype.processClearPhoto = function()
{
	this.nick_image = '';
	this.photo.image_mc.clear();
};

_global.EffectsTab.prototype.processClearCustom = function()
{
	var parent = _global.FlashChatNS.chatUI;
	
	if(parent.settings.user.skin.id == _global.FlashChatNS.selectedSkin)
	{ 
		parent.settings.user.skin.backgroundImage = parent.settings.user.skin.backgroundImageRO;
		parent.settings.user.skin.dialogBackgroundImage = parent.settings.user.skin.dialogBackgroundImageRO;
	}	
		
	for(var i = 0; i < parent.settings.skin.preset.length; i++)
	{
		if(	
			parent.settings.user.skin.customBg == 4 || 
			parent.settings.skin.preset[i].id == _global.FlashChatNS.selectedSkin
		  )
		{
			parent.settings.skin.preset[i].backgroundImage = parent.settings.skin.preset[i].backgroundImageRO;
			parent.settings.skin.preset[i].dialogBackgroundImage = parent.settings.skin.preset[i].dialogBackgroundImageRO;
			if(
				parent.settings.skin.preset[i].id == _global.FlashChatNS.selectedSkin &&
				this.cbShowBackgroundImages.getValue()
			  )
			{ 
				parent.applyBackground(parent.settings.skin.preset[i]);
			}
		}	
	}
};

_global.EffectsTab.prototype.imageLoaded = function(inImg)
{
	var w2h  = this.photo.image_mc.width/this.photo.image_mc.height;
	var cw2h = 3/4;
	
	if(
		this.photo.image_mc.width > this.photo.frame_width ||
		this.photo.image_mc.height > this.photo.frame_height
	  )
	{
		
		var w = this.photo.frame_width;
		var h = this.photo.frame_height;
		
		if(w2h < cw2h)
		{
			w = w2h*this.photo.frame_height;
			h = this.photo.frame_height;
		}
		else if(w2h > cw2h)
		{
			w = this.photo.frame_width;
			h = 1/w2h * this.photo.frame_width;
		}
		
		this.photo.image_mc.image_mc._width  = w;
		this.photo.image_mc.image_mc._height = h;
	}	
	else
	{
		
	}
};

_global.EffectsTab.prototype.doLoadImage = function(imageURL)
{
	var filterURL = filterImgUrl(imageURL);
	
	this.photo.image_mc.removeMovieClip();
	this.photo.image_mc = this.photo.attachMovie('Image', 'image_mc', 1, {_x : 1, _y : 1});
	this.photo.image_mc.setHandler('imageLoaded', this);
	
	if(imageURL != '')
	{
		this.nick_image = imageURL;
		this.photo.image_mc.loadImage(filterURL, true, true);
	}
};


Object.registerClass('EffectsTab', _global.EffectsTab);

#endinitclip
