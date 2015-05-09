namespace Emendo
{
private Gee.ArrayList<string> files;
private Gtk.ApplicationWindow window;
private Gtk.Button button_find;
private Gtk.MenuButton menubutton;
private Gtk.HeaderBar headerbar;
private Gtk.Notebook notebook;

public class MainWin: Gtk.ApplicationWindow
{
    private const GLib.ActionEntry[] action_entries =
    {
        { "show-menu", action_show_menu },
        { "show-find", action_find },
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
        app.set_accels_for_action("app.replace",    {"<Primary>H"});
        app.set_accels_for_action("app.wrap",       {"<Primary>R"});
        app.set_accels_for_action("app.color",      {"F9"});
        app.set_accels_for_action("app.close",      {"<Primary>W"});
        app.set_accels_for_action("app.close-all",  {"<Primary><Shift>W"});
        app.set_accels_for_action("app.quit",       {"<Primary>Q"});

        // app menu
        var menu = new GLib.Menu();
        var app_section_one = new GLib.Menu();
        var app_section_two = new GLib.Menu();

        app_section_one.append(_("Preferences"),  "app.pref");
        menu.append_section(null, app_section_one);

        app_section_two.append(_("About"),        "app.about");
        app_section_two.append(_("Quit"),         "app.quit");
        menu.append_section(null, app_section_two);

        app.set_app_menu(menu);

        // buttons
        var button_open  = new Gtk.Button.with_label(_("Open"));
        button_open.width_request  = 55;
        button_open.clicked.connect(action_open);

        var button_save = new Gtk.Button.with_label(_("Save"));
        button_save.width_request = 55;
        button_save.clicked.connect(action_save);

        var image_find = new Gtk.Image.from_icon_name("edit-find-symbolic", Gtk.IconSize.MENU);

        button_find = new Gtk.Button();
        button_find.set_image(image_find);
        button_find.valign = Gtk.Align.CENTER;
        button_find.clicked.connect(action_find);

        // gear menu system
        var gmenu = new GLib.Menu();
        var gmenu_one = new GLib.Menu();
        var gmenu_two = new GLib.Menu();
        var gmenu_three = new GLib.Menu();

        gmenu_one.append(_("New"),            	"app.new");
        gmenu_one.append(_("Save As..."),     	"app.save-as");
        gmenu_one.append(_("Save All"),       	"app.save-all");
        gmenu.append_section(null, gmenu_one);

        gmenu_two.append(_("Replace..."),   	"app.replace");
        gmenu_two.append(_("Text Wrap"), 		"app.wrap");
        gmenu_two.append(_("Select Color"), 	"app.color");
        gmenu.append_section(null, gmenu_two);

        gmenu_three.append(_("Close"),          "app.close");
        gmenu_three.append(_("Close All"),      "app.close-all");
        gmenu.append_section(null, gmenu_three);

        var menuimage = new Gtk.Image.from_icon_name("open-menu-symbolic", Gtk.IconSize.MENU);

        menubutton = new Gtk.MenuButton();
        menubutton.valign = Gtk.Align.CENTER;
        menubutton.set_use_popover(true);
        menubutton.set_menu_model(gmenu);
        menubutton.set_image(menuimage);

        var popover = menubutton.get_popover();
        popover.hide.connect(action_view_grab_focus);

        // window
        notebook = new Gtk.Notebook();
        notebook.expand = true;
        notebook.set_scrollable(true);
        notebook.switch_page.connect(on_notebook_page_switched);

        headerbar = new Gtk.HeaderBar();
        headerbar.set_show_close_button(true);
        headerbar.pack_start(button_open);
        headerbar.pack_start(button_save);
        headerbar.pack_end  (menubutton);
        headerbar.pack_end  (button_find);

        window = new Gtk.ApplicationWindow(app);
        window.window_position = Gtk.WindowPosition.CENTER;
        window.set_default_size(width, height);
        window.set_icon_name(ICON);
        window.set_titlebar(headerbar);
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
        headerbar.set_title(path);
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

    private void action_view_grab_focus()
    {
        if (notebook.get_n_pages() == 0)
            return;
        var tabs = new Emendo.Tabs();
        var view = tabs.get_current_sourceview();
        view.grab_focus();
    }

    // without menu item
    private void action_show_menu()
    {
        var operations = new Emendo.Operations();
        operations.show_menu();
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
