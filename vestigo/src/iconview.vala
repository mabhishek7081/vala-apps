namespace Vestigo {
public class IconView : GLib.Object {
    string content;

    public void open_location(GLib.File file, bool start_monitor) {
        var list_dir  = new GLib.List<string>();
        var list_file = new GLib.List<string>();
        history = new GLib.List<string>();
        string prev_dir = current_dir;
        if (prev_dir != null) {
            history.append(prev_dir);
        }
        string name;
        string fullpath;
        current_dir = file.get_path();
        Gdk.Pixbuf pbuf = null;
        history.append(current_dir);
        if (current_dir != null && file.query_file_type(0) == GLib.FileType.DIRECTORY) {
            try {
                var d = Dir.open(file.get_path());
                model.clear();
                while ((name = d.read_name()) != null) {
                    fullpath = GLib.Path.build_filename(current_dir, name);
                    get_file_content(fullpath);
                    if (content == "inode/directory") {
                        list_dir.append(name);
                    } else {
                        list_file.append(name);
                    }
                }
                list_dir.sort(strcmp);
                list_file.sort(strcmp);
                foreach(string i in list_dir) {
                    fullpath = GLib.Path.build_filename(current_dir, i);
                    Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default();
                    pbuf = icon_theme.load_icon("folder", icon_size, 0);
                    model.append(out iter);
                    model.set(iter, 0, pbuf, 1, i, 2, fullpath, 3, i.replace("&", "&amp;"));
                }
                foreach(string i in list_file) {
                    fullpath = GLib.Path.build_filename(current_dir, i);
                    get_file_content(fullpath);
                    GLib.Icon icon = GLib.ContentType.get_icon(content);
                    Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default();
                    Gtk.IconInfo? icon_info = icon_theme.lookup_by_gicon(icon, icon_size, 0);
                    if (icon_info != null) {
                        pbuf = icon_info.load_icon();
                    } else {
                        pbuf = icon_theme.load_icon("gtk-file", icon_size, 0);
                    }
                    model.append(out iter);
                    model.set(iter, 0, pbuf, 1, i, 2, fullpath, 3, i.replace("&", "&amp;"));
                }
                window.set_title("%s".printf(current_dir));
                list_dir = null;
                list_file = null;
                places.set_location(file);
                GLib.Environment.set_current_dir(current_dir);
                view.grab_focus();
                if (start_monitor == true) {
                    var m = new Vestigo.DirectoryMonitor();
                    m.setup_file_monitor();
                }
            } catch (GLib.Error e) {
                stderr.printf("%s\n", e.message);
            }
        }
    }

    public void icon_clicked() {
        List<Gtk.TreePath> paths = view.get_selected_items();
        GLib.Value filepath;
        foreach (Gtk.TreePath path in paths) {
            model.get_iter(out iter, path);
            model.get_value(iter, 2, out filepath);
            var file_check = File.new_for_path((string)filepath);
            if (file_check.query_file_type(0) == GLib.FileType.DIRECTORY) {
                open_location(GLib.File.new_for_path((string)filepath), true);
            } else {
                try {
                    GLib.FileInfo file_info = file_check.query_info("standard::content-type", 0,
                                              null);
                    string content = file_info.get_content_type();
                    string mime = GLib.ContentType.get_mime_type(content);
                    if (mime == "application/x-bzip-compressed-tar"
                            || mime == "application/x-compressed-tar"
                            || mime == "application/zip"
                            || mime == "application/x-xz-compressed-tar") {
                        string uncomp_dir_s = file_check.get_basename().replace(".tar.bz2",
                                              "").replace(".tar.gz", "").replace(".zip", "").replace(".tar.xz", "");
                        string uncomp_dir_path = GLib.Path.get_dirname((string)filepath) + "/" +
                                                 uncomp_dir_s;
                        var uncomp_dir = File.new_for_path(uncomp_dir_path);
                        if (uncomp_dir.query_exists() == false) {
                            new Vestigo.Operations().execute_command_async("mkdir -p \"%s\"".printf(
                                        uncomp_dir_path));
                            new Vestigo.Operations().execute_command_async("bsdtar -xf \"%s\" -C \"%s\"".printf((
                                        string)filepath, uncomp_dir_path));
                        }
                        return;
                    }
                    var appinfo = AppInfo.get_default_for_type(mime, false);
                    if (appinfo != null) {
                        new Vestigo.Operations().execute_command_async("%s '%s'".printf(
                                    appinfo.get_executable(), (string)filepath));
                    } else {
                        var dialog = new Gtk.AppChooserDialog.for_content_type(window, 0, mime);
                        if (dialog.run() == Gtk.ResponseType.OK) {
                            appinfo = dialog.get_app_info();
                            if (appinfo != null) {
                                new Vestigo.Operations().execute_command_async("%s '%s'".printf(
                                            appinfo.get_executable(), (string)filepath));
                            }
                        }
                        dialog.close();
                    }
                } catch (GLib.Error e) {
                    stderr.printf ("%s\n", e.message);
                }
            }
        }
    }

    public string get_file_content(string filepath) throws GLib.Error {
        var file_check = File.new_for_path(filepath);
        var file_info = file_check.query_info("standard::content-type", 0, null);
        content = file_info.get_content_type();
        return content;
    }

    public void go_to_prev_directory() {
        string name = history.nth_data(0);
        open_location(GLib.File.new_for_path(name), true);
    }

}
}
