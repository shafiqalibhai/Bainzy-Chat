#initclip 10

_global.TabbedPropertiesBox = function() {        
        
        super();
        
        this.dialog_name = 'tabbedpropertiesbox';
        
        this.isCanceled = false;
        this._visible = false;
        this.depth = 100;
        
        this.textStyle = new Object();
        
        this.tabs = new Array();
        
        this.tabs[0] = this.themesTab;
        this.tabs[1] = this.soundsTab;
        this.tabs[2] = this.textTab;
        this.tabs[3] = this.aboutTab;
        this.tabs[4] = this.adminTab;
        this.tabs[5] = this.effectsTab;
        
        this.tabIndexes = new Object();
        this.tabIndexes.themes  = 0;
        this.tabIndexes.sounds  = 1;
        this.tabIndexes.text    = 2;
        this.tabIndexes.about   = 3;
        this.tabIndexes.admin   = 4;
        this.tabIndexes.effects = 5;
};

_global.TabbedPropertiesBox.prototype = new DialogBox();

//PUBLIC METHODS.

_global.TabbedPropertiesBox.prototype.setEnabled = function(inDialogEnabled) {
        super.setEnabled(inDialogEnabled);
        this.btnOK.setEnabled(inDialogEnabled);
        this.btnCancel.setEnabled(inDialogEnabled);
};

_global.TabbedPropertiesBox.prototype.setParent = function(parent) {
        this.parent = parent;
}        

_global.TabbedPropertiesBox.prototype.show = function() {
                
        this.isCanceled = false;
        
        this.btnOK.setClickHandler('processOKButton', this);
        this.btnCancel.setClickHandler('processCancelButton', this);
        
        Key.addListener(this);
               
        //is tab already visited or not
        this.visited = [true, false, false, false, false, false]; 
               
        //setup tab listener and tab view style if not yet
        if (this.tab_listener == undefined)
        { 
                this.tab_listener = new Object();
                this.tab_listener.onSelect = function(oldIndex, newIndex, tbv)
                {
				var parent = tbv._parent;
				//hide visible tabs
				var oldTab =  tbv.getItemAt(oldIndex);
				parent.tabs[parent.tabIndexes[oldTab.data]].hide();
				
				var newTab = tbv.getItemAt(newIndex);
				switch (newTab.data)
				{ 
					//Themes-tab
					case 'themes' :
						parent.ShowThemesTab(false);        
					break;
					//Sounds-tab
					case 'sounds' :
						parent.ShowSoundsTab(not parent.visited[1]);
						parent.visited[1] = true; 
					break;
					//Text-tab
					case 'text' :
						parent.ShowTextTab(not parent.visited[2]);
						parent.visited[2] = true; 
					break;
					//Admin-tab
					case 'admin' :
					break;
					//About-tab
					case 'about' :
						parent.ShowAboutTab(not parent.visited[4]);
						parent.visited[4] = true;
					break;
					case 'effects' :
						parent.ShowEffectsTab(not parent.visited[5]);
						parent.visited[5] = true;
					break;
				}
			}
                this.PropTabView.addListener( this.tab_listener );
        }
        
        //set first tab as active
        this.PropTabView.setSelectedIndex(0);
        this.tab_listener.onSelect(0, 0, this.PropTabView);
        
        this._visible = true;
};

_global.TabbedPropertiesBox.prototype.setSettings = function(inSettings)
{
	this.settings = inSettings;
}

_global.TabbedPropertiesBox.prototype.canceled = function() {
        return this.isCanceled;
};

_global.TabbedPropertiesBox.prototype.initialized = function() {
        return (super.initialized() && (this.btnOK.setEnabled != null));
};

_global.TabbedPropertiesBox.prototype.applyTextProperty = function(propName, val)
{
	this.textStyle[propName] = val;
	
	for(var tab = 0; tab < this.tabs.length; tab++)
		this.tabs[tab].applyTextProperty(propName, val);
}

