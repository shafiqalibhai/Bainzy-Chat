function Initable() {
};

Initable.prototype.copyAttrs = function(fromXML, toObj) {
	for(var i in toObj) {
		if(fromXML.attributes[i] != undefined) {
			switch(typeof toObj[i]) {
				case 'number' : toObj[i] = Number(fromXML.attributes[i]); break;
				case 'boolean': toObj[i] = (fromXML.attributes[i]) ? true : false; break;
				case 'string' : toObj[i] = fromXML.attributes[i]; break;
			}
			//trace(i + '=' + toObj[i]);
		}
	}
};

Initable.prototype.copyAllAttrs = function(fromXML, toObj) {
	for(var i in fromXML.attributes) 
	{		
		switch(typeof toObj[i]) 
		{
			case 'number' : toObj[i] = Number(fromXML.attributes[i]); break;
			case 'boolean': toObj[i] = (fromXML.attributes[i]) && fromXML.attributes[i] != '' ? true : false; break;
			//default copy as string
			default : toObj[i] = fromXML.attributes[i]; break;
		}
		//trace(i + '=' + toObj[i]);		
	}
};
