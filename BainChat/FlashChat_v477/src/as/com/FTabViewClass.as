#initclip 1

FTabViewClass = function(){
	this.width = this._width;
	
	super();
	
	this._xscale = this._yscale = 100;
	
	this.setDataProvider(new DataProviderClass());
	
	//text
	this.setStyleProperty("textAlign","center", true);
	this.setStyleProperty("textColor",this.labelColor, true);
	this.setStyleProperty("textFont",this.labelFont, true);

	//default
	this.setStyleProperty("face",this.faceColor, true);
	this.setStyleProperty("face2",this.faceColor2, true);

	//active
	this.setStyleProperty("activeFace",this.activeFaceColor, true);
	this.setStyleProperty("activeFace2",this.activeFaceColor2, true);
	this.setStyleProperty("activeSeperator",this.activeFaceColor, true);
	this.setStyleProperty("seperator",this.activeFaceColor2, true);

	//disabled
	this.setStyleProperty("disabledFace",0xAAAAAA, true);
	
	this.setEnabled(this.enabled);
	
	var tabNamesLen = this.tabNames.length;
	
	for(var i=0; i<tabNamesLen; i++){
		this.addItem(this.tabNames[i], this.tabData[i]);		
	}

	this.setChangeHandler(this.changeHandler);
	
	if(this.selectedIndex < 0 || this.selectedIndex>this.getLength()-1){
		this.selectedIndex = 0;
	}
	
	this.setSelectedIndex(this.selectedIndex);
	
	this._listeners = [];

	this.invalidate("setSize");
}

FTabViewClass.prototype = new FUIComponentClass();

Object.registerClass("FTabViewSymbol",FTabViewClass);

AsBroadcaster.initialize(FTabViewClass.prototype); 

FTabViewClass.prototype.depth = 0;
FTabViewClass.prototype.itemSymbol = "ftv_tab";
FTabViewClass.prototype.labelField = "label";
FTabViewClass.prototype.selectedIndex = 0;

//styles
FTabViewClass.prototype.faceColor = 0xEEEEEE;
FTabViewClass.prototype.activeFaceColor = 0xFFFFFF;
FTabViewClass.prototype.labelColor = 0x000000;
FTabViewClass.prototype.labelFont = "_sans";

FTabViewClass.prototype.setSize = function(width){
	
	this.width = (width) ? width : this.width;
	var numTabs = this.getLength();
	
	this.tabWidth = this.width/numTabs;
	
	if(this.tabWidth<20){ 
		this.tabWidth = 20;
		this.width = numTabs*this.tabWidth;
	}
	
	var depth = (this.tabHolder_mc) ? this.tabHolder_mc.getDepth() : this.depth++;
	
	this.tabHolder_mc.removeMovieClip();
	this.createEmptyMovieClip("tabHolder_mc",depth);
	if(this.getSkinFrame() == 4)
	{ 
		this.tabHolder_mc.attachMovie("aqt_seperator","tabSeperator",1000);
		this.tabHolder_mc.tabSeperator._width = this.width;
	}
	else this.tabHolder_mc.tabSeperator.removeMovieClip();
		
	for(var i=0; i<numTabs; i++)
	{
		var tab = this.tabHolder_mc.attachMovie(this.itemSymbol,"tab"+i,i,{_x: i*this.tabWidth, controller: this, tabNum: i});
		tab.setSize(this.tabWidth);
		tab.setLabel(this.getItemAt(i)[this.labelField]);
		tab.setEnabled(this.enabled);
		if(this.getSkinFrame() == 4)
		{ 
			if(i == this.selectedIndex) tab._y = 0;
			else	tab._y = 2;
		}
	}
	
	if(this.getSkinFrame() == 4) this.tabHolder_mc.tabSeperator._y = tab._height;
}

/*
FTabViewClass.prototype.drawSkin = function(){
	
}
*/

FTabViewClass.prototype.addItem = function(label, data){
	
	var item = {};
	item[this.labelField] = (label.length<1) ? "Tab"+this.getLength() : label;
	
	item.data = data;
	
	this.dataProvider.addItem(item);

	this.invalidate("setSize");

}

FTabViewClass.prototype.setDataProvider=function(dp){
	if(dp instanceof Array){
		var len = dp.length;
		var tempDP = new DataProviderClass();
		for(var i = 0; i < len; i++){
			var item = dp[i];
			if(item.label){
				tempDP.addItem(item.label,item.data);
			}else{
				tempDP.addItem(item);
			}
		}
		dp = tempDP;
	}
	this.dataProvider = dp;
	dp.addView(this);
}

