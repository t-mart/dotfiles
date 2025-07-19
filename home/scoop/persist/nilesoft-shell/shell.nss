settings
{
	priority=1
	exclude.where = !process.is_explorer
	showdelay = 200
	// Options to allow modification of system items
	modify.remove.duplicate=1
	tip.enabled=true
}

import 'imports/theme.nss'
import 'imports/images.nss'

import 'imports/modify.nss'

menu(mode="multiple" title="Pin/Unpin" image=icon.pin)
{
}

menu(mode="multiple" title=title.more_options image=icon.more_options)
{
}

// import 'imports/terminal.nss'
// import 'imports/file-manage.nss'
// import 'imports/develop.nss'
// import 'imports/goto.nss'
// import 'imports/taskbar.nss'

// Explorer 
menu(where=sel.count>0 type='file|dir|drive|namespace|back' mode="multiple" expanded=true separator="both")
{
	menu(title=title.copy_path image=icon.copy_path)
	{
		item(where=sel.count > 1 title='Copy (@sel.count) items selected' cmd=command.copy(sel(false, "\n")))
		item(mode="single" title=@sel.path tip=sel.path cmd=command.copy(sel.path))
		item(mode="single" type='file' separator="before" find='.lnk' title='Goto target')

		separator

		item(mode="single" where=@sel.parent.len>3 title=sel.parent cmd=@command.copy(sel.parent))

		separator

		item(mode="single" type='file|dir|back.dir' title=sel.file.name cmd=command.copy(sel.file.name))
		item(mode="single" type='file' where=sel.file.len != sel.file.title.len title=@sel.file.title cmd=command.copy(sel.file.title))
		item(mode="single" type='file' where=sel.file.ext.len>0 title=sel.file.ext cmd=command.copy(sel.file.ext))
	}

	menu(image=\uE290 title=title.select)
	{
		item(title="All" image=icon.select_all cmd=command.select_all)
		item(title="Invert" image=icon.invert_selection cmd=command.invert_selection)
		item(title="None" image=icon.select_none cmd=command.select_none)
	}

	menu(type='file|dir|back.dir' mode="single" title='Attributes' image=icon.properties)
	{
		item(title="Created" keys=io.dt.created(sel.path, 'm/d/y h:m:S P') vis=label)
		item(title="Modified" keys=io.dt.modified(sel.path, 'm/d/y h:m:S P') vis=label)
		item(title="Accessed" keys=io.dt.accessed(sel.path, 'm/d/y h:m:S P') vis=label)

		separator

		$atrr = io.attributes(sel.path)
		item(title='Hidden' checked=io.attribute.hidden(atrr)
			cmd args='/c ATTRIB @if(io.attribute.hidden(atrr),"-","+")H "@sel.path"' window=hidden)
		item(title='System' checked=io.attribute.system(atrr)
			cmd args='/c ATTRIB @if(io.attribute.system(atrr),"-","+")S "@sel.path"' window=hidden)
		item(title='Read-Only' checked=io.attribute.readonly(atrr)
			cmd args='/c ATTRIB @if(io.attribute.readonly(atrr),"-","+")R "@sel.path"' window=hidden)
		item(title='Archive' checked=io.attribute.archive(atrr)
			cmd args='/c ATTRIB @if(io.attribute.archive(atrr),"-","+")A "@sel.path"' window=hidden)
	}
}


// Taskbar Settings Menu
menu(where=@(this.count == 0) type='taskbar' image=icon.settings expanded=true)
{
	menu(title=title.windows image=\uE1FB)
	{
		item(title=title.cascade_windows cmd=command.cascade_windows)
		item(title=title.Show_windows_stacked cmd=command.Show_windows_stacked)
		item(title=title.Show_windows_side_by_side cmd=command.Show_windows_side_by_side)

		separator

		item(title=title.minimize_all_windows cmd=command.minimize_all_windows)
		item(title=title.restore_all_windows cmd=command.restore_all_windows)
	}

	item(title=title.taskbar_Settings sep=both image=inherit cmd='ms-settings:taskbar')
	item(title="Restart Nilesoft Shell" image=icon.restore cmd='sudo.exe' args='shell -register -treat -silent -restart')
}

