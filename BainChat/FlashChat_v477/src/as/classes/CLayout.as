function CLayout() {
	this.role = 1;
	this.allowBan = false;
	this.allowInvite = true;
	this.allowIgnore = true;
	this.allowProfile = true;
	this.allowFileShare = false;//---share file attribute
	this.allowPrivateMessage = true;
	this.allowCustomBackground = true;
	this.showUserList = true;
	this.showPublicLog = true;
	this.showPrivateLog = true;
	this.showInputBox = true;
	this.showOptionPanel = true;
	this.showLogout = true;
	this.isSingleRoomMode = false;
	this.allowCreateRoom = true;
	this.showAddressee = true;

	this.toolbar = new Object();
	
	this.optionPanel = new Object();
	
	this.userList = new Object();
	this.publicLog = new Object();
	this.privateLog = new Object();
	this.inputBox = new Object();	
	
	this.userList.minWidth = 50;
	this.userList.width = -1;
	this.userList.relWidth = 30;
	this.userList.dockWidth = 75; 
	this.userList.dockHeight = 50;
	this.userList.position = 1;
	
	this.publicLog.minHeight = 35;
	this.publicLog.height = -1;
	this.publicLog.relHeight = 66;
	
	this.privateLog.minHeight = 35;
	this.privateLog.height = -1;
	this.privateLog.relHeight = 25;
	
	this.inputBox.minHeight = 35;
	this.inputBox.height = -1;
	this.inputBox.relHeight = 8;
	this.inputBox.position = 1;
};

CLayout.prototype = new Initable();

CLayout.prototype.init = function(xml) {
	this.copyAttrs(xml, this);
	for (var i = 0; i<xml.childNodes.length; i++) {
		var node = xml.childNodes[i];
		if(node.nodeType == 1) {
			switch(node.nodeName) {
				case 'toolbar':
					var obj = new Object();
					obj.status  = true;
					obj.skin    = true;
					obj.color   = true;
					obj.save    = true;
					obj.help    = true;
					obj.smilies = 1;
					obj.clear   = true;
					obj.bell    = true;
					
					this.copyAttrs(node, obj); 
					for(var itm in node.attributes)
					{ 
						this.toolbar[itm] = obj[itm];
					}
					break;
				case 'optionPanel': 
					var obj = new Object();
					obj.themes  = true;
					obj.sounds  = true;
					obj.effects = true;
					obj.text    = true;
					
					this.copyAttrs(node, obj); 
					for(var itm in node.attributes)
					{ 
						this.optionPanel[itm] = obj[itm];
					}
					break;
				case 'constraint': 
					this.copyAttrs(node, this[node.attributes.id]); 
					break;
			}
		}
	}
};

