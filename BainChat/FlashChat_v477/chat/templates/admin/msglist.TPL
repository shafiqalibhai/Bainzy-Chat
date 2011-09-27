{assign var=title value=Messages}
{include file=top.tpl}
<center>
	<h4>Messages</h4>
	<form name="msglist" id="msglist" action="msglist.php" method="post">
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
			<td align="right">by this user:</td>
			<td>
				<select name="userid">
				<option value="0">[ Any user ]
				{html_options options=$users selected=$smarty.request.userid}
					</select>
				</td>
			</tr>
			<tr>
				<td align="right" width="200">containing this keyword:</td>
				<td><input type="text" name="keyword" value="{$smarty.request.keyword}" size="32"></td>
			</tr>
			<tr>
				<td colspan="2" align="center">
					<input type="submit" name="apply" value="Show messages">
					<input type="submit" name="clear" value="Clear filter">
					<input type="hidden" id="sort" name="sort" value="none">
					<!--<input type="submit" name="remove" value="Remove messages">-->
				</td>
			</tr>
		</table>
	</form>

{if $messages}

<table border="1">
	<tr>
		<th><a href="javascript:my_getbyid('sort').value = 'id'; my_getbyid('msglist').submit()">id</a></th>
		<th><a href="javascript:my_getbyid('sort').value = 'sent'; my_getbyid('msglist').submit()">sent</a></th>
		<th><a href="javascript:my_getbyid('sort').value = 'user'; my_getbyid('msglist').submit()">from user</a></th>
		<th><a href="javascript:my_getbyid('sort').value = 'toroom'; my_getbyid('msglist').submit()">to room</a></th>
		<th><a href="javascript:my_getbyid('sort').value = 'touser'; my_getbyid('msglist').submit()">to user</a></th>
		<th>txt</th>
	</tr>

{foreach from=$messages item=message}
	<tr>
		<td>{$message.id}</td>
		<td>{$message.sent}</td>
		<td>
		{$message.user}
		</td>
		<td><a href="room.php?id={$message.toroomid}">{$message.toroom}</a></td>
		<td>
		{$message.touser}
		</td>
		<td>{$message.txt}</td>
	</tr>
{/foreach}
{else}
	No messages found
{/if}

</center>

{include file=bottom.tpl}