FTabViewClass.prototype.modelChanged = function(event){
	this.invalidate("setSize");
}

FTabViewClass.prototype.getLength = function(){
	return this.dataProvider.getLength();
}

FTabViewClass.prototype.setSelectedIndex = function(index){
	
	if(index < 0 || index>this.getLength()-1) return false;
	
	var fireEvent = (index!=this.selectedIndex);
	
	var oldIndex = this.selectedIndex;
	
	this.selectedIndex = index;
	
	var oldTab = this.tabHolder_mc["tab"+this.selectedIndex];
	
	this.selectedItem = this.getItemAt(this.selectedIndex);
	
	var newTab = this.tabHolder_mc["tab"+this.selectedIndex];
	
	this.setSize();
	
	if(fireEvent){
		this.executeCallBack();
		this.broadcastMessage("onSelect",oldIndex, index, this);
	}
	
}

FTabViewClass.prototype.getItemAt=function(index){
	return this.dataProvider.getItemAt(index);
}

FTabViewClass.prototype.getDataProvider = function(){
	return this.dataProvider;
}

FTabViewClass.prototype.sortItemsBy = function(){
	this.dataProvider.sortItemsBy.apply(this.dataProvider,arguments);
}

FTabViewClass.prototype.setEnabled = function(enabled){
	var fireEvent = (enabled!=this.enabled);

	this.enabled = enabled;
	
	if(fireEvent) this.broadcastMessage("onEnable",enabled, this);
	
	this.invalidate("setSize");
}

FTabViewClass.prototype.removeAll = function(){
	this.dataProvider.removeAll();
}

FTabViewClass.prototype.addItemAt=function(index, label, data){
	
	var item = {};
	item[this.labelField] = (label.length<1) ? "Tab"+this.getLength() : label;
	
	item.data = data;
	
	this.dataProvider.addItemAt(index, item);
}

FTabViewClass.prototype.getEnabled = function(){
	return this.enabled;
}

FTabViewClass.prototype.getItemSymbol = function(){
	return this.itemSymbol;
}

FTabViewClass.prototype.setItemSymbol = function(linkage){
	this.itemSymbol = linkage;
	this.invalidate("setSize");
}

FTabViewClass.prototype.setLabelField = function(labelField){
	this.labelField = labelField;
	this.invalidate("setSize");
}

FTabViewClass.prototype.getLabelField = function(){
	return this.labelField;
}

FTabViewClass.prototype.getSelectedIndex = function(){
	return this.selectedIndex;
}

FTabViewClass.prototype.getSelectedItem = function(){
	return this.selectedItem;
}

FTabViewClass.prototype.getValue = function(){
	return this.selectedItem;
}

FTabViewClass.prototype.removeItemAt = function(){
	this.dataProvider.removeItemAt.apply(this.dataProvider,arguments);
}

FTabViewClass.prototype.replaceItemAt = function(index, item){
	if(item.label==undefined) {
		var label = item;
		item = {};
		item.label = label;
	}
	
	this.dataProvider.replaceItemAt(index, item);
}

FTabViewClass.prototype.myOnKeyUp = function(){
	var code = Key.getCode();
	var index = this.getSelectedIndex();
	if(code==Key.LEFT){
		index--;
	}else if(code==Key.RIGHT){
		index++;
	}else{
		return;
	}
	
	if(index<0) index = this.getLength()-1;
	else if(index>=this.getLength()) index = 0;
	this.setSelectedIndex(index);
	
}

FTabViewClass.prototype.registerSkinElement = function(skinMCRef, propName, isGlobal){

	var tabNum = skinMCRef._parent._parent.tabNum;
	propName = (tabNum==this.selectedIndex) ? "active"+propName : propName;	
	propName = (this.enabled) ? propName : "disabled"+propName;

	return super.registerSkinElement(skinMCRef,propName,isGlobal);
}
FTabViewClass.prototype.setStyleProperty=function(propName, value, isGlobal)
{

	var aName = substring(propName,0,6);
	var dName = substring(propName, 0,8)
	var lName, cName, tempName;
	if(aName == "active")
	{
		lName = substring(propName, 7,propName.length);
		propName = aName+lName.toLowerCase();
	}
	if(dName == "disabled")
	{
		lName = (substring(propName,9,propName.length)).toLowerCase();
		cName = substring(lName, lName.length-1, lName.length);
		if(cName == "3d")
		{
			var t = substring(lName, 1, lName.length-1)+"D"
			propName = dName+t;
		}
		else
		{
			propName = dName+lName;
		}
	}
	
	super.setStyleProperty(propName,value, isGlobal);
}

#endinitclip