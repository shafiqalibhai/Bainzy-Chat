#initclip 10

_global.LoginBox = function() {
	//change height and width based on  config.php settings
	if(_level0.ini.login.height != "" && _level0.ini.login.height != "0")
	{
		this._height = _level0.ini.login.height;
	}
	if(_level0.ini.login.width != "" && _level0.ini.login.width != "0")
	{
		this._width = _level0.ini.login.width;
	}
	//change height and width based on  config.php settings
	super();
	 
	this.dialog_name = 'loginbox';
	
	//redirect links from InputGroup
	this.lblUserName = this.InputGroup.lblUserName;
	this.lblPassword = this.InputGroup.lblPassword;
	this.lblModerator = this.InputGroup.lblModerator;
	this.lblLanguage = this.InputGroup.lblLanguage;
	this.lblPasswordRequired = this.InputGroup.lblPasswordRequired;
	this.lblUserNameRequired = this.InputGroup.lblUserNameRequired;
	
	this.txtUserName = this.InputGroup.txtUserName;
	this.txtUserNameBackground = this.InputGroup.txtUserNameBackground;
	this.txtPassword = this.InputGroup.txtPassword;
	this.txtPasswordBackground = this.InputGroup.txtPasswordBackground;
	this.languageChooser = this.InputGroup.languageChooser;
	
	this.setCloseButtonEnabled(false);
	this._visible = false;
	this.txtLabel.autoSize = 'left';
	//this.vartxtLabel="Hello";
	this.txtPassword.password = true;
	
	//login settings as in config.php
	this.config_fields = new Array('lang','title_label');
	this.field_labels = new Array('lblLanguage','txtLabel');
	this.field_names = new Array('languageChooser','');
	this.config_field_attributes = new Array('align','x_label','y_label','x_field','y_field');
	
	var temp_attribute = "";
	var replace_attribute = "";
	var temp_field = "";
	var temp_field_attribute ="";
	for (var i=0; i < this.config_fields.length; i++)
	{
		for(var j = 0; j < this.config_field_attributes.length; j++)
		{
			temp_attribute = _level0.ini.login[this.config_fields[i]][this.config_field_attributes[j]];
			switch(this.config_field_attributes[j])
			{
				 case 'align':
				  temp_field = this.field_labels[i];
				  //this[this.field_labels[j]].autosize = false;
				  temp_field_attribute = 'align';
				  var fmt = this[temp_field].getTextFormat();
	              fmt.align = temp_attribute;
	              this[temp_field].setNewTextFormat(fmt);
				  replace_attribute = temp_attribute;
				  continue;
				  break;
				 case 'x_label':
				  temp_field = this.field_labels[i];
				  replace_attribute = this.setInputFieldX(temp_attribute);
				  temp_field_attribute = '_x';
				  break;
				 case 'x_field':
				  temp_field = this.field_names[i];
				  replace_attribute = this.setInputFieldX(temp_attribute); 
				  temp_field_attribute = '_x';
				  break;
				 case 'y_label':
				  temp_field = this.field_labels[i];
				  replace_attribute = this.setInputFieldY(temp_attribute);
				  temp_field_attribute = '_y';
				  break;
				 case 'y_field':
				  temp_field = this.field_names[i];
				  replace_attribute =this.setInputFieldY(temp_attribute); 
				  temp_field_attribute = '_y';
				  break;
				  
				 default:
				  
			}
			//var temp_field_instance_attibute = eval("this." + temp_field + "." + temp_field_attribute);
			eval_text = "this." + temp_field + "." + temp_field_attribute + " = " +replace_attribute + ";";
 		    //trace( eval_text);
			
 	     if(temp_attribute != "" and temp_attribute != "0" and temp_attribute != undefined  and temp_field != '')
		 {
			this[temp_field][temp_field_attribute] = replace_attribute;
		 }
		}
	}
	if(_level0.ini.login.title == 'false')
	{
	 this.dbTopLeft._visible = false;
	 this.dbTop._visible = false;
	 this.dbTopRight._visible = false;
	}

	if(_level0.ini.login.username.type == "password")
	{
	 this.txtUserName.password = true;
	}
	if(_level0.ini.login.username.x_label != "" && _level0.ini.login.username.x_label != "0")
	{
	 this.lblUserName._x = this.setInputFieldX(_level0.ini.login.username.x_label);
	}
	if(_level0.ini.login.username.x_field!= "" && _level0.ini.login.username.x_field!= "0")
	{
	 this.txtUserName._x = this.setInputFieldX(_level0.ini.login.username.x_field);
	 this.txtUserNameBackground._x = this.setInputFieldX(_level0.ini.login.username.x_field);
    }
	if(_level0.ini.login.username.y_label!="" && _level0.ini.login.username.y_label!="0")
	{
	 this.lblUserName._y = this.setInputFieldY(this._level0.ini.login.username.y_label);
	}
	if(_level0.ini.login.username.y_field!="" && _level0.ini.login.username.y_field!="0")
	{
	 this.txtUserName._y = this.setInputFieldY(_level0.ini.login.username.y_field) ;
	 this.txtUserNameBackground._y = this.setInputFieldY(_level0.ini.login.username.y_field);
	}
	
	var fmt = this.lblUserName.getTextFormat();
	fmt.align = _level0.ini.login.username.align;
	this.lblUserName.setNewTextFormat(fmt);
	this.txtUserName._width = _level0.ini.login.username.width;
	this.txtUserNameBackground._width = this.txtUserName._width;
	
	if(_level0.ini.login.password.type == "text")
	{
	 this.txtPassword.password = false;
	}
	if(_level0.ini.login.password.x_label!="" && _level0.ini.login.password.x_label!="0")
	{
	 this.lblPassword._x = this.setInputFieldX(_level0.ini.login.password.x_label);
	 this.lblModerator._x = this.lblPassword._x;
	}
	if(_level0.ini.login.password.x_field!="" && _level0.ini.login.password.x_field!="0")
	{
	 this.txtPassword._x = this.setInputFieldX(_level0.ini.login.password.x_field);
	 this.txtPasswordBackground._x = this.setInputFieldX(_level0.ini.login.password.x_field);
	}
	if(_level0.ini.login.password.y_label!="" && _level0.ini.login.password.y_label!="0")
	{
	 this.lblPassword._y = this.setInputFieldY(_level0.ini.login.password.y_label);
	 this.lblModerator._y = this.lblPassword._y +15.8;
	}
	if(_level0.ini.login.password.y_field!="" && _level0.ini.login.password.y_field!="0")
	{
	 this.txtPassword._y = this.setInputFieldY(_level0.ini.login.password.y_field);
	 this.txtPasswordBackground._y = this.setInputFieldY(_level0.ini.login.password.y_field);
	}
	
	fmt = this.lblPassword.getTextFormat();
	fmt.align = _level0.ini.login.password.align;
	this.lblPassword.setNewTextFormat(fmt);
	fmt = this.lblModerator.getTextFormat();
	fmt.align = _level0.ini.login.password.align;
	this.lblModerator.setNewTextFormat(fmt);
	this.txtPassword._width = _level0.ini.login.password.width;
	this.txtPasswordBackground._width = this.txtPassword._width;
	
	this.btnLogin._visible = (_level0.ini.login.btn=='false'?false:true);
	
	//login settings as in config.php
	this.languageList = null;
	this.selectedLanguage = null;
	this.languageTarget = null;
	
	this.labelTextId = null;
	this.language = null;

	this.txtUserName._height = this.txtPassword._height = 20;
	this.txtUserNameBackground._height = this.txtPasswordBackground._height = this.txtUserName._height;
	
	this.txtUserName.onChanged = function() {
		this._parent.languageChooser.myOnKillFocus();
		this._parent._parent.textValidator();
	};
	this.txtPassword.onChanged = function() {
		this._parent.languageChooser.myOnKillFocus();
		//this._parent._parent.textValidator();
	};
	this.txtUserName.background = false;
	this.txtPassword.background = false;
	this.txtUserName.onSetFocus = function() {
		this.borderColor = this._style.bodyText;
	};
	this.txtUserName.onKillFocus = function() {
		this.borderColor = this._style.borderColor;
	};
	this.txtPassword.onSetFocus = function() {
		this.borderColor = this._style.bodyText;
	};
	this.txtPassword.onKillFocus = function() {
		this.borderColor = this._style.borderColor;
	};
};

