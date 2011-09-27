
//responsible for creating, positioning and disposing private message boxes.
function CPrivateBoxManager(inPrivateBoxHolder, inStageWidth, inStageHeight) {
	this.privateBoxHolder = inPrivateBoxHolder;
	this.privateBoxList = new Array();
	this.intervalId = null;
	this.settings = null;
	this.style = null;
	this.language = null;
	this.stageWidth = inStageWidth;
	this.stageHeight = inStageHeight;
	//this.depthHash = new Object();
	this.boundsHash = new Object();
	this.textStyle  = new Object();
	this.privateBoxCounter = 0;
	this.enabled = true;
	this.textColor = null;

	this.newX = this.INITIAL_X;
	this.newY = this.INITIAL_Y;
	this.privateBoxWidth = null;
	this.privateBoxHeight = null;

	//keeps object and method name of private box handler. private box handler is notified when
	//user presses send button in private box. argument of notification is private box instance.
	this.privateBoxHandlerFunctionName = null;
	this.privateBoxHandlerObj = null;

	this.privateBoxHolder._privateBoxManager = this;
	this.privateBoxHolder.onMouseDown = function() {
		this._privateBoxManager.onHolderMouseDown();
	};
}

//initial coordinates of the very first private box created by the manager.
CPrivateBoxManager.prototype.INITIAL_X = 50;
CPrivateBoxManager.prototype.INITIAL_Y = 50;
//coordinates increment for creating subsequent private boxes.
CPrivateBoxManager.prototype.INC_X = 20;
CPrivateBoxManager.prototype.INC_Y = 20;

//PUBLIC METHODS.

CPrivateBoxManager.prototype.setPrivateBoxHandler = function(inHandlerFunctionName, inHandlerObj) {
	this.privateBoxHandlerFunctionName = inHandlerFunctionName;
	this.privateBoxHandlerObj = inHandlerObj;
};

//creates a private box for given user and starts 'show' thread.
CPrivateBoxManager.prototype.createPrivateBox = function(inUser) {
	if(!_global.FlashChatNS.chatUI.settings.allowPhoto)
	{
		//sent request to getPhoto
		_global.FlashChatNS.chatUI.listener.getPhoto(inUser.id);
	}
	
	//if private box for this user is already opened, exit.
	for (var i = 0; i < this.privateBoxList.length; i ++) {
		if (this.privateBoxList[i].getUser().id == inUser.id) {
			trace('CPrivateBoxManager: createPrivateBox: private box for user [' + inUser + '] already exists.');
			//maximize if minimized
			this.maximizeForUser(this.privateBoxList[i].getUser());
			return;
		}
	}

	var depth_0 = this.getUnoccupiedDepth();
	this.privateBoxHolder.depthHash[depth_0] = true;
	
	var depth = this.getUnoccupiedDepth();
	this.privateBoxHolder.attachMovie('PrivateMessageBox', 'privateBox_' + this.privateBoxCounter, depth);
	this.privateBoxHolder.depthHash[depth] = true;
	
	var newPrivateBox = this.privateBoxHolder['privateBox_' + this.privateBoxCounter];
	
	//_global.FlashChatNS.chatUI.mc.msgTxt.htmlText += 'Manager Set photo' + inUser + '<br>';
	newPrivateBox.setUser(inUser);
	newPrivateBox.setHandler('onPrivateBoxNotify', this);
	if (this.privateBoxWidth == null) {
		var dimension = newPrivateBox.getSize();
		this.privateBoxWidth = dimension.width;
		this.privateBoxHeight = dimension.height;
	}
	//if there is bounds in the hash for this user, do not use newX/newY for dialog positioning.
	if (this.boundsHash[inUser.id] == null) {
		newPrivateBox._x = this.newX;
		newPrivateBox._y = this.newY;
		this.newX += this.INC_X;
		this.newY += this.INC_Y;
		this.validateNewXY();
	}

	this.privateBoxCounter ++;
	newPrivateBox._visible = false;
	this.privateBoxList.push(newPrivateBox);
	
	if (this.intervalId == null) {
		this.intervalId = setInterval(this.showPrivateBoxThread, 1, this);
	}
};

