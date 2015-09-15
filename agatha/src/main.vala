/*  Author: simargl <https://github.org/simargl>
 *  License: GPL v3
 */

namespace Agatha
{
Gtk.ApplicationWindow window;
Gtk.Image image;
Gtk.ScrolledWindow scrolled;
GLib.Settings settings;
Gtk.Menu popup;

string filename;
int cpage;
int total;

const string NAME        = "Agatha";
const string VERSION     = "0.0.1";
const string DESCRIPTION = _("PDF Viewer in GTK3 and Poppler");
const string ICON        = "evince";
const string[] AUTHORS   = { "Simargl <archpup-at-gmail-dot-com>", null };

int x_start;
int y_start;
int x_current;
int y_current;
int x_end;
int y_end;
bool dragging;
double hadj_value;
double vadj_value;
    
Gtk.Adjustment hadj;
Gtk.Adjustment vadj;
    
public class Application: Gtk.Application
{
    private const GLib.ActionEntry[] action_entries =
    {
        { "previous-page",        action_previous_page        },
        { "next-page",            action_next_page            },
        { "scroll-up",            action_scroll_up            },
        { "scroll-down",          action_scroll_down          },
        { "page-up",              action_page_up              },
        { "page-down",            action_page_down            },
        { "zoom-plus",            action_zoom_plus            },
        { "zoom-minus",           action_zoom_minus           },
        { "full-screen-toggle",   action_full_screen_toggle   },
        { "open",                 action_open                 },
        { "goto",                 action_goto                 },
        { "about",                action_about                },
        { "quit",                 action_quit                 }
    };

    public Application()
    {
        Object(application_id: "org.example.window", flags: GLib.ApplicationFlags.HANDLES_OPEN | GLib.ApplicationFlags.NON_UNIQUE);
        add_action_entries(action_entries, this);
    }

    public override void startup()
    {
        base.startup();

        var settings = new Agatha.Settings();
        settings.get_all();

        // accelerator
        add_accelerator("Left",        "app.previous-page", null);
        add_accelerator("Right",       "app.next-page", null);
        add_accelerator("Up",          "app.scroll-up", null);
        add_accelerator("Down",        "app.scroll-down", null);        
        add_accelerator("Page_Up",     "app.page-up", null);
        add_accelerator("Page_Down",   "app.page-down", null);
        add_accelerator("KP_Add",      "app.zoom-plus", null);
        add_accelerator("KP_Subtract", "app.zoom-minus", null);
        add_accelerator("F11",         "app.full-screen-toggle", null);
        add_accelerator("<Control>O",  "app.open", null);
        add_accelerator("<Control>G",  "app.goto", null);
        add_accelerator("<Control>Q",  "app.quit", null);

        // context menu
        var menu_popup = new GLib.Menu();
        menu_popup.append(_("Open"), "app.open");
        menu_popup.append(_("Go to page"), "app.goto");
        menu_popup.append(_("About"), "app.about");
        menu_popup.append(_("Quit"), "app.quit");        

        // widgets
        image = new Gtk.Image();

        scrolled = new Gtk.ScrolledWindow(null, null);
        scrolled.get_style_context().add_class(Gtk.STYLE_CLASS_VIEW);
        scrolled.add(image);
        scrolled.scroll_event.connect(button_scroll_event);

        hadj = scrolled.get_hadjustment();
        vadj = scrolled.get_vadjustment();

        var eventbox = new Gtk.EventBox();
        eventbox.add(scrolled);
        eventbox.show();
        eventbox.add_events(Gdk.EventMask.POINTER_MOTION_MASK
                            | Gdk.EventMask.BUTTON_PRESS_MASK
                            | Gdk.EventMask.BUTTON_RELEASE_MASK);
        eventbox.button_press_event.connect(button_press_event);
        eventbox.motion_notify_event.connect(button_motion_event);
        eventbox.button_release_event.connect(button_release_event);

        window = new Gtk.ApplicationWindow(this);
        window.window_position = Gtk.WindowPosition.CENTER;
        window.add(eventbox);
        window.set_icon_name(ICON);
        window.set_default_size(width, height);
        window.show_all();

        window.delete_event.connect(() =>
        {
            action_quit();
            return true;
        });

        popup = new Gtk.Menu.from_model(menu_popup);
        popup.attach_to_widget(window, null);
        
        if (last_file != "")
        {
            File file = File.new_for_path(last_file);
            if (file.query_exists() == true) {
                filename = last_file;
                cpage = last_page;
                var viewer = new Agatha.Viewer();
                viewer.open_file();
            }
        }
    }

    public override void activate()
    {
        window.present();
    }

