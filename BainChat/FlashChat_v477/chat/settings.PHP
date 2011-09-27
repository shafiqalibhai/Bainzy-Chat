<?php
	error_reporting(0);
	ob_start();

	require_once('inc/common.php');
	
	header("Pragma: public");
	header("Expires: 0");
	header("Content-type: text/xml");
	//header('Content-type: text/plain');

	ChatServer::loadCMSclass();
	$cmsclass = strtolower(get_class($GLOBALS['fc_config']['cms']));
	$hasProfile = ($cmsclass != 'statelesscms');

?>
<settings 
	debug="<?php echo $GLOBALS['fc_config']['debug']?>"
	version="<?php echo $GLOBALS['fc_config']['version']?>" 
	enableSocketServer="<?php echo $GLOBALS['fc_config']['enableSocketServer']?>"
	liveSupportMode="<?php echo $GLOBALS['fc_config']['liveSupportMode']?>"
	hideSelfPopup="<?php echo $GLOBALS['fc_config']['hideSelfPopup']?>"
	showConfirmation="<?php echo $GLOBALS['fc_config']['showConfirmation']?>"
	labelFormat="<?php echo htmlspecialchars($GLOBALS['fc_config']['labelFormat'])?>"
	maxMessageSize="<?php echo $GLOBALS['fc_config']['maxMessageSize']?>"
	maxMessageCount="<?php echo $GLOBALS['fc_config']['maxMessageCount']?>"
	userListAutoExpand="<?php echo $GLOBALS['fc_config']['userListAutoExpand']?>"
	helpUrl="<?php echo $GLOBALS['fc_config']['helpUrl']?>" 
	msgRequestInterval="<?php echo $GLOBALS['fc_config']['msgRequestInterval']?>" 
	msgRequestIntervalAway="<?php echo $GLOBALS['fc_config']['msgRequestIntervalAway']?>" 
	floodInterval="<?php echo $GLOBALS['fc_config']['floodInterval']?>" 
	inactivityInterval="<?php echo $GLOBALS['fc_config']['inactivityInterval']?>" 
	roomTitleFormat="<?php echo $GLOBALS['fc_config']['roomTitleFormat']?>"
	maxUsersPerRoom="<?php echo $GLOBALS['fc_config']['maxUsersPerRoom']?>"
	listOrder="<?php echo $GLOBALS['fc_config']['listOrder']?>"
	disabledIRC="<?php echo $GLOBALS['fc_config']['disabledIRC']?>"
	mods="<?php echo $GLOBALS['fc_config']['mods']?>"
	defaultRoom="<?php echo $GLOBALS['fc_config']['defaultRoom']?>" 
	defaultTheme="<?php echo $GLOBALS['fc_config']['defaultTheme']?>" 
	defaultSkin="<?php echo $GLOBALS['fc_config']['defaultSkin']?>"
	defaultLanguage="<?php echo $GLOBALS['fc_config']['defaultLanguage']?>"
	allowLanguage="<?php echo $GLOBALS['fc_config']['allowLanguage']?>"
	allowPhoto="<?php echo !method_exists($GLOBALS['fc_config']['cms'], 'getPhoto')?>"
	splashWindow="<?php echo $GLOBALS['fc_config']['splashWindow']?>">
	
	<?php 	
		foreach($GLOBALS['fc_config']['layouts'] as $k => $v) {
			if(!$hasProfile) $v['allowProfile'] = false;
	?>
		<layout role="<?php echo $k?>" <?php echo array2attrs($v)?>>
		<toolbar <?php echo array2attrs($v['toolbar'])?>/>
		<optionPanel <?php echo array2attrs($v['optionPanel'])?>/>
		<?php foreach($v['constraints'] as $ck => $cv) {?>
			<constraint id="<?php echo $ck?>" <?php echo array2attrs($cv)?>/>
		<?php } ?>
		</layout>
	<?php } ?>
	<?php if($GLOBALS['fc_config']['enableSocketServer']){ ?>
		<socketServer <?php echo array2attrs($GLOBALS['fc_config']['socketServer'])?>/>
	<?php } ?>	
	
	<smiles <?php echo array2attrs($GLOBALS['fc_config']['smiles'])?>/>
	
	<avatars>
		<mod_only list="<?php echo $GLOBALS['fc_config']['avatars']['mod_only']?>"/>
		
		<?php 
			foreach($GLOBALS['fc_config']['avatars'] as $k => $v)
			{ 
				if( $k != 'mod_only' )
				{
		?>
					<<?php echo $k; ?>>
					<male>
						<mainchat <?php echo array2attrs($v['male']['mainchat'])?>/>
						<room <?php echo array2attrs($v['male']['room'])?>/>
					</male>
					<female>
						<mainchat <?php echo array2attrs($v['female']['mainchat'])?>/>
						<room <?php echo array2attrs($v['female']['room'])?>/>
					</female>
					</<?php echo $k; ?>>
		<?php   }
		    } ?>
	</avatars>
	
	<sound <?php echo array2attrs($GLOBALS['fc_config']['sound'])?>/>
	<sound_options <?php echo array2attrs($GLOBALS['fc_config']['sound_options'])?>/>
	
	<text>
		<itemToChange myTextColor="<?php echo $GLOBALS['fc_config']['text']['itemToChange']['myTextColor']?>"> 
			<mainChat <?php echo array2attrs($GLOBALS['fc_config']['text']['itemToChange']['mainChat'])?>/>
			<interfaceElements <?php echo array2attrs($GLOBALS['fc_config']['text']['itemToChange']['interfaceElements'])?>/>
			<title <?php echo array2attrs($GLOBALS['fc_config']['text']['itemToChange']['title'])?>/>
		</itemToChange>
		<fontSize <?php echo array2attrs($GLOBALS['fc_config']['text']['fontSize'])?>/>
		<fontFamily <?php echo array2attrs($GLOBALS['fc_config']['text']['fontFamily'])?>/>
	</text>
	
	<special_language <?php echo array2attrs($GLOBALS['fc_config']['special_language'])?>/>
	
	<?php foreach($GLOBALS['fc_config']['skin'] as $k => $v) {?>
		<skin id="<?php echo $k?>" <?php echo array2attrs($v)?>/>
	<?php } ?>
	
	<?php foreach($GLOBALS['fc_config']['themes'] as $k => $v) {?>
		<theme id="<?php echo $k?>" <?php echo array2attrs($v)?>/>
	<?php } ?>
	<?php foreach($GLOBALS['fc_config']['languages'] as $k => $v) {
	 /*login="<?php echo $v['messages']['login']?>"*/
	?>
		<language id="<?php echo $k?>" name="<?php echo $v['name']?>">
			<messages 
				wrongPass="<?php echo $v['messages']['wrongPass']?>" 
				anotherlogin="<?php echo $v['messages']['anotherlogin']?>" 
				banned="<?php echo $v['messages']['banned']?>" 
				expiredlogin="<?php echo $v['messages']['expiredlogin']?>"
			>
			<login>
				<![CDATA[<?php echo $v['messages']['login']?>]]>
			</login>
			</messages>
			<dialog id="login" <?php echo array2attrs($v['dialog']['login'])?>/>
		</language>
	<?php }?>
	
	<login btn="<?php echo $GLOBALS['fc_config']['login']['btn'];  ?>"  title="<?php echo $GLOBALS['fc_config']['login']['title_bar'];  ?>" theme="<?php echo $GLOBALS['fc_config']['login']['theme'];  ?>" width="<?php echo $GLOBALS['fc_config']['login']['width'];  ?>" height="<?php echo $GLOBALS['fc_config']['login']['height'];  ?>">
	 <username <?php echo array2attrs($GLOBALS['fc_config']['login']['username'])?>/>
	 <password <?php echo array2attrs($GLOBALS['fc_config']['login']['password'])?>/>
	 <lang <?php echo array2attrs($GLOBALS['fc_config']['login']['lang'])?>/>
	 <title_label <?php echo array2attrs($GLOBALS['fc_config']['login']['title'])?>/>
	</login>
	
	<logout <?php echo array2attrs($GLOBALS['fc_config']['logout'])?>/>
	
	<module <?php echo array2attrs($GLOBALS['fc_config']['module'])?>/>
	
</settings>
<?php 
	ob_end_flush();
?>