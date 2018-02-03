namespace Vestigo {
public class Window: Gtk.ApplicationWindow {
    private const GLib.ActionEntry[] action_entries = {
        { "go-prev",       action_go_to_prev_directory },
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
        { "paste",         action_paste                },
        { "about",         action_about                },
        { "quit",          action_quit                 }
    };

    public void add_app_window(Gtk.Application app) {
        app.add_action_entries(action_entries, app);
        var menu = new GLib.Menu();
        var section = new GLib.Menu();
        section.append(_("Previous Directory"),  "app.go-prev");
        section.append(_("Up Directory"),  "app.go-up");
        section.append(_("Home Directory"),  "app.go-home");
        menu.append_section(null, section);
        section = new GLib.Menu();
        section.append(_("Create folder"), "app.create-folder");
        section.append(_("Create file"),  "app.create-file");
        section.append(_("Add to Bookmarks"), "app.add-bookmark");
        section.append(_("Open in Terminal"),  "app.terminal");
        menu.append_section(null, section);
        section = new GLib.Menu();
        section.append(_("About"), "app.about");
        section.append(_("Quit"),  "app.quit");
        menu.append_section(null, section);
        app.set_app_menu(menu);
        app.add_accelerator("<Alt>Left",  "app.go-prev", null);
        app.add_accelerator("BackSpace",  "app.go-up", null);
        app.add_accelerator("<Alt>Home",  "app.go-home", null);
        app.add_accelerator("F4",         "app.terminal", null);
        app.add_accelerator("<Control>X", "app.cut", null);
        app.add_accelerator("<Control>C", "app.copy", null);
        app.add_accelerator("F2",         "app.rename", null);
        app.add_accelerator("<Control>V", "app.paste", null);
        app.add_accelerator("Delete",     "app.delete", null);
        app.add_accelerator("<Control>Q", "app.quit", null);
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
        places.set_show_trash(false);
        places.width_request = 200;
        places.expand = false;
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
        var css_stuff =
            """ iconview:hover { color: black; background-color: #EEEEEE; border-radius: 3%; } 
                iconview:selected:hover { color: #ffffff; background-color: #4a90d9; border-radius: 3%; }
            """;
        var provider = new Gtk.CssProvider();
        try {
            provider.load_from_data(css_stuff, css_stuff.length);
        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }
        view.get_style_context().add_provider(provider,
                                              Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        var scrolled = new Gtk.ScrolledWindow(null, null);
        scrolled.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrolled.add(view);
        scrolled.expand = true;
        var grid = new Gtk.Grid();
        grid.attach(places,   0, 0, 1, 1);
        grid.attach(scrolled, 1, 0, 1, 1);
        window.add(grid);
        window.set_title(NAME);
        window.set_default_size(width, height);
        window.set_icon_name(ICON);
        window.show_all();
    }

    private void connect_signals(Gtk.ApplicationWindow appwindow) {
        places.open_location.connect(() => {
            new Vestigo.IconView().open_location(places.get_location(), true);
        });
        view.item_activated.connect(() => {
            (new Vestigo.IconView().icon_clicked());
        });
        view.button_press_event.connect(context_menu_activate);
        window.delete_event.connect(() => {
            action_quit();
            return true;
        });
    }

    private bool context_menu_activate(Gdk.EventButton event) {
        Gtk.TreePath? path = null;
        if (event.button == 3) {
            path = view.get_path_at_pos((int) event.x, (int) event.y);
            if (path != null) {
                view.select_path(path);
                menu = new Vestigo.Menu().activate_file_menu();
                menu.popup(null, null, null, event.button, event.time);
            } else {
                view.unselect_all();
                menu = new Vestigo.Menu().activate_context_menu();
                menu.popup(null, null, null, event.button, event.time);
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

    private void action_go_to_prev_directory() {
        new Vestigo.IconView().go_to_prev_directory();
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
