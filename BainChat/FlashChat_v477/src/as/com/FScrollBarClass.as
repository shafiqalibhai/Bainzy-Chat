#initclip 1

/*
		FScrollBarClass
		EXTENDS FUIComponentClass
	
*/

FScrollBarClass = function()
{
	if (this._height==4) {
		return	;
	}
	this.init();

	this.minPos = this.maxPos = this.pageSize = this.largeScroll = 0;
	this.smallScroll = 1;
	
	this.autoHide = false;
	this.scroll_thumb_state = this.STATE_OUT;
	
	this.width = (this.horizontal) ? this._width : this._height;
	this._xscale = this._yscale = 100;
	this.setScrollPosition(0);
	this.tabEnabled = false;
	if ( this._targetInstanceName.length > 0 ) {
		this.setScrollTarget(this._parent[this._targetInstanceName]);
	}
	this.tabChildren = false;
	this.setSize(this.width);
}

FScrollBarClass.prototype = new FUIComponentClass();

//  ::: PUBLIC METHODS

FScrollBarClass.prototype.setHorizontal = function(flag)
{
	if (this.horizontal && !flag) {
		this._xscale = 100;
		this._rotation = 0;
	} else if (flag && !this.horizontal) {
		this._xscale = -100;
		this._rotation = -90;
	}
	
	this.horizontal = flag;
}