_global.LoginBox.prototype = new _global.DialogBox();

//PUBLIC METHODS.

_global.LoginBox.prototype.setEnabled = function(inDialogEnabled) {
	super.setEnabled(inDialogEnabled);
	this.textValidator();
	this.languageChooser.enabled = (inDialogEnabled);
};

_global.LoginBox.prototype.show = function() 
{
	this.btnLogin.setClickHandler('processButton', this);
	this.languageChooser.setChangeHandler('processLanguageChooser', this);
	
	this.txtUserName.text = '';
	this.txtPassword.text = '';
	this.textValidator();
	this.setLanguageList(this.languageList);
	this.setLabelText(this.labelTextId);
	this.setSelectedLanguage(this.selectedLanguage);
	
	if(_level0.ini.allowLanguage == false)
	{
		this.languageChooser.setEnabled(false);
		this.languageChooser._visible = false;
		this.lblLanguage._visible = false;
		
		var dim = this.getSize();
		var fH  = this.txtLabel._y + this.txtLabel._height + 
				this.lblModerator._y + this.lblModerator._height - this.lblUserName._y + this.btnLogin._height;
		var dH = (dim.height - fH) / 3;
		
		this.InputGroup._y = (this.txtLabel._y + this.txtLabel._height + dH);
		this.btnLogin._y = dim.height - this.btnLogin._height - dH;
	}
	
	Key.addListener(this);
	this._visible = true;
	Selection.setFocus(this.txtUserName);
};



