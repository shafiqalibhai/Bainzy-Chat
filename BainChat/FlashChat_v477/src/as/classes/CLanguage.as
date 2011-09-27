function CLanguage() {
	this.loaded = false;
	
	this.id = 'en';
	this.name = 'English';
	
	this.messages = new Object();
	this.messages.banned = 'You\'ve been banned';
	this.messages.ignored = 'User \'USER_LABEL\' ignores your messages';
	this.messages.login = "Please login to the chat";
	this.messages.wrongPass = 'Incorrect user name or password. Please try again.';
	this.messages.anotherlogin = 'Another user is logged in with this user name. Please try again.';
	this.messages.expiredlogin = 'Your connection has expired. Please re-login.';
	this.messages.enterroom = '[ROOM_LABEL]: USER_LABEL has entered at TIMESTAMP';
	this.messages.leaveroom = '[ROOM_LABEL]: USER_LABEL has left at TIMESTAMP';
	this.messages.selfenterroom = 'Welcome! You have entered [ROOM_LABEL] at TIMESTAMP';
	this.messages.bellrang = 'USER_LABEL rang the bell';
	this.messages.chatfull = 'The chat is full. Please try again later.';
	this.messages.iplimit = 'You are already in chat.';
	this.messages.roomlock = 'This room is password protected.<br>Please enter the room password:';
	this.messages.locked = 'Invalid password. Please try again.';
	this.messages.botfeat = 'The bot feature is not currently enabled.';
	this.messages.securityrisk = 'The file that you uploaded may contain scripting elements, which could pose a security risk. Please try another file.';
	
	this.usermenu = new Object();
	this.usermenu.privatemessage = 'Private message';
	this.usermenu.invite = 'Invite';
	this.usermenu.ignore = 'Ignore';
	this.usermenu.unignore = 'Un-ignore';
	this.usermenu.ban = 'Ban';
	this.usermenu.unban = 'Un-ban';
	this.usermenu.profile = 'Profile';
	this.usermenu.fileshare = 'Share File';
	
	
	this.status = new Object();
	this.status.here = 'Here';
	this.status.busy = 'Busy';
	this.status.away = 'Away';
	
	
	this.dialog = new Object();
	
	this.dialog.misc = new Object();
	this.dialog.misc.roomnotcreated = 'Room was not created';
	this.dialog.misc.invitationaccepted = 'User \'USER_LABEL\' accepted your invitation to room \'ROOM_LABEL\'';
	this.dialog.misc.invitationdeclined = 'User \'USER_LABEL\' declined your invitation to room \'ROOM_LABEL\'';
	this.dialog.misc.ignored = 'You were ignored by user \'USER_LABEL\'';
	this.dialog.misc.unignored = 'You were un-ignored by user \'USER_LABEL\'';
	this.dialog.misc.banned = 'You were banned by user \'USER_LABEL\'';
	this.dialog.misc.unbanned = 'You were un-banned by user \'USER_LABEL\'';
	this.dialog.misc.usernotfound = 'User \'USER_LABEL\' not found';
	this.dialog.misc.roomnotfound = 'Room \'ROOM_LABEL\' not found';
	this.dialog.misc.roomisfull = '[ROOM_LABEL] is full. Please choose another room.';
	this.dialog.misc.alert = '<b>ALERT!</b>';
	this.dialog.misc.chatalert = '<b>ALERT!</b>\n\n';
	this.dialog.misc.gag = '<b>You\'ve been gagged for DURATION minute(s)!</b>\nYou may view messages in this room, but not contribute new messages to the conversation, until the gag expires.';
	this.dialog.misc.ungagged = 'You were un-gagged by user \'USER_LABEL\'';
	this.dialog.misc.gagconfirm = 'USERNAME is gagged for MINUTES minute(s).';
	this.dialog.misc.alertconfirm = 'USERNAME has read the alert.';
	this.dialog.misc.file_declined = 'Your file was declined by USER_LABEL.';
	this.dialog.misc.file_accepted = 'Your file was accepted by USER_LABEL.';
	
	
	this.dialog.unignore = new Object();
	this.dialog.unignore.unignoretext = 'Enter unignore text';
	this.dialog.unignore.unignoreBtn = 'Unignore';
	
	this.dialog.unban = new Object();
	this.dialog.unban.unbantext = 'Enter unban text';
	this.dialog.unban.unbanBtn = 'Unban';
	
	this.dialog.tablabels = new Object();
	this.dialog.tablabels.themes = 'Themes'; 
	this.dialog.tablabels.sounds = 'Sounds';
	this.dialog.tablabels.text = 'Text';
	this.dialog.tablabels.effects = 'Effects';
	this.dialog.tablabels.admin = 'Admin';
	this.dialog.tablabels.about = 'About';
	
	this.dialog.text = new Object();
	this.dialog.text.itemChange = "Item to Change";
	this.dialog.text.fontSize = "Font Size";
	this.dialog.text.fontFamily = "Font Family";
	this.dialog.text.language = "Language";
	this.dialog.text.mainChat = "Main Chat";
	this.dialog.text.interfaceElements = "Interface Elements";
	this.dialog.text.title = "Title";
	this.dialog.text.mytextcolor = "Use my text color for all received messages.";
	
	this.dialog.effects = new Object();
	this.dialog.effects.avatars = "Avatars";
	this.dialog.effects.photo = 'Photo';
	this.dialog.effects.mainchat = "Main chat";
	this.dialog.effects.roomlist = "Room list";
	this.dialog.effects.background = "Background";
	this.dialog.effects.custom = "Custom";
	this.dialog.effects.showBackgroundImages = 'Show background';
	this.dialog.effects.splashWindow = 'Focus window on new message';
	this.dialog.effects.uiAlpha = 'Transparency';
			
	this.dialog.sound = new Object();
	this.dialog.sound.volume = 'Volume';
	this.dialog.sound.pan = 'Pan';
	this.dialog.sound.leaveroom = 'Leave room';
	this.dialog.sound.enterroom = 'Enter room';
	this.dialog.sound.reveivemessage = 'Receive message';
	this.dialog.sound.submitmessage = 'Submit message';
	this.dialog.sound.muteall = 'Mute all';
	this.dialog.sound.testBtn = 'Test';
	this.dialog.sound.sampleBtn = 'Sample';
	this.dialog.sound.initiallogin = 'Initial login';
	this.dialog.sound.logout = 'Logout';
	this.dialog.sound.privatemessagereceived = 'Receive private message';
	this.dialog.sound.invitationreceived = 'Receive invitation';
	this.dialog.sound.combolistopenclose = 'Open/close combobox list';
	this.dialog.sound.userbannedbooted = 'User banned or booted';
	this.dialog.sound.usermenumouseover = 'User menu mouse over';
	this.dialog.sound.roomopenclose = 'Open/close room section';
	this.dialog.sound.popupwindowopen = 'Popup window opens';
	this.dialog.sound.popupwindowclosemin = 'Popup window closes';
	this.dialog.sound.pressbutton = 'Key press';
	this.dialog.sound.otheruserenters = 'Other user enter room';
	
	this.dialog.skin = new Object();
	this.dialog.skin.selectskin = 'Select Color Scheme...';
	this.dialog.skin.selectBigSkin = 'Select Skin...';
	this.dialog.skin.background = 'Main Background';
	this.dialog.skin.bodyText = 'Body text';
	this.dialog.skin.borderColor = 'Border color';
	this.dialog.skin.button = 'Buttons background';
	this.dialog.skin.buttonText = 'Buttons text';
	this.dialog.skin.buttonBorder = 'Buttons border color';
	this.dialog.skin.dialog = 'Dialog background';
	this.dialog.skin.dialogTitle = 'Dialog title';
	this.dialog.skin.userListBackground = 'User list background';
	this.dialog.skin.room = 'Rooms background';
	this.dialog.skin.roomText = 'Rooms text';
	this.dialog.skin.enterRoomNotify = 'Enter room notification';
	this.dialog.skin.publicLogBackground = 'Public log background';
	this.dialog.skin.privateLogBackground = 'Private log background';
	this.dialog.skin.inputBoxBackground = 'Input box background';
	this.dialog.skin.titleText = 'Title text';
	
	this.dialog.privateBox = new Object();
	this.dialog.privateBox.sendBtn = 'Send';
	this.dialog.privateBox.toUser = 'Talking to user USER_LABEL:';
	
	this.dialog.login = new Object();
	this.dialog.login.username = 'User name:';
	this.dialog.login.password = 'Password:';
	this.dialog.login.moderator = '(if moderator)';
	this.dialog.login.required = 'required';
	this.dialog.login.language = 'Language:';
	this.dialog.login.loginBtn = 'Login';
	
	this.dialog.invitenotify = new Object();
	this.dialog.invitenotify.userinvited = 'User \'USER_LABEL\' invited you to room \'ROOM_LABEL\':\n';
	this.dialog.invitenotify.acceptBtn = 'Accept';
	this.dialog.invitenotify.declineBtn = 'Decline';
	
	this.dialog.invite = new Object();
	this.dialog.invite.inviteto = 'Invite user to:';
	this.dialog.invite.includemessage = 'Include this message with your invitation:';
	this.dialog.invite.sendBtn = 'Send';
	
	this.dialog.ignore = new Object();
	this.dialog.ignore.ignoretext = 'Enter ignore text';
	this.dialog.ignore.ignoreBtn = 'Ignore';
	
	this.dialog.createroom = new Object();
	this.dialog.createroom.entername = 'Enter room name';
	this.dialog.createroom.enterpass = 'Enter a room password or leave blank to allow access without password.';
	this.dialog.createroom["public"] = 'Public';
	this.dialog.createroom["private"] = 'Private';
	this.dialog.createroom.createBtn = 'Create';
	
	this.dialog.ban = new Object();
	this.dialog.ban.banText = 'Enter ban text';
	this.dialog.ban.fromRoom = 'from room';
	this.dialog.ban.fromChat = 'from chat';
	this.dialog.ban.byIP = 'by IP';
	this.dialog.ban.banBtn = 'Ban';
	
	this.dialog.common = new Object();
	this.dialog.common.okBtn = 'OK';
	this.dialog.common.cancelBtn = 'Cancel';
	
	
	this.desktop = new Object();
	this.desktop.welcome = 'Welcome USER_LABEL';
	this.desktop.logOffBtn = 'X';
	this.desktop.room = 'Room';
	this.desktop.addRoomBtn = 'Add';
	this.desktop.skinBtn = 'Options';
	this.desktop.clearBtn = 'Clear';
	this.desktop.saveBtn = 'Save';
	this.desktop.helpBtn = '?';
	this.desktop.sendBtn = 'Send';
	this.desktop.selectsmile = 'Smilies';
	this.desktop.invalidsettings = 'Invalid settings';
	this.desktop.ringTheBell = 'No Answer? Ring The Bell:';
	this.desktop.version = 'Version';
	this.desktop.adminSign = '';
	//this.desktop.logOff = 'log off';
	//this.desktop.myStatus = 'My status';
};