// updates the thumb, turns the bar on and off
FScrollBarClass.prototype.setScrollProperties = function(pSize, mnPos, mxPos)
{
	if (!this.enable) {
		return ;
	}
	
	this.pageSize = pSize;
	this.minPos = Math.max(mnPos, 0);
	this.maxPos = Math.max(mxPos,0);
	this.scrollPosition = Math.max(this.minPos, this.scrollPosition);
	this.scrollPosition = Math.min(this.maxPos, this.scrollPosition);
	
	if (this.maxPos-this.minPos<=0) { // turn it off
		//--old version--
		//this.scrollThumb_mc.removeMovieClip();
		//--old version--
		this.scrollThumb_mc._visible = false;
		this.upArrow_mc.gotoAndStop(3);
		this.downArrow_mc.gotoAndStop(3);
		this.downArrow_mc.onPress = this.downArrow_mc.onRelease = this.downArrow_mc.onDragOut = null;
		this.upArrow_mc.onPress = this.upArrow_mc.onRelease = this.upArrow_mc.onDragOut = null;
		this.scrollTrack_mc.onPress = this.scrollTrack_mc.onRelease = null;
		this.scrollTrack_mc.onDragOut = this.scrollTrack_mc.onRollOut = null;
		this.scrollTrack_mc.useHandCursor = false;
		
		if(this.autoHide) 
		{ 
			this.upArrow_mc._visible = false;
			this.downArrow_mc._visible = false;
			this.scrollTrack_mc._visible = false;
		}
	} else { // turn it on
		var tmp = this.getScrollPosition();
		this.upArrow_mc.gotoAndStop(1);
		this.downArrow_mc.gotoAndStop(1);
		this.upArrow_mc.onPress = this.upArrow_mc.onDragOver = this.startUpScroller;
		this.upArrow_mc.onRelease = this.upArrow_mc.onDragOut = this.stopScrolling;
		this.upArrow_mc.onRollOver = this.startRollOverUpArrow;
		this.upArrow_mc.onRollOut = this.startRollOutUpArrow;
		this.downArrow_mc.onPress = this.downArrow_mc.onDragOver = this.startDownScroller;
		this.downArrow_mc.onRelease = this.downArrow_mc.onDragOut = this.stopScrolling;
		this.downArrow_mc.onRollOver = this.startRollOverDownArrow;
		this.downArrow_mc.onRollOut = this.startRollOutDownArrow;
		
		//------------------------------------------------------------------------------------------------//
		this.scrollTrack_mc.gotoAndStop(this.getSkinFrame());
		//------------------------------------------------------------------------------------------------//
		
		this.scrollTrack_mc.onPress = this.scrollTrack_mc.onDragOver = this.startTrackScroller; 
		this.scrollTrack_mc.onRelease = this.stopScrolling;
		this.scrollTrack_mc.onDragOut = this.stopScrolling;
		this.scrollTrack_mc.onRollOut = this.stopScrolling;
		this.scrollTrack_mc.useHandCursor = false;
		
		if(this.scrollThumb_mc == undefined) 	this.attachMovie("ScrollThumb", "scrollThumb_mc", 3);
		else this.scrollThumb_mc._visible = true;
		
		//------------------------------------------------------------------------------------------------//
		if(this.scrollThumb_mc._currentframe != this.getSkinFrame())
		{ 
			this.scrollThumb_mc.gotoAndStop(this.getSkinFrame());
			this.scrollThumb_mc.clear();
		}
		//------------------------------------------------------------------------------------------------//
		
		var thumb_x = 0;
		if(this.getSkinFrame() == 3) 
			thumb_x = (this.upArrow_mc._height - this.scrollThumb_mc.mc_sliderMid._width) / 2 + 0.5;
			
		this.scrollThumb_mc._x = thumb_x;	
		
		this.scrollThumb_mc._y = this.upArrow_mc._height;
		this.scrollThumb_mc.onPress = this.startDragThumb;
		this.scrollThumb_mc.controller = this;
		this.scrollThumb_mc.onRelease = this.scrollThumb_mc.onReleaseOutside = this.stopDragThumb;
		this.scrollThumb_mc.onRollOver = this.startRollOverThumb;
		this.scrollThumb_mc.onRollOut = this.startRollOutThumb;
		this.scrollThumb_mc.useHandCursor=false;
		
		this.thumbHeight = this.pageSize / (this.maxPos-this.minPos+this.pageSize) * this.trackSize;
		this.thumbMid_mc = this.scrollThumb_mc.mc_sliderMid;
		this.thumbTop_mc = this.scrollThumb_mc.mc_sliderTop;
		this.thumbBot_mc = this.scrollThumb_mc.mc_sliderBot;
		
		//the smallest a thumb should be
		if(this.getSkinFrame() == 3) this.thumbHeight = Math.max (this.thumbHeight, 10); 
		else this.thumbHeight = Math.max (this.thumbHeight, 6);
		
		this.midHeight = this.thumbHeight - this.thumbTop_mc._height - this.thumbBot_mc._height;
		if(this.midHeight < 0) this.midHeight = 0;
		
		//--old version--
		//this.thumbMid_mc._yscale = this.midHeight * 100 / this.thumbMid_mc._height;
		//--old version--
		
		this.thumbMid_mc._height = this.midHeight;
		this.thumbMid_mc._y = this.thumbTop_mc._height;
		this.thumbBot_mc._y = this.thumbTop_mc._height + this.midHeight;
		
		this.thumbFrameMid_mc = this.scrollThumb_mc.mc_frameMid;
		this.thumbFrameMid_mc._x = this.thumbMid_mc._x + (this.thumbMid_mc._width - this.thumbFrameMid_mc._width)/2; 
		this.thumbFrameMid_mc._y = this.thumbMid_mc._y + (this.thumbMid_mc._height - this.thumbFrameMid_mc._height)/2; 
		
		this.scrollTop = this.scrollThumb_mc._y;
		this.trackHeight = this.trackSize - this.thumbHeight;
		this.scrollBot = this.trackHeight + this.scrollTop; 
		tmp = Math.min(tmp, this.maxPos);
		this.setScrollPosition(Math.max(tmp, this.minPos));
		
		if(this.autoHide) 
		{ 
			this.upArrow_mc._visible = true;
			this.downArrow_mc._visible = true;
			this.scrollTrack_mc._visible = true;
		}
	}
	
	//------------------------------------------------------------------------------------------------//
	this.drawFrame(true);
	//------------------------------------------------------------------------------------------------//
}

FScrollBarClass.prototype.getScrollPosition = function ()
{
	return this.scrollPosition;
}

FScrollBarClass.prototype.setScrollPosition = function(pos)
{
	this.scrollPosition = pos;
	if (this.scrollThumb_mc != undefined) {
		pos = Math.min(pos, this.maxPos);
		pos = Math.max(pos, this.minPos);
	}
	this.scrollThumb_mc._y = ((pos-this.minPos) * this.trackHeight / (this.maxPos-this.minPos)) + this.scrollTop;

	this.executeCallBack();
}

FScrollBarClass.prototype.setLargeScroll = function(lScroll)
{
	this.largeScroll = lScroll;	
}

FScrollBarClass.prototype.setSmallScroll = function(sScroll)
{
	this.smallScroll = sScroll;	
}

