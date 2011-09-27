<?php	
	error_reporting( E_ALL ^ E_NOTICE ); 
	
	require_once('inc/smartyinit.php');
	
	//check for install--------------------------------------------------------------------------
	$stmt = new Statement("SELECT * FROM {$GLOBALS['fc_config']['db']['pref']}connections LIMIT 1");
	$res  = $stmt->process();
	if($res == null)
	{
		Header("Location: install.php");  
		die;
	} 
	//-------------------------------------------------------------------------------------------
	$data = array();
	
	$data['version'] = $GLOBALS['fc_config']['version'];
	$data['file_exists'] = file_exists('install.php') || file_exists('install_files');
	
	ChatServer::loadCMSclass();
	$cms = $GLOBALS['fc_config']['cms'];
	$cmsclass = strtolower(get_class($cms));
	$data['is_cms'] = ($cmsclass == 'defaultcms') && (! isset($cms->constArr) );
	
	$data['languages'] = $GLOBALS['fc_config']['languages'];
	$data['defaultLanguage'] = $GLOBALS['fc_config']['defaultLanguage'];
	
	$data['is_statelesscms'] = ($cmsclass == 'statelesscms');
	$data['adminPassword']   = $GLOBALS['fc_config']['adminPassword'];
	$data['moderatorPassword'] = $GLOBALS['fc_config']['moderatorPassword'];
	$data['spyPassword']     = $GLOBALS['fc_config']['spyPassword'];
	
	$smarty->assign('data', $data);
	$smarty->display('index.tpl'); 
?>
