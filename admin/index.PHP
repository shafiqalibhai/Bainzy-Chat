<?php

require_once('init.php');

if(!inSession()) {
	include('login.php');
	exit;
}

$stmt = new Statement("SELECT count(*) as msgnumb FROM {$GLOBALS['fc_config']['db']['pref']}messages WHERE command='msg' AND (userid IS NOT NULL OR roomid IS NOT NULL)");
$rs = $stmt->process();
$rec = $rs->next();
$msgnumb = $rec['msgnumb'];

if($manageUsers) {
	$stmt = new Statement("SELECT count(*) as usrnumb FROM {$GLOBALS['fc_config']['db']['pref']}users");
	$rs = $stmt->process();
	$rec = $rs->next();
	$usrnumb = $rec['usrnumb'];
} else {
	$usrnumb = 0;
}

//Assign Smarty variables and load the admin template
$smarty->assign('manageUsers',$manageUsers);
$smarty->assign('usrnumb',$usrnumb);
$smarty->assign('msgnumb',$msgnumb);
$smarty->display('admin_index.tpl');

?>
