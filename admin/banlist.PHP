<?php

require_once('init.php');

if(!inSession()) {
	include('login.php');
	exit;
}
else if(!inPermission('bans'))
{
	$tabName = 'Bans';
	include('nopermit.php');
	exit;
}

$req = array_merge($_GET, $_POST);

if(isset($_REQUEST['unbanid'])) {
	$stmt = new Statement("DELETE FROM {$GLOBALS['fc_config']['db']['pref']}bans WHERE banneduserid=?");
	$stmt->process($_REQUEST['unbanid']);
	$notice = 'ban removed';}
if(!isset($_REQUEST['sort']) || isset($_REQUEST['clear'])) $_REQUEST['sort'] = 'none';	

$stmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}bans ORDER BY userid");
$rs = $stmt->process();

$bannedlist = array();

while($rec = $rs->next()) {
	$temp_ban = array();

	$user  = ChatServer::getUser($rec['userid']);
	$buser = ChatServer::getUser($rec['banneduserid']);

	$temp_ban['user']  	= $user['login'];
	$temp_ban['buser'] 	= $buser['login'];
	$temp_ban['userid']	= $rec['userid'];
	$temp_ban['banneduserid'] = $rec['banneduserid'];
	$temp_ban['roomid'] 	= $rec['roomid'];

	$temp_ban['banlevel'] = "chat";
	if ($rec['roomid']) {$temp_ban['banlevel'] = "room";}
	if ($rec['ip']) {$temp_ban['banlevel'] = "ip";}

	$temp_ban['created'] 	= $rec['created'];
	$temp_ban['roomid'] 	= $rec['roomid'];
	$temp_ban['ip'] 	= $rec['ip'];

	array_push($bannedlist, $temp_ban);
}

if ($_REQUEST['sort'] != 'none') {
	sort_table($_REQUEST['sort'], $bannedlist);
}

//Assign Smarty variables and load the admin template
$smarty->assign('error',$error);
$smarty->assign('notice',$notice);
$smarty->assign('bannedlist',$bannedlist);
$smarty->display('banlist.tpl');

?>
