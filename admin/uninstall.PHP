<?php
require_once('init.php');

function removeTables($tables)
{
	$link = mysql_connect($GLOBALS['fc_config']['db']['host'], $GLOBALS['fc_config']['db']['user'], $GLOBALS['fc_config']['db']['pass']);
	mysql_select_db($GLOBALS['fc_config']['db']['base'], $link);

	foreach($tables as $table)
	{
		$query = "DROP TABLE `$table`";	
	    $dropcode = mysql_query($query, $link);	
	}	
}

function removeDir( $dir_name )
{
	if(!file_exists($dir_name)) return;

	$d = dir( $dir_name );
	while (false !== ($entry = $d->read()))
	{
		$full_path = $d->path.'/'.$entry;
		$is_dir = is_dir($full_path) && $entry != '.' && $entry != '..' && $entry != 'admin' && $entry != 'smarty' && $entry != 'templates';
		if( $is_dir ) 
		{
			removeDir( $full_path );
			@rmdir( $full_path );
		}
		else if(is_file( $full_path )) 
		{
			@unlink($full_path);	
		}	
	}
	$d->close();
}

if(!inSession()) {
	include('login.php');
	exit;
}
else if(!inPermission('uninstall'))
{
	$tabName = 'Uninstall';
	include('nopermit.php');
	exit;
}

$_REQUEST['installed'] = 1;

if(isset($_GET['action']))// && isset($_GET['type']))
{
	if($_GET['action'] == '1')
	{
		removeTables(getTables());
		/*
		if($_GET['type'] == '0')
		{
			removeTables(getTables());
		}
		else if($_GET['type'] == '1')
		{
			removeTables($_REQUEST['tables']);
			removeDir("../");
		}
		*/
	}
}

$_REQUEST['tables'] = getTables();
if(sizeof($_REQUEST['tables']) == 0) 
{
	if(isset($_GET['action'])) $_REQUEST['installed'] = 2;
	else $_REQUEST['installed'] = 3;
}	

$smarty->assign('_REQUEST', $_REQUEST);
$smarty->display('uninstall.tpl');
?>