    public override void open(File[] files, string hint)
    {
        foreach (File f in files)
        filename = f.get_path();

        cpage = 0;
        var viewer = new Agatha.Viewer();
        viewer.open_file();

        window.present();
    }
    
    // Mouse EventButton Press
    private bool button_press_event(Gdk.EventButton event)
    {
        if (event.button == 3)
            popup.popup(null, null, null, 0, Gtk.get_current_event_time());
        if (event.button == 1 && event.type == Gdk.EventType.2BUTTON_PRESS)
            action_full_screen_toggle();
        if (event.button == 1 || event.button == 2)
        {
            var device = Gtk.get_current_event_device();
            if(device != null)
            {
                event.window.get_device_position(device, out x_start, out y_start, null);
                event.window.set_cursor(new Gdk.Cursor.for_display(Gdk.Display.get_default(), Gdk.CursorType.FLEUR));
            }
            dragging = true;
            hadj_value = hadj.get_value();
            vadj_value = vadj.get_value();
        }
        return true;
    }

    // motion
    private bool button_motion_event(Gdk.EventMotion event)
    {
        if (dragging == true)
        {
            var device = Gtk.get_current_event_device();
            if (device != null)
                event.window.get_device_position(device, out x_current, out y_current, null);

            int x_diff = x_start - x_current;
            int y_diff = y_start - y_current;

            hadj.set_value(hadj_value + x_diff);
            vadj.set_value(vadj_value + y_diff);
        }
        return false;
    }
    
    // release
    private bool button_release_event(Gdk.EventButton event)
    {
        if (event.type == Gdk.EventType.BUTTON_RELEASE)
        {
            if (event.button == 1 || event.button == 2)
            {
                var device = Gtk.get_current_event_device();
                if(device != null)
                {
                    event.window.get_device_position(device, out x_end, out y_end, null);
                    event.window.set_cursor(null);
                }
                dragging = false;
            }
        }
        return false;
    }

    // Mouse EventButton Scroll
    private bool button_scroll_event(Gdk.EventScroll event)
    {
        double direction = event.delta_y;
        if (direction < 0)
            action_scroll_up();
        else
            action_scroll_down();
        return false;
    }

    private void action_previous_page()
    {
        cpage--;

        var viewer = new Agatha.Viewer();
        viewer.render_page(cpage);
    }

    private void action_next_page()
    {
        cpage++;

        var viewer = new Agatha.Viewer();
        viewer.render_page(cpage);
    }

    private void action_page_up()
    {
        vadj_value = vadj.get_value();
        if (vadj_value == 0)
            action_previous_page();
        else
            vadj.set_value(vadj.get_value() - vadj.get_page_increment());
    }

    private void action_page_down()
    {
        vadj_value = vadj.get_value();
        if (vadj_value == vadj.get_upper() - vadj.get_page_size() )
            action_next_page();
        else
            vadj.set_value(vadj.get_value() + vadj.get_page_increment());
    }

    private void action_scroll_up()
    {
        vadj_value = vadj.get_value();
        if (vadj_value == 0)
            action_previous_page();
        else
            vadj.set_value(vadj.get_value() - vadj.get_page_increment() / 10);
    }

    private void action_scroll_down()
    {
        vadj_value = vadj.get_value();
        if (vadj_value == vadj.get_upper() - vadj.get_page_size() )
            action_next_page();
        else
            vadj.set_value(vadj.get_value() + vadj.get_page_increment() / 10);
    }

    private void action_zoom_plus()
    {
        var page_zoom = new Agatha.PageZoom();
        page_zoom.zoom_plus();
    }

    private void action_zoom_minus()
    {
        var page_zoom = new Agatha.PageZoom();
        page_zoom.zoom_minus();
    }

    private void action_full_screen_toggle()
    {
        if ((window.get_window().get_state() & Gdk.WindowState.FULLSCREEN) == 0)
            window.fullscreen();
        else
            window.unfullscreen();
    }

    private void action_open()
    {
        var dialogs = new Agatha.Dialogs();
        dialogs.show_open();
    }

    private void action_goto()
    {
        var dialogs = new Agatha.Dialogs();
        dialogs.show_goto();
    }
    
    private void action_about()
    {
        var dialogs = new Agatha.Dialogs();
        dialogs.show_about();
    }

    private void action_quit()
    {
        window.get_size(out width, out height);
        var settings = new Agatha.Settings();
        settings.set_width();
        settings.set_height();
        GLib.Settings.sync();
        quit();
    }

    public static int main (string[] args)
    {
        Agatha.Application app = new Agatha.Application();
        return app.run(args);
    }

}
}
