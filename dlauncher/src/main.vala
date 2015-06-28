/*  Author: simargl <https://github.com/simargl>
 *  License: GPL v3
 */

namespace Dlauncher
{
Gtk.ApplicationWindow window;
Gtk.IconView view;
Gtk.TreeIter iter;
Gtk.ListStore liststore;

public class Application: Gtk.Application
{
    const string NAME        = "Dlauncher";
    const string VERSION     = "0.0.1";
    const string DESCRIPTION = _("Desktop file launcher");
    const string[] AUTHORS   = { "Simargl <https://github.com/simargl>", null };

    private const GLib.ActionEntry[] action_entries =
    {
        { "quit", action_quit }
    };

    public Application()
    {
        Object(application_id: "org.dlauncher.window");
        add_action_entries(action_entries, this);
    }

    public override void startup()
    {
        base.startup();

        set_accels_for_action("app.quit", {"Escape"});

        liststore = new Gtk.ListStore(4, typeof (Gdk.Pixbuf), typeof (string), typeof (string), typeof (string));

        view = new Gtk.IconView.with_model(liststore);
        view.set_pixbuf_column(0);
        view.set_text_column(1);
        view.set_tooltip_column(2);
        view.set_item_width(72);
        view.set_row_spacing(22);
        view.set_selection_mode(Gtk.SelectionMode.BROWSE);
        view.set_activate_on_single_click(true);
        view.item_activated.connect(icon_clicked);
        view.override_font(Pango.FontDescription.from_string("10"));

        var cache = new Dlauncher.Cache();
        cache.list_applications();

        var scrolled = new Gtk.ScrolledWindow(null, null);
        scrolled.add(view);

        int height = Gdk.Screen.height();

        window = new Gtk.ApplicationWindow(this);
        window.add(scrolled);
        window.set_decorated(false);
        window.set_has_resize_grip(false);
        window.set_property("skip-taskbar-hint", true);
        window.set_default_size(610, 390);
        window.move(20, height - 390 - 50);
        window.stick();
        window.focus_out_event.connect(() =>
        {
            action_quit();
            return false;
        });
    }

    public override void activate()
    {
        if (window.get_visible() == true)
        {
            action_quit();
        }
        else
        {
            window.show_all();
            window.present();
        }
    }

    public void icon_clicked()
    {
        var model = new Dlauncher.Model();
        model.exec_selected();
    }

    public void action_quit()
    {
        window.hide();
        quit();
    }

    public static int main (string[] args)
    {
        var app = new Dlauncher.Application();
        return app.run(args);
    }
}
}
