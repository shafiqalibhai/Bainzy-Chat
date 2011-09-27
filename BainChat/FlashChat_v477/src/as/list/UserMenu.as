#initclip 10

_global.UserMenu = function() {
	this.listener = null;
	this.user = null;
	
	this.settings = _global.FlashChatNS.chatUI.settings.user;
};

_global.UserMenu.prototype = new MovieClip();

//PUBLIC METHODS.

_global.UserMenu.prototype.setup = function(inLabelList, inActiveList, inListener, inUser) {
	this.listener = inListener;
	this.user = inUser;
	
	if(this._parent.selectedUser._parent.item['id'] != inUser['id'])
	{ 
		this._parent.selectedUser.onRollOut(true);//unselect old menu
		this._parent.selectedUser2.onRollOver(true);
	}
		
	var maxWidth = 0;	
	
	for (var i = 0; i < inLabelList.length; i ++) {
		this.attachMovie('UserMenuButtonContainer', 'menuItem_' + i, i);
		var menuItem = this['menuItem_' + i];
		
		menuItem.hash = i;
		menuItem.max_hash = inLabelList.length;
		
		menuItem.txtLabel.autoSize = 'left';
		
		setTextProperty('size', this.settings.text.itemToChange.interfaceElements.fontSize, menuItem.txtLabel, true);
		setTextProperty('font', this.settings.text.itemToChange.interfaceElements.fontFamily, menuItem.txtLabel, true);
		
		menuItem.txtLabel.text = inLabelList[i] + ' ';
		menuItem.txtLabel.textColor = globalStyleFormat.textColor;
		
		menuItem._y = i * menuItem.txtLabel._height;
		menuItem.menuButton._height = menuItem.txtLabel._height + 2.0;
		
		menuItem.menuButton.onRollOver = function()
		{ 
			inListener.onUserMenuMouseOver();
			
			this.gotoAndStop('over');
			this._parent._parent.setBtnFrame(this.over_mc, this._parent.hash, this._parent.max_hash); 
		}
		
		menuItem.menuButton.onRollOut = function()
		{ 
			this.gotoAndStop('up');
			this._parent._parent.setBtnFrame(this.up_mc, this._parent.hash, this._parent.max_hash);
		}
		
		if (maxWidth < menuItem.txtLabel._width) {
			maxWidth = menuItem.txtLabel._width;
		}

		if (inActiveList[i])
		{
			menuItem.menuButton.onRelease = function()
			{
				this._parent._parent.processButton(this._parent.txtLabel.text.substr(0,this._parent.txtLabel.text.length-1));
			};
			menuItem.menuButton.onPress = function()
			{
				this.gotoAndStop('down');
				this._parent._parent.setBtnFrame(this.down_mc, this._parent.hash, this._parent.max_hash); 
			}
		} else
		{ 
			menuItem.menuButton.enabled = false;
		}
		
		this.setBtnFrame(menuItem.menuButton.up_mc, i, inLabelList.length);
	}

	for (var i = 0; i < inLabelList.length; i ++) {
		var menuItem = this['menuItem_' + i];
		menuItem.menuButton._width = maxWidth + menuItem.txtLabel._x + 10;
	};
};

//PRIVATE METHODS.

_global.UserMenu.prototype.setBtnFrame = function(state_mc, ind, len)
{
	if(ind == 0) state_mc.gotoAndStop('top');
	else if(ind < (len - 1)) state_mc.gotoAndStop('middle');
	else if(ind == (len - 1)) state_mc.gotoAndStop('bottom');
	
	var myColor;
	switch(state_mc._name)
	{
		case 'up_mc' : 
			myColor = new Color(state_mc.face);
			myColor.setRGB(globalStyleFormat.background);
			break;
		case 'over_mc' : 
			myColor = new Color(state_mc.face);
			myColor.setRGB(globalStyleFormat.selection);
			break;
		case 'down_mc' : 
			myColor = new Color(state_mc.face);
			myColor.setRGB(darker(globalStyleFormat.selection));
			break;
	}
	
	myColor = new Color(state_mc.highlight);
	myColor.setRGB(globalStyleFormat.highlight);
	
	myColor = new Color(state_mc.shadow);
	myColor.setRGB(globalStyleFormat.darkshadow);
	
	myColor = new Color(state_mc.line);
	myColor.setRGB(brighter(globalStyleFormat.darkshadow));
	
	myColor = new Color(state_mc.line1);
	myColor.setRGB(brighter(globalStyleFormat.darkshadow));
	
	myColor = new Color(state_mc.line2);
	myColor.setRGB(brighter(globalStyleFormat.darkshadow));
	
}

_global.UserMenu.prototype.processButton = function(inMenuItem) {
	this.listener.onUserMenuClick(this.user, inMenuItem);
	this._parent.selectedUser.onRollOut(true);
	this.removeMovieClip();
};

_global.UserMenu.prototype.onMouseDown = function() {
	if ((this._xmouse < 0) || (this._xmouse > this._width) || (this._ymouse < 0) || (this._ymouse > this._height)) 
	{		
		this._parent.selectedUser.onRollOut(true);
		this.removeMovieClip();
	}
};

Object.registerClass('UserMenu', _global.UserMenu);

#endinitclip
