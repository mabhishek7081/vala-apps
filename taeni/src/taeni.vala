/*  Author: simargl <https://github.com/simargl>
 *  License: GPL v3
 */

private class Program : Gtk.Application {
    const string NAME        = "Taeni";
    const string VERSION     = "2.2.0";
    const string DESCRIPTION = _("Multi-tabbed terminal emulator based on VTE");
    const string ICON        = "utilities-terminal";
    const string APP_ID      = "org.vala-apps.taeni";
    const string APP_ID_PREF = "org.vala-apps.taeni.preferences";
    const string[] AUTHORS   = { "Simargl <https://github.com/simargl>", null };

    Vte.Terminal term;
    Gtk.Dialog preferences;
    Gtk.Menu context_menu;
    Gtk.ApplicationWindow window;
    Gtk.Notebook notebook;
    Gtk.MenuButton menubutton;

    Gtk.FontButton preferences_font_button;
    Gtk.ColorButton preferences_bg_button;
    Gtk.ColorButton preferences_fg_button;

    string terminal_bgcolor;
    string terminal_fgcolor;
    string terminal_font;
    const int width = 752;
    const int height = 464;

    GLib.Settings settings;
    GLib.Pid child_pid;

    private const GLib.ActionEntry[] action_entries = {
        { "new-window",  action_new_window  },
        { "pref",        action_pref        },
        { "new-tab",     action_new_tab     },
        { "close-tab",   action_close_tab   },
        { "next-tab",    action_next_tab    },
        { "prev-tab",    action_prev_tab    },
        { "copy",        action_copy        },
        { "paste",       action_paste       },
        { "select-all",  action_select_all  },
        { "full-screen", action_full_screen },
        { "show-menu",   action_show_menu   },
        { "about",       action_about       },
        { "quit",        action_quit        }
    };

    private Program() {
        Object(application_id: APP_ID,
               flags: ApplicationFlags.HANDLES_COMMAND_LINE | ApplicationFlags.NON_UNIQUE);
        add_action_entries(action_entries, this);
    }

    public override void startup() {
        base.startup();
        set_accels_for_action("app.new-window",    {"<Primary><Shift>N"});
        set_accels_for_action("app.new-tab",       {"<Primary><Shift>T"});
        set_accels_for_action("app.close-tab",     {"<Primary><Shift>W"});
        set_accels_for_action("app.quit",          {"<Primary><Shift>Q", "<Primary>Q"});
        set_accels_for_action("app.next-tab",      {"<Primary>Page_Down", "<Primary>Tab"});
        set_accels_for_action("app.prev-tab",      {"<Primary>Page_Up"});
        set_accels_for_action("app.copy",          {"<Primary><Shift>C"});
        set_accels_for_action("app.paste",         {"<Primary><Shift>V"});
        set_accels_for_action("app.select-all",    {"<Primary><Shift>A"});
        set_accels_for_action("app.full-screen",   {"F11"});
        set_accels_for_action("app.show-menu",     {"<Primary>F10"});
    }

    public override void activate() {
        window.present();
    }

    public override int command_line(ApplicationCommandLine command_line) {
        var args = command_line.get_arguments();
        if (args[1] == "-h" || args[1] == "--help") {
            string USAGE = "%s\n  %s %s %s".printf("Usage:", NAME.down(), "[OPTION...] -",
                                                   DESCRIPTION);
            string OPTIONS =
                "Application Options:\n  -d Set working directory\n  -e Execute command\n  -v Print version number";
            print("%s\n\n%s\n\n".printf(USAGE, OPTIONS));
            return 0;
        }
        if (args[1] == "-v" || args[1] == "--version") {
            print("%s %s %s\n".printf(NAME, "version is", VERSION));
            return 0;
        }
        string path;
        if (args[1] == "-d") {
            path = args[2];
        } else {
            path = "";
        }
        window = add_new_window();
        create_tab(path);
        if (args[1] == "-e") {
            execute_command(args[2]);
        }
        return 0;
    }

    private Gtk.ApplicationWindow add_new_window() {
        settings = new GLib.Settings(APP_ID_PREF);
        terminal_bgcolor = settings.get_string("bgcolor");
        terminal_fgcolor = settings.get_string("fgcolor");
        terminal_font = settings.get_string("font");
        notebook = new Gtk.Notebook();
        notebook.expand = true;
        notebook.set_scrollable(true);
        notebook.set_show_tabs(false);
        notebook.set_can_focus(false);
        window = new Gtk.ApplicationWindow(this);
        Gdk.Geometry hints = Gdk.Geometry();
        hints.height_inc = 19;
        hints.width_inc = 10;
        window.set_geometry_hints(null, hints, Gdk.WindowHints.RESIZE_INC);
        window.set_default_size(width, height);
        window.set_title(NAME);
        window.add(notebook);
        window.set_icon_name(ICON);
        window.show_all();
        window.delete_event.connect(() => {
            action_quit();
            return true;
        });
        context_menu = new Gtk.Menu();
        add_popup_menu(context_menu);
        return window;
    }

