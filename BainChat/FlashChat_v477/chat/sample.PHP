<?php
	require_once('inc/smartyinit.php');
	
	$data = array();
	$lin = false;
	
	if(isset($_REQUEST['username'])) {
		if(!isset($_REQUEST['lang'])) $_REQUEST['lang'] = $GLOBALS['fc_config']['defaultLanguage'];
		if(!isset($_REQUEST['password'])) $_REQUEST['password'] = '';

		$params = array(
			'login' => $_REQUEST['username'],
			'password' => $_REQUEST['password'],
			'lang'  => $_REQUEST['lang']
		);

		$lin = true;
		
		//third parameter = width in pixels
		//fourth parameter = height in pixels
		$data['flashChatTag'] = flashChatTag('600', '500', $params);
	}
	else
	{
		$data['languages'] = $GLOBALS['fc_config']['languages'];
		$data['defaultLanguage'] = $GLOBALS['fc_config']['defaultLanguage'];
	}	
	
	$data['lin'] = $lin;
	$smarty->assign('data', $data);
	$smarty->display('sample.tpl');
?>
