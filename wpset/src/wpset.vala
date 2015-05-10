/*  Author: simargl <https://github.com/simargl>
 *  License: GPL v3
 */

private class Program : Gtk.Application
{
    const string NAME = "Desktop Wallpaper";
    const string VERSION = "1.8.0";
    const string DESCRIPTION = _("A simple tool for changing your desktop wallpaper");
    const string ICON = "preferences-desktop-wallpaper";
    const string[] AUTHORS = { "Jonathan Koren (imlibsetroot) <jonathan-at-jonathankoren-dot-com>", "Simargl <https://github.com/simargl>", null };

    Gtk.ApplicationWindow window;
    GLib.Settings settings;
    Gtk.MenuButton menubutton;
    Gdk.Pixbuf pixbuf;
    Gtk.ListStore liststore;
    Gtk.TreeIter iter;
    Gtk.IconView view;
    string[] wallpaper;
    string[] images_dir;
    int thumbnail_size;
    Gtk.ScrolledWindow scrolled;
    private const Gtk.TargetEntry[] targets = { {"text/uri-list", 0, 0} };

    private const GLib.ActionEntry[] action_entries =
    {
        { "add",       action_add       },
        { "reset",     action_reset     },
        { "show-menu", action_show_menu },
        { "about",     action_about     },
        { "quit",      action_quit      }
    };

    private Program()
    {
        Object(application_id: "org.vala-apps.wpset", flags: ApplicationFlags.FLAGS_NONE);
        add_action_entries(action_entries, this);
    }

    public override void startup()
    {
        base.startup();

        var menu = new Menu();
        menu.append(_("About"),     "app.about");
        menu.append(_("Quit"),      "app.quit");

        set_app_menu(menu);

        set_accels_for_action("app.add",       {"<Primary><Shift>A"});
        set_accels_for_action("app.reset",     {"Delete"});
        set_accels_for_action("app.show-menu", {"F10"});
        set_accels_for_action("app.quit",      {"<Primary>Q"});

        settings = new GLib.Settings("org.vala-apps.wpset.preferences");
        images_dir = settings.get_strv("images-dir");
        thumbnail_size = settings.get_int("thumbnail-size");

        liststore = new Gtk.ListStore (2, typeof (Gdk.Pixbuf), typeof (string));

        view = new Gtk.IconView.with_model(liststore);
        view.set_pixbuf_column(0);
        view.item_activated.connect(apply_selected_image);
        view.set_activate_on_single_click(true);

        for (int i = 0; i < images_dir.length; i++)
            list_images(images_dir[i]);

        var gear_menu = new Menu();
        gear_menu.append(_("Add folder"), "app.add");
        gear_menu.append(_("Reset list"), "app.reset");

        menubutton = new Gtk.MenuButton();
        menubutton.valign = Gtk.Align.CENTER;
        menubutton.set_use_popover(true);
        menubutton.set_menu_model(gear_menu);
        menubutton.set_image(new Gtk.Image.from_icon_name("open-menu-symbolic", Gtk.IconSize.MENU));

        var headerbar = new Gtk.HeaderBar();
        headerbar.set_show_close_button(true);
        headerbar.set_title(NAME);
        headerbar.pack_end(menubutton);

        scrolled = new Gtk.ScrolledWindow(null, null);
        scrolled.add(view);
        scrolled.expand = true;

        window = new Gtk.ApplicationWindow(this);
        window.set_icon_name(ICON);
        window.window_position = Gtk.WindowPosition.CENTER;
        window.set_titlebar(headerbar);
        window.add(scrolled);
        window.set_default_size(600, 480);
        window.show_all();

        Gtk.drag_dest_set(scrolled, Gtk.DestDefaults.ALL, targets, Gdk.DragAction.COPY);
        scrolled.drag_data_received.connect(on_drag_data_received);
    }

    public override void activate()
    {
        window.present();
    }

    void list_images(string directory)
    {
        try
        {
            string output;
            Environment.set_current_dir(directory);
            Process.spawn_command_line_sync(" sh -c \"find '%s' -maxdepth 1 -name '*jpg' -o -name '*png' -o -name '*bmp' | sort -n\" ".printf(directory), out output);
            wallpaper = Regex.split_simple("[\n]", output, GLib.RegexCompileFlags.MULTILINE);
            add_pixbuf_to_liststore(wallpaper);
        }
        catch (GLib.Error e)
        {
            stderr.printf ("%s\n", e.message);
        }
    }

