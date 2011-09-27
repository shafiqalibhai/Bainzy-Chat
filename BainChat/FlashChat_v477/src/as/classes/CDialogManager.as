function CDialogManager(inDialogHolder, inStageWidth, inStageHeight) {
	this.dialogHolder = inDialogHolder;
	this.dialogCounter = 0;
	this.dialogList = new Array();
	this.paneList = new Object();
	this.dialogHash = new Object();
	this.boundsHash = new Object();
	this.textStyle = new Object();
	this.stageWidth = inStageWidth;
	this.stageHeight = inStageHeight;
	this.style = null;
	this.language = null;
	
	//keeps object and method name of handler. handler is notified immediately before dialog box
	//is shown.
	this.handlerFunctionName = null;
	this.handlerObj = null;

	this.intervalId = null;
	this.paneIntervalId = new Object();
}

CDialogManager.prototype.setHandler = function(inHandlerFunctionName, inHandlerObj) {
	this.handlerFunctionName = inHandlerFunctionName;
	this.handlerObj = inHandlerObj;
};


CDialogManager.prototype.createDialog = function(inSymbolName) {
	this.enableDialogs(false);
	
	if (this.dialogHash[inSymbolName] != null) {
		var hashedDialog = this.dialogHash[inSymbolName];
		
		this.dialogHash[inSymbolName] = null;
		this.dialogList.splice(0, 0, hashedDialog);
		
		hashedDialog.setEnabled(true);		
		return hashedDialog;
	}
	var depth_0 = this.getUnoccupiedDepth();
	this.dialogHolder.depthHash[depth_0] = true;
	
	var depth = this.getUnoccupiedDepth();
	this.dialogHolder.attachMovie(inSymbolName, 'dialog_' + this.dialogCounter, depth);
	this.dialogHolder.depthHash[depth] = true;
	
	var newDialog = this.dialogHolder['dialog_' + this.dialogCounter];
	this.dialogCounter ++;
	newDialog._visible = false;
	newDialog.symbolName = inSymbolName;
	this.dialogList.splice(0, 0, newDialog);
	
	return newDialog;
};

CDialogManager.prototype.showDialog = function(inDialog) {
	if (inDialog == this.dialogList[0]) {
		if (this.boundsHash[inDialog.symbolName] == null)
		{
			this.centerDialog(inDialog);
		}
		
		this.intervalId = setInterval(this.showDialogThread, 1, this);
	}
};

CDialogManager.prototype.createPane = function(inPaneName) {
	var depth_0 = this.getUnoccupiedDepth();
	this.dialogHolder.depthHash[depth_0] = true;
	
	var depth  = this.getUnoccupiedDepth();
	
	this.dialogHolder.attachMovie('PaneWindow', 'dialog_' + this.dialogCounter, depth);
	this.dialogHolder.depthHash[depth] = true;
	
	var newDialog = this.dialogHolder['dialog_' + this.dialogCounter];
	this.dialogCounter ++;
	newDialog._visible = false;
	newDialog.symbolName = inPaneName;
	this.paneList[inPaneName] = newDialog;
	
	return newDialog;
};

CDialogManager.prototype.showPane = function(inPaneName) {
	this.paneIntervalId[inPaneName] = setInterval(this.showPaneThread, 1, this, inPaneName);
};

CDialogManager.prototype.paneToBack = function(inPaneName) {
	var depth = this.paneList[inPaneName].getDepth();
	
	var newDepth = depth;
	if(this.dialogHolder.getInstanceAtDepth(1) == undefined)
	{
		newDepth = 1;
	}
	else if(this.dialogHolder.getInstanceAtDepth(3) == undefined)
	{
		newDepth = 3;
	}
	
	this.paneList[inPaneName].swapDepths(newDepth);
};

CDialogManager.prototype.hidePane = function(inPaneName) {
	this.paneList[inPaneName].hide();
};

CDialogManager.prototype.hideAllPanes = function() {
	for(var itm in this.paneList)
	{
		this.paneList[itm].hide();	
	}
};

CDialogManager.prototype.showPaneThread = function(inManager, inPaneName) {
	var pane = inManager.paneList[inPaneName];
	
	if (pane.initialized()) {
		pane.initializeDialog();
		
		if (inManager.style != null) {
			pane.applyStyle(inManager.style);
		}
		if (inManager.language != null) {
			pane.applyLanguage(inManager.language);
		}
		
		if (inManager.textStyle != null) {
			pane.applyTextProperty('font', inManager.textStyle['font']);
			pane.applyTextProperty('size', inManager.textStyle['size']);
		}
		
		pane.show();
		
		if (inManager.boundsHash[pane.symbolName] != null) {
			var bounds = inManager.boundsHash[inManager.dialogList[0].symbolName];
			pane._x = bounds.x;
			pane._y = bounds.y;
			pane.setSize(bounds.width, bounds.height);
			inManager.fixDialogPosition(pane);
		}
		
		clearInterval(inManager.paneIntervalId[inPaneName]);
	}
};

