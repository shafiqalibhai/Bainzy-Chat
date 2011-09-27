#initclip 10

_global.CustomListView = function() {
	//create background mc.
	this.createEmptyMovieClip('customListView_background', 0);
	this.customListView_background.drawRect2(0, 0, 1, 1, 0, 0, 100, 0xffffff, 100);
	
	//prepare mask movie clip, its initial size will be 1x1.
	this.createEmptyMovieClip('customListView_mask', -10, {_x : -1, _y : -1});
	this.customListView_mask.drawRect2(0, 0, 1, 1, 0.1, 0xffffff, 100, 0xffffff, 100);
		
	this.createEmptyMovieClip('customListView_items', 102);
	
	this.testMCDepth = 0;
	this.createEmptyMovieClip('customListView_testMC', 103);
	this.customListView_testMC._visible = false;
	
	this.freeDepthLevel = 0;

	this.x = 0;
	this.y = 0;
	this.maxHeight = 0;
	this.maxWidth = 0;
	this.totalHeight = 0;
	
	this.firstShownIdx = 0;

	this.enabled = true;

	this.style = inStyle;
	this.language = null;

	this.paneWindow = null;

	this.listWidth = this._width;
	this.listHeight = this._height;

	this.addProperty('_width', this.getPropWidth, this.setPropWidth);
	this.addProperty('_height', this.getPropHeight, this.setPropHeight);

	this.customListView_mask._width = this.listWidth + 2;
	this.customListView_mask._height = this.listHeight + 2;
	this.setMask(this.customListView_mask);

	this.itemWrapperList = new Array();
	this.mcList = new Array();
	this.mcHash = new Object();

	this.customListViewIcon.swapDepths(104);
	this.customListViewIcon._visible = false;
	this.createEmptyMovieClip('customListView_border', 106);
	this.scrollBarRect.swapDepths(105);
	this.vScrollBar.swapDepths(107);
	this.hScrollBar.swapDepths(108);
	
	//!!! uncomment if bugs
	//this.setSize(this.listWidth, this.listHeight);

	this.isColored = true;
	this.selfColor = -1;
	
	this.dataProvider = null;
	this.bWidth  = new Array();
	this.bHeight = new Array();
	
	this.allow_paint = true;
	
	//setup module
	this.createModule();	
	//---
};

_global.CustomListView.prototype = new MovieClip();

//---
//--- 
_global.CustomListView.prototype.createModule = function()
{	
	//module
	for(var i = 0; i < _level0.ini.module.length; i++)
	{
		if(_level0.ini.module[i].path == '' || _level0.ini.module[i].anchor > 4 || _level0.ini.module[i].anchor < 0) 
			continue;
		
		this.createEmptyMovieClip('module_'+i, i+1);
		this['module_'+i].loadMovie(_level0.ini.module[i].path);	
		this['module_'+i].id = i;
		
		this.createEmptyMovieClip('module_loader_'+i, -1000-(i+1));
		this['module_loader_'+i].id = i;
		this['module_loader_'+i].onEnterFrame = function()
		{
			var item = this._parent['module_'+this.id];
			var bloaded = item.getBytesLoaded();
			var btotal = item.getBytesTotal();
			
			if(btotal > 10 && bloaded >= btotal) 
			{			
				delete this.onEnterFrame;
				this.onEnterFrame = undefined;
				this._parent.bWidth[this.id]  = this._parent['module_'+this.id]._width;
				this._parent.bHeight[this.id] = this._parent['module_'+this.id]._height;
				removeMovieClip(this);
			}
		}
	}
}


//PUBLIC METHODS.
_global.CustomListView.prototype.setColored = function(inColor, inVal)
{
	this.selfColor = (inColor != undefined)? inColor : this.selfColor;
	if(this.isColored == inVal) return;
	
	this.isColored = (inVal != undefined)? inVal : this.isColored;
	
	this.setSize(this.listWidth, this.listHeight);
}

//adds new item to the end of the list.
_global.CustomListView.prototype.addItem = function(inItem) {
	this.addItemAt(this.itemWrapperList.length, inItem);
};

//adds new items to the end of the list. inItemList is an Array instance.
_global.CustomListView.prototype.addItems = function(inItemList) {
	this.addItemsAt(this.itemWrapperList.length, inItemList);
};