//sets stage size - maximum allowable area for positioning private boxes.
CPrivateBoxManager.prototype.setStageSize = function(inStageWidth, inStageHeight) {
	this.stageWidth = inStageWidth;
	this.stageHeight = inStageHeight;
	this.validateNewXY();
	for (var i = 0; i < this.privateBoxList.length; i ++) {
		var privateBox = this.privateBoxList[i];
		this.fixPrivateBoxPosition(privateBox);
	}
};

/*
CPrivateBoxManager.prototype.setTextColor = function(inTextColor) {
	this.textColor = inTextColor;
	for (var i = 0; i < this.privateBoxList.length; i ++) {
		this.privateBoxList[i].setTextColor(this.textColor);
	}
};
*/

CPrivateBoxManager.prototype.setSettings = function(inSettings) {
	this.settings = inSettings;
	for (var i = 0; i < this.privateBoxList.length; i ++) {
		this.privateBoxList[i].setSettings(this.settings);
	}
};

CPrivateBoxManager.prototype.applyTextProperty = function(propName, val, targetObj) {
	if (this.textStyle[targetObj] == undefined) this.textStyle[targetObj] = new Object();
	this.textStyle[targetObj][propName] = val;
	for (var i = 0; i < this.privateBoxList.length; i ++) {
		this.privateBoxList[i].applyTextProperty(propName, val, targetObj);
	}
}

CPrivateBoxManager.prototype.setStyle = function(inStyle) {
	this.style = inStyle;
	
	for (var i = 0; i < this.privateBoxList.length; i ++) {
		this.privateBoxList[i].applyStyle(this.style);
	}
};

CPrivateBoxManager.prototype.setBackground = function(inStyle) {
	this.style = inStyle;
	for (var i = 0; i < this.privateBoxList.length; i ++) {
		this.privateBoxList[i].applyBackground(this.style);
	}
};

CPrivateBoxManager.prototype.setCustomBackground = function(inImageURL) {
	for (var i = 0; i < this.privateBoxList.length; i ++) {
		this.privateBoxList[i].applyCustomBackground(inImageURL);
	}
};

CPrivateBoxManager.prototype.applyLanguage = function(inLanguage) {
	this.language = inLanguage;
	for (var i = 0; i < this.privateBoxList.length; i ++) {
		this.privateBoxList[i].applyLanguage(this.language);
	}
};

CPrivateBoxManager.prototype.setAvatar = function(inUserId) {
	for (var i = 0; i < this.privateBoxList.length; i ++) {
		var user = this.privateBoxList[i].getUser();
		if(user.id == inUserId || inUserId == _global.FlashChatNS.chatUI.selfUserId)
		{ 
			this.privateBoxList[i].log.changeAvatar(inUserId);
		}
	}
};

CPrivateBoxManager.prototype.getEnabled = function() {
	return this.enabled;
};

CPrivateBoxManager.prototype.setEnabled = function(inEnabled) {
	this.enabled = inEnabled;
	for (var i = 0; i < this.privateBoxList.length; i ++) {
		if (this.privateBoxList[i]._visible) {
			this.privateBoxList[i].setEnabled(this.enabled);
		}
	}
};

CPrivateBoxManager.prototype.clear = function() {
	for (var i = 0; i < this.privateBoxList.length; i ++) {
		this.privateBoxHolder.depthHash[this.privateBoxList[i].getDepth()] = false;
		this.privateBoxList[i].removeMovieClip();
	}
	this.privateBoxList.splice(0, this.privateBoxList.length);
	this.boundsHash = new Object();
	this.newX = this.INITIAL_X;
	this.newY = this.INITIAL_Y;
};

CPrivateBoxManager.prototype.removeForUser = function(inUser) {
	for (var i = 0; i < this.privateBoxList.length; i ++) {
		if (this.privateBoxList[i].getUser().id == inUser.id) {
			//this.depthHash[this.privateBoxList[i].getDepth()] = false;
			var bounds = new Object();
			bounds.x = this.privateBoxList[i]._x;
			bounds.y = this.privateBoxList[i]._y;
			var size = this.privateBoxList[i].getSize();
			bounds.width = size.width;
			bounds.height = size.height;
			this.boundsHash[inUser.id] = bounds;
			this.privateBoxList[i].removeMovieClip();
			this.privateBoxList.splice(i, 1);
			
			this.privateBoxHandlerObj.soundObj.attachSound('PopupWindowCloseMin');
			return;
		}
	}
};

