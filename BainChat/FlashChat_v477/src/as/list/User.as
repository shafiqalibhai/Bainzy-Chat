function User(id, label, inColor, inState, inRoles, inGender, inItemListener) {
	this.id = id;
	this.label = label;
	//this.room = null;
	this.color = inColor;
	this.state = inState;
	
	this.ignored    = false;
	this.banned     = false;
	this.roles      = inRoles;
	this.gender     = inGender;
	this.portrait   = '';
	this.fcportrait = '';
	
	this.itemListener = inItemListener;
	
	this.avatar = new Object();
	this.avatar.mainchat = '';
	this.avatar.room     = '';
};

User.prototype.ROLE_USER      = 1;
User.prototype.ROLE_ADMIN     = 2;
User.prototype.ROLE_MODERATOR = 3;
User.prototype.ROLE_SPY       = 4;
User.prototype.ROLE_CUSTOMER  = 8;

User.prototype.GENDER_MALE    = 'M';
User.prototype.GENDER_FEMALE  = 'F';

//PUBLIC METHODS.
User.prototype.setAvatar = function(inType, inValue) {
	this.avatar[inType] = inValue;
};

User.prototype.getAvatar = function(inType) {
	return this.avatar[inType];
};

User.prototype.getState = function() {
	return this.state;
};

User.prototype.setState = function(inState) {
	this.state = inState;
};

User.prototype.getRoles = function() {
	return this.roles;
};

User.prototype.getColor = function() {
	return this.color;
};

User.prototype.setColor = function(inColor) {
	this.color = inColor;
};

User.prototype.getIgnored = function() {
	return this.ignored;
};

User.prototype.setIgnored = function(inIgnored) {
	this.ignored = inIgnored;
};

User.prototype.getBanned = function() {
	return this.banned;
};

User.prototype.setBanned = function(inBanned) {
	this.banned = inBanned;
};

User.prototype.getPortrait = function() {
	return this.portrait;
};

User.prototype.setPortrait = function(inPortrait) {
	this.portrait = inPortrait;
};

User.prototype.getFCPortrait = function() {
	return this.fcportrait;
};

User.prototype.setFCPortrait = function(inPortrait) {
	this.fcportrait = inPortrait;
};

User.prototype.getMC = function() {
	return 'ItemUser';
};

//returns listener object that will react to events in user movie clip.
//listener should implement the following method:
//onUserClick(user, mouseX, mouseY, buttonX, buttonY, buttonWidth, buttonHeight)
User.prototype.getItemListener = function() {
	return this.itemListener;
};

//sets item listener. should be used in case user was created from xml.
User.prototype.setItemListener = function(inItemListener) {
	this.itemListener = inItemListener;
};

//PRIVATE METHODS.

User.prototype.toString = function() {
	return 'User[id=' + this.id + 
			',label=' + this.label + 
			',state=' + this.state + 
			',portrait=' + this.portrait + 
			',fcportrait=' + this.fcportrait + ']';
};
