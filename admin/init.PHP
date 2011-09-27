<?php
error_reporting(0);

require_once('../inc/smartyinit.php');
$smarty->template_dir  = INC_DIR . '../templates/admin';

/*
if(!ini_get('session.use_trans_sid')) 
	print ' ';
 
if(headers_sent())
	print 'Headers sent, remove any UTF-8 garbage characters: i»?';

if(!inSession()) 
	print 'Not in Session<br>';
*/ 

if(substr_count($GLOBALS['fc_config']['botsdata_path'], '.') < 3) 
	$GLOBALS['fc_config']['botsdata_path'] = '.' . $GLOBALS['fc_config']['botsdata_path'];

//------------------------------------------------------------------------------------------------------------------------------//
function sort_table($by, &$a)
{
	$n = count($a);
	for ($i=0; $i < $n-1 ; $i++) {
		 for ($j=0; $j<$n-1-$i; $j++)
			 if (strnatcmp($a[$j+1][$by],$a[$j][$by]) < 0 ) {
				$tmp = $a[$j];
				$a[$j] = $a[$j+1];
				$a[$j+1] = $tmp;
		}
	}
}

function getTables()
{
	$standart_tables = array(
		$GLOBALS['fc_config']['db']['pref'].'bans',
		$GLOBALS['fc_config']['db']['pref'].'bot',
		$GLOBALS['fc_config']['db']['pref'].'bots',
		$GLOBALS['fc_config']['db']['pref'].'connections',
		$GLOBALS['fc_config']['db']['pref'].'conversationlog',
		$GLOBALS['fc_config']['db']['pref'].'dstore',
		$GLOBALS['fc_config']['db']['pref'].'gmcache',
		$GLOBALS['fc_config']['db']['pref'].'gossip',
		$GLOBALS['fc_config']['db']['pref'].'ignors',
		$GLOBALS['fc_config']['db']['pref'].'messages',
		$GLOBALS['fc_config']['db']['pref'].'patterns',
		$GLOBALS['fc_config']['db']['pref'].'rooms',
		$GLOBALS['fc_config']['db']['pref'].'templates',
		$GLOBALS['fc_config']['db']['pref'].'thatindex',
		$GLOBALS['fc_config']['db']['pref'].'thatstack',
		//WARNING $GLOBALS['fc_config']['db']['pref'].'users' !!! DON'T remove users table
	);
	
	$link = mysql_connect($GLOBALS['fc_config']['db']['host'], $GLOBALS['fc_config']['db']['user'], $GLOBALS['fc_config']['db']['pass']);
	mysql_select_db($GLOBALS['fc_config']['db']['base'], $link);

	$query = "SHOW TABLES FROM `{$GLOBALS['fc_config']['db']['base']}` LIKE '{$GLOBALS['fc_config']['db']['pref']}%'";	
    $showcode = mysql_query($query, $link);
   	
	$tables = array();
	if ($showcode && mysql_numrows($showcode) !== false)
	{
    	while ($rec = mysql_fetch_array($showcode, MYSQL_NUM)) $tables[] = $rec[0];    
    }
	
	$tables = array_intersect($tables, $standart_tables); 

	return $tables;
}

function isInstalled()
{
	$stmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}connections LIMIT 1");
	$res  = $stmt->process();
	if($res == null)
	{
		return false;
	} 
	
	return true;
	//return (sizeof(getTables()) > 0);
}

function inSession()
{
	$role = (ChatServer::userInRole($_SESSION['userid'], ROLE_ADMIN) || ChatServer::userInRole($_SESSION['userid'], ROLE_MODERATOR));
	return (isset($_SESSION['userid']) && $role && isInstalled());
}

function inPermission( $tabName )
{
	if(ChatServer::userInRole($_SESSION['userid'], ROLE_MODERATOR))
	{
		return (strpos(strtolower($GLOBALS['fc_config']['modsAdminRestrictions']), $tabName) === false);
	}	
	
	return true;	
}
//------------------------------------------------------------------------------------------------------------------------------//	
	 
error_reporting(E_ALL ^ E_NOTICE);

?>