CPrivateBoxManager.prototype.minimizeForUser = function(inUser) {
	for (var i = 0; i < this.privateBoxList.length; i ++) {
		if (this.privateBoxList[i].getUser().id == inUser.id) {
			this.	privateBoxList[i].state = 'minimized';
			this.privateBoxHandlerObj.soundObj.attachSound('PopupWindowCloseMin');
			break; 
		}
	}
}

CPrivateBoxManager.prototype.maximizeForUser = function(inUser) {
	var userRef = this.privateBoxHandlerObj.mc.userList.getItemRef(inUser);
	userRef.showMinimizeIcon(false);
	for (var i = 0; i < this.privateBoxList.length; i ++) {
		if (this.privateBoxList[i].getUser().id == inUser.id) {
			this.privateBoxList[i].state = 'maximized';
			this.privateBoxHandlerObj.soundObj.attachSound('PopupWindowOpen');
			this.privateBoxList[i].show();
			break;
		}
	}
}

CPrivateBoxManager.prototype.getUserPrivateBox = function(inUser) {
	for (var i = 0; i < this.privateBoxList.length; i ++) {
		if (this.privateBoxList[i].getUser().id == inUser.id) {
			return this.privateBoxList[i];
		}
	}
	return null;
};

CPrivateBoxManager.prototype.existsForUser = function(inUser) {
	for (var i = 0; i < this.privateBoxList.length; i ++) {
		if (this.privateBoxList[i].getUser().id == inUser.id) {
			return true;
		}
	}
	return false;
};

CPrivateBoxManager.prototype.addMessageForUser = function(inUser, inLabel, inMessage, inColor, inSender) {
	for (var i = 0; i < this.privateBoxList.length; i ++) {
		if (this.privateBoxList[i].getUser().id == inUser.id) {
			this.privateBoxList[i].addMessage(inLabel, inMessage, inColor, inSender);
		}
	}
};

//PRIVATE METHODS.

//fixes specified private box position.
CPrivateBoxManager.prototype.fixPrivateBoxPosition = function(inPrivateBox) {
	var dimension = inPrivateBox.getSize();
	var positionFixed = false;
	if (inPrivateBox._x + dimension.width > this.stageWidth) {
		inPrivateBox._x = this.stageWidth - dimension.width;
		positionFixed = true;
	}
	if (inPrivateBox._y + dimension.height > this.stageHeight) {
		inPrivateBox._y = this.stageHeight - dimension.height;
		positionFixed = true;
	}
	if (inPrivateBox._x < 0) {
		inPrivateBox._x = 0;
		positionFixed = true;
	}
	if (inPrivateBox._y < 0) {
		inPrivateBox._y = 0;
		positionFixed = true;
	}
	if (positionFixed) {
		trace('CPrivateBoxManager: fixPrivateBoxPosition: fixed position of private box [' + inPrivateBox + ']: x: ' + inPrivateBox._x + ', y: ' + inPrivateBox._y);
	}
};

CPrivateBoxManager.prototype.getUnoccupiedDepth = function() {
	var depth = this.privateBoxHolder.baseDepth;
	while (this.privateBoxHolder.depthHash[depth] == true) {
		depth ++;
	}
	
	this.privateBoxHolder.currentDepth = depth;
	return depth;
};

