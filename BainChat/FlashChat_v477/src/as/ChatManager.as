function ChatManager(settings) {
	this.settings = settings;
	
	this.enableSocketServer = settings.enableSocketServer;
	if(this.enableSocketServer)
	{ 
		this.socketServer = new socketServer(settings.socketServer.host, settings.socketServer.port, this);
		this.socketServer.setManageIncomingHandler( this, 'onLoad');
		this.socketServer.doConnect();
	}
	
	this.connid        = 0;
	this.userid        = 0;
	this.user_role     = 0;
	this.user_gender   = '';
	this.ui            = null;
	this.currMessageID = 0;

	this.interval = null;
	this.intervalTime = this.settings.msgRequestInterval * 1000;
};

ChatManager.prototype.debug = function(msg) 
{
	return;
	
	var str = 'ChatManager (connid:' + this.connid + ', userid:' + this.userid + ', currMessageID:' + this.currMessageID + '):' + msg;	
	trace('str >>> ' + str);
};

ChatManager.prototype.enableAutopoll = function(enabled) {
	if(this.enableSocketServer)
	{
		/*
		if( this.socketServer.incommings.length >= 1)
		{ 
			var xml = this.socketServer.incommings[0];
			this.onLoad( true, xml );	
		}
		*/
	}
	else if(enabled)
	{
		if(this.interval) clearInterval(this.interval);
		this.interval = setInterval(this, 'loadMessages', this.intervalTime);
	}
	else
	{
		if(this.interval) clearInterval(this.interval);
		this.interval = null;
	}
};

ChatManager.prototype.setUI = function(ui) {
	this.ui = ui;

	var initialSkin = this.settings.skin.preset[this.settings.skin.defaultSkin].clone();
	var initialBigSkin = this.settings.bigSkin.preset[this.settings.bigSkin.defaultSkin].clone();
	
	var initialText = new Object();
	for(var itm in this.settings.text.itemToChange)
	{
		initialText[itm] = new Object();
		initialText[itm].size = this.settings.text.itemToChange[itm].fontSize;
		initialText[itm].font = this.settings.text.itemToChange[itm].fontFamily;
		initialText[itm].presence = this.settings.text.itemToChange[itm].presence;
	}
	
	_global.FlashChatNS.DefaultSkin = initialBigSkin.swf_name;
	
	//initialSkin.backgroundImage = null;
	//initialSkin.dialogBackgroundImage = null;
	this.ui.setInitialBigSkin(initialBigSkin);
	this.ui.setInitialSkin(initialSkin);
	this.ui.setInitialText(initialText);
	this.ui.setLanguages(this.settings.languages);
	this.ui.setInitialLanguageId(this.settings.defaultLanguage);
	
	this.ui.firstInit = true;
};

ChatManager.prototype.getRequester = function() {
	var req = this.enableSocketServer? new Object() : new XMLRequester();
	
	req.id  = this.connid;
	req.cid = this.settings.chatid;

	req.c = 'msgl';
	req.b = this.currMessageID + 1;

	return req;
};

ChatManager.prototype.sendAndLoad = function(req) {
	if(this.userid || req.c == 'lin' || req.c == 'tzset') {
		if( this.enableSocketServer )
		{ 
			this.socketServer.sendRequest( req );
		}
		else
		{ 
			req.sendAndLoad(_root.documentRoot + 'getxml.php', this, 'POST');
			this.enableAutopoll(false);
		}
	}
};

