if SAM_LOADED then return end

local sam, command = sam, sam.command

command.set_category("Noah | mTokens")

local function GetTokenName()
	if mTokens and mTokens.Config and mTokens.Config.TokenName then
		return mTokens.Config.TokenName
	end

	return "mTokens"
end

local function EnsurePlayerTokens(ply)
	if not IsValid(ply) then return false end
	if not mTokens or not mTokens.PlyData then return false end

	local sid = ply:SteamID64()
	if mTokens.PlyData[sid] then return true end

	if mTokens.SQL and mTokens.SQL.InitializePlayer then
		mTokens.SQL.InitializePlayer(ply)
	end

	return mTokens.PlyData[sid] ~= nil
end

local function NotifyTarget(target, message)
	if DarkRP and DarkRP.notify then
		DarkRP.notify(target, 0, 4, message)
	end
end

command.new("addmtokens")
	:SetPermission("addmtokens", "admin")

	:AddArg("player", {single_target = true})
	:AddArg("number", {hint = "amount", min = 1})

	:Help("Ajoute des points mTokens a un joueur.")

	:OnExecute(function(ply, targets, amount)
		if not mTokens or not mTokens.AddPlayerTokens then
			return sam.player.send_message(ply, "mTokens n'est pas installe.")
		end

		local target = targets[1]
		if not EnsurePlayerTokens(target) then
			return sam.player.send_message(ply, "Impossible de charger les mTokens du joueur.")
		end

		mTokens.AddPlayerTokens(target, amount)

		local tokenName = GetTokenName()
		NotifyTarget(target, ply:Nick() .. " vous a donne " .. amount .. " " .. tokenName)

		if sam.is_command_silent then return end
		sam.player.send_message(nil, "{A} a donne {V} " .. tokenName .. " a {T}.", {
			A = ply,
			T = targets,
			V = amount,
		})
	end)
:End()

command.new("removemtokens")
	:SetPermission("removemtokens", "admin")

	:AddArg("player", {single_target = true})
	:AddArg("number", {hint = "amount", min = 1})

	:Help("Retire des points mTokens a un joueur.")

	:OnExecute(function(ply, targets, amount)
		if not mTokens or not mTokens.GetPlayerTokens or not mTokens.SetPlayerTokens then
			return sam.player.send_message(ply, "mTokens n'est pas installe.")
		end

		local target = targets[1]
		if not EnsurePlayerTokens(target) then
			return sam.player.send_message(ply, "Impossible de charger les mTokens du joueur.")
		end

		local current = mTokens.GetPlayerTokens(target)
		local removed = math.min(amount, current)
		mTokens.SetPlayerTokens(target, math.max(0, current - amount))

		local tokenName = GetTokenName()
		NotifyTarget(target, ply:Nick() .. " vous a retire " .. removed .. " " .. tokenName)

		if sam.is_command_silent then return end
		sam.player.send_message(nil, "{A} a retire {V} " .. tokenName .. " a {T}.", {
			A = ply,
			T = targets,
			V = removed,
		})
	end)
:End()
