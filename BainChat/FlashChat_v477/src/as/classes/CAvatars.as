function CAvatars() {
	this.mod_only = new Object();
	this.user = new Object();
	
	this.admin = new Object();
	this.moderator = new Object();	
	
	this.createNode(this.user);
	this.createNode(this.admin);
	this.createNode(this.moderator);
};

CAvatars.prototype = new Initable();

CAvatars.prototype.createNode = function(inObj)
{
	inObj.male = new Object();
	inObj.female = new Object();
	
	inObj.male.mainchat = new Object();
	this.createLastNode(inObj.male.mainchat);
	inObj.male.room = new Object();
	this.createLastNode(inObj.male.room);
	
	inObj.female.mainchat = new Object();
	this.createLastNode(inObj.female.mainchat);
	inObj.female.room = new Object();
	this.createLastNode(inObj.female.room);
}

CAvatars.prototype.createLastNode = function(inObj)
{
	inObj.default_value  = 'smi_smile';
	inObj.default_state  = false;
	inObj.allow_override = true;
}

CAvatars.prototype.copyNode = function(inName, inNode)
{
	for (var i = 0; i < inNode.childNodes.length; i++) 
	{
		var node = inNode.childNodes[i];
		if(node.nodeType == 1) 
		{
			for(var j = 0; j < node.childNodes.length; j++) 
			{ 
				var node2 = node.childNodes[j];
				if(node2.nodeType == 1) 
				{
					this.copyAllAttrs(node2, this[inName][node.nodeName][node2.nodeName]);					
				}
			}
		}
	}
	
	
}

CAvatars.prototype.init = function(xml)
{
	this.copyAllAttrs(xml, this);
	
	for (var i = 0; i<xml.childNodes.length; i++)
	{
		var node = xml.childNodes[i];
		if(node.nodeType == 1) 
		{
			if(node.nodeName == "mod_only") 
				this.copyAllAttrs(node, this.mod_only);
			else if(node.nodeName == "user" || node.nodeName == "admin" || node.nodeName == "moderator")
			{
				this.copyNode(node.nodeName, node);
			}
					
		}
	}
	
};