ChatManager.prototype.onLoad = function(succ, xmlResponse) {
	var startPoller = true;
	
	this.debug(xmlResponse.toString());	

	if(this.settings.debug) {
		if(!this.logger) this.logger = new LocalConnection();

		this.logger.send('logger', 'log', xmlResponse.toString());
	}

	if(succ) {
		if(xmlResponse.childNodes[0].nodeType == 1 && xmlResponse.childNodes[0].nodeName == 'response') {
			var response = xmlResponse.childNodes[0];

			if(this.connid != response.attributes.id) {
				this.connid = response.attributes.id;
			}

			for(var i = 0; i < response.childNodes.length; i++) {
				var node = response.childNodes[i];
				if(node.nodeType == 1) {
					if(!node.attributes.u) node.attributes.u = 0;
					if(!node.attributes.r) node.attributes.r = 0;

					var start = (node.attributes.id != undefined)?Number(node.attributes.id):0;
					if(start > this.currMessageID || this.enableSocketServer) {
						this.currMessageID = start;
						
						switch(node.nodeName) {
							case 'error':
								this.ui.errorAlert(node.firstChild.nodeValue, node.attributes.u, node.attributes.r);
								break;
							case 'lin':
								if(!this.userid) {
									this.userid = node.attributes.u;
									this.user_role = node.attributes.rs;
									this.user_gender = node.attributes.gn;
									this.ui.loggedin(this.userid, this.user_role, this.user_gender);
									for (var j = 0; j < this.settings.layouts.length; j ++) {
										if (this.settings.layouts[j].role == node.attributes.r) {
											this.settings.layout = this.settings.layouts[j];
											break;
										}
									}
									this.ui.setSettings(this.settings);
								}
								if( _root._url.indexOf("file") == -1 )
									getURL("javascript:setConnid('" + this.connid + "');void(0);");
								
								break;
							case 'lout':
								this.userid = 0;
								this.ui.loggedout(node.firstChild.nodeValue);
								startPoller = false;
								break;
							case 'lng':
								var langini = new XML(node.firstChild.nodeValue);
								var lang = new CLanguage();
								lang.init(langini.firstChild);
								this.ui.setLanguage(lang);								
								break;
							case 'glng':
								var langini = new XML(node.firstChild.nodeValue);
								var lang = new CLanguage();
								lang.init(langini.firstChild);
								this.ui.applyLanguage(lang, true);
								break;
							case 'adr': 
								this.ui.roomAdded(node.attributes.r, node.firstChild.nodeValue);
								break;
							case 'srl':
								this.ui.setRoomLock(node.attributes.r, Boolean(node.firstChild.nodeValue));
								break;
							case 'nadr': 
								this.ui.notCreated(node.firstChild.nodeValue);
								break;
							case 'rmr': 
								this.ui.removeRoom(node.attributes.r);
								break;
							case 'adu': 
								var usr_name = replaceHTMLSpecChars( node.firstChild.nodeValue );
								this.ui.userAdded(node.attributes.u, usr_name, node.attributes.r, null, null, node.attributes.t, Number(node.attributes.rs), node.attributes.gn, node.attributes.pt);
								break;
							case 'adu2': 
								var usr_name = replaceHTMLSpecChars( node.firstChild.nodeValue );
								this.ui.userAdded(node.attributes.u, usr_name, node.attributes.r, null, null, node.attributes.t, Number(node.attributes.rs), node.attributes.gn, node.attributes.pt,false);
								break;
							case 'rmu': 
								this.ui.userRemoved(node.attributes.u, node.attributes.t);
								trace('Remove user: ' + node.attributes.u + ' t ' + node.attributes.t);
								break;
							case 'mvu': 
								//here goes a dirty hack!!!
								if(this.settings.layout.role == 8) break;
								
								this.ui.userMovedTo(node.attributes.u, node.attributes.r, node.attributes.t);
								break;
							case 'msgu':
								this.ui.messageAddedTo(node.attributes.u, node.attributes.a, node.attributes.r, node.firstChild.nodeValue, node.attributes.l, 'isUrgent', node.attributes.t);
								break;
							case 'msgb':
							case 'msg':
								this.ui.messageAddedTo(node.attributes.u, node.attributes.a, node.attributes.r, node.firstChild.nodeValue, node.attributes.l, '', node.attributes.t);
								break;
							case 'invu': 
								this.ui.invitedTo(node.attributes.u, node.attributes.r, node.firstChild.nodeValue);
								break;
							case 'inva': 
								this.ui.invitationAccepted(node.attributes.u, node.attributes.r, node.firstChild.nodeValue);
								break;
							case 'invd': 
								this.ui.invitationDeclined(node.attributes.u, node.attributes.r, node.firstChild.nodeValue);
								break;
							case 'ignu': 
								//here goes a dirty hack!!!
								if(node.attributes.a == undefined)
								{
									node.attributes.a = node.attributes.u;
									node.attributes.u = this.userid;
								}
								this.ui.ignored(node.attributes.u, node.attributes.a, node.firstChild.nodeValue);
								break;
							case 'nignu':
								this.ui.unignored(node.attributes.u, node.attributes.a, node.firstChild.nodeValue);
								break;
							case 'banu': 
								this.ui.banned(node.attributes.u, node.attributes.a, node.attributes.r, node.firstChild.nodeValue);
								break;
							case 'nbanu':
								this.ui.unbanned(node.attributes.u, node.attributes.a, node.firstChild.nodeValue);
								break;
							case 'ustc':
								state = Number(node.firstChild.nodeValue);
								if(this.ui.selfUserId == node.attributes.u)
								{
									this.intervalTime = ((state == ChatUI.prototype.USER_STATE_AWAY) ? this.settings.msgRequestIntervalAway : this.settings.msgRequestInterval) * 1000;
								}	
								this.ui.userStateChanged(node.attributes.u, state);
								break;
							case 'uclc':
								this.ui.userColorChanged(node.attributes.u, Number(node.firstChild.nodeValue));
								break;
							case 'usrp':
								//this.ui.setUserProfileText(node.attributes.u, node.firstChild.nodeValue);
								var val = node.firstChild.nodeValue;
								if(val != null)
								{
									_root.createEmptyMovieClip('profiler', 90);
									_root.profiler.flashchatid = this.connid;
									_root.profiler.getURL(val, '_blank', 'POST');
								}	
								break;
							case 'help':
								this.ui.setHelpText(node.firstChild.nodeValue);
								break;
							case 'rang':
								//here goes a dirty hack!!!
								if(this.settings.layout.role == 8 && this.userid != node.attributes.u) break;
								this.ui.bellRang(node.attributes.u, node.attributes.t);
								break;
							case 'back':
								this.ui.back(node.attributes.r);
								break;
							case 'backt':
								this.ui.backtime(node.attributes.r);
								break;
							case 'alrt':
								this.ui.alert(node.attributes.u, node.attributes.a, node.firstChild.nodeValue);
								break;
							case	'ralrt': 
								this.ui.roomAlert(node.attributes.u, node.firstChild.nodeValue);
								break;
							case 'calrt':
								this.ui.chatAlert(node.attributes.u, node.firstChild.nodeValue);
								break;
							case 'gag':
								this.ui.gag(node.attributes.u, node.attributes.a, node.firstChild.nodeValue);
								break;
							case 'ngag':
								this.ui.ungagged(node.attributes.u, node.attributes.a, node.firstChild.nodeValue);
								break;
							case 'cfrm':
								this.ui.confirm(node.attributes.u, node.attributes.a, node.firstChild.nodeValue);
								break;
							case 'fileshare': //---share
								if(node.attributes.a == undefined && node.attributes.u == this.ui.selfUserId)
								{ 
									break;//not show window if send to room!
								}																
								this.ui.fileShare(node.firstChild.nodeValue);
								break;
							case 'load_av_bg': 	
								this.ui.loadAvatarBG(node.firstChild.nodeValue);
								break;
							case 'load_photo': 	
								this.ui.loadPhoto(node.firstChild.nodeValue);
								break;	
							case 'mavt':
							case 'ravt':
								this.ui.setAvatar(node.nodeName, node.attributes.u, node.attributes.a, node.firstChild.nodeValue);
								break;
							case 'spht':
								this.ui.setPhoto(node.attributes.u, node.attributes.a, node.firstChild.nodeValue);
								break;
							case 'sgen':
								this.ui.setGender(node.attributes.u, node.firstChild.nodeValue);
								break;
							case 'notf':
								this.ui.userNotify(node.attributes.u);
								break;
							default:
								this.debug('Unknown response:' + node.toString());
								break;
						}
					}
				}
			}
		}
	}
	
	//if( this.enableSocketServer ) this.socketServer.incommings.splice(0, 1);
	
	this.enableAutopoll(startPoller);
}

