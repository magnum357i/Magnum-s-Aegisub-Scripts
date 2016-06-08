	script_name = "Select Lines"
	script_desription = "Her türlü yolla satır seçer."
	script_version = "1.4"
	script_author = "Magnum357"

	mag_import, mag = pcall(require,"mag")

	function act_style_before(subs,sel,act)
	local idx, index = 0, {}
	for i = 1, act do if subs[i].class == "dialogue" and subs[i].style == subs[act].style then idx = idx + 1 index[idx] = i end end
	return index
	end

	function act_style_after(subs,sel,act)
	local idx, index = 0, {}
	for i = act, #subs do if subs[i].style == subs[act].style then idx = idx + 1 index[idx] = i end end
	return index
	end

	function act_before(subs,sel,act)
	local idx, index = 0, {}
	for i = 1, act do if subs[i].class == "dialogue" then idx = idx + 1 index[idx] = i end end
	return index
	end

	function act_after(subs,sel,act)
	local idx, index = 0, {}
	for i = act, #subs do idx = idx + 1 index[idx] = i end
	return index
	end

	function prev_act(subs,sel,act) if subs[act - 1].class == "dialogue" then return {act - 1} end end

	function next_act(subs,sel,act) if act < #subs then return {act + 1} end end

	function first_style_line(subs,sel,act) return {mag.style_first_index(subs,subs[act].style)} end

	function last_style_line(subs,sel,act) return {mag.style_last_index(subs,subs[act].style)} end

	function style_all_lines(subs,sel,act)
	local idx, index = 0, {}
	for i = 1, #subs do if subs[i].class == "dialogue" and subs[i].style == subs[act].style then idx = idx + 1 index[idx] = i end end
	return index
	end

	function not_selection(subs,sel)
	local idx, index = 0, {}
	for si, li in ipairs(sel) do idx = idx + 1 index[idx] = li end
	if index[1] ~= nil then local k, vls, values = 1, 0, {}
	for i = 1, #subs do if subs[i].class == "dialogue" then if index[k] ~= i then vls = vls + 1 values[vls] = i else k = k + 1 end end end
	return values
	end
	end

	function lines_from_to(subs)
	local total_line = mag.total_full(subs)
	local first_index = mag.first_index(subs)
	local idx, index = 0, {}
	local var_tmp
	local dlg =
	{{class = "label",                                      x = 0, y = 0, width = 1, height = 1, label = "Başlangıç:"}
	,{class = "intedit", name = "var1",                     x = 1, y = 0, width = 1, height = 1, min = 1}
	,{class = "label",                                      x = 0, y = 1, width = 1, height = 1, label = mag.wall(" ",9).."Bitiş:"}
	,{class = "intedit", name = "var2", value = total_line, x = 1, y = 1, width = 1, height = 1, min = 1, max = total_line, hint = "Bu kutucukta ilk gördüğünüz değer alt yazıdaki satır sayısının toplamıdır."}}
	ok, config = mag.dlg(dlg,{"Seç","Kapat"})
	if ok == mag.ascii("Seç") then
	if config.var1 > config.var2 then
	var_tmp = config.var2
	config.var2 = config.var1
	config.var1 = var_tmp
	end
	config.var1 = config.var1 + first_index - 1
	config.var2 = config.var2 + first_index - 1
	for i = 1, #subs do if subs[i].class == "dialogue" and i >= config.var1 and i <= config.var2 then idx = idx + 1 index[idx] = i end end
	return index
	end
	end

	function line_jumping(subs,sel,act)
	local total_line = mag.total_full(subs)
	local index = {}
	local dlg =
	{{class = "label",                                                        x = 0, y = 0, width = 1, height = 1, label = "Gidilecek satır:"}
	,{class = "intedit", name = "var", value = mag.current_act(subs,sel,act), x = 1, y = 0, width = 1, height = 1, min = 1, max = total_line, hint = "Bu kutucukta ilk gördüğünüz değer bulunduğunuz satırın numarasıdır."}
	,{class = "label",                                                        x = 0, y = 1, width = 1, height = 1, label = mag.wall(" ",2).."Toplam satır:"}
	,{class = "label",                                                        x = 1, y = 1, width = 1, height = 1, label = total_line}}
	ok, config = mag.dlg(dlg,{"Atla","Kapat"})
	if ok == "Atla" then return {(#subs - total_line) + config.var} end
	end


	if mag_import then
	mag.register(script_name.."/Geçerli satır/Öncesi",        act_before      )
	mag.register(script_name.."/Geçerli satır/Sonrası",       act_after       )
	mag.register(script_name.."/Geçerli satır/Öncesi(Stil)",  act_style_before)
	mag.register(script_name.."/Geçerli satır/Sonrası(Stil)", act_style_after )
	mag.register(script_name.."/Stil/İlk satır",              first_style_line)
	mag.register(script_name.."/Stil/Son satır",              last_style_line )
	mag.register(script_name.."/Stil/Tüm satırlar",           style_all_lines )
	mag.register(script_name.."/Satır/Satır aralığı",         lines_from_to   )
	mag.register(script_name.."/Satır/Satır atlama",          line_jumping    )
	mag.register(script_name.."/Satır/Önceki satır",          prev_act        )
	mag.register(script_name.."/Satır/Sonraki satır",         next_act        )
	mag.register(script_name.."/Seçimin tersi",               not_selection   )
	else function mag()
	local k = aegisub.dialog.display({{class = "label", label="Mag modülü bulunamadı. \nBu lua dosyasını kullanmak için Mag modülünü İndirmek ister misiniz?"}},{"Evet","Kapat"})
	if k == "Evet" then os.execute("start https://github.com/magnum357i/Magnum-s-Aegisub-Scripts") end end
	aegisub.register_macro(script_name,script_desription,mag) end
