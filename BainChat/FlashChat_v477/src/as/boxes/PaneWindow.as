#initclip 10

_global.PaneWindow = function() {
	super();
	
	this.setResizable(false);
	
	this.isCanceled = false;
	this.dockState = false;
	this.minButtonVisible = true;
	this._visible = false;
	
	this.content_mc.mc = null;
	
	this.content_obj = new Object();
	this.content_obj.dockWidth  = 100;
	this.content_obj.dockHeight = 100; 
	this.content_obj.minWidth   = 100;
	this.content_obj.minHeight  = 100;
	
	this.last_size = this.getSize();
	this.setSize(this.last_size.width, this.last_size.height);
};

_global.PaneWindow.prototype = new DialogBox();

//PUBLIC METHODS.

_global.PaneWindow.prototype.setMinButtonEnabled = function(inEnabled) {
	this.dbMinTopRight.trBtn.btnMin.setEnabled(inEnabled);
};

_global.PaneWindow.prototype.initializeDialog = function() {
	super.initializeDialog();
	this.dbMinTopRight.trBtn.btnMin.setClickHandler('onMinimize', this);
};

_global.PaneWindow.prototype.setDockState = function(inState, inPos) {
	this.dockState = inState;
	
	if(!this.dockState && !this.content_mc._visible) this.onMinimize();
	
	super.setDraggable(this.dockState);
	this.content_mc.mc.enablePressHandler(!inState);
	
	var val = (this.dockState)? this.dbTop._height + 1 : 1;
	this.content_mc._y = val;
	this.setResizable(this.dockState);
	
	var dim = this.getSize();
	
	var pw = this.content_obj.dockWidth  / 100;
	var ph = this.content_obj.dockHeight / 100;
	
	if(inState)
	{ 
		pw = (isNaN(pw))? 1 : pw;
		ph = (isNaN(ph))? 1 : ph;
	}
	else
	{
		pw = ph = 1;
	}
	
	this.setSize(dim.width * pw, dim.height * ph);
	
	this.showWindowBody(this.dockState);
	
	if(inPos != undefined)
	{
		this._x = inPos.x;
		this._y = inPos.y;
	}
	
	this.content_mc._visible = true;
};

_global.PaneWindow.prototype.showWindowBody = function(inVal, inShow)
{
	inShow = (inShow != undefined);
	
	this.dbTopLeft._visible = inVal || inShow;
	this.dbTop._visible = inVal || inShow;
	this.dbMinTopRight._visible = inVal || inShow;
	this.dbTopRight._visible = inVal || inShow;
	
	this.dbLeft._visible = inVal;
	this.dbCenter._visible = inVal;
	this.dbRight._visible = inVal;
	
	this.dbBottomLeft._visible = inVal;
	this.dbBottom._visible = inVal;
	this.dbBottomRight._visible = inVal;
	
	this.background._visible = inVal || inShow;
	
	this.dialogEnabled = inVal || inShow;
	this.border._visible = inVal || inShow;
	
	this.content_mc.mc.customListView_border._visible = !(inVal || inShow);
	this.content_mc.mc.optionPanelBG._visible = !inVal;
};

_global.PaneWindow.prototype.setEnabled = function(inDialogEnabled) {
	super.setEnabled(inDialogEnabled);
	super.setDraggable(inDialogEnabled&&this.dockState);
	
	this.setMinButtonEnabled(inDialogEnabled);
	this.content_mc.mc.setEnabled(inDialogEnabled);
};

_global.PaneWindow.prototype.setSettings = function(inSettings) {
	this.settings = inSettings;
};

_global.PaneWindow.prototype.show = function() {
	this.isCanceled = false;
	Key.addListener(this);
	this._visible = true;
};

_global.PaneWindow.prototype.hide = function() {
	this._visible = false;
};

_global.PaneWindow.prototype.canceled = function() {
	return this.isCanceled;
};

_global.PaneWindow.prototype.initialized = function() {
	return (super.initialized());
};

_global.PaneWindow.prototype.setContentObject = function(inObj) {
	// ==> .dockWidth, .dockHeight, .minWidth, .minHeight
	this.content_obj = inObj;
};

_global.PaneWindow.prototype.createContentMC = function(inName, inDepth)
{
	this.content_mc.mc = this.content_mc.createEmptyMovieClip(inName, inDepth);
	return (this.content_mc.mc);
};

_global.PaneWindow.prototype.setContent = function(inName, postObj, postFunc) {
	this.content_mc.mc = this.content_mc.attachMovie(inName, inName, 1);
	this.content_mc.mc.setPane(this);
	
	if(postObj != undefined)
	{ 
		this.onEnterFrame = function()
		{
			if( this.content_mc.mc.msgTxt.setTextFormat != undefined )
			{ 
				postObj[postFunc](this);
				delete(this.onEnterFrame);
			}
		}
	}
	
	return (this.content_mc.mc);
};