//senders
ChatManager.prototype.sendTimeZone = function() {
	var req = this.getRequester();

	req.c  = 'tzset';
	req.tz = new Date().getTimezoneOffset();
	
	this.sendAndLoad(req);
}

ChatManager.prototype.loadMessages = function() {
	this.sendAndLoad(this.getRequester());

	/*
	var req = this.getRequester();

	req.c = 'msg';
	req.t = "FLOOD test FLOOD test FLOOD test FLOOD test FLOOD test FLOOD test FLOOD test";

	this.sendAndLoad(req);
	*/
}

ChatManager.prototype.login = function(login, password, lang, roomID) {
	var req = this.getRequester();

	req.c  = 'lin';
	req.lg = login;
	req.ps = password;
	req.l  = lang;

	if(roomID != undefined) req.r = roomID;

	req.tz = new Date().getTimezoneOffset();

	this.sendAndLoad(req);
};

ChatManager.prototype.logout = function() {
	//this.ui.saveUserSettings();
	
	var req = this.getRequester();
	req.c = 'lout';
	this.sendAndLoad(req);
	
	//implement logout behavior	
	if(this.settings.logout.redirect)
	{
		getURL(this.settings.logout.url,this.settings.logout.window);
	}		
	if(this.settings.logout.close)
	{
		getURL("javascript:window.close();");
	}	
	//---
};

