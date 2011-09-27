function CSkin(inSrc) {
	if (inSrc == null) {
		this.id = 'navy';
		
		this.name = 'Navy Blue';
		
		this.backgroundImage = '';
		this.dialogBackgroundImage = '';
		this.backgroundImageRO = '';
		this.dialogBackgroundImageRO = '';
		
		this.showBackgroundImages = false;
		this.showBackgroundImagesOnLogin = false;
		
		this.uiAlpha = 100;
		this.dialogTitle = 0x000066;
		this.dialog = 0x24244F;
		this.roomText = 0xFFFFFF;
		this.roomBackground = 0x24244F;
		this.userListBackground = 0x333366;
		this.enterRoomNotify = 0xEBC04B;
		this.buttonText = 0xFFFFFF;
		this.button = 0x24244F;
		this.buttonBorder = 0x343471;
		this.inputBoxBackground = 0x333366;
		this.privateLogBackground = 0x333366;
		this.publicLogBackground = 0x333366;
		this.borderColor = 0x000000;
		this.bodyText = 0xEBC04B;
		this.titleText = 0xFFFFFF;
		this.background = 0x24244F;
		this.recommendedUserColor = 0xFFFFFF;
		this.closeButton = 0x000099;
		this.closeButtonPress = 0x009900;
		this.closeButtonArrow = 0xFFFDF1;
		
		this.minimizeButton = 0x000099;
		this.minimizeButtonPress = 0x009900;
		
		this.check = 0x000099;
		
		//extra options
		this.scrollBG = -1;
		this.scrollerBG = -1;
		this.scrollBGPress = -1;
		this.scrollBorder = -1;
		this.closeButtonBorder = -1;
		this.buttonPress = -1;
		this.minimizeButtonBorder = -1;
		this.headline = -1;
		this.userListItem = -1;
		this.controlsBackground = -1;
	} else {
		this.id = inSrc.id;
		
		this.name = inSrc.name;
		
		this.recommendedUserColor = inSrc.recommendedUserColor;
		this.background = inSrc.background;
		this.bodyText = inSrc.bodyText;
		this.borderColor = inSrc.borderColor;
		this.publicLogBackground = inSrc.publicLogBackground;
		this.privateLogBackground = inSrc.privateLogBackground;
		this.inputBoxBackground = inSrc.inputBoxBackground;
		this.button = inSrc.button;
		this.buttonText = inSrc.buttonText;
		this.buttonBorder = inSrc.buttonBorder;
		this.enterRoomNotify = inSrc.enterRoomNotify;
		this.userListBackground = inSrc.userListBackground;
		this.roomBackground = inSrc.roomBackground;
		this.roomText = inSrc.roomText;
		this.dialog = inSrc.dialog;
		this.dialogTitle = inSrc.dialogTitle;
		this.backgroundImage = inSrc.backgroundImage;
		this.dialogBackgroundImage = inSrc.dialogBackgroundImage;
		
		this.backgroundImageRO = this.backgroundImage;
		this.dialogBackgroundImageRO = this.dialogBackgroundImage;
		
		this.titleText = inSrc.titleText;
		this.uiAlpha = inSrc.uiAlpha;
		this.showBackgroundImages = inSrc.showBackgroundImages;
		this.showBackgroundImagesOnLogin = inSrc.showBackgroundImagesOnLogin;
		
		//extra options
		this.scrollBG = inSrc.scrollBG;
		this.scrollerBG = inSrc.scrollerBG;
		this.scrollBGPress = inSrc.scrollBGPress;
		this.scrollBorder = inSrc.scrollBorder;
		this.closeButton = inSrc.closeButton;
		this.closeButtonPress = inSrc.closeButtonPress;
		this.closeButtonBorder = inSrc.closeButtonBorder;
		this.closeButtonArrow = inSrc.closeButtonArrow;
		this.minimizeButton = inSrc.minimizeButton;
		this.minimizeButtonPress = inSrc.minimizeButtonPress;
		this.minimizeButtonBorder = inSrc.minimizeButtonBorder;
		this.buttonPress = inSrc.buttonPress;
		this.check = inSrc.check;
		
		this.headline = inSrc.headline;
		this.userListItem = inSrc.userListItem;
		this.controlsBackground = inSrc.controlsBackground;
	}
};

CSkin.prototype = new Initable();

CSkin.prototype.clone = function() {
	var obj = new CSkin(this);
	return obj;
};

CSkin.prototype.init = function(xml) {
	this.copyAttrs(xml, this);
	
	this.backgroundImageRO = this.backgroundImage;
	this.dialogBackgroundImageRO = this.dialogBackgroundImage;
}
