	function lang_switch_keys(lang)
	local in_lang = {}
	local langs   =
	{
	[1] = {lang_key = "tr", lang_name = "Türkçe",  script_name = "Karakter Yerleştir"},
	[2] = {lang_key = "en", lang_name = "English", script_name = "K Char"}
	}
	local lang_list        = {}
	local script_name_list = {}
	for i = 1, #langs do
	lang_list[langs[i].lang_key]        = langs[i].lang_name
	script_name_list[langs[i].lang_key] = langs[i].script_name
	end
	if lang == langs[1].lang_key then
	in_lang["module_incompatible"] = "Mag modülünün kurulu sürümü bu lua dosyası ile uyumsuz!\n\nModül dosyasının en az \"%s\" sürümü veya daha üstü gerekiyor.\n\n\nŞimdi indirme sayfasına gitmek ister misiniz?"
	in_lang["module_not_found"]    = "Mag modülü bulunamadı!\n\nBu lua dosyasını kullanmak için Mag modülünü indirip Aegisub programı kapalıyken\n\"Aegisub/automation/include/\" dizinine taşımanız gerekiyor.\n\n\nŞimdi indirme sayfasına gitmek ister misiniz?"
	in_lang["module_yes"]          = "Git"
	in_lang["module_no"]           = "Daha Sonra"
	in_lang["s_name"]              = langs[1].script_name
	in_lang["s_desc"]              = "Satırdaki her karakterin başına herhangi bir şey koymanızı sağlar."
	in_lang["guiLabelKey1"]        = "Her karakterden önce:"
	in_lang["buttonKey1"]          = "Uygula"
	in_lang["buttonKey2"]          = "Kapat"
	elseif lang == langs[2].lang_key then
	in_lang["module_incompatible"] = "The installed version of the Mag module is incompatible with this lua file!\n\nAt least \"%s\" version or higher of the module file is required.\n\n\nWould you like to go to the download page now?"
	in_lang["module_not_found"]    = "The module named Mag could not be found!\n\nTo use this file, you need to download the module named mag\nand move it to \"Aegisub/automation/include/\" directory when Aegisub is off.\n\n\nDo you want to go to download page now?"
	in_lang["module_yes"]          = "Go"
	in_lang["module_no"]           = "Later"
	in_lang["s_name"]              = langs[2].script_name
	in_lang["s_desc"]              = "Allows you to put anything before each character on the line."
	in_lang["guiLabelKey1"]        = "Before each character:"
	in_lang["buttonKey1"]          = "Apply"
	in_lang["buttonKey2"]          = "Close"
	end
	return in_lang, lang_list, script_name_list
	end

	c_lang_switch      = "en"
	c_lang,
	c_lang_list,
	c_script_name_list = lang_switch_keys(c_lang_switch)

	script_name        = c_lang.s_name
	script_description = c_lang.s_desc
	script_version     = "1.1"
	script_author      = "Magnum357"
	script_mag_version = "1.1.4.4"
	script_file_name   = "mag.k_char"
	script_file_ext    = ".lua"

	include_unicode    = true
	mag_import, mag    = pcall(require, "mag")

	if mag_import then
	mag.lang           = c_lang_switch

	c_lock_gui         = false
	c_buttons1         = {c_lang.buttonKey1, c_lang.buttonKey2}

	c                  = {}
	c.comment_mode     = true
	c.empty_mode       = true
	c.apply            = mag.window.lang.message("select")
	c.char             = "{\\k}"

	gui = {
		main1        = {
		               {class = "label",                             x = 0, y = 0, width = 1, height = 1, label = c_lang.guiLabelKey1},
		char         = {class = "edit",     name = "u_char",         x = 1, y = 0, width = 1, height = 1},
		               {class = "label",                             x = 0, y = 1, width = 1, height = 1, label = mag.window.lang.message("apply")},
		apply        = {class = "dropdown", name = "u_apply_lines",  x = 1, y = 1, width = 1, height = 1, hint = mag.window.lang.message("style_hint1")},
		comment_mode = {class = "checkbox", name = "u_comment_mode", x = 1, y = 2, width = 1, height = 1, label = mag.window.lang.message("comment_mode")},
		empty_mode   = {class = "checkbox", name = "u_empty_mode",   x = 1, y = 3, width = 1, height = 1, label = mag.window.lang.message("empty_mode")},
		}
	}
	end

	function k_char(subs,sel)
	local line
	local pcs         = false
	local lines_index = mag.line.index(subs, sel, c.apply, c.comment_mode, c.empty_mode)
	for i = 1, #lines_index do
	if not pcs then pcs = true end
	local index = lines_index[i]
	line        = subs[index]
	local in_tags = false
	local result  = ""
		for char in unicode.chars(line.text) do
		if char == "{" then in_tags = true end
		if not in_tags and not mag.match(char, "%s") then char = c.char..char end
		result = result..char
		if char == "}" then in_tags = false end
		end
	line.text = result
	subs[index] = line
	end
	mag.show.no_op(pcs)
	end

	function add_macro1(subs,sel)	
	local apply_items     = mag.list.full_apply(subs, sel, "comment")
	c.apply               = mag.array.search_apply(apply_items, c.apply)
	gui.main1.apply.items = apply_items
	local ok, config
	repeat
	gui.main1.apply.value        = c.apply
	gui.main1.comment_mode.value = c.comment_mode
	gui.main1.empty_mode.value   = c.empty_mode
	gui.main1.char.value         = c.char
	ok, config                   = mag.window.dialog(gui.main1, c_buttons1)
	c.apply                      = config.u_apply_lines
	c.comment_mode               = config.u_comment_mode
	c.empty_mode                 = config.u_empty_mode
	c.char                       = config.u_char
	until ok == mag.convert.ascii(c_buttons1[1]) and c.apply ~= mag.window.lang.message("select") or ok == mag.convert.ascii(c_buttons1[2])
	if ok == mag.convert.ascii(c_buttons1[1]) then
	k_char(subs, sel)
	end
	end

	function check_macro1(subs,sel)
	if c_lock_gui then
	mag.show.log(1, mag.window.lang.message("restart_aegisub"))
	else
	mag.config.get(c)
	local fe, fee = pcall(add_macro1, subs, sel)
	mag.window.funce(fe, fee)
	mag.window.undo_point()
	mag.config.set(c)
	end
	end

	function mag_redirect_gui()
	local mag_module_link = "https://github.com/magnum357i/Magnum-s-Aegisub-Scripts"
	local k = aegisub.dialog.display({{class = "label", label = mag_gui_message}}, {c_lang.module_yes, c_lang.module_no})
	if k == c_lang.module_yes then os.execute("start "..mag_module_link) end
	end

	if mag_import then
		if mag_module_version:gsub("%.", "") < script_mag_version:gsub("%.", "") then
		mag_gui_message = string.format(c_lang.module_incompatible, script_mag_version)
		aegisub.register_macro(script_name, script_desription, mag_redirect_gui)
		else
		mag.window.register(script_name.."/"..mag.window.lang.message("gui_tabname"), check_macro1)
		mag.window.lang.register()
		end
	else
	mag_gui_message = c_lang.module_not_found
	aegisub.register_macro(script_name, script_desription, mag_redirect_gui)
	end