ChatManager.prototype.getLanguage = function(lang, save_only) {
	var req = this.getRequester();

	req.c = 'glan';
	req.l = lang;
	req.s = (save_only)? 1 : 0;

	this.sendAndLoad(req);
};

ChatManager.prototype.sendAvatar = function(inType, inSmile, toUserID) {
	var req = this.getRequester();
	if(inType == 'mainchat') req.c = 'mavt';	
	if(inType == 'room') req.c = 'ravt';
	
	req.u = (toUserID == undefined)? 0 : toUserID;
	req.a = inSmile;
	
	this.sendAndLoad(req);
};

ChatManager.prototype.sendMessageTo = function(toUserID, toRoomID, txt, args, sup) {
	var req = this.getRequester();
	req.c = 'msg';

	req.u = toUserID;
	req.r = toRoomID;
	req.t = txt;
	if(args != undefined) req.a = args;
	if(sup  != undefined) req.s = sup;

	this.sendAndLoad(req);
};

ChatManager.prototype.moveTo = function(roomID, pass) {
	var req = this.getRequester();

	req.c  = 'mvu';
	req.r  = roomID;
	if(pass != undefined) req.ps = pass;

	this.sendAndLoad(req);
};

//!!!not needed longer!!!
ChatManager.prototype.inviteMoveTo = function(roomID)
{
	var req = this.getRequester();

	req.c  = 'imvu';
	req.r  = roomID;

	this.sendAndLoad(req);
};

ChatManager.prototype.createRoom = function(label, isPublic, password) {
	var req = this.getRequester();

	req.c = 'adr';
	req.l = label;
	req.p = (isPublic)?1:0;
	req.ps = password;

	this.sendAndLoad(req);
};

ChatManager.prototype.inviteUserTo = function(invitedUserID, toRoomID, txt) {
	var req = this.getRequester();

	req.c = 'invu';
	req.u = invitedUserID;
	req.r = toRoomID;
	req.t = txt;

	this.sendAndLoad(req);
};

ChatManager.prototype.acceptInvitationTo = function(invitedByUserID, toRoomID, txt) {
	var req = this.getRequester();

	req.c = 'inva';
	req.u = invitedByUserID;
	req.r = toRoomID;
	req.t = txt;

	this.sendAndLoad(req);
};

ChatManager.prototype.declineInvitationTo = function(invitedByUserID, toRoomID, txt) {
	var req = this.getRequester();

	req.c = 'invd';
	req.u = invitedByUserID;
	req.r = toRoomID;
	req.t = txt;

	this.sendAndLoad(req);
};

ChatManager.prototype.ignoreUser = function(ignoredUserID, txt) {
	var req = this.getRequester();

	req.c = 'ignu';
	req.u = ignoredUserID;
	req.t = txt;

	this.sendAndLoad(req);
};

ChatManager.prototype.unignoreUser = function(ignoredUserID, txt) {
	var req = this.getRequester();

	req.c = 'nignu';
	req.u = ignoredUserID;
	req.t = txt;

	this.sendAndLoad(req);
};

ChatManager.prototype.banUser = function(bannedUserID, banType, banRoomID, txt, sup) {
	var req = this.getRequester();

	req.c = 'banu';
	req.u = bannedUserID;
	req.b = banType;
	req.r = banRoomID;
	req.t = txt;
	if(sup != undefined) req.s = sup;

	this.sendAndLoad(req);
};

ChatManager.prototype.unbanUser = function(bannedUserID, txt, sup) {
	var req = this.getRequester();

	req.c = 'nbanu';
	req.u = bannedUserID;
	req.t = txt;
	if(sup != undefined) req.s = sup;

	this.sendAndLoad(req);
};

ChatManager.prototype.setState = function(state) {
	var req = this.getRequester();

	req.c = 'sst';
	req.t = state;

	this.sendAndLoad(req);
};

ChatManager.prototype.setColor = function(color) {
	var req = this.getRequester();

	req.c = 'scl';
	req.t = color;
	
	this.sendAndLoad(req);
};

ChatManager.prototype.requestUserProfileText = function(userid) {
	var req = this.getRequester();

	req.c = 'usrp';
	req.u = userid;

	this.sendAndLoad(req);
};

ChatManager.prototype.requestHelpText = function() {
	var req = this.getRequester();

	req.c = 'help';

	this.sendAndLoad(req);
};

