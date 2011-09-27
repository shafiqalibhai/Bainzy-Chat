function CText() {
	this.itemToChange = new Object();
	this.fontSize = new Object();
	this.fontFamily = new Object();
	
	this.itemToChange.myTextColor = false;
	
	this.itemToChange.mainChat = new Object();
	this.itemToChange.mainChat.presence = true;
	this.itemToChange.mainChat.fontSize = 13;
	this.itemToChange.mainChat.fontFamily = "Arial";
	
	this.itemToChange.interfaceElements = new Object();
	this.itemToChange.interfaceElements.presence = true;
	this.itemToChange.interfaceElements.fontSize = 13;
	this.itemToChange.interfaceElements.fontFamily = "Arial";
	
	this.itemToChange.title = new Object();
	this.itemToChange.title.presence = true;
	this.itemToChange.title.fontSize = 13;
	this.itemToChange.title.fontFamily = "Arial";
	
	this.fontSize = [20,18,16,14,13,12,11,10,9,8];
	this.fontFamily = ["Georgia","Verdana","Courier","Times","Arial"];
};

CText.prototype = new Initable();

CText.prototype.init = function(xml) {
	this.copyAllAttrs(xml, this);
	
	for (var i = 0; i<xml.childNodes.length; i++) {
		var node = xml.childNodes[i];
		if(node.nodeType == 1) {
			switch(node.nodeName) {
				case 'itemToChange': 
					for(var j = 0; j < node.childNodes.length; j++)
					{
						this.copyAllAttrs(node.childNodes[j], this.itemToChange[node.childNodes[j].nodeName]);
					}
				break;
				case 'fontSize'    : this.fontSize = node.attributes; break;
				case 'fontFamily'  : this.fontFamily = node.attributes; break;
			}
		}
	}
};
