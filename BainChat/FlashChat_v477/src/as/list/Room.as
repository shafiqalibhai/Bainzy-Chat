function Room(id, label, inItemListener) {
	this.users = new Array();
	this.opened = false;
	this.lock = false; 
	
	this.isprivate = false;
	this.itemListener = null;
	
	if(arguments.length > 1) {
		this.id = id;
		this.label = label;
		this.itemListener = inItemListener;
	} else {
		var _xml = arguments[0];
		this.id = _xml.attributes.id;
		this.label = _xml.attributes.label;
		for(var i = 0; i < _xml.childNodes.length; i++) {
			var node = _xml.childNodes[i];
			if(node.nodeType == 1 && node.nodeName == 'user') {
				//XXX01 avu: FIX THIS CODE.
				this.users.push(new User(node.attributes.id, node.attributes.label, null, null, null, null));
			}
		}
	} 

};

//PUBLIC METHODS.
Room.prototype.addUser = function(user) {
	this.users.push(user);
	this.sortUsers();
};

Room.prototype.sortUsers = function() {
	order = _global.FlashChatNS.chatUI.settings.listOrder;
	
	//AZ, ENTRY, MOD_THEN_AZ, MOD_THEN_ENTRY
	switch(order)
	{
		case 'AZ' :
			this.users.sortOn('label', Array.CASEINSENSITIVE);
			break;
		case 'ENTRY' :
			break;
		case 'MOD_THEN_AZ' :
			this.users.sort(this.compareFunction);	
			break;
		case 'MOD_THEN_ENTRY' :
			this.users.sort(this.compareFunction);
			break;
		case 'STATUS' :
			this.users.sort(this.compareByStateFunction);
			break;
		case 'MOD_STATUS' :
			this.users.sort(this.compareFunction);
			break;
	}
};

Room.prototype.compareFunction = function(a,b) {
	
	if (a.roles == a.ROLE_ADMIN && b.roles != a.ROLE_ADMIN) return -1;
	if (a.roles != a.ROLE_ADMIN && b.roles == a.ROLE_ADMIN) return 1;
	
	if(_global.FlashChatNS.chatUI.settings.listOrder == 'MOD_THEN_AZ')
	{ 
		var a_up = a.label.toUpperCase();
		var b_up = b.label.toUpperCase();
		if (a_up < b_up) return -1;
		if (a_up > b_up) return 1;
	}
	
	if(_global.FlashChatNS.chatUI.settings.listOrder == 'MOD_STATUS')
	{
		var a_up = _global.FlashChatNS.chatUI.USER_STATE_LIST.states[a.state].toUpperCase();
		var b_up = _global.FlashChatNS.chatUI.USER_STATE_LIST.states[b.state].toUpperCase();
		if (a_up < b_up) return -1;
		if (a_up > b_up) return 1;
	}
	
	return 0;
};

Room.prototype.compareByStateFunction = function(a,b) {
	var a_state = _global.FlashChatNS.chatUI.USER_STATE_LIST.states[a.state].toUpperCase();
	var b_state = _global.FlashChatNS.chatUI.USER_STATE_LIST.states[b.state].toUpperCase();
	
	
	if (a_state < b_state) return -1;
	if (a_state > b_state) return 1;
	
	return 0;
};

Room.prototype.removeUser = function(userid) {
	var userIdx = this.getUserIdx(userid);
	if (userIdx != -1) {
		this.users.splice(userIdx, 1);
	}
};

Room.prototype.containsUser = function(userid) {
	return (this.getUserIdx(userid) != -1);
};

Room.prototype.getUser = function(userid) {
	var userIdx = this.getUserIdx(userid);
	return (userIdx == -1 ? null : this.users[userIdx]);
};

Room.prototype.getUserCount = function() {
	return this.users.length;
};

Room.prototype.getUserByName = function(inUserName) {
	for (var i = 0; i < this.users.length; i ++) {
		if (this.users[i].label.toLowerCase() == inUserName.toLowerCase()) {
			return this.users[i];
		}
	}
	return null;
};

//PRIVATE METHODS.

Room.prototype.getUserIdx = function(userid) {
	for (var i = 0; i < this.users.length; i ++) {
		if (this.users[i].id == userid) {
			return i;
		}
	}
	return -1;
};

/*
Room.prototype.messagesToString = function() {
	var ret = '';
	for(var i = 0; i < this.messages.length; i++) {
		ret += this.messages[i].toString() + '<br>';
	}
	
	return ret;
};
*/

Room.prototype.setOpened = function(inOpened) {
	this.opened = inOpened;
};

Room.prototype.getOpened = function() {
	return this.opened;
};

//returns name of movie clip to display a room.
Room.prototype.getMC = function() {
	return 'ItemGroup';
};

//returns listener object that will react to events in room movie clip.
//listener should implement 'onRoomStateChange(room)' method.
Room.prototype.getItemListener = function() {
	return this.itemListener;
};

//sets item listener. should be used in case room was created from xml.
Room.prototype.setItemListener = function(inItemListener) {
	this.itemListener = inItemListener;
};

Room.prototype.toString = function() {
	return 'Room[id=' + this.id + ',label=' + this.label + ',password=' + this.password + ']';
};
