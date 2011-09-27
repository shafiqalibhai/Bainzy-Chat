{assign var=title value=Un-install}
{include file=top.tpl}

<center>
	{if $_REQUEST.installed == 2}
		FlashChat is un-installed succesfully.
	{elseif $_REQUEST.installed == 3}
		<font color="red">FlashChat is not installed.</font>
	{else}
	<h4>Un-install</h4>
	<form name="uninstall" action="uninstall.php" method="post">
	<table border="0" cellspacing="8">
		<tr>
			<td colspan="3" valign="TOP">
				Remove all FlashChat tables from MySQL. This option will allow you to re-run the installer.<br>
				You may need to re-upload the "install_files" folder and the install.php file before re-install.<br>
				The following tables will be permanently removed:<br>
			</td>
		</tr>
		<tr>
			<td width="80">&nbsp;</td>
			<td>
			<font color="Red"><b>
				{foreach from=$_REQUEST.tables key=key item=ordersel}
					{$ordersel}<br>
				{/foreach}
			</b></font>
			</td>
		</tr>
		<tr>
			<td colspan="2">				
				<input type="checkbox" id="CB_AGREE" name="CB_AGREE" onclick="javascript:my_getbyid('continue').disabled=!my_getbyid('CB_AGREE').checked" id="agree_id">
				I understand that these actions are not reversible.
			</td>	
		</tr>
		<tr>
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td colspan="2" align="center">
				<input type="button" id="continue" name="continue" onclick="javascript: decision('Are you sure?!? This action is NOT reversible!', 'uninstall.php?action=1')" value="Continue" disabled>
				<input type="submit" name="cancel" value="Cancel">
			</td>
		</tr>
	</table>
	</form>
	{/if}
</center>
{include file=bottom.tpl}