<?php

require_once('init.php');

//@error_reporting(0);
$error = '';

function doLogin($userid) {
	global $smarty;
	$_SESSION['userid'] = $userid;
	include('index.php');
	exit;
}

$userid = ChatServer::isLoggedIn();
if($userid != null && ChatServer::userInRole($userid, ROLE_ADMIN)) 
{
	doLogin($userid);
} 
else 
{
	unset($_SESSION['userid']);
}	

if(isset($_REQUEST['do'])) {
	if(
		($userid = ChatServer::login($_REQUEST['login'], $_REQUEST['password'])) 
		&& (ChatServer::userInRole($userid, ROLE_ADMIN) || ChatServer::userInRole($userid, ROLE_MODERATOR))
	  ) 
	{
		doLogin($userid);
	} 
	else 
	{
		unset($_SESSION['userid']);
		$error = 'Could not grant admin role for this login and password. '.mysql_error();
	}
} else {
	unset($_SESSION['userid']);
	$_REQUEST['login'] = '';
	$_REQUEST['password'] = '';
}

$installed = isInstalled();
if( !$installed ) 
{
	unset($_SESSION['userid']);
	$error = 'FlashChat is not installed.';
}
 
//Assign Smarty variables and load the admin template
$smarty->assign('error',$error);
$smarty->assign('installed',$installed);
$smarty->display('login.tpl');
?>