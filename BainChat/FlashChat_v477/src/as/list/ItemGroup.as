#initclip 10

_global.ItemGroup = function() {
	this.item = null;
	this.txtGroupName.autoSize = 'left';
	
	this.parent = _global.FlashChatNS.chatUI;
	
	var fsize = this.parent.settings.user.text.itemToChange.interfaceElements.fontSize;
	var ffamily = this.parent.settings.user.text.itemToChange.interfaceElements.fontFamily;
	setTextProperty('size', fsize, this.txtGroupName, true);
	setTextProperty('font', ffamily, this.txtGroupName, true);
	
	this.button._x = 1;
	this.button._y = 0;
	this.btn_width = 0;
	
	this.enabled = true;

	this.textColor = null;
	this.textColorDarker = null;
	
	this.blink_id = null;
	this.blink_type = 0;
	
	this.lock._visible = false;
	
	this.button.onRelease = function() {
		this._parent.processButton();
	};
};

_global.ItemGroup.prototype = new MovieClip();

//PUBLIC METHODS.

_global.ItemGroup.prototype.setWidth = function(inPreferrableWidth, inMaxWidth) {
	this.button._width = inMaxWidth - 0.5;
	this.btn_width = this.button._width;
};

_global.ItemGroup.prototype.setData = function(inItem) {
	if(inItem == null) return;
	this.item = inItem;
	
	this.setLock(this.item.lock);
	var roomTitle = this.item.label;
	if(this.item.users.length != 0 && this.item.users.length != undefined)
	{ 
		roomTitle = this.parent.replace(this.parent.settings.roomTitleFormat, 'ROOM_LABEL', this.item.label);
		roomTitle = this.parent.replace(roomTitle, 'USER_COUNT', this.item.users.length);
	}
	this.txtGroupName.text = roomTitle;
	
	this.lock._x = this.button._width - this.lock._width - 4;
	this.lock._y = (this.button._height - this.lock._height) / 2;
	
	this.lock._xscale = this.lock._yscale = (this.button._height - 6) * 100 / 16;
		
	if(this.item.textProp != undefined) 
	{ 
		for(var itm in this.item.textProp)
			setTextProperty(itm, this.item.textProp[itm], this.txtGroupName);
	}
	
	this.button._height = Math.ceil(this.txtGroupName._height);
	this.button.enabled = this.enabled && (this.item.getUserCount() > 0);
	
	if(this.button._x == 4)
	{ 
		this.button._x = 1;
		this.button._width = this.btn_width;
	}
	
	if(_global.FlashChatNS.SKIN_ID == 2)
	{ 
		this.arrow.icon_mc._y = -0.5;
		this.arrow.icon_mc._width = this.button._height - 2;
		this.arrow.icon_mc._height = this.button._height - 2;
	}
	else if(_global.FlashChatNS.SKIN_ID == 3)
	{
		if(this.button._x != 4)
		{ 
			this.button._x = 4;
			this.button._width = this.btn_width - 4;
		}
		
		this.arrow.icon_mc._y = - 1.75;
		this.arrow.icon_mc._height = this.button._height - 0.5;
	}
	else if(_global.FlashChatNS.SKIN_ID == 4)
	{
		this.arrow.icon_mc._y = -0.5;
		this.arrow.icon_mc._width = this.button._height - 1;
		this.arrow.icon_mc._height = this.button._height - 1;
	}
	else
	{ 
		this.arrow.icon_mc._xscale = this.button._height / 20 * 100;
		this.arrow.icon_mc._yscale = this.button._height / 20 * 100;
		this.arrow.icon_mc._y = (this.button._height - this.arrow.icon_mc._height) / 2;
	}
	
	this.applySkin();
	
	this.txtGroupName._x = this.arrow.icon_mc._x + this.arrow.icon_mc._width + 3;
};

_global.ItemGroup.prototype.setLock = function( inLock ) {
	this.item.lock = inLock;
	this.lock._visible = inLock; 
};

