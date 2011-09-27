<?php
	error_reporting(0);

	ob_start();

	$req = array_merge($_GET, $_POST);

	$GLOBALS['fc_config_stop'] = true;
	if($req['c'] == 'lin' || !isset($req['id']) || !$req['id'] || $req['c'] == 'tzset' || $req['c'] == 'srtbt')
		$GLOBALS['fc_config_stop'] = false;

	require_once('inc/common.php');

	if($req['c'] == 'glan' && strlen($req['l']) == 2)
	{
		$in_str = 'inc/langs/' . $req['l'] . '.php';
		//if(file_exists($in_str))
		require_once($in_str);
	}

	$GLOBALS['fc_config_stop'] = false;

	header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
	header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
	header("Cache-Control: no-store, no-cache, must-revalidate");
	header("Cache-Control: post-check=0, pre-check=0", false);
	header("Pragma: no-cache");

	header("Pragma: public");
	header("Expires: 0");
	header("Content-type: text/xml");
	//header('Content-type: text/plain');

	$conn =& ChatServer::getConnection($req);
	$mqi = $conn->process($req);

	ChatServer::purgeExpired();
?>
<response id="<?php echo $conn->id?>">
	<?php
		while($mqi->hasNext()) {
			$m = $mqi->next();
			echo($m->toXML($conn->tzoffset));
		}

		if($req['c'] == 'msg' && $GLOBALS['fc_config']['enableBots'])
		{
			$GLOBALS['fc_config']['bot']->processMessages();
		}
	?>
</response>
<?php
	ob_end_flush();
?>