//inserts new item at the specified index.
_global.CustomListView.prototype.addItemAt = function(inIdx, inItem) {
	this._addItemAt(inIdx, inItem);
	
	this.updateScrollBars();
	this.paint();
};

//inserts new items at the specified index. inItemList is an Array instance.
_global.CustomListView.prototype.addItemsAt = function(inIdx, inItemList) {
	this._addItemsAt(inIdx, inItemList);
	
	this.updateScrollBars();
	this.paint();
};

//returns item at specified index. returns null if index is out of bounds.
_global.CustomListView.prototype.getItemAt = function(inIdx) {
	if ((inIdx >= 0) && (inIdx < this.itemWrapperList.length)) {
		return this.itemWrapperList[inIdx].item;
	} else {
		return null;
	}
};

_global.CustomListView.prototype.getItemRef = function(inItem) {
	for(var i = 0; i < this.mcList.length; i++)
	{
		if(this.mcList[i].mc.item == inItem) return (this.mcList[i].mc);
	}
	
	return null;
}

//returns total number of items.
_global.CustomListView.prototype.getLength = function() {
	return this.itemWrapperList.length;
};

//removes all items.
_global.CustomListView.prototype.removeAll = function() {
	this.totalHeight = 0;
	this.maxHeight = 0;
	this.maxWidth = 0;
	this.x = 0;
	this.y = 0;
	this.firstShownIdx = 0;
	for (var mcName in this.customListView_testMC) {
		this.customListView_testMC[mcName].removeMovieClip();
	}
	this.testMCDepth = 0;

	this.itemWrapperList.splice(0);
	this.updateScrollBars();
	this.paint();
};

//removes item at specified index.
_global.CustomListView.prototype.removeItemAt = function(inIdx) {
	this._removeItemsAt(inIdx, inIdx);
	
	this.updateScrollBars();
	this.paint();
};

//removes items at specified index range. first argument is start index, last argument is end index.
_global.CustomListView.prototype.removeItemsAt = function(inStartIdx, inEndIdx) {
	this._removeItemsAt(inStartIdx, inEndIdx);
	
	this.updateScrollBars();
	this.paint();
};

//replaces item at specified index with a new one.
_global.CustomListView.prototype.replaceItemAt = function(inIdx, inItem) {
	this._removeItemsAt(inIdx, inIdx);
	this._addItemAt(inIdx, inItem);
	
	this.updateScrollBars();
	this.paint();
};

//gets list view size.
_global.CustomListView.prototype.getSize = function() {
	var dimm = new Object();
	dimm.width = this.listWidth;
	dimm.height = this.listWidth;
	
	return (dimm);
};

//sets list view size.
_global.CustomListView.prototype.setSize = function(inWidth, inHeight) {
	this.listWidth = inWidth;
	this.listHeight = inHeight;

	this.customListView_background._x = 0;
	this.customListView_background._y = 0;
	this.customListView_background._width = this.listWidth;
	this.customListView_background._height = this.listHeight;

	this.customListView_mask._x = -1;
	this.customListView_mask._y = -1;
	this.customListView_mask._width = this.listWidth + 2;
	this.customListView_mask._height = this.listHeight + 2;
	
	this.vScrollBar._x = this.listWidth - this.vScrollBar._width;
	
	this.hScrollBar._y = this.listHeight - this.hScrollBar._height;

	this.scrollBarRect._x = this.listWidth - this.vScrollBar._width;
	this.scrollBarRect._y = this.listHeight - this.hScrollBar._height;

	this.drawListBorder();

	this.vScrollBar.setEnabled(false);
	this.vScrollBar._visible = false;
	this.hScrollBar.setEnabled(false);
	this.hScrollBar._visible = false;

	this.resetItems();
	this.updateScrollBars();
	
	this.paint();
};

_global.CustomListView.prototype.setPane = function(inPane) {
	this.paneWindow = inPane;
};

_global.CustomListView.prototype.setStyle = function(inStyle) {
	this.style = inStyle;
	
	var c = new Color(this.customListView_background);
	c.setRGB(this.style.userListBackground);
	
	c = new Color(this.scrollBarRect);
	c.setRGB(this.style.userListBackground);
	
	this.customListView_background._alpha = this.style.uiAlpha;
	for (var i = 0; i < this.mcList.length; i ++) {
		this.mcList[i].mc.applyStyle(this.style);
	}
	this.drawListBorder();
};

