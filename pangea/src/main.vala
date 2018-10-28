/*  Author: simargl <https://github.org/simargl>
 *  License: GPL v3
 */

namespace Pangea {
private class Main: Gtk.Application {
    public Main() {
        Object(application_id: "org.vala-apps.pangea",
               flags: GLib.ApplicationFlags.HANDLES_OPEN);
    }

    public override void startup() {
        base.startup();
        new Pangea.Window().add_app_window(this);
    }

    public override void open(File[] files, string hint) {
        foreach (File f in files) {
            saved_dir = f.get_path();
        }
        get_active_window().present();
        new Pangea.IconView().open_location(GLib.File.new_for_path(saved_dir), true);
    }

    public override void activate() {
        get_active_window().present();
        new Pangea.IconView().open_location(GLib.File.new_for_path(saved_dir), true);
    }

    private static int main (string[] args) {
        Pangea.Main app = new Pangea.Main();
        return app.run(args);
    }
}
}