CLanguage.prototype = new Initable();

CLanguage.prototype.init = function(xml) {
	this.copyAttrs(xml, this);
	for (var i = 0; i<xml.childNodes.length; i++) {
		var node = xml.childNodes[i];
		if(node.nodeType == 1) {
			switch(node.nodeName) {
				case 'messages': 
				    //messages has a child node <login>
				    for (var j = node.childNodes.length-1; j >= 0; j--)
					{
						var itm = node.childNodes[j];
						if(itm.nodeType == 1)
						{
							this.messages[itm.nodeName] = itm.firstChild.nodeValue;
							
							//if(itm.nodeValue<>'') trace(itm.nodeName + ' ' + itm.firstChild.nodeValue);
						}
					}
					this.copyAttrs(node, this.messages);
					break;
				case 'dialog': 
					this.copyAttrs(node, this.dialog[node.attributes.id]); 
					break;
				case 'desktop': 
					this.copyAttrs(node, this.desktop); 
					break;
				case 'status': 
					this.status = new Object();
					var tmp_arr = new Array();
					for(var attr in node.attributes) tmp_arr.push([attr, node.attributes[attr]]);
					for(var j = tmp_arr.length-1; j >= 0; j--)
					{
						this.status[tmp_arr[j][0]] = tmp_arr[j][1];
					}
					break;
				case 'usermenu': 
					this.copyAttrs(node, this.usermenu); 
					break;
				case 'misc': 
					this.copyAttrs(node, this.misc); 
					break;
			}
		}
	}
};
