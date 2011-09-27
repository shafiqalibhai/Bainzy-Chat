#initclip 10

_global.ItemUser = function() {
	this.item = null;
	this.style = null;
	this.language = null;
	this.txtUserName.autoSize = 'left';
	
	this.parent = _global.FlashChatNS.chatUI;
	
	var fsize = this.parent.settings.user.text.itemToChange.interfaceElements.fontSize;
	var ffamily = this.parent.settings.user.text.itemToChange.interfaceElements.fontFamily;
	setTextProperty('size', fsize, this.txtUserName, true);
	setTextProperty('font', ffamily, this.txtUserName, true);

	this.blink_id   = null;
	this.blink_type = 0;

	this.minIcon._visible = false;
	
	this.minIcon.onPress = function()
	{ 
		this._parent.processMinMaximize();
	};
	
	this.button.onRelease = function() {
		this._parent.processButton();
	};
	
	this.button.onRollOver = function(c) 
	{	
		this._parent.parent.mc.userMenuContainer.selectedUser2 = this;
		
		if(this._parent.parent.mc.userMenuContainer.userMenu._x != undefined && c!=true) return;
		
		this._parent.parent.mc.userMenuContainer.selectedUser.onRollOut();
		
		this._parent.parent.mc.userMenuContainer.selectedUser = this;
		
		var c = new Color(this);
		//this._parent.btnRGB = c.getRGB();								
		c.setRGB(this._parent.style.userBackgroundDarker);	
		
		this._parent.parent.soundObj.attachSound('UserMenuMouseOver');
	};
	
	this.button.onRollOut = this.button.onReleaseOutside = function(c) 
	{		
		if(this._parent.parent.mc.userMenuContainer.userMenu._x != undefined && c != true || this._parent.blink_type != 0) return;
		var c = new Color(this);		
		c.setRGB(this._parent.style.userBackground);
	};
	
	this.userIcon.onPress = function()
	{
		this._parent.processAvatar();	
	};
};

_global.ItemUser.prototype = new MovieClip();

//PUBLIC METHODS.

_global.ItemUser.prototype.setData = function(inItem) {
	this.setAvatar(inItem);
	
	this.item = inItem;
	if(this.item.label == undefined) return;
	if (this.item.minIconVisible != undefined) this.minIcon._visible = this.item.minIconVisible;
	if (this.item.blink_type != null) this.blink_type = this.item.blink_type;
	if (this.item.blink_id != null) this.startBlinking(this.blink_type);
	
	if(this.item.textProp != undefined)
	{
		for(var itm in this.item.textProp)
			setTextProperty(itm, this.item.textProp[itm], this.txtUserName, true);
	}
	
	var stateString = null;
	var state = this.item.getState();
	switch (state) {
		case 1 :
			break;
		default :
			if(state <= ChatUI.prototype.USER_STATE_LIST.length)
			{ 
				for(var i = 0; i < ChatUI.prototype.USER_STATE_LIST.length; i++)
				{ 
					if(ChatUI.prototype.USER_STATE_LIST[i][0] == state)
						stateString = ChatUI.prototype.USER_STATE_LIST[i][1];
				}
			}
	}
	
	var userName = this.item.label + (stateString == null ? '' : ' (' + stateString + ')');
	this.txtUserName.htmlText = userName;
	this.button._height = Math.ceil(this.txtUserName._height);
	
	this.userIcon._xscale = this.userIcon._yscale = this.button._height / 25 * 100;
	this.minIcon._xscale  = this.minIcon._yscale  = this.button._height / 25 * 100;
	
	var icon_height = this.userIcon._height;
	
	if(this.userIcon.avatar_mc.pref_height != undefined)
	{ 
		icon_height = (this.userIcon.avatar_mc.pref_height*this.userIcon.avatar_mc._yscale)/100;
	}
	
	this.userIcon._y = (this.button._height - icon_height + 2)/2;
	this.minIcon._y  = (this.button._height - this.minIcon._height + 1)/2;
	
	this.userIcon._x = 4; 
	var icon_width   = this.userIcon._width;
	
	if(this.userIcon.avatar_mc.pref_width != undefined)
	{ 
		icon_width = (this.userIcon.avatar_mc.pref_width*this.userIcon.avatar_mc._xscale)/100 - 3;
	}
		
	this.txtUserName._x = this.userIcon._x + icon_width + 2;
	
	var userNameTextFormat = this.txtUserName.getTextFormat();
	
	var userColor = (!this._parent._parent.isColored)? this.parent.settings.user.userColor : inItem.getColor();
	userNameTextFormat.color = userColor;
	
	this.txtUserName.setTextFormat(userNameTextFormat);
	
	var adm = this.language.desktop.adminSign;
	if (
		((this.item.getRoles() & this.item.ROLE_ADMIN) > 0) 
		&& (this.style != null) 
		&& (this.language != null) 
		&& (adm.trim() != '')
	   ) 
	{
		var oldColor = this.txtUserName.getTextFormat().color;
		var tf = this.txtUserName.getTextFormat();//new TextFormat();
		tf.color = this.style.enterRoomNotify;
		this.txtUserName.htmlText = adm + this.txtUserName.htmlText;
		this.txtUserName.setTextFormat(0, adm.length, tf);		
		tf.color = oldColor;
		this.txtUserName.setTextFormat(adm.length, this.txtUserName.length, tf);		
	}
};

