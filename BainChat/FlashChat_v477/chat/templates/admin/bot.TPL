{assign var="title" value="Bot"}
{include file="top.tpl"}
<center>
<h4>bot</h4>
{if $enableBots}
	<form name="bot" action="bot.php" method="post">
		<input type="hidden" name="id" value="{$_REQUEST.id}">
		<table border="0" cellspacing="8">
		<tr><td align="right">bot name</td><td><input type="text" name="login" value="{$_REQUEST.login}"></td></tr>
		<tr>
			<td align="right">bot room list avatar</td>
			<td >
				<select name="room_avatar">
					{assign var="selected" value="`$_REQUEST.bot.room_avatar`"}
					<option id="0" {if $selected==""}selected{/if}>--none--</option>
					{foreach from=$_REQUEST.smilies key=key item=ordersel}
					<option id="{$key}" {if $ordersel==$selected}selected{/if}>{$ordersel}</option>
					{/foreach}
				</select>				
			</td>
		</tr>
		<tr>
			<td align="right">bot main chat avatar</td>
			<td >
				<select name="chat_avatar">
					{assign var="selected" value="`$_REQUEST.bot.chat_avatar`"}
					<option id="0" {if $selected==""}selected{/if}>--none--</option>
					{foreach from=$_REQUEST.smilies key=key item=ordersel}
					<option id="{$key}" {if $ordersel==$selected}selected{/if}>{$ordersel}</option>
					{/foreach}
				</select>				
			</td>
		</tr>
		<tr>
			<td align="right">login into room</td>
			<td >
				<select name="roomid">
					{assign var="selected" value="`$_REQUEST.bot.roomid`"}
					{foreach from=$_REQUEST.rooms key=key item=ordersel}
					<option id="{$key}" {if $key==$selected}selected{/if}>{$ordersel}</option>
					{/foreach}
				</select>				
			</td>
		</tr>
		<tr>
			<td align="right">active when &lt;X users are present</td>
			<td >
				<input type="text" name="active_on_min_users" size="3" maxlength="2" value="{$_REQUEST.bot.active_on_min_users}">
			</td>			
		</tr>
		<tr>
			<td align="right">active when &gt;X users are present</td>
			<td >
				<input type="text" name="active_on_max_users" size="3" maxlength="2" value="{$_REQUEST.bot.active_on_max_users}">
			</td>			
		</tr>
		<!--
		<tr>
			<td align="right">
				<input type="checkbox" name="active_on_supportmode" id="active_on_supportmode" 
				{if $_REQUEST.bot.active_on_supportmode == 1} checked {/if}>
			</td>
			<td>active when using FlashChat in "support" mode</td>
		</tr>
		-->
		<tr>
			<td align="right">active when an admin is not present</td>
			<td >
				<input type="checkbox" name="active_on_no_moderators" id="active_on_no_moderators" 
				{if $_REQUEST.bot.active_on_no_moderators == 1} checked {/if}>
			</td>			
		</tr>
		<tr>
			<td align="right">active when there are no other bots in the room</td>
			<td >
				<input type="checkbox" name="active_on_no_bots" id="active_on_no_bots" 
				{if $_REQUEST.bot.active_on_no_bots == 1} checked {/if}>
			</td>
			
		</tr>
		<tr>
			<td align="right">active when a particular user is present</td>
			<td >
				<select name="active_on_user">
					{assign var="selected" value="`$_REQUEST.bot.active_on_user`"}
					<option id="0" {if $selected=="0"}selected{/if}>--none--</option>
					{foreach from=$_REQUEST.users key=key item=ordersel}
					<option id="{$ordersel.id}" {if $ordersel.id==$selected}selected{/if}>{$ordersel.login}</option>
					{/foreach}
				</select>				
			</td>
		</tr>
		<tr>
			<td align="center" colspan="2"><input type="submit" name="submit" value="Submit"></td>
		</tr>
		</table>
	</form>
{else}
Bots is disabled on your system.
<!--
The bot could not be added because the bot installation was skipped in the Flash Chat installer. 
Please re-run the installer to enable bot support.
-->
{/if}	
</center>
{include file="bottom.tpl"}