    void add_pixbuf_to_liststore(string[] images_in_a_folder)
    {
        for (int i = 0; i < images_in_a_folder.length; i++)
        {
            string fullpath = wallpaper[i];
            if (fullpath != "")
            {
                load_thumbnail.begin(fullpath, (obj, res) =>
                {
                    pixbuf = load_thumbnail.end(res);

                    liststore.append(out iter);
                    liststore.set(iter, 0, pixbuf, 1, fullpath);
                });
            }
        }
    }

    private async Gdk.Pixbuf load_thumbnail(string name)
    {
        Gdk.Pixbuf? pix = null;
        var file = GLib.File.new_for_path(name);
        try
        {
            GLib.InputStream stream = yield file.read_async();
            pix = yield new Gdk.Pixbuf.from_stream_at_scale_async(stream, thumbnail_size, thumbnail_size, true, null);
        }
        catch (Error e)
        {
            stderr.printf("%s\n", e.message);
        }
        return pix;
    }

    private void apply_selected_image()
    {
        List<Gtk.TreePath> paths = view.get_selected_items();
        GLib.Value selected;
        foreach (Gtk.TreePath path in paths)
        {
            liststore.get_iter(out iter, path);
            liststore.get_value(iter, 1, out selected);
            var gnome_settings = new GLib.Settings("org.gnome.desktop.background");
            gnome_settings.set_string("picture-uri", "file://".concat((string)selected));
            GLib.Settings.sync();
            try
            {
                Process.spawn_command_line_sync("wpset-shell --set");
            }
            catch(Error error)
            {
                stderr.printf("error: %s\n", error.message);
            }
        }       
    }

    private void add_images_from_selected(string directory)
    {
        int i;
        int[] indexes = {};
        for (i = 0; i < images_dir.length; i++)
        {
            if (images_dir[i] == directory)
            {
                indexes += i;
            }
        }
        if (indexes.length == 0)
        {
            images_dir += directory;
            list_images(directory);
            settings.set_strv("images-dir", images_dir);
        }
    }

    // Drag Data
    private void on_drag_data_received(Gdk.DragContext drag_context, int x, int y, Gtk.SelectionData data, uint info, uint time)
    {
        foreach(string uri in data.get_uris())
        {
            string file;
            file = uri.replace("file://", "");
            file = Uri.unescape_string(file);
            string dirname = Path.get_dirname(file);
            add_images_from_selected(dirname);
        }
        Gtk.drag_finish(drag_context, true, false, time);
    }

    private void action_add()
    {
        var dialog = new Gtk.FileChooserDialog(_("Add folder"), window, Gtk.FileChooserAction.SELECT_FOLDER,
                                               _("Cancel"), Gtk.ResponseType.CANCEL,
                                               _("Open"), Gtk.ResponseType.ACCEPT);
        dialog.set_transient_for(window);
        if (dialog.run() == Gtk.ResponseType.ACCEPT)
        {
            string dirname = dialog.get_current_folder();
            add_images_from_selected(dirname);
        }
        dialog.destroy();
    }

    private void action_reset()
    {
        liststore.clear();
        images_dir = {"/usr/share/backgrounds"};
        list_images(images_dir[0]);
        view.grab_focus();
        settings.set_strv("images-dir", images_dir);
        GLib.Settings.sync();
    }

    private void action_show_menu()
    {
        menubutton.set_active(true);
    }

    private void action_about()
    {
        var about = new Gtk.AboutDialog();
        about.set_program_name(NAME);
        about.set_version(VERSION);
        about.set_comments(DESCRIPTION);
        about.set_logo_icon_name(ICON);
        about.set_authors(AUTHORS);
        about.set_copyright("Copyright \xc2\xa9 2015");
        about.set_website("https://github.com/simargl");
        about.set_property("skip-taskbar-hint", true);
        about.set_transient_for(window);
        about.license_type = Gtk.License.GPL_3_0;
        about.run();
        about.hide();
    }

    private void action_quit()
    {
        quit();
    }

    private static int main (string[] args)
    {
        Program app = new Program();
        return app.run(args);
    }
}
