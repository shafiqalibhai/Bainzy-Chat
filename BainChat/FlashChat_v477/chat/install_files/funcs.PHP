<?php

function Message( $message, $good )
{
	if ( $good )
		$yesno = '<b><font color="green" size="2px">Yes</font></b>';
	else
		$yesno = '<b><font color="red" size="2px">No</font></b>';

	echo '<tr><td class="normal">'. $message .'</td><td>'. $yesno .'</td></tr>';
}

/**
 ** Check writeability of needed files and directories - used for step 1.
 **/

function isWriteable ( $canContinue, $file, $mode, $desc ) 
{
	@chmod( $file, $mode );
	$good = is_writable( $file ) ? 1 : 0;
	Message ( $desc.' is writable: ', $good );
	return ( $canContinue && $good );
}


function changeConfigVariables( $contents, $replaces )
{
	foreach( $replaces as $k=>$v)
	{
		$patterns[]     = '/\s*\''. $k .'\'\s*=>\s*\'{0,1}\w*\'{0,1}\s*,/i';
		$replacements[] = "\n\t\t'$k' => $v,";		
	}
	//return $contents;
	return preg_replace($patterns, $replacements, $contents);
}


function getConfigData( $fname='' )
{
	if($fname == '')$fname = CONFIG_FILE;
	
	$handle = fopen($fname, "r");
	$contents = fread($handle, filesize($fname));
	fclose($handle);
	
	return $contents;
}

function writeConfig( $configData, $fname='' )
{	
	if( $fname == '' )$fname = CONFIG_FILE;
	
	$fp = @fopen( $fname, 'wb' );

	if ( $fp ) {
		fwrite( $fp, $configData );
		fclose( $fp );
		return true;
	}
	else
		return false;
}

//-------------------------------------------------
//connect to database return Error str
//-------------------------------------------------
function connectToDB($dbname='', $dbuser='', $dbpass='', $dbhost='', &$dbpref)
{
	if( $dbname == '' )
	{
		require_once './inc/config.srv.php';
		$dbhost = $GLOBALS['fc_config']['db']['host'];
		$dbuser = $GLOBALS['fc_config']['db']['user'];
		$dbpass = $GLOBALS['fc_config']['db']['pass'];
		$dbname = $GLOBALS['fc_config']['db']['base'];
		$dbpref = $GLOBALS['fc_config']['db']['pref'];
	}	
	
	if($conn = @mysql_connect($dbhost, $dbuser, $dbpass)) 
	{
		if(! mysql_select_db($dbname, $conn))
		{
			return "<b>Could not select '$dbname' database - please make sure this database exists</b><br>" . mysql_error();			
		}
	}
	else
	{
		return '<b>Could not connect to MySQL database - please check database settings</b><br>' . mysql_error();
	}
	
	return '';
	 
}

//return string error or result array if all ok
function db_get_array($sql, $primary_fld='')
{
	$errstr = '';
	$result = @mysql_query($sql) OR ($errstr = mysql_error()) ;
	
	if($errstr != '') return $errstr;
	
	$return = array();
	
	while($ret = mysql_fetch_array($result,MYSQL_ASSOC))
	{
		
		if( $primary_fld != '' )		
		{
			$return[$ret[$primary_fld]] = $ret;
		}else
		{
			$return[] = $ret;
		}

	}
	
	return $return;
}

//-------------------------------------------------
//generate html combo
//-------------------------------------------------
function htmlSelect($name, $arr, $selected, $addprop='')
{
	$ret = "<SELECT name=\"$name\" $addprop>";

	foreach($arr as $k=>$v)
	{
		if($selected == $k)$sel = 'SELECTED';
		else $sel = '';
		
		$ret .= "<option value=\"$k\" $sel>$v";
	}						
							
	$ret .=	"</SELECT>";
	
	return $ret;	
}
//-------------------------------------------------
//redirect_inst
//-------------------------------------------------
function redirect_inst($url)
{
	echo '<script language="JavaScript" type="text/javascript">
				<!--// redirect_inst
		  			window.location.href = "'.$url.'";
				//-->
			 </script>
			';
	
	die;	
}

?>