_global.ItemUser.prototype.setAvatar = function(inItem) {
	var user   = this.parent.getUser(inItem.id);
	var avatar = user.getAvatar('room');
	if(avatar != '' && avatar != undefined)
	{ 
		var obj = this.parent.findSmile('patternStr', avatar);
		this.userIcon.gotoAndStop('avatar');
		this.userIcon.attachMovie(obj.patternIcon, 'avatar_mc', 2);
		
		var w = _global.FlashChatNS.SMILIES[obj.patternIcon].width;
		var h = _global.FlashChatNS.SMILIES[obj.patternIcon].height;
		
		this.userIcon.avatar_mc.pref_width = w;
		if(obj.iconWidth != undefined) this.userIcon.avatar_mc.pref_width = obj.iconWidth;
		this.userIcon.avatar_mc.pref_height = h;
		
		var w2h = w/h, txt_h = this.button._height - 4;
		this.userIcon.avatar_mc._xscale = (txt_h*w2h)/w * 100;
		this.userIcon.avatar_mc._yscale = txt_h/h * 100;
	}
	else
	{ 
		this.userIcon.avatar_mc.removeMovieClip();
		this.userIcon.gotoAndStop(_global.FlashChatNS.BIG_SKIN_NAME);
	}
};

_global.ItemUser.prototype.applyStyle = function(inStyle) {
	if (inStyle != null) {
		this.style = inStyle;
		if(inStyle.userBackground != undefined)
		{
			var c = new Color(this.button);
			c.setRGB(this.style.userBackground);
			
		}
		else
		{
			var c = new Color(this.button);
			c.setRGB(_global.FlashChatNS.userListStyle.userBackground);
		}
		
		this.userIcon.gotoAndStop(_global.FlashChatNS.BIG_SKIN_NAME);
		this.minIcon.gotoAndStop(_global.FlashChatNS.BIG_SKIN_NAME);
		
		switch(_global.FlashChatNS.BIG_SKIN_NAME)
		{
			case 'default_skin': 
				var sets = new Object();
				
				var mc = this.userIcon.default_icon_mc;
				sets.fillType = 'none';
				sets.figure = 'icon_plus_default';
				mc._width = mc._height = 15;
				fillGradient(mc, 0x000000, sets);
				
				var c = new Color(this.minIcon.default_icon_mc.wins_mc);
				c.setRGB(darker(_global.FlashChatNS.userListStyle.roomBackground));
				
				sets.fillType = 'radial';
				sets.figure = 'icon_roundrect_default';
				sets.corners = [false, false, false, false];
				fillGradient(this.minIcon.default_icon_mc.bg1_mc, _global.FlashChatNS.userListStyle.roomBackground, sets);
				fillGradient(this.minIcon.default_icon_mc.bg2_mc, _global.FlashChatNS.userListStyle.roomBackground, sets);
			break;
			case 'xp_skin': 
				var sets = new Object();
				sets.fillType = 'radial';
				sets.figure = 'icon_roundrect_xp';
				sets.corners = [false, false, true, true];
				fillGradient(this.minIcon.xp_icon_mc.bg1_mc, _global.FlashChatNS.userListStyle.roomBackground, sets);
				//fillGradient(this.minIcon.xp_icon_mc.bg2_mc, _global.FlashChatNS.userListStyle.roomBackground, sets);
			break;
			case 'gradient_skin': case 'aqua_skin':
				var sets = new Object();
				sets.fillType = 'radial';
				sets.figure = 'icon_circle';
				
				fillGradient(this.userIcon.gradient_icon_mc, _global.FlashChatNS.userListStyle.roomBackground, sets);
				
				sets.fillType = 'radial';
				sets.figure = 'icon_roundrect_gradient';
				sets.corners = [true, true, true, true];
				fillGradient(this.minIcon.gradient_icon_mc.bg_mc, _global.FlashChatNS.userListStyle.roomBackground, sets);
				
				var c = new Color(this.minIcon.gradient_icon_mc.wins_mc);
				c.setRGB(ex_brighter(_global.FlashChatNS.userListStyle.roomBackground, 0.35));
			break;
			default: 
			break;
		}
		
		this.setData(this.item);
	}
};

