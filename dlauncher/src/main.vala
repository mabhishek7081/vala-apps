/*  Author: simargl <https://github.com/simargl>
 *  License: GPL v3
 */

namespace Dlauncher {

Gtk.IconView view;
Gtk.ListStore liststore;
Gtk.TreeIter iter;
Gtk.TreeModelFilter filter;

public class Application: Gtk.Application {
    const string NAME        = "Dlauncher";
    const string VERSION     = "0.0.1";
    const string DESCRIPTION = "Application launcher";
    const string[] AUTHORS   = { "Simargl <https://github.com/simargl>", null };

    Gtk.ApplicationWindow window;
    Gtk.Entry entry;

    private int width = 490;
    private int height = 460;

    private const GLib.ActionEntry[] action_entries = {
        { "quit", action_quit }
    };

    public Application() {
        Object(application_id: "org.dlauncher.window");
        add_action_entries(action_entries, this);
    }

    public override void startup() {
        base.startup();
#if GTK_3_22
        set_accels_for_action("app.quit", {"Escape"});
#else
        add_accelerator("Escape", "app.quit", null);
#endif
        entry = new Gtk.Entry();
        entry.hexpand = true;
        entry.height_request = 36;
        entry.set_placeholder_text("Search");
#if GTK_3_22
        entry.primary_icon_name = "system-search-symbolic";
        entry.secondary_icon_name = "edit-clear-symbolic";
#else
        entry.primary_icon_name = "edit-find";
        entry.secondary_icon_name = "edit-clear";
#endif
        entry.secondary_icon_activatable = true;
        entry.icon_press.connect((position, event) => {
            if (position == Gtk.EntryIconPosition.SECONDARY) {
                entry.text = "";
            }
        });
        entry.changed.connect(on_entry_changed);
        entry.activate.connect(on_entry_activated);
        liststore = new Gtk.ListStore(4, typeof (Gdk.Pixbuf), typeof (string),
                                      typeof (string), typeof (string));
        filter = new Gtk.TreeModelFilter(liststore, null);
        filter.set_visible_func(filter_func);
        view = new Gtk.IconView.with_model(filter);
        view.set_pixbuf_column(0);
        view.set_text_column(1);
        view.set_tooltip_column(2);
        view.set_item_width(72);
        view.set_row_spacing(22);
        view.set_selection_mode(Gtk.SelectionMode.BROWSE);
        view.set_activate_on_single_click(true);
        view.item_activated.connect(icon_clicked);
        var css_stuff =
            """ iconview:hover { color: black; background-color: #EEEEEE; border-radius: 3%; } """;
        var provider = new Gtk.CssProvider();
        try {
            provider.load_from_data(css_stuff, css_stuff.length);
        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }
        view.get_style_context().add_provider(provider,
                                              Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        var cache = new Dlauncher.Cache();
        cache.list_applications();
        var scrolled = new Gtk.ScrolledWindow(null, null);
        scrolled.add(view);
        scrolled.expand = true;
        var grid = new Gtk.Grid();
        grid.attach(entry,  0, 0,  1, 1);
        grid.attach(scrolled,  0, 1, 1, 1);
        window = new Gtk.ApplicationWindow(this);
        window.add(grid);
        window.set_decorated(false);
        //window.set_resizable(false);
        window.set_keep_above(true);
        window.set_property("skip-taskbar-hint", true);
        window.set_default_size(width, height);
        window.stick();
        window.focus_out_event.connect(() => {
            action_quit();
            return false;
        });
        entry.grab_focus();
    }

    public override void activate() {
        if (window.get_visible() == true) {
            action_quit();
        } else {
            window.realize();
            window.show_all();
            window.present();
            int rh;
            var root_window = Gdk.get_default_root_window();
            root_window.get_geometry(null, null, null, out rh);
            window.move(0, rh - height - 36);
        }
    }

    // refilter on entry change
    void on_entry_changed() {
        filter.refilter();
    }

    // activate first item in filtered list
    void on_entry_activated() {
        filter.get_iter_first(out iter);
        GLib.Value val;
        filter.get_value(iter, 3, out val);
        var model = new Dlauncher.Model();
        model.spawn_command((string)val);
        action_quit();
    }

    private bool filter_func(Gtk.TreeModel m, Gtk.TreeIter iter) {
        string search = entry.get_text().down();
        if(search != "") {
            GLib.Value val;
            string strval;
            liststore.get_value(iter, 2, out val);
            strval = val.get_string();
            if (strval.contains(search) == false) {
                liststore.get_value(iter, 3, out val);
                strval = val.get_string();
            }
            return strval.contains(search);
        } else {
            return true;
        }
    }

    public void icon_clicked() {
        var model = new Dlauncher.Model();
        model.exec_selected();
        action_quit();
    }

    public void action_quit() {
        window.hide();
        quit();
    }

    public static int main (string[] args) {
        var app = new Dlauncher.Application();
        return app.run(args);
    }
}
}