ChatManager.prototype.saveChat = function() {
	/*
	_root.createEmptyMovieClip('saver', 90);
	_root.saver.id = this.connid;
	_root.saver.getURL(_root.documentRoot + 'save.php', '_blank', 'POST');
	*/
	var sendStr = _root.documentRoot + 'save.php?id=' + this.connid; 
	    sendStr += '&font=' + this.ui.settings.user.text.itemToChange.mainChat.fontFamily;
	    sendStr += '&size=' + this.ui.settings.user.text.itemToChange.mainChat.fontSize;
	
	_root.getURL(sendStr, '_blank');
};

ChatManager.prototype.ringBell = function() {
	var req = this.getRequester();

	req.c = 'ring';

	this.sendAndLoad(req);
};

ChatManager.prototype.back = function(numb) {
	var req = this.getRequester();

	req.c = 'back';
	req.n = numb;

	this.sendAndLoad(req);
};

ChatManager.prototype.backtime = function(numb) {
	var req = this.getRequester();

	req.c = 'backt';
	req.n = numb;

	this.sendAndLoad(req);
};

ChatManager.prototype.alert = function(userID, txt, sup){
	var req = this.getRequester();

	req.c = 'alrt';
	req.u = userID;
	req.t = txt;
	if(sup != undefined) req.s = sup;

	this.sendAndLoad(req);
};

ChatManager.prototype.roomAlert = function(roomID, txt, sup){
	var req = this.getRequester();

	req.c = 'ralrt';
	req.r = roomID;
	req.t = txt;
	if(sup != undefined) req.s = sup;

	this.sendAndLoad(req);
};

ChatManager.prototype.chatAlert = function(txt, sup){
	var req = this.getRequester();

	req.c = 'calrt';
	req.t = txt;
	if(sup != undefined) req.s = sup;

	this.sendAndLoad(req);
};

ChatManager.prototype.gag = function(userid, minutes, sup){
	var req = this.getRequester();

	req.c = 'gag';
	req.u = userid;
	req.t = minutes;
	if(sup != undefined) req.s = sup;
	
	this.sendAndLoad(req);
};

ChatManager.prototype.ungag = function(userid, sup){
	var req = this.getRequester();

	req.c = 'ngag';
	req.u = userid;
	if(sup != undefined) req.s = sup;
	
	this.sendAndLoad(req);
};

//inArgs = {alrt|gag}
ChatManager.prototype.confirm = function(userid, inData, inArgs){
	var req = this.getRequester();

	req.c = 'cfrm';
	req.u = userid;
	req.t = inData;
	req.a = inArgs;
	
	this.sendAndLoad(req);
};

ChatManager.prototype.startBot = function(userName, roomId, sup){
	var req = this.getRequester();

	req.c  = 'srtbt';
	req.lg = userName;
	req.r  = roomId;
	if(sup != undefined) req.s  = sup;
	
	this.sendAndLoad(req);
};

ChatManager.prototype.killBot = function(userName, sup){
	var req = this.getRequester();

	req.c  = 'klbt';
	req.lg = userName;
	if(sup != undefined) req.s  = sup;
	
	this.sendAndLoad(req);
};

ChatManager.prototype.addBot = function(login, bot, sup){
	var req = this.getRequester();

	req.c  = 'adbt';
	req.lg = login;
	req.a  = bot;
	if(sup != undefined) req.s  = sup;
	
	this.sendAndLoad(req);
};

ChatManager.prototype.teachBot = function(userName, args, sup){
	var req = this.getRequester();

	req.c  = 'tchbt';
	req.lg = userName;
	req.a  = args;
	if(sup != undefined) req.s  = sup;
	
	this.sendAndLoad(req);
};

ChatManager.prototype.unTeachBot = function(userName, args, sup){
	var req = this.getRequester();

	req.c  = 'utbt';
	req.lg = userName;
	req.a  = args;
	if(sup != undefined) req.s  = sup;
	
	this.sendAndLoad(req);
};

ChatManager.prototype.removeBot = function(userName, sup){
	var req = this.getRequester();

	req.c  = 'rmbt';
	req.lg = userName;
	if(sup != undefined) req.s  = sup;
	
	this.sendAndLoad(req);
};

ChatManager.prototype.showBots = function(sup){ 
	var req = this.getRequester();
	
	req.c  = 'swbt';
	if(sup != undefined) req.s = sup;
	
	this.sendAndLoad(req);
};

ChatManager.prototype.sendPhoto = function(inURL){ 
	var req = this.getRequester();
	
	req.c = 'spht';
	req.a = inURL;
	
	this.sendAndLoad(req);
};

ChatManager.prototype.getPhoto = function(inUserID){ 
	var req = this.getRequester();
	
	req.c = 'gpht';
	req.u = inUserID;
	
	this.sendAndLoad(req);
};