    private void execute_command(string command) {
        term.feed_child(command + "\n", command.length + 1);
    }

    private void create_tab(string path) {
        term = new Vte.Terminal();
        term.set_scrollback_lines(4096);
        term.expand = true;
        term.set_cursor_blink_mode(Vte.CursorBlinkMode.OFF);
        term.set_cursor_shape(Vte.CursorShape.UNDERLINE);
        term.child_exited.connect(action_close_tab);
        term.button_press_event.connect(terminal_button_press);
        try {
            term.set_encoding("ISO-8859-1");
        } catch (Error e) {
            stderr.printf("error: %s\n", e.message);
        }
        try {
            term.spawn_sync(Vte.PtyFlags.DEFAULT, path, { Vte.get_user_shell() }, null,
                            SpawnFlags.SEARCH_PATH, null, out child_pid);
        } catch(Error e) {
            stderr.printf("error: %s\n", e.message);
        }
        var tab_label = new Gtk.Label("");
        tab_label.set_alignment(0, 0.5f);
        tab_label.set_hexpand(true);
        tab_label.set_size_request(100, -1);
        var eventbox = new Gtk.EventBox();
        eventbox.add(tab_label);
        var css_stuff = """ * { padding :0; } """;
        var provider = new Gtk.CssProvider();
        try {
            provider.load_from_data(css_stuff, css_stuff.length);
        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }
        var tab_button_close = new Gtk.Button.from_icon_name("window-close-symbolic",
                Gtk.IconSize.MENU);
        tab_button_close.set_relief(Gtk.ReliefStyle.NONE);
        tab_button_close.set_hexpand(false);
        tab_button_close.get_style_context().add_provider(provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        var tab = new Gtk.Grid();
        tab.attach(eventbox,   0, 0, 1, 1);
        tab.attach(tab_button_close, 1, 0, 1, 1);
        tab.set_hexpand(false);
        tab.show_all();
        var scrolled = new Gtk.ScrolledWindow(null, null);
        scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.ALWAYS);
        scrolled.add(term);
        scrolled.show_all();
        tab_button_close.clicked.connect(() => {
            term = get_current_terminal();
            int page_num = notebook.page_num(scrolled);
            notebook.remove_page(page_num);
            if (notebook.get_n_pages() == 1) {
                notebook.set_show_tabs(false);
            }
        });
        // Close tab with middle click
        eventbox.button_press_event.connect((event) => {
            if (event.button == 2) {
                term = get_current_terminal();
                int page_num = notebook.page_num(scrolled);
                notebook.remove_page(page_num);
                if (notebook.get_n_pages() == 1) {
                    notebook.set_show_tabs(false);
                }
            }
            return false;
        });
        term.window_title_changed.connect(() => {
            term = get_current_terminal();
            string dir = term.get_window_title();
            string dir_short = dir;
            if (dir.length > 22) {
                dir_short = dir.substring(0, 19) + "...";
            }
            tab_label.set_tooltip_text(dir);
            tab_label.set_text(dir_short);
        });
        notebook.append_page(scrolled, tab);
        if (notebook.get_n_pages() > 1) {
            notebook.set_show_tabs(true);
        }
        notebook.set_tab_reorderable(scrolled, true);
        notebook.set_current_page(notebook.get_n_pages() - 1);
        set_color_from_string(terminal_bgcolor, terminal_fgcolor);
        term.set_font(Pango.FontDescription.from_string(terminal_font));
        term.grab_focus();
    }

