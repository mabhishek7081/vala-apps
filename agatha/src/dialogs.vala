namespace Agatha
{
public class Dialogs: Gtk.Dialog
{
    private Gtk.Entry entry;
    
    public void show_open()
    {
        var dialog = new Gtk.FileChooserDialog(_("Open"), window, Gtk.FileChooserAction.OPEN,
                                               _("Cancel"), Gtk.ResponseType.CANCEL,
                                               _("Open"),   Gtk.ResponseType.ACCEPT);
        if (filename != null)
            dialog.set_current_folder(Path.get_dirname(filename));
        dialog.set_select_multiple(false);
        dialog.set_modal(true);
        dialog.show();
        if (dialog.run() == Gtk.ResponseType.ACCEPT)
        {
            filename = dialog.get_filename();

            cpage = 0;
            var viewer = new Agatha.Viewer();
            viewer.open_file();
        }
        dialog.destroy();
    }
    
    public void show_goto()
    {
        var dialog = new Gtk.Dialog();
        dialog.set_title(_("Go to page"));
        dialog.set_border_width(10);
        dialog.set_property("skip-taskbar-hint", true);
        dialog.set_transient_for(window);
        dialog.set_resizable(false);        
        
        entry = new Gtk.Entry();
        entry.set_text(cpage.to_string());
        entry.set_size_request(250, 0);
        entry.activate.connect(() => { on_entry_activate(dialog); });
        
        var content = dialog.get_content_area() as Gtk.Box;
        content.pack_start(entry, true, true, 10);
        
        dialog.add_button(_("Go"), Gtk.ResponseType.OK);
        dialog.add_button(_("Close"), Gtk.ResponseType.CLOSE);
        dialog.set_default_response(Gtk.ResponseType.OK);
        dialog.show_all();
      
        if (dialog.run() == Gtk.ResponseType.OK)
            on_entry_activate(dialog);
        dialog.destroy();
    }

    private void on_entry_activate(Gtk.Dialog d)
    {
        cpage = int.parse(entry.get_text());
        var viewer = new Agatha.Viewer();
        viewer.render_page(cpage);
        d.destroy();
    }

    public void show_about()
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
}
}
