function fieldsAreValid(exsc) 
{
	var theForm = document.installInfo;

	var formElements = theForm.elements;
	var numElements = theForm.elements.length;
	
	// determine if valid by comparing size
	// if size = 6 & is not number, then not valid input
	// if size = 10 & is not color code, then not valid input
		
	for ( var i = 0; i < numElements; i++ ) {
		var elemName  = theForm.elements[i].name;
		var elemValue = theForm.elements[i].value;
		var elemSize  = theForm.elements[i].size;
		var elemType  = theForm.elements[i].type;
		
		if( exsc )
		if( exsc.indexOf(elemName) >= 0 )continue;

		// all fields are required
		if ( elemType == 'text' || elemType == 'password') {
		
			if ( elemValue == "" ) {
				alert( 'One or more required fields was left empty.');
				theForm.elements[i].focus();
				return false;
			}
		}
	}
	return true;
}


function addUserID(cmb, fld)
{
	var uid = cmb.options[cmb.selectedIndex].value;
	var val = fld.value;
	var find_str = 'user={';
	
	var ind1 = val.toLowerCase().indexOf(find_str);
	if(ind1 == -1) return;
	var str1 = val.substring(0, ind1 + find_str.length);
	var str2 = val.substring(val.indexOf('}',ind1), val.length);
	
	fld.value = str1 + uid + str2;
	
}