<html>
<head>
<title>FlashChat <?php echo $GLOBALS['fc_config']['version'];?> Installer</title>
<META http-equiv=Content-Type content="text/html; charset=UTF-8">
<link href="./install_files/styles.css" rel="stylesheet" type="text/css" media="screen"> 
<script language="javascript" src="install_files/scripts.js"></script>

</head>
<body>
<table align="center" cellpadding=2 cellspacing=7 class=normal width=70% border="0" >
<tr>
<td colspan="2" nowrap class='title' valign="middle"><?php if( !isset($notShowHdr) ) echo 'FlashChat ' . $GLOBALS['fc_config']['version'] . ' Installer'; ?> 
</td>
</tr>
<div align="center" class="normal"><?php include INST_DIR . 'trans_box.php'; //Looking for the Translation File ?></div>
