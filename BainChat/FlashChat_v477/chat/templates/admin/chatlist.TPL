{assign var=title value=Chats}
{include file=top.tpl}
{if $manageUsers}
<div align="center"><br>This option is not available when FlashChat is integrated with a custom CMS (content management system).<br> Please use the user administration tools which come with your system to add, edit, or remove users.</div>
{else}
<center>
	<h4>Chats</h4>
	<form name="chatlist" id="chatlist" action="chatlist.php" method="post">
	<table border="0">
		<tr>
			<td align="right">in this room:</td>
			<td>
				<select name="roomid">
				<option value="0">[ Any room ]
				{html_options options=$rooms selected=$smarty.request.roomid}
				</select>
			</td>
		</tr>
		<tr>
			<td align="right">between these dates:</td>
			<td><input type="text" name="from" value="{$smarty.request.from}" size="19">  and <input type="text" name="to" value="{$smarty.request.to}" size="19">(YYYY-MM-DD hh:mm:ss)</td>
		</tr>
		<tr>
			<td align="right">from the past X days:</td>
			<td><input type="text" name="days" value="{$smarty.request.days}" size="8"></td>
		</tr>
		<tr>
			<td align="right">by initiator:</td>
			<td>
				<select name="initiatorid">
				<option value="0">[ Any user ]
				{html_options options=$initiators selected=$smarty.request.initiatorid}
				</select>
			</td>
		</tr>
		<tr>
			<td align="right">by moderator:</td>
			<td>
				<select name="moderatorid">
				<option value="0">[ Any user ]
				{html_options options=$moderators selected=$smarty.request.moderatorid}
				</select>
			</td>
		</tr>
		<tr>
			<td colspan="2" align="center">
				<input type="submit" name="apply" value="Show chats">
				<input type="submit" name="clear" value="Clear filter">
				<input type="hidden" id="sort" name="sort" value="none">
				<!--<input type="submit" name="remove" value="Remove messages">-->
			</td>
		</tr>
	</table>
</form>

{if $chats}
<table border="1">
	<tr>
		<th><a href="javascript:my_getbyid('sort').value = 'roomname'; my_getbyid('chatlist').submit()"> Room name </a></th>
		<th><a href="javascript:my_getbyid('sort').value = 'initiatorlogin'; my_getbyid('chatlist').submit()">Initiator login</a></th>
		<th><a href="javascript:my_getbyid('sort').value = 'moderatorlogin'; my_getbyid('chatlist').submit()">Moderator login</a></th>
		<th><a href="javascript:my_getbyid('sort').value = 'start'; my_getbyid('chatlist').submit()">Start</a></th>
		<th><a href="javascript:my_getbyid('sort').value = 'end'; my_getbyid('chatlist').submit()">End</a></th>
		<th>preview</th>
	</tr>
{foreach from=$chats item=chat}
	<tr>
		<td valign="top"><a href="roomlist.php?id={$chat.roomid}">{$chat.roomname}</a></td>
		<td valign="top"><a href="usrlist.php?id={$chat.initiatorid}">{$chat.initiatorlogin}</a></td>
		<td valign="top">
	{if $chat.moderatorid}
		<a href="usrlist.php?id={$chat.moderatorid}">{$chat.moderatorlogin}</a>
	{else}
		[No Moderator]
	{/if}
		</td>
		<td valign="top">
			<a href="msglist.php?roomid={$chat.roomid}&from={$chat.start}&to={$chat.end}">
			{$chat.start}
			</a>
		</td>
		<td valign="top">
			{$chat.end}
		</td>
		<td valign="top">
			<table border="0" CELLSPACING="0" CELLPADDING="0">
{foreach from=$chat.messages item=message}
			<tr>
				<td><b>{$message.name}: </b>{$message.txt}</td>
			</tr>
	{/foreach}
			</table>
		</td>
	</tr>
{/foreach}
	</table>
{else}
	No chats found
{/if}

</center>

{/if}
{include file=bottom.tpl}
