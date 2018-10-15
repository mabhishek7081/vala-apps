namespace Vestigo {
public class Window: Gtk.ApplicationWindow {
    private const GLib.ActionEntry[] action_entries = {
        { "go-up",         action_go_to_up_directory   },
        { "go-home",       action_go_to_home_directory },
        { "create-folder", action_create_folder        },
        { "create-file",   action_create_file          },
        { "add-bookmark",  action_add_bookmark         },
        { "terminal",      action_terminal             },
        { "cut",           action_cut                  },
        { "copy",          action_copy                 },
        { "rename",        action_rename               },
        { "delete",        action_delete               },
        { "properties",    action_properties           },
        { "paste",         action_paste                },
        { "about",         action_about                },
        { "quit",          action_quit                 }
    };

    public void add_app_window(Gtk.Application app) {
        app.add_action_entries(action_entries, app);
        var menu = new GLib.Menu();
        var section = new GLib.Menu();
        section.append("Create folder", "app.create-folder");
        section.append("Create file",  "app.create-file");
        menu.append_section(null, section);
        section = new GLib.Menu();
        section.append("Paste", "app.paste");
        menu.append_section(null, section);
        section = new GLib.Menu();
        section.append("Add to Bookmarks", "app.add-bookmark");
        section.append("Open in Terminal", "app.terminal");
        menu.append_section(null, section);
        section = new GLib.Menu();
        section.append("About", "app.about");
        section.append("Quit",  "app.quit");
        menu.append_section(null, section);
        app.set_app_menu(menu);
        app.set_accels_for_action("app.go-up",            {"BackSpace"});
        app.set_accels_for_action("app.go-home",          {"<Alt>Home"});
        app.set_accels_for_action("app.create-folder",    {"<Control>N"});
        app.set_accels_for_action("app.create-file",      {"<Control><Shift>N"});
        app.set_accels_for_action("app.terminal",         {"F4"});
        app.set_accels_for_action("app.cut",              {"<Control>X"});
        app.set_accels_for_action("app.copy",             {"<Control>C"});
        app.set_accels_for_action("app.rename",           {"F2"});
        app.set_accels_for_action("app.paste",            {"<Control>V"});
        app.set_accels_for_action("app.delete",           {"Delete"});
        app.set_accels_for_action("app.properties",       {"<Control>I"});
        app.set_accels_for_action("app.quit",             {"<Control>Q"});        
        new Vestigo.Settings().get_settings();
        window = new Gtk.ApplicationWindow(app);
        add_widgets(window);
        connect_signals(window);
        var tmpfile = GLib.File.new_for_path("/tmp/.vestigo.lock");
        try {
            FileOutputStream os = tmpfile.create(FileCreateFlags.NONE);
            os.close();
        } catch (Error e) {
            stdout.printf ("Error: %s\n", e.message);
        }
    }

    private void add_widgets(Gtk.ApplicationWindow appwindow) {
        places = new Gtk.PlacesSidebar();
        places.width_request = 180;
        places.vexpand = true;
        places.hexpand = false;
        places.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.NEVER);
        var button_up = new Gtk.Button.with_label("Up Directory");
        button_up.set_always_show_image(true);
        button_up.set_image(new Gtk.Image.from_icon_name("go-up-symbolic",
                            Gtk.IconSize.MENU));
        button_up.set_relief(Gtk.ReliefStyle.NONE);
        button_up.set_alignment(0.0f, 0.0f);
        button_up.clicked.connect(() => {
            action_go_to_up_directory();
        });
        button_up.get_style_context().add_class("button_up");
        var places_grid = new Gtk.Grid();
        places_grid.attach(button_up, 0, 0, 1, 1);
        places_grid.attach(places,    0, 1, 1, 1);
        model = new Gtk.ListStore(4, typeof (Gdk.Pixbuf), typeof (string),
                                  typeof (string), typeof (string));
        view = new Gtk.IconView.with_model(model);
        view.set_pixbuf_column(0);
        view.set_text_column(1);
        view.set_tooltip_column(3);
        view.set_column_spacing(3);
        view.set_item_width(70);
        view.set_activate_on_single_click(true);
        view.set_selection_mode(Gtk.SelectionMode.MULTIPLE);
        view.enable_model_drag_source(Gdk.ModifierType.BUTTON1_MASK, targets, Gdk.DragAction.COPY);
        view.drag_data_get.connect(drag_source_operation);
        view.drag_data_received.connect(on_drag_data_received);
        Gtk.drag_dest_set(view, Gtk.DestDefaults.ALL, targets, Gdk.DragAction.COPY);
        var css_stuff =
            """
            placessidebar row { min-height: 25px; }
            iconview:hover { color: black; background-color: #EEEEEE; border-radius: 3%; }
            iconview:selected:hover { color: #ffffff; background-color: #4a90d9; border-radius: 3%; }
            .button_up { color: black; background-color: #f4f4f4; border-right-width: 0.5px; border-right-color: grey;
                 color: black; background-color: #f4f4f4; transition: none; padding-top: 3px; padding-bottom: 0px;
                 padding-left: 14px; padding-right: 10px; }
            .button_up:hover { background-image: none; border-color: transparent; color: black; box-shadow: none;
                 border-right-width: 0.5px; border-right-color: grey; background-color: #ebebea; }
            .button_up:focus { background-color: #4a90d9; color: white; border-right-width: 0.5px; border-right-color: grey; }
            .button_up label { padding-left: 6px; }
        """;
        var provider = new Gtk.CssProvider();
        try {
            provider.load_from_data(css_stuff, css_stuff.length);
        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        Gtk.Settings.get_default().gtk_theme_name = "Adwaita";
        var scrolled = new Gtk.ScrolledWindow(null, null);
        scrolled.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrolled.add(view);
        scrolled.expand = true;
        scrolled.width_request = 250;
        statusbar = new Gtk.Statusbar();
        context_id = statusbar.get_context_id("vestigo");
		statusbar.push(context_id, "Starting up...");
        var grid = new Gtk.Grid();
        grid.attach(places_grid, 0, 0, 1, 1);
        grid.attach(scrolled,    1, 0, 1, 1);
        grid.attach(statusbar,   0, 1, 2, 1);
        window.add(grid);
        window.set_title(NAME);
        window.set_default_size(width, height);
        window.set_icon_name(ICON);
        window.show_all();
        }

        private void drag_source_operation(Gdk.DragContext ctx, Gtk.SelectionData data, uint info, uint time_) {
            var path = view.get_selected_items().nth_data(0);
            var model = view.get_model();
            Gtk.TreeIter iter;
            model.get_iter(out iter, path);
            GLib.Value filepath;
            model.get_value(iter, 2, out filepath);
            string[] uris = {""};
            uris[0] = filepath.get_string();
            data.set_uris(uris);
        }

        private void on_drag_data_received (Gdk.DragContext ctx, int x, int y, Gtk.SelectionData data, uint info, uint time) {
            print("received");
        }

        private void connect_signals(Gtk.ApplicationWindow appwindow) {
            places.open_location.connect(() => {
                new Vestigo.IconView().open_location(places.get_location(), true);
            });
            view.item_activated.connect(() => {
                (new Vestigo.IconView().icon_clicked());
            });
            view.selection_changed.connect(() => {
                (new Vestigo.IconView().on_selection_changed());
            });
            view.key_press_event.connect(on_key_press_event);
            view.button_press_event.connect(context_menu_activate);
            window.delete_event.connect(() => {
                action_quit();
                return true;
            });
        }

        private bool on_key_press_event(Gdk.EventKey event) {
            if (Gdk.keyval_name(event.keyval) == "Escape") {
                view.unselect_all();
            }
            string match = event.str;
            if (match != "") {
                var model = view.get_model();
                GLib.Value val;
                var paths = new List<Gtk.TreePath>();
                int i = 0;
                while (i < model.iter_n_children(null)) {
                    var path = new Gtk.TreePath.from_indices(i, -1);
                    model.get_iter(out iter, path);
                    model.get_value(iter, 3, out val);
                    string strval = val.get_string();
                    if (strval.substring(0, 1).down() == match.down()) {
                        paths.append(path);
                    }
                    i++;
                }
                if (paths.length() == 0) {
                    return false;
                }
                var test = view.get_selected_items().nth_data(0);
                if (test == null) {
                    view.select_path(paths.first().data);
                    view.set_cursor(paths.first().data, null, false);
                    view.scroll_to_path(paths.first().data, false, 0, 0);
                } else {                
                    uint len = paths.length();
                    unowned List<Gtk.TreePath> last = paths.nth(len-1);
                    paths.delete_link(last);
                    foreach(Gtk.TreePath j in paths) {
                        if (j.to_string() == test.to_string()) {
                            j.next();
                            view.unselect_path(test);
                            view.select_path(j);
                            view.set_cursor(j, null, false);
                            view.scroll_to_path(j, false, 0, 0);
                        }
                    }
                }
            }
            return false;
        }

        private bool context_menu_activate(Gdk.EventButton event) {
            Gtk.TreePath? path = null;
            if (event.button == 3) {
                var selection = new GLib.List<string>();
                selection = new Vestigo.Operations().get_files_selection();
                uint len_s = selection.length();
                if (len_s == 1) {
                    view.unselect_all();
                }
                path = view.get_path_at_pos((int) event.x, (int) event.y);
                if (path != null) {
                    view.select_path(path);
                    menu = new Vestigo.Menu().activate_file_menu();
                    menu.popup (null, null, null, event.button, event.time);
                } else {
                    view.unselect_all();
                    menu = new Vestigo.Menu().activate_context_menu();
                    menu.popup (null, null, null, event.button, event.time);
                }
            }
            return false;
        }

        private void action_create_folder() {
            new Vestigo.Operations().make_new(false);
        }

        private void action_create_file() {
            new Vestigo.Operations().make_new(true);
        }

        private void action_add_bookmark() {
            new Vestigo.Operations().add_bookmark();
        }

        private void action_go_to_up_directory() {
            new Vestigo.IconView().open_location(GLib.File.new_for_path(
                    GLib.Path.get_dirname(current_dir)), true);
        }

        private void action_go_to_home_directory() {
            string home = GLib.Environment.get_home_dir();
            new Vestigo.IconView().open_location(GLib.File.new_for_path(home), true);
        }

        private void action_terminal() {
            new Vestigo.Operations().execute_command_async("%s '%s'".printf(terminal,
                    current_dir));
        }

        private void action_cut() {
            new Vestigo.Operations().file_cut_activate();
        }

        private void action_copy() {
            new Vestigo.Operations().file_copy_activate();
        }

        private void action_rename() {
            new Vestigo.Operations().file_rename_activate();
        }

        private void action_delete() {
            new Vestigo.Operations().file_delete_activate();
        }

        private void action_properties() {
            new Vestigo.Operations().file_properties_activate();
        }

        private void action_paste() {
            new Vestigo.Operations().file_paste_activate();
        }

        private void action_about() {
            var about = new Gtk.AboutDialog();
            about.set_program_name(NAME);
            about.set_version(VERSION);
            about.set_comments(DESCRIPTION);
            about.set_logo_icon_name(ICON);
            about.set_authors(AUTHORS);
            about.set_copyright("Copyright \xc2\xa9 2018");
            about.set_website("https://github.com/simargl");
            about.set_property("skip-taskbar-hint", true);
            about.set_transient_for(window);
            about.license_type = Gtk.License.GPL_3_0;
            about.run();
            about.hide();
        }

        private void action_quit() {
            File tmpfile = File.new_for_path("/tmp/.vestigo.lock");
            try {
                tmpfile.delete();
            } catch (Error e) {
                stdout.printf("Error: %s\n", e.message);
            }
            new Vestigo.Settings().save_settings();
            window.get_application().quit();
        }
    }
}