FScrollBarClass.prototype.setEnabled = function(enabledFlag)
{
	var wasEnabled = this.enable;
	if (enabledFlag && !wasEnabled) {
		this.enable = enabledFlag;
		if (this.textField!=undefined) {
			this.setScrollTarget(this.textField);
		} else {
			this.setScrollProperties(this.pageSize, this.cachedMinPos, this.cachedMaxPos);
			this.setScrollPosition(this.cachedPos);
		}
		this.clickFilter = undefined;
		this.drawScrollThumb(this.STATE_OUT);
	} else if (!enabledFlag && wasEnabled) { 
		this.textField.removeListener(this);
		this.cachedPos = this.getScrollPosition();
		this.cachedMinPos = this.minPos;
		this.cachedMaxPos = this.maxPos;
		if (this.clickFilter==undefined) {
			this.setScrollProperties(this.pageSize,0,0);
		} else {
			this.clickFilter=true;
		}
		this.enable = enabledFlag;
		this.drawScrollThumb(this.STATE_DISABLED);
	}
}


// stretches the track, creates + positions arrows
FScrollBarClass.prototype.setSize = function(hgt)
{
	if (this._height == 1) return;
	this.width = hgt;
	if(this.getSkinFrame() != 4 && this.getSkinFrame() != 2)
	{ 
		this.scrollTrack_mc._yscale = 100;
		this.scrollTrack_mc._yscale = 100 * this.width / this.scrollTrack_mc._height;
	}
	else 	this.scrollTrack_mc._yscale = 100;
	
	if (this.upArrow_mc == undefined) {
		this.attachMovie("UpArrow", "upArrow_mc", 1);  	    //1 is arbitrary
		this.attachMovie("DownArrow", "downArrow_mc", 2);   //2 is arbitrary
		this.downArrow_mc.controller = this.upArrow_mc.controller = this;
		this.upArrow_mc.useHandCursor = this.downArrow_mc.useHandCursor = false;
		this.upArrow_mc._x = this.upArrow_mc._y = 0;
		this.downArrow_mc._x = 0;
		this._arrow_width  = this.upArrow_mc._width;
		this._arrow_height = this.upArrow_mc._height;
	}
	
	this.scrollTrack_mc.controller = this;
	this.downArrow_mc._y = this.width - this.downArrow_mc._height;
	this.trackSize = this.width - (2 * this.downArrow_mc._height);
		
	if (this.textField!=undefined) {
		this.onTextChanged();
	} else {
		this.setScrollProperties(this.pageSize, this.minPos, this.maxPos);
	}
}

FScrollBarClass.prototype.drawSkin = function()
{
	this.drawFrame(true);
}

FScrollBarClass.prototype.drawFrame = function(nForce)
{
	var curr_frame = this.getSkinFrame();
	
	this.scrollTrack_mc.gotoAndStop(curr_frame);
	
	var down_obj = null;
	switch(this.downArrow_mc._currentframe)
	{ 
		case 1 : down_obj = this.downArrow_mc.up; break;
		case 2 : down_obj = this.downArrow_mc.down; break;
		case 3 : down_obj = this.downArrow_mc.disabled; break;
	}
	down_obj.gotoAndStop(curr_frame);
	down_obj.clear();
	
	var up_obj = null;
	switch(this.upArrow_mc._currentframe)
	{ 
		case 1 : up_obj = this.upArrow_mc.up; break;
		case 2 : up_obj = this.upArrow_mc.down; break;
		case 3 : up_obj = this.upArrow_mc.disabled; break;
	}
	up_obj.gotoAndStop(curr_frame);
	up_obj.clear();
	
	this._prev_frame = curr_frame;
	
	if(nForce)	
	{ 
		this.scrollTrack_mc.clear();
	}
		
	var data = {pLink : this, dir : 'vert'};
		
	var w     = this._arrow_width;  
	var h     = this.width;
	
	switch (this.getSkinFrame())
	{
		case 1  : break;
		case 2  : 
			if(nForce)
			{ 
				data.type = this.BG_TYPE_SCROLL;
				_global.xpLook.draw(this.scrollTrack_mc, w, h, data);
			}
			
			this.drawScrollThumb(this.STATE_OUT, nForce);
			
			data.dir = 'vert';
			data.type = this.BTN_TYPE_SCROLL_LOW;
			_global.xpLook.draw(up_obj, this._arrow_width, this._arrow_width, data);
			
			data.type = this.BTN_TYPE_SCROLL_HI;
			_global.xpLook.draw(down_obj, this._arrow_width, this._arrow_width, data);
			break;
		case 3  : break;
		case 4  : 
			if(nForce)
			{ 
				data.type = this.BG_TYPE_SCROLL;
				_global.aquaLook.draw(this.scrollTrack_mc, w, h, data);
			}
			
			this.drawScrollThumb(this.STATE_OUT, nForce);
			
			data.dir = 'vert';
			data.type = this.BTN_TYPE_SCROLL_LOW;
			_global.aquaLook.draw(up_obj, this._arrow_width, this._arrow_width, data);
			
			data.type = this.BTN_TYPE_SCROLL_HI;
			_global.aquaLook.draw(down_obj, this._arrow_width, this._arrow_width, data);
			break;
		default : break;
	};

}


