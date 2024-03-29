{assign var=title value=Room}
{include file=top.tpl}
<center>

{if $smarty.request.error}
<font color="red">{$smarty.request.error}</font>
{/if}
{if $smarty.request.notice}
<font color="green">{$smarty.request.notice}</font>
{/if}

<h4>Room</h4>
<form name="room" action="room.php" method="post">
	<input type="hidden" name="id" value="{$smarty.request.id}">
	<table border="0">
		<tr><td align="right">name</td><td><input type="text" name="name" value="{$smarty.request.name}"></td></tr>
		<tr><td align="right">password</td><td><input type="text" name="password" value="{$smarty.request.password}"></td></tr>
		<tr><td align="right">public</td><td><input type="checkbox" name="ispublic" value="{if $smarty.request.ispublic}{$smarty.request.ispublic}{else}y{/if}"
				{if $smarty.request.ispublic}
					checked
				{/if}>
			</td>
		</tr>
		<tr><td align="right">permanent</td><td><input type="checkbox" name="ispermanent" value="{if $smarty.request.ispermanent}{$smarty.request.ispermanent}{else}l{/if}" 
				{if $smarty.request.ispublic}
					checked
				{/if}>
			</td>
		</tr>
		<tr>
			<td colspan="2" align="center">
				<input type="submit" name="add" value="Add new room">
				<input type="submit" name="set" value="Update room" {if !$smarty.request.id}disabled{/if}>
				<input type="submit" name="del" value="Remove room" {if !$smarty.request.id}disabled{/if}>
			</td>
		</tr>
	</table>
</form>
</center>
{include file=bottom.tpl}