_global.ItemGroup.prototype.applySkin = function() {
	var groupNameTextFormat = this.txtGroupName.getTextFormat();
	if (this.item.getUserCount() > 0) {
		groupNameTextFormat.color = this.textColor;
		this.arrow.gotoAndStop(this.item.getOpened() ? 'open_' +  _global.FlashChatNS.SKIN_ID : 'close_' +  _global.FlashChatNS.SKIN_ID);
	} else {
		groupNameTextFormat.color = this.textColorDarker;
		this.arrow.gotoAndStop('empty_' +  _global.FlashChatNS.SKIN_ID);
	}
	this.txtGroupName.setTextFormat(groupNameTextFormat);
	
	if(_global.FlashChatNS.SKIN_ID == 2)
	{ 
		var c = new Color(this.arrow.icon_mc.arrow_mc);
		c.setRGB(globalStyleFormat.arrow);
		c = new Color(this.arrow.icon_mc.face_mc);
		c.setRGB(globalStyleFormat.face);
		c = new Color(this.arrow.icon_mc.highlight_mc);
		c.setRGB(globalStyleFormat.face);
		c = new Color(this.arrow.icon_mc.border_mc);
		c.setRGB(globalStyleFormat.highlight3D);
	}
	else if(_global.FlashChatNS.SKIN_ID == 3)
	{
		var c = new Color(this.arrow.icon_mc.border_mc);
		c.setRGB(globalStyleFormat.scrollBorder);
		c = new Color(this.arrow.icon_mc.arrow_mc);
		c.setRGB(globalStyleFormat.arrow);
		
		var inSets = new Object();
		inSets.fillType = 'linear';
		inSets.orientType = 'v';
		inSets.figure = 'rect';
		
		fillGradient(this.arrow.icon_mc.face_mc, globalStyleFormat.scrollFace, inSets);
	}
	else if(_global.FlashChatNS.SKIN_ID == 4)
	{
		var c = new Color(this.arrow.icon_mc.arrow_mc);
		c.setRGB(globalStyleFormat.arrow);
		var c = new Color(this.arrow.icon_mc.face_mc);
		c.setRGB(globalStyleFormat.face);
		var c = new Color(this.arrow.icon_mc.face2_mc);
		c.setRGB(globalStyleFormat.highlight);
	}
};

_global.ItemGroup.prototype.applyStyle = function(inStyle) {
	if (inStyle != null) {
		var c = new Color(this.button.roomButtonCenter);
		c.setRGB(inStyle.roomBackground);
		c = new Color(this.button.roomButtonTopLeft);
		c.setRGB(inStyle.roomBackgroundBrighter);
		c = new Color(this.button.roomButtonBottomRight);
		c.setRGB(inStyle.roomBackgroundDarker);

		this.textColor = inStyle.roomText;
		this.textColorDarker = inStyle.roomTextDarker;
		this.applySkin();
	}
};

_global.ItemGroup.prototype.applyTextProperty = function(propName, val) {
	if (this.item.textProp == undefined) this.item.textProp = new Object();
	this.item.textProp[propName] = val;
	
	this.setData(this.item);
}
//empty implementation.
_global.ItemGroup.prototype.setLanguage = function(inLanguage) {
};

_global.ItemGroup.prototype.getEnabled = function() {
	return this.enabled;
};

_global.ItemGroup.prototype.setEnabled = function(inEnabled) {
	this.enabled = inEnabled;
	this.button.enabled = this.enabled && (this.item.getUserCount() > 0);
};

_global.ItemGroup.prototype.startBlinking = function(inType)
{
	if(this.blink_id == null)
	{ 
		clearInterval( this.blink_id );
		this.blink_id = setInterval(this, 'blink', 50, this, inType);
		
		this.blink_type = inType;
	}	
};

_global.ItemGroup.prototype.blink = function( trg, inType )
{
	var step = trg.blink_idx ? 10 : -10;
	trg.button._alpha += step;
	
	if(trg.button._alpha <= 10) trg.blink_idx = true; 
	else if(trg.button._alpha >= 100) trg.blink_idx = false;
};

_global.ItemGroup.prototype.stopBlinking = function( inType )
{
	clearInterval( this.blink_id );
	this.blink_id      = null;
	this.button._alpha = 100;
	this.blink_type = inType;
};


//PRIVATE METHODS.

_global.ItemGroup.prototype.processButton = function() {
	this.item.getItemListener().onRoomStateChange(this.item);
	this.stopBlinking(0);
};

Object.registerClass('ItemGroup', _global.ItemGroup);

#endinitclip