_global.TabbedPropertiesBox.prototype.applyStyle = function(inStyle) {
	//trace("Apply Style in TabbedPropertiesBox");
	this.style = inStyle;
	super.applyStyle(inStyle);
	
	for(var tab = 0; tab < this.tabs.length; tab++)
		this.tabs[tab].applyStyle(inStyle);
	
	this.tab_view_sf.removeListener(this.PropTabView); 
	
	this.setPropTbvSkin();
	
	this.PropTabView.setStyleProperty("textColor", inStyle.buttonText, true);
	var font = this.textStyle['font'];
	var size = this.textStyle['size'];
	if( font == undefined || font == undefined)
	{ 
		font = this.settings.user.text.itemToChange.interfaceElements.fontFamily;
		size = this.settings.user.text.itemToChange.interfaceElements.fontSize;
	}
	
	this.PropTabView.setStyleProperty("textFont", font, true);
	this.PropTabView.setStyleProperty("textSize", size, true);
	
	this.tab_view_sf.addListener(this.PropTabView); 
};

_global.TabbedPropertiesBox.prototype.applyLanguage = function(inLanguage) {
	this.language = inLanguage;
        
	var font = this.settings.user.text.itemToChange.interfaceElements.fontFamily;
	var size = this.settings.user.text.itemToChange.interfaceElements.fontSize;
	for(var tab = 0; tab < this.tabs.length; tab++)
	{ 
		this.tabs[tab].applyLanguage(inLanguage);
		this.tabs[tab].applyTextProperty('size', size);
		this.tabs[tab].applyTextProperty('font', font);
	}
        
	this.btnOK.setLabel(this.language.dialog.common.okBtn);
	this.btnCancel.setLabel(this.language.dialog.common.cancelBtn);
        
	//label of each tab
	this.PropTabView.removeAll();
	var op = new Array();
	for(var tab in this.settings.layout.optionPanel) op.push(tab);
	for(var i = op.length-1; i >= 0; i--)
	{ 
		var tabLabel = this.language.dialog.tablabels[op[i]];
		if(this.settings.layout.optionPanel[op[i]] && op[i] != 'about')
		{ 
			this.PropTabView.addItem(tabLabel, op[i]);
		}
	}
	this.PropTabView.addItem(this.language.dialog.tablabels.about, 'about');
};

//PRIVATE METHODS.

_global.TabbedPropertiesBox.prototype.onKeyDown = function() {
        if (Key.isDown(Key.ENTER)) {
                this.processOKButton();
        }
        if (Key.isDown(Key.ESCAPE)) {
                this.processCancelButton();
        }
};        

_global.TabbedPropertiesBox.prototype.onClose = function() {
        this.processCancelButton();
};

_global.TabbedPropertiesBox.prototype.processOKButton = function() {
        this._visible = false;
        Key.removeListener(this);
        
        for(var tab = 0; tab < this.tabs.length; tab++)
            this.tabs[tab].processOKButton();
                
        this.handlerObj[this.handlerFunctionName](this);
};

_global.TabbedPropertiesBox.prototype.processCancelButton = function() {
        this._visible = false;
        Key.removeListener(this);
        
        for(var tab = 0; tab < this.tabs.length; tab++)
            this.tabs[tab].processCancelButton();
                
        this.isCanceled = true;
        this.handlerObj[this.handlerFunctionName](this);
};

_global.TabbedPropertiesBox.prototype.setPropTbvSkin = function() {
        this.tab_view_sf = new FStyleFormat();
           
        this.tab_view_sf.textBold = true;
        
        this.tab_view_sf.face = globalStyleFormat.face;
        this.tab_view_sf.activeFace = darker(globalStyleFormat.face);
        this.tab_view_sf.activeSeperator = globalStyleFormat.face;
        
        this.tab_view_sf.activeDarkshadow = globalStyleFormat.darkshadow;
        this.tab_view_sf.activeHighlight3D = globalStyleFormat.highlight3D;
        this.tab_view_sf.activeShadow = globalStyleFormat.shadow;
        
        this.tab_view_sf.removeListener(this.PropTabView);
        this.tab_view_sf.addListener(this.PropTabView);
        this.tab_view_sf.applyChanges();
}

_global.TabbedPropertiesBox.prototype.ShowThemesTab = function(init) {
	if(this.themesTab == undefined)
	{ 
	   this.themesTab = this.attachMovie('ThemesTab', 'themesTab', this.depth++, {_x : 10, _y : 65});
	   
   	   this.onEnterFrame = this.ShowThemesTabFrame;
	   
	   this.tabs[0] = this.themesTab;
	   return;
	} 
	
	this.themesTab.show(init);
}