FScrollBarClass.prototype.drawScrollThumb = function(nState, nForce)
{
	if(this.scroll_thumb_state != nState || nForce)
	{ 
		this.scroll_thumb_state = nState;
		
		if(this.scrollThumb_mc == undefined) return;
		
		var data = {pLink : this, type : this.BTN_TYPE_SCROLL, mode : nState, dir  : 'vert'};
		
		this.scrollThumb_mc.clear();
		this.scrollThumb_mc._xscale = this.scrollThumb_mc._yscale = 100;
		if(this.scrollThumb_mc.mask != undefined) this.scrollThumb_mc.mask.removeMovieClip();
		
		switch (this.getSkinFrame())
		{
			case 1  : break;
			case 2  : 
				var w     = this._arrow_width - 0.5;
				var h     = this.thumbHeight + 1;
				_global.xpLook.draw(this.scrollThumb_mc, w, h, data);
				break;
			case 3  : break;
			case 4  : 
				var w     = this._arrow_width;
				var h     = this.thumbHeight;
				_global.aquaLook.draw(this.scrollThumb_mc, w, h, data);
				break;
			default : break;	
		}
	}
}


//   ::: PRIVATE METHODS

FScrollBarClass.prototype.scrollIt = function (inc, mode)
{
	var delt = this.smallScroll;
	if (inc!="one") {
		delt = (this.largeScroll==0) ? this.pageSize : this.largeScroll;
	} 
	var newPos = this.getScrollPosition() + (mode*delt);
	if (newPos>this.maxPos) {
		newPos = this.maxPos;
	} else if (newPos<this.minPos) {
		newPos = this.minPos;
	}
	this.setScrollPosition(newPos);
}

FScrollBarClass.prototype.startRollOverUpArrow = function()
{
	this.state = this._parent.STATE_OVER;
}

FScrollBarClass.prototype.startRollOutUpArrow = function()
{
	this.state = this._parent.STATE_OUT;
}

FScrollBarClass.prototype.startRollOverDownArrow = function()
{
	this.state = this._parent.STATE_OVER;
}

FScrollBarClass.prototype.startRollOutDownArrow = function()
{
	this.state = this._parent.STATE_OUT;
}

FScrollBarClass.prototype.startDragThumb = function()
{
	this.lastY = this._ymouse;
	this.onMouseMove = this.controller.dragThumb;
	this._parent.drawScrollThumb(this._parent.STATE_PRESS);
}

FScrollBarClass.prototype.startRollOverThumb = function()
{
	this._parent.drawScrollThumb(this._parent.STATE_OVER);
}

FScrollBarClass.prototype.startRollOutThumb = function()
{
	this._parent.drawScrollThumb(this._parent.STATE_OUT);
}

FScrollBarClass.prototype.dragThumb = function()
{
	this.scrollMove = this._ymouse - this.lastY;
	this.scrollMove += this._y;
	if (this.scrollMove<this.controller.scrollTop) {
		this.scrollMove = this.controller.scrollTop;
	}
	else if (this.scrollMove>this.controller.scrollBot) {
		this.scrollMove = this.controller.scrollBot;
	}
	this._y = this.scrollMove;
	var c = this.controller;
	c.scrollPosition = Math.round( (c.maxPos-c.minPos) * (this._y - c.scrollTop) / c.trackHeight) + c.minPos;

	this.controller.isScrolling = true;
	updateAfterEvent();
	this.controller.executeCallBack();
}

FScrollBarClass.prototype.stopDragThumb = function()
{
	this.controller.isScrolling = false;
	this.onMouseMove = null;
	this._parent.drawScrollThumb(this._parent.STATE_OUT);
}

FScrollBarClass.prototype.startTrackScroller = function()
{
	this.controller.trackScroller();
	this.controller.scrolling = setInterval(this.controller, "scrollInterval", 500, "page", -1);
}

