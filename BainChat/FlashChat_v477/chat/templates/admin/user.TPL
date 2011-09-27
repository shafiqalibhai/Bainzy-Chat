{assign var=title value=User}
{include file=top.tpl}
<center>
	
{if $error}
<font color="red">{$error}</font>
{/if}
{if $notice}
<font color="green">{$notice}</font>
{/if}
{if $manageUsers}
	<div align="center"><br>This option is not available when FlashChat is integrated with a custom CMS (content management system).<br> Please use the user administration tools which come with your system to add, edit, or remove users.</div>
{else}
<h4>user</h4>
<form name="user" action="user.php" method="post">
	<input type="hidden" name="id" value="{$_REQUEST.id}">
	<table border="0">
		<tr><td align="right">login</td><td><input type="text" name="login" value="{$_REQUEST.login}"></td></tr>
		<tr><td align="right">{if $encryptPass}new {/if}password</td><td><input type="text" name="password" value="{$_REQUEST.password}">{if $encryptPass} leave blank if no change{/if}</td></tr>
		<tr>
			<td align="right">role</td>
			<td>
				<select name="roles">
				{html_options options=$roles selected=$_REQUEST.roles}
				</select>
				</td>
			</tr>
			<tr>
				<td colspan="2" align="center">
					<input type="submit" name="add" value="Add new user">
					<input type="submit" name="set" value="Update user"
{if !$_REQUEST.id}
					disabled
{/if}
					>
					<input type="submit" name="del" value="Remove user"
{if !$_REQUEST.id}
					disabled
{/if}
					>
				</td>
			</tr>
		</table>
	</form>

{/if}
	
</center>

{include file=bottom.tpl}
