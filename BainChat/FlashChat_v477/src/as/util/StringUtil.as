
//contains useful string manipulation functions.

String.prototype.TRIM_CHARS = ' \t\r\n';

//removes all spaces, \r, \n and tab characters from both sides of the string.
String.prototype.trim = function() {
	return this.ltrim().rtrim();
};

//removes all spaces, \r, \n and tab characters from the left side of the string.
String.prototype.ltrim = function() {
	var idx = 0;
	while (idx < this.length) {
		if (this.TRIM_CHARS.indexOf(this.charAt(idx)) == -1) {
			return this.substring(idx);
		}
		idx ++;
	}
	return '';
};

//removes all spaces, \r, \n and tab characters from the right side of the string.
String.prototype.rtrim = function() {
	var idx = this.length - 1;
	while (idx >= 0) {
		if (this.TRIM_CHARS.indexOf(this.charAt(idx)) == -1) {
			return this.substring(0, idx + 1);
		}
		idx --;
	}
	return '';
};

String.prototype.strreplace = function(_old, _new, str)
{
	if(_new.indexOf(_old) >= 0) return str;
	
	var str1,str2;
	var pos = str.indexOf(_old);
	while (pos >= 0 ){
		str1 = str.substring(0, pos);
		str2 = str.substring(pos+_old.length);
		 str = str1 + _new + str2;
		 pos = str.indexOf(_old);
	};
	
	return str;
}

//converter
_root.converterSpecChars = function(txt_in)
{
   var name = "_CoNvErTeR_TeXt_";
   if(this[name] == undefined) 
   {
		this.createTextField(name, 10159, 10, 10, 0, 0);
		this[name]._visible = false;
		this[name].html = true;
   }
   
   this[name].htmlText = txt_in;
   return (this[name].text);
} 