CDialogManager.prototype.releaseDialog = function(inDialog) {
	//play close sound
	if (this.dialogList[0].dialog_name != 'loginbox') 
		this.handlerObj.soundObj.attachSound('PopupWindowCloseMin');
		
	if (inDialog == this.dialogList[0]) {
		//store position and size for this type of dialog.
		var bounds = new Object();
		bounds.x = inDialog._x;
		bounds.y = inDialog._y;
		var size = inDialog.getSize( true );
		bounds.width = size.width;
		bounds.height = size.height;
		this.boundsHash[inDialog.symbolName] = bounds;
		if (inDialog.dialog_name == 'tabbedpropertiesbox')
		{
			this.dialogHolder.depthHash[inDialog.getDepth()-1] = null;
			this.dialogHolder.depthHash[inDialog.getDepth()] = null;
			this.dialogHolder.currentDepth -= 2;
			
			inDialog.removeMovieClip();
		} else {
			inDialog._visible = false;
			inDialog.setEnabled(false);
			this.dialogHash[inDialog.symbolName] = inDialog;
		}
		this.dialogList.splice(0, 1);
		this.enableDialogs(true);
	}
	
	/*
	if (this.dialogList.length > 0 && this.boundsHash[this.dialogList[0].symbolName] == null) {
		this.showDialog(this.dialogList[0]);
	}
	*/
};

CDialogManager.prototype.fixDialogPositions = function(inStageWidth, inStageHeight) {
	this.stageWidth = inStageWidth;
	this.stageHeight = inStageHeight;
	for (var i = 0; i < this.dialogList.length; i ++) {
		this.fixDialogPosition(this.dialogList[i]);
	}
};

CDialogManager.prototype.setStyle = function(inStyle) {
	this.style = inStyle;
	
	for (var i = 0; i < this.dialogList.length; i ++) {
		this.dialogList[i].applyStyle(this.style);
	}
	
	for(var itm in this.paneList)
	{
		this.paneList[itm].applyStyle(this.style);
	}
};

CDialogManager.prototype.setBackground = function(inStyle) {
	this.style = inStyle;
	
	for (var i = 0; i < this.dialogList.length; i ++) {
		this.dialogList[i].applyBackground(this.style);
	}
	
	for(var itm in this.paneList)
	{
		this.paneList[itm].applyBackground(this.style);
	}
};

CDialogManager.prototype.setCustomBackground = function(inImageURL) {
	for (var i = 0; i < this.dialogList.length; i ++) {
		this.dialogList[i].applyCustomBackground(inImageURL);
	}
	
	for(var itm in this.paneList)
	{
		this.paneList[itm].applyCustomBackground(inImageURL);
	}
};

CDialogManager.prototype.applyLanguage = function(inLanguage) {
	this.language = inLanguage;
	for (var i = 0; i < this.dialogList.length; i ++) {
		this.dialogList[i].applyLanguage(this.language);
	}
	
	for(var itm in this.paneList)
	{
		this.paneList[itm].applyLanguage(this.language);
	}
};

CDialogManager.prototype.applyTextProperty = function(propName, val) {
	this.textStyle[propName] = val;
	for (var i = 0; i < this.dialogList.length; i ++) {
		this.dialogList[i].applyTextProperty(propName, val);
	}
	
	for(var itm in this.paneList)
	{
		this.paneList[itm].applyTextProperty(propName, val);
	}
}

CDialogManager.prototype.clear = function() {
	this.boundsHash = new Object();
};

//PRIVATE METHODS.

//fixes specified private box position.
CDialogManager.prototype.fixDialogPosition = function(inDialog) {
	var dimension = inDialog.getSize();
	if (inDialog._x + dimension.width > this.stageWidth) {
		inDialog._x = this.stageWidth - dimension.width;
	}
	if (inDialog._y + dimension.height > this.stageHeight) {
		inDialog._y = this.stageHeight - dimension.height;
	}
	if (inDialog._x < 0) {
		inDialog._x = 0;
	}
	if (inDialog._y < 0) {
		inDialog._y = 0;
	}
};

CDialogManager.prototype.getUnoccupiedDepth = function() {
	var depth = this.dialogHolder.baseDepth;
	while (this.dialogHolder.depthHash[depth] == true) {
		depth ++;
	}
	
	this.dialogHolder.currentDepth = depth;
	return depth;
};

CDialogManager.prototype.centerDialog = function(inDialog) {
	var dimensions = inDialog.getSize();
	inDialog._x = (this.stageWidth - dimensions.width) / 2;
	inDialog._y = (this.stageHeight - dimensions.height) / 2;
};

CDialogManager.prototype.enableDialogs = function(inEnable) {
	for (var i = 0; i < this.dialogList.length; i ++) {
		this.dialogList[i].setEnabled(inEnable);
	}
};

CDialogManager.prototype.showDialogThread = function(inManager) {
	if (inManager.dialogList[0].initialized()) {
		if (inManager.dialogList[0].dialog_name != 'loginbox') 
			inManager.handlerObj.soundObj.attachSound('PopupWindowOpen');
		
		inManager.handlerObj[inManager.handlerFunctionName](inManager);
		inManager.dialogList[0].initializeDialog();
		
		if (inManager.style != null) {
			inManager.dialogList[0].applyStyle(inManager.style);
		}
		if (inManager.language != null) {
			inManager.dialogList[0].applyLanguage(inManager.language);
		}
		
		if (inManager.textStyle != null) {
			inManager.dialogList[0].applyTextProperty('font', inManager.textStyle['font']);
			inManager.dialogList[0].applyTextProperty('size', inManager.textStyle['size']);
		}
		
		inManager.dialogList[0].sendToFront();
		inManager.dialogList[0].show();
		
		if (inManager.boundsHash[inManager.dialogList[0].symbolName] != null) {
			var bounds = inManager.boundsHash[inManager.dialogList[0].symbolName];
			inManager.dialogList[0]._x = bounds.x;
			inManager.dialogList[0]._y = bounds.y;
			inManager.dialogList[0].setSize(bounds.width, bounds.height);
			inManager.fixDialogPosition(inManager.dialogList[0]);
		}
		clearInterval(inManager.intervalId);
	}
};
