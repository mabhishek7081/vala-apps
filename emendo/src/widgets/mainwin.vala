namespace Emendo
{
private Gee.ArrayList<string> files;
private Gtk.ApplicationWindow window;
private Gtk.Notebook notebook;

public class MainWin: Gtk.ApplicationWindow
{
    private const GLib.ActionEntry[] action_entries =
    {
        { "show-find", action_find      },
        { "undo",      action_undo      },
        { "redo",      action_redo      },
        { "open",      action_open      },
        { "save",      action_save      },
        { "find",      action_find      },
        { "new",       action_new       },
        { "save-as",   action_save_as   },
        { "save-all",  action_save_all  },
        { "replace",   action_replace   },
        { "wrap",      action_wrap      },
        { "color",     action_color     },
        { "close",     action_close     },
        { "close-all", action_close_all },
        { "pref",      action_pref      },
        { "about",     action_about     },
        { "quit",      action_quit      }
    };

    public void add_main_window(Gtk.Application app)
    {
        files = new Gee.ArrayList<string>();

        var settings = new Emendo.Settings();
        settings.get_all();

        // accelerators
        app.add_action_entries(action_entries, app);

        app.set_accels_for_action("app.show-menu",  {"F10"});
        app.set_accels_for_action("app.show-find",  {"<Primary>F"});
        app.set_accels_for_action("app.undo",       {"<Primary>Z"});
        app.set_accels_for_action("app.redo",       {"<Primary>Y"});
        app.set_accels_for_action("app.open",       {"<Primary>O"});
        app.set_accels_for_action("app.save",       {"<Primary>S"});
        app.set_accels_for_action("app.new",        {"<Primary>N"});
        app.set_accels_for_action("app.save-all",   {"<Primary><Shift>S"});
        app.set_accels_for_action("app.find",       {"<Primary>F"});
        app.set_accels_for_action("app.replace",    {"<Primary>H"});
        app.set_accels_for_action("app.wrap",       {"<Primary>R"});
        app.set_accels_for_action("app.color",      {"F9"});
        app.set_accels_for_action("app.close",      {"<Primary>W"});
        app.set_accels_for_action("app.close-all",  {"<Primary><Shift>W"});
        app.set_accels_for_action("app.quit",       {"<Primary>Q"});

        // app menu
        var menu = new GLib.Menu();

        var section = new GLib.Menu();
        section.append(_("New"),            "app.new");
        section.append(_("Open"),           "app.open");
        section.append(_("Save"),           "app.save");
        section.append(_("Save As..."),     "app.save-as");
        section.append(_("Save All"),       "app.save-all");
        menu.append_section(null, section);
        
        section = new GLib.Menu();
        section.append(_("Find..."),   	    "app.find");
        section.append(_("Replace..."),   	"app.replace");
        section.append(_("Text Wrap"), 		"app.wrap");
        section.append(_("Select Color"), 	"app.color");
        menu.append_section(null, section);
        
        section = new GLib.Menu();
        section.append(_("Close"),          "app.close");
        section.append(_("Close All"),      "app.close-all");
        menu.append_section(null, section);

        section = new GLib.Menu();
        section.append(_("Preferences"),    "app.pref");
        menu.append_section(null, section);
        
        section = new GLib.Menu();
        section.append(_("About"),          "app.about");
        section.append(_("Quit"),           "app.quit");
        menu.append_section(null, section);

        app.set_app_menu(menu);

        // window
        notebook = new Gtk.Notebook();
        notebook.expand = true;
        notebook.set_scrollable(true);
        notebook.switch_page.connect(on_notebook_page_switched);

        window = new Gtk.ApplicationWindow(app);
        window.window_position = Gtk.WindowPosition.CENTER;
        window.set_default_size(width, height);
        window.set_icon_name(ICON);
        window.set_title(NAME);
        window.add(notebook);
        window.show_all();
        window.delete_event.connect(() =>
        {
            action_quit();
            return true;
        });
    }

    private void on_notebook_page_switched(Gtk.Widget page, uint page_num)
    {
        var tabs = new Emendo.Tabs();
        string path = tabs.get_path_at_tab((int)page_num);
        window.set_title(path);
    }

    public void action_app_quit()
    {
        window.get_size(out width, out height);
        var settings = new Emendo.Settings();
        settings.set_width();
        settings.set_height();
        GLib.Settings.sync();
        window.get_application().quit();
    }

    private void action_undo()
    {
        var operations = new Emendo.Operations();
        operations.undo_last();
    }

    private void action_redo()
    {
        var operations = new Emendo.Operations();
        operations.redo_last();
    }

    // buttons
    private void action_open()
    {
        var dialogs = new Emendo.Dialogs();
        dialogs.show_open();
    }

    private void action_save()
    {
        var operations = new Emendo.Operations();
        operations.save_current();
    }

    private void action_find()
    {
        var find = new Emendo.Find();
        find.show_dialog();
    }

    // gear menu
    private void action_new()
    {
        var nbook = new Emendo.NBook();
        nbook.create_tab("/tmp/untitled");
    }

    private void action_save_as()
    {
        var dialogs = new Emendo.Dialogs();
        dialogs.show_save();
    }

    private void action_save_all()
    {
        var operations = new Emendo.Operations();
        operations.save_all();
    }

    private void action_replace()
    {
        var replace = new Emendo.Replace();
        replace.show_dialog();
    }

    private void action_wrap()
    {
        var operations = new Emendo.Operations();
        operations.wrap_text();
    }

    private void action_color()
    {
        var color = new Emendo.Color();
        color.show_dialog();
    }

    private void action_close()
    {
        var operations = new Emendo.Operations();
        operations.close_tab();
    }

    private void action_close_all()
    {
        var operations = new Emendo.Operations();
        operations.close_all_tabs();
    }

    // app menu
    private void action_pref()
    {
        var prefdialog = new Emendo.PrefDialog();
        prefdialog.on_activate();
    }

    private void action_about()
    {
        var dialogs = new Emendo.Dialogs();
        dialogs.show_about();
    }

    public void action_quit()
    {
        var dialogs = new Emendo.Dialogs();
        dialogs.changes_all();
    }

}
}