_global.ItemUser.prototype.applyTextProperty = function(propName, val) {
	if (this.item.textProp == undefined) this.item.textProp = new Object();
	this.item.textProp[propName] = val;
	
	this.setData(this.item);
}

_global.ItemUser.prototype.setLanguage = function(inLanguage) {
	this.language = inLanguage;
	this.setData(this.item);
};

_global.ItemUser.prototype.setWidth = function(inPreferrableWidth, inMaxWidth) {
	this.button._width = inMaxWidth - 1;
	this.userIcon._x = 4; 
	this.txtUserName._x = this.userIcon._x + this.userIcon._width + 2;
	this.minIcon._x = this.button._width - this.minIcon._width - 4;
};

_global.ItemUser.prototype.getEnabled = function() {
	return this.button.enabled;
};

_global.ItemUser.prototype.setEnabled = function(inEnabled) {
	this.button.enabled = inEnabled;
	this.minIcon.enabled = inEnabled;
};

_global.ItemUser.prototype.showMinimizeIcon = function(inShow) {
	this.minIcon._visible = inShow;
	this.item.minIconVisible = this.minIcon._visible;
};

_global.ItemUser.prototype.refreshItem = function()
{
	if(this.style != null) this.applyStyle(this.style);
	else this.setData(this.item);
}

_global.ItemUser.prototype.startBlinking = function( inType )
{
	if(this.blink_id == null)
	{ 
		clearInterval( this.blink_id );
		this.blink_id = setInterval(this, 'blink', 50, this, inType);
		this.item.blink_id = this.blink_id;
		
		this.blink_type = inType;
		this.item.blink_type = this.blink_type;
		
		if(inType == 1) 
		{
			var c = new Color(this.button);
			c.setRGB(this.style.roomBackgroundDarker);		
		}
	}	
}

_global.ItemUser.prototype.blink = function( trg, inType )
{
	var step = trg.blink_idx ? 10 : -10;
	
	var src = trg.minIcon;
	if(inType != 0) src = trg.button;
	
	src._alpha += step;
	
	if(src._alpha <= 10) trg.blink_idx = true; 
	else if(src._alpha >= 100) trg.blink_idx = false;
}

_global.ItemUser.prototype.stopBlinking = function(inType)
{
	clearInterval( this.blink_id );
	this.blink_id       = null;
	this.item.blink_id  = null;
	this.blink_type      = 0;
	this.item.blink_type = 0;
	
	
	if(inType == 0) this.minIcon._alpha = 100;
	else
	{
		this.button._alpha = 100;
		var c = new Color(this.button);
		c.setRGB(this.style.userBackground);		
	}
	
}
//PRIVATE METHODS.

_global.ItemUser.prototype.processMinMaximize = function()
{
	this.item.getItemListener().onUserMinIconClick(this.item);
	this.stopBlinking(0);
}

_global.ItemUser.prototype.processAvatar = function()
{
	var sp = ''; 
	if(
		this.parent.mc.msgTxt.text.charAt(this.parent.mc.msgTxt.text.length-1) != ' ' &&
		this.parent.mc.msgTxt.text.length > 0
	  ) 
		sp += ' ';
	
	this.parent.mc.msgTxt.text += sp + this.item.label + ' ';
	this.parent.mc.sendBtn.setEnabled(true);
}

_global.ItemUser.prototype.processButton = function() {
	//here we trasform local button coordinates into global ones.
	var pointMouse = new Object();
	pointMouse.x = this._xmouse;
	pointMouse.y = this._ymouse;
	
	if(pointMouse.x > this.txtUserName._x)
	{ 
		this.localToGlobal(pointMouse);
		var pointLT = new Object();
		pointLT.x = this.button._x;
		pointLT.y = this.button._y;
		this.localToGlobal(pointLT);
		var pointRB = new Object();
		pointRB.x = this.button._x + this.button._width;
		pointRB.y = this.button._y + this.button._height;
		this.localToGlobal(pointRB);
		pointRB.x -= pointLT.x;
		pointRB.y -= pointLT.y;
		
		this.item.getItemListener().onUserClick(this.item, pointMouse.x, pointMouse.y, pointLT.x, pointLT.y, pointRB.x, pointRB.y);
	}
	else this.processAvatar();
};

Object.registerClass('ItemUser', _global.ItemUser);

#endinitclip