_global.CustomListView.prototype.applyTextProperty = function(propName, val) {
	for (var i = 0; i < this.mcList.length; i ++) {
		this.mcList[i].mc.applyTextProperty(propName, val);
	}
	
	this.setSize(this.listWidth, this.listHeight);
}
_global.CustomListView.prototype.setLanguage = function(inLanguage) {
	this.language = inLanguage;
	for (var i = 0; i < this.mcList.length; i ++) {
		this.mcList[i].mc.setLanguage(this.language);
	}
};

_global.CustomListView.prototype.setAlpha = function(inStyle) {
	this.style = inStyle;
	this.customListView_background._alpha = this.style.uiAlpha;
};

//SUPPORT FOR DATAPROVIDER INTERFACE.

//if inDataProvider is an Array instance asssume that array elemnts implements Item interface and
//just add them to the list. Otherwise, inDataProvider is an DataProvider interface implementation,
//so we add our list control to data provider's views.
_global.CustomListView.prototype.setDataProvider = function(inDataProvider) {
	this.removeAll();
	if (inDataProvider instanceof Array) {
		this.dataProvider = null;
		this.addItems(inDataProvider);
	} else {
		this.dataProvider = inDataProvider;
		this.dataProvider.addView(this);
	}
};

//called by dataprovider. inEvent object contains information about changes in external data.
_global.CustomListView.prototype.modelChanged = function(inEvent) {
	if (this.dataProvider == null) {
		return;
	}
	var event = inEvent.event;
	var firstRow = inEvent.firstRow;
	var lastRow = inEvent.lastRow;
	switch (event) {
		case 'updateAll' :
			this.removeAll();
			for (var i = 0; i < this.dataProvider.getLength(); i ++) {
				this.addItem(this.dataProvider.getItemAt(i));
			}
			break;
		case 'addRows' :
			if (firstRow == lastRow) {
				this.addItemAt(firstRow, this.dataProvider.getItemAt(firstRow));
			} else {
				var addList = new Array();
				for (var i = firstRow; i <= lastRow; i ++) {
					addList.push(this.dataProvider.getItemAt(i));
				}
				this.addItemsAt(firstRow, addList);
			}
			break;
		case 'updateRows' :
			for (var i = firstRow; i <= lastRow; i ++) {
				this.replaceItemAt(i, this.dataProvider.getItemAt(i));
			}
			break;
		case 'deleteRows' :
			this.removeItemsAt(firstRow, lastRow);
			break;
		case 'sort' :
			trace('SORT data provider event not implemented.');
			break;
		default : 
			trace('unknown data provider event[' + event + '].');
			break;
	}
};

//returns enabled state of the control.
_global.CustomListView.prototype.getEnabled = function() {
	return this.enabled;
};

//enabled or disables entire control with all custom movie clips.
_global.CustomListView.prototype.setEnabled = function(inEnabled) {
	this.enabled = inEnabled;
	if (this.vScrollBar._visible) {
		this.vScrollBar.setEnabled(inEnabled);
	}
	if (this.hScrollBar._visible) {
		this.hScrollBar.setEnabled(inEnabled);
	}
	for (var i = 0; i < this.mcList.length; i ++) {
		this.mcList[i].mc.setEnabled(inEnabled);
	}
	this.enablePressHandler(this.enabled);
};

_global.CustomListView.prototype.refreshItems = function() {
	for (var i = 0; i < this.mcList.length; i ++) {
		this.mcList[i].mc.refreshItem();
	}
};

_global.CustomListView.prototype.enablePressHandler = function(inVal) {
	if(inVal && this.paneWindow.dockState != true)
		this.customListView_background.onPress = function()
		{
			this._parent.pressHandlObj[this._parent.pressHandlFunc](this._parent.paneWindow);
		}
	else
		delete(this.customListView_background.onPress);
};

_global.CustomListView.prototype.setPressHandler = function(handlObj, handlFunc) {
	this.pressHandlObj = handlObj;
	this.pressHandlFunc = handlFunc;
	this.enablePressHandler(true);
}

//PRIVATE METHODS.

_global.CustomListView.prototype.getPropWidth = function() {
	return this.listWidth;
};

_global.CustomListView.prototype.setPropWidth = function(inWidth) {
	return this.setSize(inWidth, this.listHeight);
};