_global.PaneWindow.prototype.applyTextProperty = function(propName, val, targetObj)
{
};

_global.PaneWindow.prototype.applyStyle = function(inStyle) {
	super.applyStyle(inStyle);
	this.applyBackground(inStyle);
};

_global.PaneWindow.prototype.applyBackground = function(inStyle) {
	super.applyBackground(inStyle);
};

_global.PaneWindow.prototype.applyLanguage = function(inLanguage) {
};

_global.PaneWindow.prototype.setSize = function(inWidth, inHeight) {
	if(this.dockState)
	{ 
		if(inWidth < this.content_obj.minWidth)  
			inWidth = this.content_obj.minWidth;
		if(inHeight < this.content_obj.minHeight) 
			inHeight = this.content_obj.minHeight;
	}
	
	var val = (this.dockState)? this.dbTop._height + 1 : 1;
	
	if(this.symbolName == 'userList')
	{ 
		super.setSize(inWidth, inHeight);
		this.content_mc.mc.setSize(inWidth, inHeight - val);
	}
	else if(this.symbolName == 'inputTextArea')
	{ 
		super.setSize(inWidth, inHeight + val);
		
		var o = this.content_mc.mc;
		var SPACER = _global.FlashChatNS.chatUI.SPACER;
		
		if(o.msgTxt.htmlText == undefined || !this.dockState) return;
		
		var btn_width = o.sendBtn._width; 
		o.sendBtn._x = inWidth - (o.sendBtn._width + SPACER);
		
		var html_txt = o.msgTxt.htmlText;
		html_txt = html_txt.split("> ").join(">&nbsp;");
		
		var msg_h = (this.content_obj.op_visible)? inHeight - (o.optionPanel._height + 4*SPACER) : inHeight - 3*SPACER;
		var msg_w = o.sendBtn._x - 2*SPACER;
		o.msgTxt.setSize(msg_w, msg_h);
		
		o.msgTxt.htmlText = html_txt;
		
		o.msgTxtBackground._width = msg_w - 1;
		o.msgTxtBackground._height = msg_h - 1;
		
		msg_h = (this.content_obj.minHeight > msg_h)? msg_h : this.content_obj.minHeight;
		o.sendBtn.setSize(o.sendBtn.width, msg_h);
		
		o.sendBtn._x += btn_width - o.sendBtn._width;
	}
	else if(this.symbolName.indexOf('modulePane_') != -1 && this.symbolName != null)
	{
		super.setSize(inWidth, inHeight + val);
		
		this.content_mc.mc.mask._width = inWidth;
		this.content_mc.mc.mask._height = inHeight;
		
		//module
		var mod_i = this.id;
		if(this.content_mc.mc != undefined)
			if(_level0.ini.module[mod_i].stretch==1)
			{
				_global.FlashChatNS.chatUI.callModuleFunc('mOnModuleWindowResize', {width : inWidth, height : inHeight}, mod_i);
				
				if(this.content_mc.mc.mOnModuleWindowResize == undefined)
				{
					this.content_mc.mc._xscale = (inWidth/this.content_obj.minWidth) * 100;	
					this.content_mc.mc._yscale = (inHeight/this.content_obj.minHeight) * 100;
				}
			}
			else
			{
				_global.FlashChatNS.chatUI.callModuleFunc('mOnModuleWindowResize', {width :this.content_obj.minWidth, height : this.content_obj.minHeight}, mod_i);
			}
	}
	
	this.last_size = this.getSize();
	
	this.preff_size.width  = this.content_obj.minWidth;
	this.preff_size.height = this.content_obj.minHeight + (this.symbolName == 'userList'? 0 : val);
};

//PRIVATE METHODS.
_global.PaneWindow.prototype.onKeyDown = function() {
	if (Key.isDown(Key.ESCAPE)) this.onClose();
};

_global.PaneWindow.prototype.onClose = function() {
	_global.FlashChatNS.chatUI.soundObj.attachSound('PopupWindowOpen');
	
	this.setResizable(false);
	super.setSize(this.last_size.width, this.dbTop._height + 1);	
	this.content_mc._visible = false;
	this.showWindowBody(false, true);
};

_global.PaneWindow.prototype.onMinimize = function(withoutSound) {
	if(withoutSound != true)
		_global.FlashChatNS.chatUI.soundObj.attachSound('PopupWindowCloseMin');
	
	//this.stopBlinking(0);
	
	this.setResizable(true);
	super.setSize(this.last_size.width, this.last_size.height);
	this.content_mc._visible = true;
	
	this.showWindowBody(true);
};

Object.registerClass('PaneWindow', _global.PaneWindow);

#endinitclip