_global.LoginBox.prototype.setLabelText = function(inLabelText) {
	this.labelTextId = inLabelText;
	var toLbl = this.language.messages[this.labelTextId];
	//this.txtLabel.text = (toLbl != undefined)? toLbl : this.labelTextId;
	this.vartxtLabel = (toLbl != undefined)? toLbl : this.labelTextId;
	//this.txtLabel.border = true;
	
	this.vartxtLabel = "<p align=\""+_level0.ini.login.title_label.align+"\"><font color=\"#" + this.inttohex(this.style.bodyText) + "\">"+ this.vartxtLabel + "</font></p>";
	//trace(this.vartxtLabel);
	
	this.txtLabel._y = (this.InputGroup._y - this.txtLabel.textHeight - this.dbTop._height)/2 + this.dbTop._height;
	if( this.txtLabel._y < this.dbTop._height+this.dbTop._y) this.txtLabel._y = this.dbTop._height + this.dbTop._y;	
	//this.txtLabel.text = inLabelText;
};

_global.LoginBox.prototype.setLanguageList = function(inLanguageList) {
	this.languageList = inLanguageList;
	this.languageChooser.removeAll();
	for (var i = 0; i < this.languageList.length; i ++) {
		this.languageChooser.addItem(this.languageList[i].name, this.languageList[i]);
		//trace(this.languageList[i].name);
	}
};

_global.LoginBox.prototype.setSelectedLanguage = function(inSelectedLanguage) {
	this.selectedLanguage = inSelectedLanguage;
	for (var i = 0; i < this.languageList.length; i ++) {
		if (this.languageList[i].name == inSelectedLanguage.name) {
			this.languageChooser.setSelectedIndex(i);
			return;
		}
	}
};

_global.LoginBox.prototype.setLanguageTarget = function(inLanguageTarget) {
	this.languageTarget = inLanguageTarget;
};

_global.LoginBox.prototype.getUserName = function() {
	return this.txtUserName.text;
};

_global.LoginBox.prototype.getPassword = function() {
	return this.txtPassword.text;
};

_global.LoginBox.prototype.getSelectedLanguage = function() {
	return this.languageChooser.getSelectedItem().data;
};

_global.LoginBox.prototype.initialized = function() {
	return (super.initialized() && (this.btnLogin.setEnabled != null));
};

_global.LoginBox.prototype.applyTextProperty = function(propName, val)
{
	setTextProperty(propName, val, this.txtLabel);
	setTextProperty(propName, val, this.lblUserName);
	setTextProperty(propName, val, this.lblPassword);
	setTextProperty(propName, val, this.lblLanguage);
}

_global.LoginBox.prototype.applyStyle = function(inStyle) {
	//change themes based of config loin settings
	inStyle = _level0.ini.skin.preset[_level0.ini.login.theme];
	objChatUI.applyBackground(inStyle);
	//change themes based of config loin settings ends here
	if (!inStyle.showBackgroundImagesOnLogin) {
		inStyle.dialogBackgroundImage = null;
	}
	super.applyStyle(inStyle);
	
	this.txtLabel.textColor = inStyle.bodyText;
	this.lblUserName.textColor = inStyle.bodyText;
	this.lblPassword.textColor = inStyle.bodyText;
	this.lblModerator.textColor = inStyle.bodyText;
	this.lblLanguage.textColor = inStyle.bodyText;
	this.txtUserName.textColor = inStyle.buttonText;
	this.txtUserName._style = inStyle;
	this.txtUserName.borderColor = inStyle.borderColor;
	this.txtUserName.border = true;
	this.txtPassword.textColor = inStyle.buttonText;
	this.txtPassword._style = inStyle;
	this.txtPassword.borderColor = inStyle.borderColor;
	this.txtPassword.border = true;
	var c = new Color(this.txtUserNameBackground);
	c.setRGB(inStyle.inputBoxBackground);
	this.txtUserNameBackground._alpha = inStyle.uiAlpha;
	c = new Color(this.txtPasswordBackground);
	c.setRGB(inStyle.inputBoxBackground);
	this.txtPasswordBackground._alpha = inStyle.uiAlpha;
};