_global.CustomListView.prototype.getPropHeight = function() {
	return this.listHeight;
};

_global.CustomListView.prototype.setPropHeight = function(inHeight) {
	return this.setSize(inHeight, this.listHeight);
};

_global.CustomListView.prototype._addItemAt = function(inIdx, inItem) {
	var itemBounds = this.getItemBounds(inItem);
	var itemY = this.totalHeight;
	if (inIdx < this.itemWrapperList.length) {
		itemY = this.itemWrapperList[inIdx].y;
		for (var i = inIdx; i < this.itemWrapperList.length; i ++) {
			this.itemWrapperList[i].y += itemBounds.height;
		}
	}
	var itemWrapper = new CItemWrapper(inItem, itemY, itemBounds);
	this.totalHeight += itemBounds.height;
	if (this.maxWidth < itemBounds.width) {
		this.maxWidth = itemBounds.width;
	}
	if (this.maxHeight < itemBounds.height) {
		this.maxHeight = itemBounds.height;
	}
	this.itemWrapperList.splice(inIdx, 0, itemWrapper);
};

_global.CustomListView.prototype._addItemsAt = function(inIdx, inItemList) {
	var startItemY = this.totalHeight;
	if (inIdx < this.itemWrapperList.length) {
		startItemY = this.itemWrapperList[inIdx].y;
	}

	var itemsHeight = 0;
	for (var i = 0; i < inItemList.length; i ++) {
		var itemBounds = this.getItemBounds(inItemList[i]);
		var itemWrapper = new CItemWrapper(inItemList[i], startItemY + itemsHeight, itemBounds);
		itemsHeight += itemBounds.height;
		this.itemWrapperList.splice(inIdx + i, 0, itemWrapper);
		if (this.maxWidth < itemBounds.width) {
			this.maxWidth = itemBounds.width;
		}
		if (this.maxHeight < itemBounds.height) {
			this.maxHeight = itemBounds.height;
		}
	}
	for (var i = inIdx + inItemList.length; i < this.itemWrapperList.length; i ++) {
		this.itemWrapperList[i].y += itemsHeight;
	}
	this.totalHeight += itemsHeight;
};

_global.CustomListView.prototype._removeItemsAt = function(inStartIdx, inEndIdx) {
	var itemsHeight = 0;
	for (var i = inStartIdx; i <= inEndIdx; i ++) {
		var itemWrapper = this.itemWrapperList[i];
		itemsHeight += itemWrapper.bounds.height;
	}
	
	this.totalHeight -= itemsHeight;
	if (this.totalHeight - this.y < this.listHeight) {
		this.y = Math.max(this.totalHeight - this.listHeight, 0);
	}
	
	for (var i = inEndIdx + 1; i < this.itemWrapperList.length; i ++) {
		this.itemWrapperList[i].y -= itemsHeight;
	}
	
	this.itemWrapperList.splice(inStartIdx, inEndIdx - inStartIdx + 1);
	
	this.maxHeight = 0;
	this.maxWidth = 0;
	for (var i = 0; i < this.itemWrapperList.length; i ++) {
		if (this.maxWidth < this.itemWrapperList[i].bounds.width) {
			this.maxWidth = this.itemWrapperList[i].bounds.width;
		}
		if (this.maxHeight < this.itemWrapperList[i].bounds.height) {
			this.maxHeight = this.itemWrapperList[i].bounds.height;
		}
	}	
	if (this.maxWidth - this.x < this.listWidth) {
		this.x = Math.max(this.maxWidth - this.listWidth, 0);
	}
};