FScrollBarClass.prototype.scrollInterval = function(inc,mode)
{
	clearInterval(this.scrolling);
	if (inc=="page") {
		this.trackScroller();
	} else {
		this.scrollIt(inc,mode);
	}
	this.scrolling = setInterval(this, "scrollInterval", 35, inc, mode);
}

FScrollBarClass.prototype.trackScroller = function()
{
	if (this.scrollThumb_mc._y+this.thumbHeight<this._ymouse) {
		this.scrollIt("page",1);
	} else if (this.scrollThumb_mc._y>this._ymouse) {
		this.scrollIt("page",-1);
	}
}

FScrollBarClass.prototype.stopScrolling = function()
{
	this.controller.downArrow_mc.gotoAndStop(1);
	this.controller.upArrow_mc.gotoAndStop(1);
	clearInterval(this.controller.scrolling);
	//------------------------------------------------------------------------------------------------//
	this._parent.drawFrame();
	//------------------------------------------------------------------------------------------------//
}

FScrollBarClass.prototype.startUpScroller = function()
{
	this.controller.upArrow_mc.gotoAndStop(2);
	this.controller.scrollIt("one",-1);
	this.controller.scrolling = setInterval(this.controller, "scrollInterval",500, "one", -1);
	//------------------------------------------------------------------------------------------------//
	this._parent.drawFrame();
	//------------------------------------------------------------------------------------------------//
}

FScrollBarClass.prototype.startDownScroller = function()
{
	this.controller.downArrow_mc.gotoAndStop(2);
	this.controller.scrollIt("one",1);
	this.controller.scrolling = setInterval(this.controller, "scrollInterval", 500, "one", 1);
	//------------------------------------------------------------------------------------------------//
	this._parent.drawFrame();
	//------------------------------------------------------------------------------------------------//
}


//
// Begin Special text scroller functions
//


FScrollBarClass.prototype.setScrollTarget = function(tF)
{
	if (tF == undefined) {
		this.textField.removeListener(this);
		delete this.textField[ (this.horizontal) ? "hScroller" : "vScroller" ]; 
		if (!(this.textField.hScroller==undefined) && !(this.textField.vScroller==undefined)) {
			this.textField.unwatch("text");
			this.textField.unwatch("htmlText");
		}
	}
	this.textField = undefined;
	if (!(tF instanceof TextField)) return;
	this.textField = tF;
	this.textField[ (this.horizontal) ? "hScroller" : "vScroller" ] = this; 
	this.onTextChanged();
	this.onChanged = function()
	{
		this.onTextChanged();
	}
	this.onScroller = function()
	{
		if (!this.isScrolling) {
			if (!this.horizontal) {
				this.setScrollPosition(this.textField.scroll);
			} else { 
				this.setScrollPosition(this.textField.hscroll);
			}
		}
	}
	this.textField.addListener(this);
	this.textField.watch("text", this.callback);
	this.textField.watch("htmlText", this.callback);
}

FScrollBarClass.prototype.callback = function(prop, oldVal, newVal)
{
	clearInterval(this.hScroller.synchScroll);
	clearInterval(this.vScroller.synchScroll);
	this.hScroller.synchScroll = setInterval(this.hScroller, "onTextChanged", 50);
	this.vScroller.synchScroll = setInterval(this.vScroller, "onTextChanged", 50);
	return newVal;
}


FScrollBarClass.prototype.onTextChanged = function()
{
	if (!this.enable || this.textField==undefined) return;
	clearInterval(this.synchScroll);
	if (this.horizontal) {
		var pos = this.textField.hscroll;
		this.setScrollProperties(this.textField._width, 0, this.textField.maxhscroll);
		this.setScrollPosition(Math.min(pos, this.textField.maxhscroll));
	} else {
		var pos = this.textField.scroll;
		var pageSize = this.textField.bottomScroll - this.textField.scroll;
		this.setScrollProperties(pageSize, 1, this.textField.maxscroll);
		this.setScrollPosition(Math.min(pos, this.textField.maxscroll));
	}
}

FScrollBarClass.prototype.executeCallBack = function()
{
	if (this.textField==undefined) {
		super.executeCallBack();
	} else {
		if ( this.horizontal ) {
			this.textField.hscroll = this.getScrollPosition();
		} else {
			this.textField.scroll = this.getScrollPosition();
		}
	}
}





Object.registerClass("FScrollBarSymbol", FScrollBarClass);

#endinitclip
