<?php
	require_once('inc/common.php');

	$id = 'flashchat';
//    echo "<pre>";     print_r($_REQUEST);     print_r($_SESSION);     exit;
     
     
	$params = array();
    $_REQUEST['username']=$_SESSION['SESS_USER'];
    $_REQUEST['flash_login']="";
    $_REQUEST['password']=$_SESSION['SESS_PASSWORD'];
    $_REQUEST['lang']='en';
    
	if(isset($_REQUEST['username']) && !isset($_REQUEST['flash_login'])) {
		if($_REQUEST['username'] == '__random__') $_REQUEST['username'] = 'user_' . time();
		if(!isset($_REQUEST['lang'])) $_REQUEST['lang'] = $GLOBALS['fc_config']['defaultLanguage'];
		if(!isset($_REQUEST['password'])) $_REQUEST['password'] = '';
		if(!isset($_REQUEST['room'])) $_REQUEST['room'] = 0;

		$params = array_merge($params, array(
			'login' => $_REQUEST['username'],
			'password' => $_REQUEST['password'],
			'lang'  => $_REQUEST['lang'],
			'room'  => $_REQUEST['room']
		));
	}
?>
<html>
	<head>
		<title>FlashChat v<?php echo $GLOBALS['fc_config']['version']?></title>
		<script type="text/javascript">
			function showLogger() {
				win = window.open("logger.php", "logger", "width=500,height=400,left=0,top=0,location=no,menubar=no,resizable=yes,scrollbars=no,status=no,toolbar=no");
				win.focus();
			}
			<?php if($GLOBALS['fc_config']['debug']) {?>showLogger();<?php } ?>
		</script>

		<script language="JavaScript" type='text/javascript' src="javascript/ActivateFlash.js"></script>
	</head>

	<body marginwidth="0" marginheight="0" leftmargin="0" topmargin="0" rightmargin="0" bottommargin="0" scroll="no">
		<center><?php echo flashChatTag('100%', '100%', $params)?></center>
	</body>
</html>