_global.CustomListView.prototype.paint = function() {
	if (this.itemWrapperList.length == 0 || !this.allow_paint) return;
	
	//trace(' <<< Call PAINT >>> ' + this.itemWrapperList.length);	
	
	for (var i = 0; i < this.mcList.length; i ++) this.mcList[i].remove = true;

	if (this.itemWrapperList.length > 0) {
		this.freeDepthLevel = this.mcList.length;
		this.firstShownIdx = this.findItemWrappeIdxForY(this.y);
		itemWrapperIdx = this.firstShownIdx;
		while (itemWrapperIdx < this.itemWrapperList.length) {
			var itemWrapper = this.itemWrapperList[itemWrapperIdx];
			if (itemWrapper.y > this.y + this.listHeight) {
				break;
			}
			var existingMCWrapper = this.mcHash[itemWrapper.hash];
			var itemMC = null;
			if (existingMCWrapper != null) {
				existingMCWrapper.remove = false;
				itemMC = existingMCWrapper.mc;
			} else {
				this.customListView_items.attachMovie(itemWrapper.item.getMC(), 'customListView_' + itemWrapper.hash, this.getFreeDepthLevel());
				itemMC = this.customListView_items['customListView_' + itemWrapper.hash];
				var mcWrapper = new CMCWrapper(itemMC, itemWrapper);
				this.mcList.push(mcWrapper);
				this.mcHash[itemWrapper.hash] = mcWrapper;
				itemWrapper.mcWrapper = mcWrapper;
				itemMC.applyStyle(this.style);
				itemMC.setLanguage(this.language);
				itemMC.setData(itemWrapper.item);
			}
			
			if ((itemWrapper.item.setWidth == null) || (itemWrapper.item.getWidth == null) || (itemWrapper.item.getHeight == null)) {
				//if item itself does not support width/height calculation, set mc width.
				var prefferableWidth = this.listWidth - (this.vScrollBar._visible ? this.vScrollBar._width : 0);
				var maxWidth = this.hScrollBar.maxPos + this.hScrollBar.pageSize;
				itemMC.setWidth(prefferableWidth, this.hScrollBar._visible ? maxWidth : prefferableWidth);
			}
			
			itemMC._x = - this.x - itemWrapper.bounds.x;
			itemMC._y = itemWrapper.y - this.y - itemWrapper.bounds.y;
			
			itemWrapperIdx ++;
		}
	}

	for (var i = 0; i < this.mcList.length; i ++) {
		if (this.mcList[i].remove) {
			this.mcList[i].mc.removeMovieClip();
			this.mcHash[this.mcList[i].itemWrapper.hash] = null;
			for (var j = i + 1; j < this.mcList.length; j ++) {
				this.mcList[j].mc.swapDepths(this.mcList[j].mc.getDepth() - 1);
			}
			this.mcList.splice(i, 1);
			i --;
		}
	}
	
	this.resetItems();//realign module
	
	//module
	for(var i = 0; i < _level0.ini.module.length; i++)
	{
		if(this['module_'+i] != undefined)
		{
			if(_level0.ini.module[i].stretch==1)
			{
				_global.FlashChatNS.chatUI.callModuleFunc('mOnModuleWindowResize', {width : this.listWidth, height : (this.listHeight - this['module_'+i]._y)}, i);
			}	
			else
			{
				_global.FlashChatNS.chatUI.callModuleFunc('mOnModuleWindowResize', {width : this['module_'+i]._width, height : this['module_'+i]._height}, i);
			}
		}
	}	
};

_global.CustomListView.prototype.paintHorizontal = function() {
	for (var i = 0; i < this.mcList.length; i ++) {
		var itemMC = this.mcList[i].mc;
		itemMC._x = - this.x - this.itemWrapperList[this.firstShownIdx + i].bounds.x;
	}
};

_global.CustomListView.prototype.findItemWrappeIdxForY = function(inY) {
	var startIdx = Math.floor(inY / this.maxHeight);
	for (var i = startIdx; i < this.itemWrapperList.length; i ++) {
		var itemWrapper = this.itemWrapperList[i];
		if ((itemWrapper.y <= inY) && (itemWrapper.y + itemWrapper.bounds.height > inY)) {
			return i;
		}
	}
	return -1;
};

