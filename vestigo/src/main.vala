/*  Author: simargl <https://github.org/simargl>
 *  License: GPL v3
 */

namespace Vestigo {
private class Main: Gtk.Application {
    public Main() {
        Object(application_id: "org.vala-apps.vestigo",
               flags: GLib.ApplicationFlags.HANDLES_OPEN);
    }

    public override void startup() {
        base.startup();
        new Vestigo.Window().add_app_window(this);
    }

    public override void open(File[] files, string hint) {
        foreach (File f in files) {
            saved_dir = f.get_path();
        }
        new Vestigo.IconView().open_location(GLib.File.new_for_path(saved_dir), true);
    }

    public override void activate() {
        new Vestigo.IconView().open_location(GLib.File.new_for_path(saved_dir), true);
    }

    private static int main (string[] args) {
        Vestigo.Main app = new Vestigo.Main();
        return app.run(args);
    }
}
}