    // Context menu
    private void add_popup_menu(Gtk.Menu menu) {
        var context_new_window = new Gtk.MenuItem.with_label(_("New window"));
        context_new_window.activate.connect(action_new_window);
        var context_new_tab = new Gtk.MenuItem.with_label(_("New tab"));
        context_new_tab.activate.connect(action_new_tab);
        var context_separator1 = new Gtk.SeparatorMenuItem();
        var context_copy = new Gtk.MenuItem.with_label(_("Copy"));
        context_copy.activate.connect(action_copy);
        var context_paste = new Gtk.MenuItem.with_label(_("Paste"));
        context_paste.activate.connect(action_paste);
        var context_select_all = new Gtk.MenuItem.with_label(_("Select all"));
        context_select_all.activate.connect(action_select_all);
        var context_separator2 = new Gtk.SeparatorMenuItem();
        var context_full_screen = new Gtk.MenuItem.with_label(_("Full screen"));
        context_full_screen.activate.connect(action_full_screen);
        var context_separator3 = new Gtk.SeparatorMenuItem();
        var context_pref = new Gtk.MenuItem.with_label(_("Preferences"));
        context_pref.activate.connect(action_pref);
        var context_about = new Gtk.MenuItem.with_label(_("About"));
        context_about.activate.connect(action_about);
        var context_separator4 = new Gtk.SeparatorMenuItem();
        var context_close = new Gtk.MenuItem.with_label(_("Close tab"));
        context_close.activate.connect(action_close_tab);
        var context_quit = new Gtk.MenuItem.with_label(_("Quit"));
        context_quit.activate.connect(action_quit);
        menu.append(context_new_window);
        menu.append(context_new_tab);
        menu.append(context_separator1);
        menu.append(context_copy);
        menu.append(context_paste);
        menu.append(context_select_all);
        menu.append(context_separator2);
        menu.append(context_full_screen);
        menu.append(context_separator3);
        menu.append(context_pref);
        menu.append(context_about);
        menu.append(context_separator4);
        menu.append(context_close);
        menu.append(context_quit);
        menu.show_all();
    }

    private bool terminal_button_press(Gdk.EventButton event) {
        if (event.button == 3) {
            context_menu.popup (null, null, null, event.button, event.time);
        }
        return false;
    }

    private void set_color_from_string(string back, string text) {
        var bgcolor = Gdk.RGBA();
        var fgcolor = Gdk.RGBA();
        bgcolor.parse(back);
        fgcolor.parse(text);
        term.set_color_background(bgcolor);
        term.set_color_foreground(fgcolor);
    }

    private Gtk.Notebook get_current_notebook() {
        var window = this.get_active_window();
        notebook = (Gtk.Notebook) window.get_child();
        return notebook;
    }

    private Vte.Terminal get_current_terminal() {
        notebook = get_current_notebook();
        var widget = (Gtk.ScrolledWindow) notebook.get_nth_page(
                         notebook.get_current_page());
        term = (Vte.Terminal) widget.get_child();
        return term;
    }

    // Preferences dialog - on font change (1)
    private void font_changed() {
        notebook = get_current_notebook();
        terminal_font = preferences_font_button.get_font().to_string();
        for (int i = 0; i < notebook.get_n_pages(); i++) {
            var widget = (Gtk.ScrolledWindow) notebook.get_nth_page(i);
            term = (Vte.Terminal) widget.get_child();
            term.set_font(Pango.FontDescription.from_string(terminal_font));
        }
        settings.set_string("font", terminal_font);
    }

    // Preferences dialog - on background change (2)
    private void bg_color_changed() {
        notebook = get_current_notebook();
        var color = preferences_bg_button.get_rgba();;
        int r = (int)Math.round(color.red * 255);
        int g = (int)Math.round(color.green * 255);
        int b = (int)Math.round(color.blue * 255);
        terminal_bgcolor = "#%02x%02x%02x".printf(r, g, b).up();
        for (int i = 0; i < notebook.get_n_pages(); i++) {
            var widget = (Gtk.ScrolledWindow) notebook.get_nth_page(i);
            term = (Vte.Terminal) widget.get_child();
            set_color_from_string(terminal_bgcolor, terminal_fgcolor);
        }
        settings.set_string("bgcolor", terminal_bgcolor);
    }

    // Preferences dialog - on foreground change (3)
    private void fg_color_changed() {
        notebook = get_current_notebook();
        var color = preferences_fg_button.get_rgba();;
        int r = (int)Math.round(color.red * 255);
        int g = (int)Math.round(color.green * 255);
        int b = (int)Math.round(color.blue * 255);
        terminal_fgcolor = "#%02x%02x%02x".printf(r, g, b).up();
        for (int i = 0; i < notebook.get_n_pages(); i++) {
            var widget = (Gtk.ScrolledWindow) notebook.get_nth_page(i);
            term = (Vte.Terminal) widget.get_child();
            set_color_from_string(terminal_bgcolor, terminal_fgcolor);
        }
        settings.set_string("fgcolor", terminal_fgcolor);
    }

    private void action_new_window() {
        window = add_new_window();
        create_tab("");
    }