_global.CustomListView.prototype.getItemBounds = function(inItem) {
	var itemBounds = new Object();
	var prefferableWidth = this.listWidth - (this.vScrollBar._visible ? this.vScrollBar._width : 0);
	var maxWidth = this.hScrollBar.maxPos + this.hScrollBar.pageSize;
	var itemRef = this.getItemRef(inItem);
	
	if ((inItem.setWidth != null) && (inItem.getWidth != null) && (inItem.getHeight != null)) {
		//if item iself supports width/height calculation, do not create mc for this item
		inItem.setWidth(prefferableWidth, this.hScrollBar._visible ? maxWidth : prefferableWidth);
		
		var bounds = inItem.getBounds();
		itemBounds.x = bounds.xMin;
		itemBounds.y = bounds.yMin;
		
		itemBounds.width = inItem.getWidth();
		itemBounds.height = Math.floor(inItem.getHeight());
	}else if(itemRef != undefined) {
		itemRef.setWidth(prefferableWidth, this.hScrollBar._visible ? maxWidth : prefferableWidth);
		itemRef.setData(inItem);
		
		var bounds = itemRef.getBounds();
		if(inItem.getMC() == 'ItemUser') bounds = itemRef.button.getBounds();
		itemBounds.x = bounds.xMin;
		itemBounds.y = bounds.yMin;
		
		itemBounds.width = itemRef._width;
		itemBounds.height = Math.floor(itemRef.button._height);
	}else {
		//otherwise, create a corresponding mc to find item dimensions.
		var testDepthItem = this.customListView_testMC[inItem.getMC() + '_mc'];
		if (testDepthItem == null) {
			this.customListView_testMC.attachMovie(inItem.getMC(), inItem.getMC() + '_mc', this.testMCDepth);
			testDepthItem = this.customListView_testMC[inItem.getMC() + '_mc'];
			this.testMCDepth ++;
			testDepthItem._visible = false;
		}
		testDepthItem.setWidth(prefferableWidth, this.hScrollBar._visible ? maxWidth : prefferableWidth);
		testDepthItem.setData(inItem);

		var bounds = itemRef.getBounds();
		if(inItem.getMC() == 'ItemUser') bounds = itemRef.button.getBounds();
		itemBounds.x = bounds.xMin;
		itemBounds.y = bounds.yMin;
		itemBounds.width = testDepthItem._width;
		itemBounds.height = Math.floor(testDepthItem.button._height);
	}

	return itemBounds;
};

_global.CustomListView.prototype.getFreeDepthLevel = function() {
	return (this.freeDepthLevel ++);
};

_global.CustomListView.prototype.updateScrollBars = function() {
	this.updateVScrollBar();
	this.updateHScrollBar();
	if (this.vScrollBar._visible && this.hScrollBar._visible) {
		this.scrollBarRect._visible = true;
	} else {
		this.scrollBarRect._visible = false;
	}
};

_global.CustomListView.prototype.updateVScrollBar = function() {
	var changedVisibility = false;
	if (this.totalHeight - this.listHeight + (this.hScrollBar._visible ? this.hScrollBar._height : 0) <= 0) {
		if (this.vScrollBar._visible) {
			this.vScrollBar.setEnabled(false);
			this.vScrollBar._visible = false;
			changedVisibility = true;
		}
	} else {
		this.vScrollBar.setChangeHandler(null);
		if (!this.vScrollBar._visible) {
			this.vScrollBar.setEnabled(true);
			this.vScrollBar._visible = true;
			changedVisibility = true;
		}
		var size = this.listHeight - (this.hScrollBar._visible ? this.hScrollBar._height : 0);
		if (this.vScrollBar._height != size)  {
			this.vScrollBar.setSize(size);
		}
		this.vScrollBar.setScrollProperties(size, 0, this.totalHeight - size);
		if (this.y != this.vScrollBar.getScrollPosition()) {
			this.vScrollBar.setScrollPosition(this.y);
		}
		this.vScrollBar.setChangeHandler('vScrollHandler');
	}
	if (changedVisibility) {
		this.resetItems();
		this.updateVScrollBar();
		this.updateHScrollBar();
	}
};

_global.CustomListView.prototype.updateHScrollBar = function() {
	var changedVisibility = false;
	if (this.maxWidth <= this.listWidth - (this.vScrollBar._visible ? this.vScrollBar._width : 0)) {
		if (this.hScrollBar._visible) {
			this.hScrollBar.setEnabled(false);
			this.hScrollBar._visible = false;
			changedVisibility = true;
		}
	} else {
		this.hScrollBar.setChangeHandler(null);
		if (!this.hScrollBar._visible) {
			this.hScrollBar.setEnabled(true);
			this.hScrollBar._visible = true;
			changedVisibility = true;
		}
		var size = this.listWidth - (this.vScrollBar._visible ? this.vScrollBar._width : 0);
		if (this.hScrollBar._width != size) {
			this.hScrollBar.setSize(size);
		}
		this.hScrollBar.setScrollProperties(size, 0, this.maxWidth - size);
		if (this.x != this.hScrollBar.getScrollPosition()) {
			this.hScrollBar.setScrollPosition(this.x);
		}
		this.hScrollBar.setChangeHandler('hScrollHandler');
	}
	if (changedVisibility) {
		this.updateVScrollBar();
	}
};

