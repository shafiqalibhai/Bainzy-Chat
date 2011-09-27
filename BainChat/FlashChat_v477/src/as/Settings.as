function Settings() {
	this.chatid = 1;
	this.debug = false;
	this.version = '5.0';
	this.enableSocketServer = false;
	this.liveSupportMode = false;
	this.hideSelfPopup = true;
	this.showConfirmation = true;
	this.labelFormat = '[AVATAR USER] TIMESTAMP:';
	this.maxMessageSize = 500;
	this.maxMessageCount = 1000;
	this.helpUrl = '';
	this.userListAutoExpand = false;
	this.msgRequestInterval = 3;
	this.msgRequestIntervalAway = 5;
	this.floodInterval = 1;
	this.inactivityInterval = 36000; //10 hours
	this.roomTitleFormat = 'ROOM_LABEL - USER_COUNT';
	this.maxUsersPerRoom = 20;
	this.listOrder = 'ENTRY';
	this.disabledIRC = '';
	this.mods = '';
	this.defaultRoom = 1;
	this.defaultTheme = 'navy';
	this.defaultSkin = 'default_skin';
	this.defaultLanguage = 'en';
	this.allowLanguage = true;
	this.allowPhoto = true;
	this.splashWindow  = false;

	this.layouts = new Array();
	this.layouts[0] = new CLayout();
	this.layout = this.layouts[0];

	this.socketServer   = new Object();
	this.smiles         = new Object();
	this.extendedSmiles = new Object();
	
	this.sound = new Object();
	this.sound_options = new Object();
	
	this.avatars = new CAvatars();
	this.text = new CText();
	
	this.special_language = new Object();
	
	//Big Skin (like xp_skin, ...)
	this.bigSkin = new Object();
	this.bigSkin.defaultSkin = 0;
	this.bigSkin.preset = new Array();
	this.bigSkin.preset.push(new CBigSkin());
	
	//Simply Skin (like navy, ...)
	this.skin = new Object();
	this.skin.defaultSkin = 0;
	this.skin.preset = new Array();
	this.skin.preset.push(new CSkin());
	
	this.languages = new Array();
	this.languages.push(new CLanguage());
	
	this.user = new Object();
	this.user.skin = null;
	this.user.sound = null;
	this.user.profile = new Object();	
	this.user.user.profile.nick_image = '';
	
	//login
	this.login = new Object();
	//logout
	this.logout = new Object();
	//module
	this.module = new Array();
};

Settings.prototype = new Initable();

Settings.prototype.init = function(xml) {
	//trace(' BIG XML ');
	//trace(xml);
	
	this.copyAttrs(xml, this);
	
	var defaultSkin = xml.attributes.defaultTheme;
	var defaultBigSkin = xml.attributes.defaultSkin;

	var skinNumb = 0;
	var langNumb = 0;
	var layoutNumb = 0;
	var bigSkinNumb = 0;
	
	for (var i = 0; i<xml.childNodes.length; i++) {
		var node = xml.childNodes[i];
		
		if(node.nodeType == 1) {
			
			switch(node.nodeName) {
				case 'socketServer':
					this.copyAllAttrs(node, this.socketServer);	
					break;
				case 'smiles': 
					this.copyAllAttrs(node, this.smiles);
					SmileTextConst.setNewPattern(this.smiles);
					break;
				case 'sound': 
					this.copyAllAttrs(node, this.sound); 
					break;
				case 'language': 
					if(this.languages[langNumb]) {
						this.languages[langNumb].init(node);
					} else {
						var lang = new CLanguage();
						lang.init(node);
						this.languages.push(lang); 
					}
					langNumb++;
					break;
				case 'skin':
					if(this.bigSkin.preset[bigSkinNumb]) {
						this.bigSkin.preset[bigSkinNumb].init(node); 
					} else {
	 					var bigSkin = new CBigSkin();
						bigSkin.init(node);
						this.bigSkin.preset.push(bigSkin); 
					}

					if(this.bigSkin.preset[bigSkinNumb].swf_name == defaultBigSkin) this.bigSkin.defaultSkin = bigSkinNumb;
					
					bigSkinNumb++;
					break;
				
				case 'theme':
					if(this.skin.preset[skinNumb]) {
						this.skin.preset[skinNumb].init(node); 
					} else {
	 					var skin = new CSkin();
						skin.init(node);
						this.skin.preset.push(skin); 
					}
					
					if(this.skin.preset[skinNumb].id == defaultSkin) this.skin.defaultSkin = skinNumb;
					
					skinNumb++;
					break;
				case 'layout':
					if(this.layouts[layoutNumb]) {
						this.layouts[layoutNumb].init(node); 
					} else {
	 					var layout = new CLayout();
						layout.init(node);
						this.layouts.push(layout); 
					}
					
					layoutNumb++;
					break;
				case 'sound_options' : 
					this.copyAllAttrs(node, this.sound_options);					
					break;
				case 'text' : 
					this.text.init(node);
					break;
				case 'special_language' : 
					this.copyAllAttrs(node, this.special_language);
					break;
				case 'extendedSmiles' : //now disabled
					/*
					for (var j = node.childNodes.length-1; j >= 0; j--)
					{
						var itm = node.childNodes[j];
						if(itm.nodeType == 1)
						{
							this.extendedSmiles[itm.nodeName] = new Object();
							this.copyAllAttrs(itm, this.extendedSmiles[itm.nodeName]);
						}
					}
					SmileTextConst.setExtendedPattern(this.extendedSmiles);
					*/
					break;
				case 'logout' : 
					this.copyAllAttrs(node, this.logout);
					break;
				case 'login' :
				    for (var j = node.childNodes.length-1; j >= 0; j--)
					{
						var itm = node.childNodes[j];
						if(itm.nodeType == 1)
						{
							this.login[itm.nodeName] = new Object();
							this.copyAllAttrs(itm, this.login[itm.nodeName]);
						}
					}
					this.copyAllAttrs(node, this.login);
					//skins are better accesed by their index in preset array so them is changed to index
					for(var k =0 ;k<this.skin.preset.length; k++)
					{
						if(this.login.theme == this.skin.preset[k].id )
						{
							this.login.theme = k;
						}
					}
					break;
				case 'module' : 					
					var module = new Object();
					this.copyAllAttrs(node, module);
					
					var splt = module.path.split(',');
					var mod_cnt = 0;
					if(String(splt) != '')
						mod_cnt = splt.length;
					if(mod_cnt > 3)	mod_cnt = 3; //default value for now
					
					this.module = new Array(mod_cnt);
					this.module.anchors = new Object();
						
					for(var prop in module)
					{
						var p = module[prop].split(',');
						for(var j = 0; j < this.module.length; j++)
						{
							if(this.module[j] == null)
								this.module[j] = new Object();
							
							switch(prop)
							{
								case 'path' : 
									var path = String(p[j]);
									if(path.indexOf('http') >= 0)
										path = '';
									
									this.module[j][prop] = path;
									break;
								case 'stretch' : 
									if(p[j] == 'true') p[j] = '1';
									else if(p[j] == 'false') p[j] = '';
									
									this.module[j][prop] = p[j];
									break;
								case 'anchor' :
									this.module.anchors[Number(p[j])] = j;
									this.module[j][prop] = Number(p[j]);
									break;
								default	:
									this.module[j][prop] = Number(p[j]);
									break;	
							}	
						}	
					}
					
					break;
				case 'avatars' :
					
					this.avatars.init(node);
					
					break;
			}
		}
	}
	
	//trace(' SETTINGS ');
	//dbg(this);
};