_global.TabbedPropertiesBox.prototype.ShowThemesTabFrame = function() {
	delete(this.onEnterFrame);
	
	this.themesTab.setSettings(this.settings);
	this.themesTab.setSkinTarget(this.parent);
	
	this.themesTab.applyStyle(this.style);
	this.themesTab.applyLanguage(this.language);
	
	this.themesTab.applyTextProperty('font', this.textStyle['font']);
	this.themesTab.applyTextProperty('size', this.textStyle['size']);
	
	this.themesTab.show(true);
}

_global.TabbedPropertiesBox.prototype.ShowSoundsTab = function(init) {
	if(this.soundsTab == undefined)
	{ 
	   this.soundsTab = this.attachMovie('SoundsTab', 'soundsTab', this.depth++, {_x : 30, _y : 50});
	   
   	   this.onEnterFrame = this.ShowSoundsTabFrame;
	   
	   this.tabs[1] = this.soundsTab;
	   return;
	} 
	
	this.soundsTab.show(init);
}

_global.TabbedPropertiesBox.prototype.ShowSoundsTabFrame = function() {
     delete(this.onEnterFrame);
        
     this.soundsTab.setSoundTarget(this.parent);
     
     this.soundsTab.applyStyle(this.style);
     this.soundsTab.applyLanguage(this.language);
     
	this.soundsTab.applyTextProperty('font', this.textStyle['font']);
	this.soundsTab.applyTextProperty('size', this.textStyle['size']);
     
     this.soundsTab.show(true);
}

_global.TabbedPropertiesBox.prototype.ShowTextTab = function(init) {
	if(this.textTab == undefined)
	{ 
	   this.textTab = this.attachMovie('TextTab', 'textTab', this.depth++, {_x : 19, _y : 67});
	   
   	   this.onEnterFrame = this.ShowTextTabFrame;
	   
	   this.tabs[2] = this.textTab;
	   return;
	} 
	
	this.textTab.show(init);
}

_global.TabbedPropertiesBox.prototype.ShowTextTabFrame = function() {
     delete(this.onEnterFrame);
        
     this.textTab.setTextTarget(this.parent);
     
     this.textTab.applyStyle(this.style);
     this.textTab.applyLanguage(this.language);
     
	this.textTab.applyTextProperty('font', this.textStyle['font']);
	this.textTab.applyTextProperty('size', this.textStyle['size']);
     
     this.textTab.show(true);
}

_global.TabbedPropertiesBox.prototype.ShowEffectsTab = function(init) {
	if(this.effectsTab == undefined)
	{ 
	   this.effectsTab = this.attachMovie('EffectsTab', 'effectsTab', this.depth++, {_x : 35, _y : 50});
	   
   	   this.onEnterFrame = this.ShowEffectsTabFrame;
	   
	   this.tabs[5] = this.effectsTab;
	   return;
	} 
	
	this.effectsTab.show(init);
}

_global.TabbedPropertiesBox.prototype.ShowEffectsTabFrame = function() {
	delete(this.onEnterFrame);
        
	this.effectsTab.setSettings(this.settings);
	this.effectsTab.setEffectsTarget(this.parent);
     
	this.effectsTab.applyStyle(this.style);
	this.effectsTab.applyLanguage(this.language);
     
	this.effectsTab.applyTextProperty('font', this.textStyle['font']);
	this.effectsTab.applyTextProperty('size', this.textStyle['size']);
     
	this.effectsTab.show(true);
}

_global.TabbedPropertiesBox.prototype.ShowAboutTab = function(init) {
	if(this.aboutTab == undefined)
	{ 
		this.aboutTab = this.attachMovie('AboutTab', 'aboutTab', this.depth++, {_x : 64, _y : 58});
		
		this.aboutTab.setTarget(this.parent);
		this.aboutTab.applyStyle(this.style);
		
		this.aboutTab.applyTextProperty('font', this.textStyle['font']);
		
		this.aboutTab.show(true);
		
		this.tabs[3] = this.aboutTab;
		return;
	} 
	
	this.aboutTab.show(init);
}

_global.TabbedPropertiesBox.prototype.ShowAdminTab = function() {
	this.tabs[4] = this.adminTab;
}

Object.registerClass('TabbedPropertiesBox', _global.TabbedPropertiesBox);

#endinitclip
