<?php

require_once('init.php');

if(!inSession()) {
	include('login.php');
	exit;
}
else if(!inPermission('users'))
{
	$tabName = 'Users';
	include('nopermit.php');
	exit;
}

if(!isset($_REQUEST['sort']) || isset($_REQUEST['clear'])) $_REQUEST['sort'] = 'none';

ChatServer::loadCMSclass();

$cms = $GLOBALS['fc_config']['cms'];
$cmsclass = strtolower(get_class($cms));
$manageUsers = ($cmsclass == 'defaultcms') || ($cmsclass == 'statelesscms'  && (!isset($cms->constArr)));

if(!$manageUsers)
{
	//Assign Smarty variables and load the admin template
	$smarty->assign('manageUsers',!$manageUsers);
	$smarty->display('usrlist.tpl');

	exit;
}

$stmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}users");
$rs = $stmt->process();

function roles2str($roles) {
	switch($roles) {
		case ROLE_ADMIN: return 'admin';
		case ROLE_MODERATOR: return 'moderator';
		case ROLE_USER: return 'user';
		case ROLE_CUSTOMER: return 'customer';
		case ROLE_SPY: return 'spy';
	}
}

$users = array();
if($rs != null)
{
	while($rec = $rs->next()) {
		$temp_user 		= array();
		$temp_user['id']	= $rec['id'];
		$temp_user['login']	= $rec['login'];
		$temp_user['password']	= $rec['password'];
		$temp_user['roles']	= roles2str($rec['roles']);

		array_push($users, $temp_user);
	}
}

if ($_REQUEST['sort'] != 'none') {
	sort_table($_REQUEST['sort'], $users);
}

if ($GLOBALS['fc_config']['encryptPass'] <> 0)
	$smarty->assign('encryptPass', true);

//Assign Smarty variables and load the admin template
$smarty->assign('users',$users);
$smarty->display('usrlist.tpl');

?>