// Go To Menu (in both Explorer and Taskbar)
menu(type='*' where=window.is_taskbar||sel.count mode=mode.multiple title=title.go_to sep=sep.both image=\uE14A)
{
	menu(title='Folder' image=\uE1F4)
	{
		item(title='Profile' image=inherit cmd=user.dir)
		item(title='Desktop' image=inherit cmd=user.desktop)
		item(title='Downloads' image=inherit cmd=user.downloads)
		item(title='Startmenu' image=inherit cmd=user.startmenu)
		item(title='AppData' image=inherit cmd=user.appdata)
		item(title='User Temp' image=inherit cmd=user.temp)

		separator

		item(title='Windows' image=inherit cmd=sys.dir)
		item(title='System' image=inherit cmd=sys.bin)
		item(title='Program Files' image=inherit cmd=sys.prog)
		item(title='Program Files x86' image=inherit cmd=sys.prog32)
		item(title='Users' image=inherit cmd=sys.users)
	}

	menu(where=sys.ver.major >= 10 title='Tools' image=icon.settings)
	{
		item(title='Services' image=icon.manage cmd='services.msc')
		item(title='Device Manager' image=icon.device_manager cmd='devmgmt.msc')
		item(title='Windows Update' image=icon.install cmd='ms-settings:windowsupdate')
		item(title='Installed Apps' image=icon.content cmd='ms-settings:appsfeatures')
		item(title='Network Connections' image=icon.map_network_drive cmd='shell:::{7007ACC7-3202-11D1-AAD2-00805FC1270E}')
		item(title='System Informer (Task Manager)' image=icon.task_manager cmd='systeminformer.exe')
		item(title='Registry Editor' image=icon.edit cmd='regedit')

		separator

		menu(title='Administrative Tools' image=icon.manage)
		{
			item(title='Computer Management' image=icon.pc cmd='compmgmt.msc')
			item(title='Disk Management' image=icon.disk_management cmd='diskmgmt.msc')
			item(title='Event Viewer' image=icon.view2 cmd='eventvwr.msc')
			item(title='Task Scheduler' image=icon.properties cmd='taskschd.msc')
			item(title='Performance Monitor' image=icon.task_manager cmd='perfmon.msc')
			item(title='About System' image=icon.pc cmd="ms-settings:about")
			item(title='Resource Monitor' image=icon.task_manager cmd='resmon')
			item(title='System Configuration' image=icon.settings cmd='msconfig')
		}

		menu(title='Security and Users' image=icon.run_as_administrator)
		{
			item(title='Windows Security' image=icon.run_as_administrator cmd='ms-settings:windowsdefender')
			item(title='Firewall' image=icon.run_as_administrator cmd='ms-settings:network-firewall')
			item(title='Windows Firewall (Advanced)' image=icon.run_as_administrator cmd='wf.msc')
			
			separator
			
			// The following items may not be available in Windows Home editions.
			item(title='Group Policy Editor' image=icon.edit cmd='gpedit.msc')
			item(title='Local Security Policy' image=icon.run_as_administrator cmd='secpol.msc')
			item(title='Local Users and Groups' image=icon.run_as_different_user cmd='lusrmgr.msc')
			
			separator
			
			item(title='Certificate Manager (User)' image=icon.properties cmd='certmgr.msc')
			item(title='Certificate Manager (Computer)' image=icon.properties cmd='certlm.msc')
			
			separator
			
			item(title='Your Info' image=icon.personalize cmd='ms-settings:yourinfo')
		}

		menu(title='Network and Storage' image=icon.map_network_drive)
		{
			item(title='Network Status' image=icon.map_network_drive cmd='ms-settings:network-status')
			item(title='Ethernet' image=icon.map_network_drive cmd='ms-settings:network-ethernet')
			item(title='Shared Folders' image=icon.move_to cmd='fsmgmt.msc')
			item(title='Storage Settings' image=icon.disk_management cmd='ms-settings:disksandvolumes')
			item(title='WMI Control' image=icon.properties cmd='wmimgmt.msc')
		}

		menu(title='Personalization and Apps' image=icon.personalize)
		{
			item(title='Default Apps' image=icon.settings cmd='ms-settings:defaultapps')
			item(title='Optional Features' image=icon.expand cmd='ms-settings:optionalfeatures')
			item(title='Startup Apps' image=icon.task_manager cmd='ms-settings:startupapps')

			separator

			item(title='Personalization' image=icon.personalize cmd='ms-settings:personalization')
			item(title='Background' image=icon.set_as_desktop_wallpaper cmd='ms-settings:personalization-background')
			item(title='Colors' image=icon.personalize cmd='ms-settings:colors')
			item(title='Lockscreen' image=icon.pin cmd='ms-settings:lockscreen')
			item(title='Themes' image=icon.personalize cmd='ms-settings:themes')
			item(title='Start' image=icon.pin_to_start cmd='ms-settings:personalization-start')
			item(title='Taskbar' image=icon.settings cmd='ms-settings:taskbar')
		}

		separator

		item(title='Windows Settings' image=icon.settings cmd='ms-settings:')
	}

	// menu(title='Icon Demonstration')
	// {
	//     item(title='copy' image=icon.copy)
	//     item(title='cut' image=icon.cut)
	//     item(title='paste' image=icon.paste)
	//     item(title='paste_shortcut' image=icon.paste_shortcut)
	//     item(title='move_to' image=icon.move_to)
	//     item(title='copy_as_path' image=icon.copy_as_path)
	//     item(title='settings' image=icon.settings)
	//     item(title='task_manager' image=icon.task_manager)
	//     item(title='run_as_administrator' image=icon.run_as_administrator)
	//     item(title='run_as_different_user' image=icon.run_as_different_user)
	//     item(title='personalize' image=icon.personalize)
	//     item(title='display_settings' image=icon.display_settings)
	//     item(title='pin' image=icon.pin)
	//     item(title='unpin' image=icon.unpin)
	//     item(title='add_to_favorites' image=icon.add_to_favorites)
	//     item(title='remove_from_favorites' image=icon.remove_from_favorites)
	//     item(title='delete' image=icon.delete)
	//     item(title='sort_by' image=icon.sort_by)
	//     item(title='group_by' image=icon.group_by)
	//     item(title='view' image=icon.view)
	//     item(title='view2' image=icon.view2)
	//     item(title='align_icons_to_grid' image=icon.align_icons_to_grid)
	//     item(title='auto_arrange_icons' image=icon.auto_arrange_icons)
	//     item(title='close' image=icon.close)
	//     item(title='expand' image=icon.expand)
	//     item(title='expand_all' image=icon.expand_all)
	//     item(title='collapse' image=icon.collapse)
	//     item(title='collapse_all' image=icon.collapse_all)
	//     item(title='format' image=icon.format)
	//     item(title='eject' image=icon.eject)
	//     item(title='content' image=icon.content)
	//     item(title='details' image=icon.details)
	//     item(title='extra_large_icons' image=icon.extra_large_icons)
	//     item(title='large_icons' image=icon.large_icons)
	//     item(title='list' image=icon.list)
	//     item(title='medium_icons' image=icon.medium_icons)
	//     item(title='small_icons' image=icon.small_icons)
	//     item(title='tiles' image=icon.tiles)
	//     item(title='install' image=icon.install)
	//     item(title='select_all' image=icon.select_all)
	//     item(title='invert_selection' image=icon.invert_selection)
	//     item(title='select_none' image=icon.select_none)
	//     item(title='share' image=icon.share)
	//     item(title='mount' image=icon.mount)
	//     item(title='new' image=icon.new)
	//     item(title='new_folder' image=icon.new_folder)
	//     item(title='new_file' image=icon.new_file)
	//     item(title='open_folder' image=icon.open_folder)
	//     item(title='open_new_window' image=icon.open_new_window)
	//     item(title='open_new_tab' image=icon.open_new_tab)
	//     item(title='open_spot_light' image=icon.open_spot_light)
	//     item(title='open_with' image=icon.open_with)
	//     item(title='run_with_powershell' image=icon.run_with_powershell)
	//     item(title='properties' image=icon.properties)
	//     item(title='restore' image=icon.restore)
	//     item(title='undo' image=icon.undo)
	//     item(title='redo' image=icon.redo)
	//     item(title='refresh' image=icon.refresh)
	//     item(title='rename' image=icon.rename)
	//     item(title='rotate_left' image=icon.rotate_left)
	//     item(title='rotate_right' image=icon.rotate_right)
	//     item(title='set_as_desktop_wallpaper' image=icon.set_as_desktop_wallpaper)
	//     item(title='next_desktop_background' image=icon.next_desktop_background)
	//     item(title='desktop' image=icon.desktop)
	//     item(title='restore_previous_versions' image=icon.restore_previous_versions)
	//     item(title='create_shortcut' image=icon.create_shortcut)
	//     item(title='turn_on_bitlocker' image=icon.turn_on_bitlocker)
	//     item(title='show_file_extensions' image=icon.show_file_extensions)
	//     item(title='show_hidden_files' image=icon.show_hidden_files)
	//     item(title='compressed' image=icon.compressed)
	//     item(title='more_options' image=icon.more_options)
	//     item(title='burn_disc_image' image=icon.burn_disc_image)
	//     item(title='cleanup' image=icon.cleanup)
	//     item(title='move' image=icon.move)
	//     item(title='copy_to' image=icon.copy_to)
	//     item(title='pc' image=icon.pc)
	//     item(title='command_prompt' image=icon.command_prompt)
	//     item(title='manage' image=icon.manage)
	//     item(title='edit' image=icon.edit)
	//     item(title='troubleshoot_compatibility' image=icon.troubleshoot_compatibility)
	//     item(title='customize_this_folder' image=icon.customize_this_folder)
	//     item(title='give_access_to' image=icon.give_access_to)
	//     item(title='send_to' image=icon.send_to)
	//     item(title='include_in_library' image=icon.include_in_library)
	//     item(title='add_a_network_location' image=icon.add_a_network_location)
	//     item(title='disconnect_network_drive' image=icon.disconnect_network_drive)
	//     item(title='map_network_drive' image=icon.map_network_drive)
	//     item(title='make_available_offline' image=icon.make_available_offline)
	//     item(title='make_available_online' image=icon.make_available_online)
	//     item(title='file_explorer' image=icon.file_explorer)
	//     item(title='file_explorer_options' image=icon.file_explorer_options)
	//     item(title='print' image=icon.print)
	//     item(title='device_manager' image=icon.device_manager)
	//     item(title='disk_management' image=icon.disk_management)
	//     item(title='filter' image=icon.filter)
	//     item(title='window' image=icon.window)
	//     item(title='code' image=icon.code)
	//     item(title='reddit' image=icon.reddit)
	//     item(title='cortana' image=icon.cortana)
	//     item(title='nvidia' image=icon.nvidia)
	// }
}