_global.CustomListView.prototype.vScrollHandler = function() {
	this.y = this.vScrollBar.getScrollPosition();
	this.paint();
};

_global.CustomListView.prototype.hScrollHandler = function() {
	this.x = this.hScrollBar.getScrollPosition();
	this.paintHorizontal();
};

_global.CustomListView.prototype.drawListBorder = function() {
	this.customListView_border.clear();
	this.customListView_border.lineStyle(1, this.style.borderColor, 100);
	this.customListView_border.moveTo(0, 0);
	this.customListView_border.lineTo(this.listWidth, 0);
	this.customListView_border.lineTo(this.listWidth, this.listHeight);
	this.customListView_border.lineTo(0, this.listHeight);
	this.customListView_border.lineTo(0, 0);
};

_global.CustomListView.prototype.resetItems = function() {	
	//recalculate total items height.
	this.maxHeight = 0;
	this.maxWidth = 0;
	this.totalHeight = 0;
	this.x = 0;
	var itemY = 0;
	
	for (var i = 0; i < this.itemWrapperList.length; i ++) {
		var itemBounds = this.getItemBounds(this.itemWrapperList[i].item);
		this.itemWrapperList[i].y = itemY;
		this.itemWrapperList[i].bounds = itemBounds;
		itemY += itemBounds.height;
		this.totalHeight += itemBounds.height;
		if (this.maxWidth < itemBounds.width) {
			this.maxWidth = itemBounds.width;
		}
		if (this.maxHeight < itemBounds.height) {
			this.maxHeight = itemBounds.height;
		}
	}
	
	if (this.totalHeight - this.y < this.listHeight) {
		this.y = Math.max(this.totalHeight - this.listHeight, 0);
	}
	if (this.maxWidth - this.x < this.listWidth) {
		this.x = Math.max(this.maxWidth - this.listWidth, 0);
	}
	
	//allign module	
	//module
	for(var i = 0; i < _level0.ini.module.length; i++)
	{
		if( this['module_'+i] && this['module_'+i]._width > 0)
		{	
			var x,y; 
			var w,h;
			w = this.bWidth[i];
			h = this.bHeight[i];
			
			if(_level0.ini.module[i].stretch==1)
			{			
				this['module_'+i]._x = 0;	
				this['module_'+i]._y = itemY;
				
				if(this['module_'+i].mOnModuleWindowResize == undefined)
				{
					this['module_'+i]._xscale = (this.listWidth/w) * 100;	
					this['module_'+i]._yscale = ((this.listHeight - itemY)/h) * 100;
				}
				
				//now in paint()
				//_global.FlashChatNS.chatUI.callModuleFunc('mOnModuleWindowResize', {width : this.listWidth, height : (this.listHeight - itemY)}, i);
			}
			else
			{ 
				
				switch(_level0.ini.module[i].anchor){
				case 1 :
					x = 0;
					y = itemY;				
					break;
					
				case 2 :
					x = (this.listWidth  - w);
					y = itemY;								
					break;
					
				case 3 :
					x = 0;
					y = Math.max(itemY, itemY + (this.listHeight - itemY - h));
					break;
					
				case 4 :
					x = (this.listWidth - w);
					y = Math.max(itemY, itemY + (this.listHeight - itemY - h));				
					break;
					
				default : 
					x = (this.listWidth  - w) / 2;
					y = Math.max(itemY, itemY + (this.listHeight - itemY - h) / 2);
					break;
				}
			
				this['module_'+i]._x = x;	
				this['module_'+i]._y = y;
			}		
		}
		//---
	}
};

_global.CItemWrapper = function(inItem, inY, inBounds) {
	this.item = inItem;
	this.y = inY;
	this.bounds = inBounds;
	this.hash = '' + Math.round(1000000000 * Math.random());
	this.mcWrapper = null;
};

_global.CMCWrapper = function(inMC, inItemWrapper) {
	this.mc = inMC;
	this.itemWrapper = inItemWrapper;
	this.remove = false;
};

Object.registerClass('CustomListView', _global.CustomListView);

#endinitclip
