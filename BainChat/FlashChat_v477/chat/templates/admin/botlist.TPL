{assign var=title value=Bots}
{include file=top.tpl}

<center>
	<h4>Bots</h4>
{if $enableBots}	
	<form name="botlist" id="botlist" action="botlist.php" method="post">
		<input type="hidden" id="sort" name="sort" value="none">
	</form>		
	<a href="bot.php?id=0">Add new bot</a><br>
	<br>
{if $botnames}
	<table border="1" cellpadding="2">
		<tr>
			<th><a href="javascript:my_getbyid('sort').value = 'login'; my_getbyid('botlist').submit()">Bot Name</a></th>
			<th>Delete</th>
		</tr>
	{foreach from=$botnames item=bot}
		<tr>
			<td><a href="bot.php?id={$bot.id}">{$bot.login}</a></td>
			<td align="center">
				<input type="Button" class="submit" onclick="javascript:decision('Do you really want delete the bot?','botlist.php?id={$bot.id}')" value="  del  ">
			</td>			
		</tr>
	{/foreach}
	</table>
{else}
	No bots found
{/if}
{else}
<p align="left">
The bot feature is currently disabled. To enable bot support, set 'enableBots' to true in your /inc/config.php file.
You may need to re-run the FlashChat installer to add the necessary knowledge bases, too.
</p>
{/if}
</center>
{include file=bottom.tpl}