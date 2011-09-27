{assign var=title value=Users}
{include file=top.tpl}

{if $manageUsers}
<div align="center"><br>This option is not available when FlashChat is integrated with a custom CMS (content management system).<br> Please use the user administration tools which come with your system to add, edit, or remove users.</div>
{else}
<center>
	<form name="usrlist" id="usrlist" action="usrlist.php" method="post">
		<input type="hidden" id="sort" name="sort" value="none">
	</form>
	<h4>Users</h4>
	<a href="user.php">Add new user</a><br>
	<br>
{if $users}
	<table border="1">
		<tr>
			<th><a href="javascript:my_getbyid('sort').value = 'id'; my_getbyid('usrlist').submit()">id</a></th>
			<th><a href="javascript:my_getbyid('sort').value = 'login'; my_getbyid('usrlist').submit()">login</a></th>
			<th><a href="javascript:my_getbyid('sort').value = 'password'; my_getbyid('usrlist').submit()">password</a></th>
			<th><a href="javascript:my_getbyid('sort').value = 'roles'; my_getbyid('usrlist').submit()">role</a></th>
		</tr>
	{foreach from=$users item=user}
		<tr>
			<td>{$user.id}</td>
			<td><a href="user.php?id={$user.id}">{$user.login}</a></td>
			<td>{if $encryptPass}(password encrypted){else}{$user.password}{/if}</td>
			<td>{$user.roles}</td>
		</tr>
	{/foreach}
{else}
	No users found
{/if}
</center>
{/if}
{include file=bottom.tpl}