CPrivateBoxManager.prototype.showPrivateBoxThread = function(inManager) {
	var hasHiddenBoxes = false;
	for (var i = 0; i < inManager.privateBoxList.length; i ++) {
		//private box is hidden - it means it was not initialized yet.
		if (!inManager.privateBoxList[i]._visible && inManager.privateBoxList[i].state != 'minimized') {
			if (inManager.privateBoxList[i].initialized()) {
				//if internal box controls were initialized (thanks to stXpid MM), show it.
				inManager.privateBoxHandlerObj.soundObj.attachSound('PopupWindowOpen');
				
				inManager.privateBoxList[i].initializeDialog();
				if (inManager.settings != null) {
					inManager.privateBoxList[i].setSettings(inManager.settings);
				}
				if (inManager.style != null) {
					inManager.privateBoxList[i].applyStyle(inManager.style);
				}
				if (inManager.language != null) {
					inManager.privateBoxList[i].applyLanguage(inManager.language);
				}
				
				if (inManager.textStyle != null) {
					for(var itm in inManager.textStyle)
					{ 
						inManager.privateBoxList[i].applyTextProperty('font', inManager.textStyle[itm]['font'], itm);
						inManager.privateBoxList[i].applyTextProperty('size', inManager.textStyle[itm]['size'], itm);
					}
				}
				
				inManager.privateBoxList[i].setEnabled(inManager.enabled);
				//inManager.privateBoxList[i].setTextColor(inManager.textColor);
				inManager.	privateBoxList[i].state = 'maximized';
				inManager.privateBoxList[i].show();
				//if there is bounds in the hash for this user, do not use newX/newY for dialog positioning.
				if (inManager.boundsHash[inManager.privateBoxList[i].getUser().id] != null) {
					var bounds = inManager.boundsHash[inManager.privateBoxList[i].getUser().id];
					
					inManager.privateBoxList[i]._x = bounds.x;
					inManager.privateBoxList[i]._y = bounds.y;
					if (inManager.privateBoxHandlerObj.userListPosition == inManager.privateBoxHandlerObj.USERLIST_POSITION_LEFT)
					{ 
						inManager.privateBoxList[i]._x = inManager.privateBoxHandlerObj.mc.userList._width + (bounds.x - this.INITIAL_X);
					}
					inManager.privateBoxList[i].setSize(bounds.width, bounds.height);
					inManager.fixPrivateBoxPosition(inManager.privateBoxList[i]);
				}else if (inManager.privateBoxHandlerObj.userListPosition == inManager.privateBoxHandlerObj.USERLIST_POSITION_LEFT)
				{ 
					inManager.privateBoxList[i]._x += inManager.privateBoxHandlerObj.mc.userList._width;
				}
			} else {
				//if there are still hidden controls, but they are not initialized yet, continue thread.
				hasHiddenBoxes = true;
			}
		}
	}
	if (!hasHiddenBoxes) {
		clearInterval(inManager.intervalId);
		inManager.intervalId = null;
	}
};

//private box listener
CPrivateBoxManager.prototype.onPrivateBoxNotify = function(inPrivateBox) {
	var userRef = this.privateBoxHandlerObj.mc.userList.getItemRef(inPrivateBox.getUser());
	if (inPrivateBox.canceled()) {
		//release private box resources
		userRef.showMinimizeIcon(false);
		this.removeForUser(inPrivateBox.getUser());
	} else if(inPrivateBox.action == 'minimize'){
		//minimize private box
		inPrivateBox.action = null;
		userRef.showMinimizeIcon(true);
		this.minimizeForUser(inPrivateBox.getUser());
	}else {
		//notify private box manager listener about private box event.
		this.privateBoxHandlerObj[this.privateBoxHandlerFunctionName](inPrivateBox);
	}
};
//END private box listener

CPrivateBoxManager.prototype.validateNewXY = function() {
	if ((this.newX + this.privateBoxWidth > this.stageWidth) ||
		(this.newY + this.privateBoxHeight > this.stageHeight)) {
		this.newX = this.INITIAL_X;
		this.newY = this.INITIAL_Y;
	}
}

//mouse down listener.
CPrivateBoxManager.prototype.onHolderMouseDown = function() {
	if (!this.getEnabled() || (this.privateBoxList.length < 2)) {
		return;
	}
	var clickedList = new Array();
	for (var i = 0; i < this.privateBoxList.length; i ++) {
		var privateBox = this.privateBoxList[i];
		var dimension = privateBox.getSize();
		if ((privateBox._xmouse > 0) && (privateBox._xmouse < dimension.width) &&
			(privateBox._ymouse > 0) && (privateBox._ymouse < dimension.height)) {
			clickedList.push(privateBox);
		}
	}
	if (clickedList.length == 0) {
		return;
	}
	var topMostPrivateBox = null;
	var maxClickedDepth = null;
	for (var i = 0; i < clickedList.length; i ++) {
		if ((maxClickedDepth == null) || (clickedList[i].getDepth() > maxClickedDepth)) {
			maxClickedDepth = clickedList[i].getDepth();
			topMostPrivateBox = clickedList[i];
		}
	}
	topMostPrivateBox.swapDepths(this.getUnoccupiedDepth());
};
//END mouse down listener.
