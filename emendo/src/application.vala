/*  Author: simargl <https://github.com/simargl>
 *  License: GPL v3
 */

namespace Emendo
{
const string NAME        = "Emendo";
const string VERSION     = "3.1.0";
const string DESCRIPTION = _("Text editor with syntax highlighting");
const string ICON        = "accessories-text-editor";
const string[] AUTHORS   = { "Simargl <https://github.com/simargl>", "Yosef Or Boczko <yoseforb-at-gmail-dot-com>", null };

private class Application: Gtk.Application
{
    public Application()
    {
        Object(application_id: "org.vala-apps.emendo", flags: GLib.ApplicationFlags.HANDLES_OPEN);
    }

    public override void startup()
    {
        base.startup();

        var mainwin = new Emendo.MainWin();
        mainwin.add_main_window(this);
        
        var operations = new Emendo.Operations();
        operations.add_recent_files();        
    }

    public override void activate()
    {
        if (files.size == 0)
        {
            string fileopen = GLib.Path.build_filename(GLib.Environment.get_tmp_dir(), "untitled");

            var nbook = new Emendo.NBook();
            nbook.create_tab(fileopen);
        }

        get_active_window().present();
    }

    public override void open(File[] files, string hint)
    {
        string fileopen = null;
        foreach (File f in files)
        {
            fileopen = f.get_path();

            var nbook = new Emendo.NBook();
            nbook.create_tab(fileopen);
            var operations = new Emendo.Operations();
            operations.open_file(fileopen);
        }
        
        get_active_window().present();
    }

    private static int main (string[] args)
    {
        Emendo.Application app = new Emendo.Application();
        return app.run(args);
    }
}
}