    // Preferences dialog
    private void action_pref() {
        var preferences_font_label = new Gtk.Label(_("Font"));
        preferences_font_button = new Gtk.FontButton();
        preferences_font_button.font_name = term.get_font().to_string();
        preferences_font_button.font_set.connect(font_changed);
        var rgba_bgcolor = Gdk.RGBA();
        var rgba_fgcolor = Gdk.RGBA();
        rgba_bgcolor.parse(terminal_bgcolor);
        rgba_fgcolor.parse(terminal_fgcolor);
        var preferences_bg_label = new Gtk.Label(_("Background"));
        preferences_bg_button = new Gtk.ColorButton.with_rgba(rgba_bgcolor);
        preferences_bg_button.color_set.connect(bg_color_changed);
        var preferences_fg_label = new Gtk.Label(_("Foreground"));
        preferences_fg_button = new Gtk.ColorButton.with_rgba(rgba_fgcolor);
        preferences_fg_button.color_set.connect(fg_color_changed);
        var preferences_grid = new Gtk.Grid();
        preferences_grid.set_column_spacing(20);
        preferences_grid.set_row_spacing(10);
        preferences_grid.set_border_width(10);
        preferences_grid.set_row_homogeneous(true);
        preferences_grid.set_column_homogeneous(true);
        preferences_grid.attach(preferences_font_label, 0, 0, 1, 1);
        preferences_grid.attach(preferences_font_button, 1, 0, 1, 1);
        preferences_grid.attach(preferences_bg_label, 0, 1, 1, 1);
        preferences_grid.attach(preferences_bg_button, 1, 1, 1, 1);
        preferences_grid.attach(preferences_fg_label, 0, 2, 1, 1);
        preferences_grid.attach(preferences_fg_button, 1, 2, 1, 1);
        var window = this.get_active_window();
        preferences = new Gtk.Dialog();
        preferences.set_property("skip-taskbar-hint", true);
        preferences.set_transient_for(window);
        preferences.set_resizable(false);
        preferences.set_title(_("Preferences"));
        var content = preferences.get_content_area() as Gtk.Container;
        content.add(preferences_grid);
        preferences.show_all();
    }

    private void action_new_tab() {
        notebook = get_current_notebook();
        create_tab("");
    }

    private void action_close_tab() {
        notebook = get_current_notebook();
        notebook.remove_page(notebook.get_current_page());
        if (notebook.get_n_pages() == 0) {
            action_quit();
        }
        if (notebook.get_n_pages() == 1) {
            notebook.set_show_tabs(false);
        }
    }

    private void action_prev_tab() {
        notebook = get_current_notebook();
        if (notebook.get_n_pages()> 1) {
            get_current_terminal();
            notebook.set_current_page(notebook.get_current_page() - 1);
        }
    }

    private void action_next_tab() {
        notebook = get_current_notebook();
        if (notebook.get_n_pages()> 1) {
            get_current_terminal();
            if ((notebook.get_current_page() + 1)  == notebook.get_n_pages()) {
                notebook.set_current_page(0);
            } else {
                notebook.set_current_page(notebook.get_current_page() + 1);
            }
        }
    }

    private void action_copy() {
        get_current_terminal();
        term.copy_clipboard();
        term.grab_focus();
    }

    private void action_paste() {
        get_current_terminal();
        term.paste_clipboard();
        term.grab_focus();
    }

    private void action_select_all() {
        get_current_terminal();
        term.select_all();
        term.grab_focus();
    }

    private void action_full_screen() {
        var window = this.get_active_window();
        if ((window.get_window().get_state() & Gdk.WindowState.FULLSCREEN) != 0) {
            window.unfullscreen();
        } else {
            window.fullscreen();
        }
    }

    private void action_show_menu() {
        var window = this.get_active_window();
        if ((window.get_window().get_state() & Gdk.WindowState.FULLSCREEN) == 0) {
            menubutton.set_active(true);
        }
    }

    private void action_about() {
        var window = this.get_active_window();
        var about = new Gtk.AboutDialog();
        about.set_program_name(NAME);
        about.set_version(VERSION);
        about.set_comments(DESCRIPTION);
        about.set_logo_icon_name(ICON);
        about.set_icon_name(ICON);
        about.set_authors(AUTHORS);
        about.set_copyright("Copyright \xc2\xa9 2015");
        about.set_website("https://github.com/simargl");
        about.set_property("skip-taskbar-hint", true);
        about.set_transient_for(window);
        about.license_type = Gtk.License.GPL_3_0;
        about.run();
        about.hide();
    }

    private void action_quit() {
        var window = this.get_active_window();
        remove_window(window);
        window.destroy();
    }

    private static int main (string[] args) {
        Program app = new Program();
        return app.run(args);
    }
}