_global.LoginBox.prototype.applyLanguage = function(inLanguage) {
	this.language = inLanguage;
	this.setLabelText(this.labelTextId);
	this.lblUserName.text = this.language.dialog.login.username;
	this.lblPassword.text = this.language.dialog.login.password;
	this.lblModerator.text = this.language.dialog.login.moderator;
	this.lblLanguage.text = this.language.dialog.login.language;
	
	if(_level0.ini.login.username.req == 'true' )
	{
	 this.lblUserNameRequired._x = this.txtUserName._x + this.txtUserName._width + 1;
	 this.lblUserNameRequired._y = this.txtUserName._y;
	 this.lblUserNameRequired.text = this.language.dialog.login.required;
	 this.lblUserNameRequired.autoSize = true;
    }
	if(_level0.ini.login.password.req == 'true' )
	{
	 this.lblPasswordRequired._x = this.txtPassword._x + this.txtPassword._width + 1;
	 this.lblPasswordRequired._y = this.txtPassword._y;
	 this.lblPasswordRequired.text = this.language.dialog.login.required;
	 this.lblPasswordRequired.autoSize = true;
    }
	
	this.btnLogin.setLabel(this.language.dialog.login.loginBtn );
	this.btnLogin._x = (this.dialogWidth - this.btnLogin._width) / 2;
};

//PRIVATE METHODS.

_global.LoginBox.prototype.onKeyDown = function() {
	if(this.btnLogin.enabled)
	{ 
		if(this.handlerObj.isSpecialLanguage(this.languageChooser.getSelectedItem().data.id))
		{ 
			if(Key.isDown(Key.CONTROL) && Key.isDown(Key.ENTER))
			{ 
				this.processButton();
			}
		}
		else	if (Key.isDown(Key.ENTER))
		{
			this.processButton();
		}
	}
};

_global.LoginBox.prototype.processButton = function() {
	var usr = this.getUserName();
	
	//show error message if username or password is not inputted when it is set as required in config.php
	var pswd = this.getPassword();
	if(((_level0.ini.login.username.req == 'true') && (usr.length == 0)) ||
  	   ((_level0.ini.login.password.req == 'true') && (pswd.length == 0)))
	{
	 //this.txtLabel.text = this.language.messages.wrongPass;
	 this.vartxtLabel = this.language.messages.wrongPass;
	 this.vartxtLabel = "<p align=\""+_level0.ini.login.title_label.align+"\"><font color=\"#" + this.inttohex(this.style.bodyText) + "\">"+ this.vartxtLabel + "</font></p>";
	 return;
	}
	//show error message if username or password is not inputted when it is set as required in config.php ends here
	
	
	
	//fix for symbol #160
	var str_buff = '';
	for(var i = 0; i < length(usr); i++) 
	{ 
		if(ord(usr.charAt(i)) == 160) continue;
		
		str_buff += usr.charAt(i);
	}
	usr = str_buff;	
	
	if(usr.trim() != '') 	
	{ 
		this._visible = false;
		Key.removeListener(this);
		this.handlerObj[this.handlerFunctionName](this);
	}
	else
	{
		this.txtUserName.text = '';
		Selection.setFocus(this.txtUserName);
	}
};

_global.LoginBox.prototype.processLanguageChooser = function() {
	var chosenLanguage = this.languageChooser.getSelectedItem().data;
	this.languageTarget.setSelectedLanguage(chosenLanguage);
	this.languageTarget.applyLanguage(chosenLanguage);
};

_global.LoginBox.prototype.textValidator = function() {
	this.btnLogin.setEnabled( (this.getEnabled() && (this.txtUserName.text.length > 0)) );
};

_global.LoginBox.prototype.setInputFieldX = function(field_x) {
	  var this_start_x= - this.InputGroup._x;
      return Number(field_x) + this_start_x;
	
}
_global.LoginBox.prototype.setInputFieldY = function(field_y) {
	  var this_start_y = this.dbTop._height - this.InputGroup._y ;
	  return Number(field_y) + this_start_y; 
}
_global.LoginBox.prototype.inttohex=function(x)
{
y = new Array (8);
hex = new Array ("0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F");

for (k=7; k >= 0; k--)
{
y[k] = x >> (k*4);
if (y[k] > 0)
x = x % Math.pow (16, k);
}
final = new String();
for (j = 7; j >= 0; j--)
final += hex[y[j]];
return final;
}
Object.registerClass('LoginBox', _global.LoginBox);

#endinitclip
