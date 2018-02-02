/*  Author: simargl <https://github.org/simargl>
 *  License: GPL v3
 */

namespace Vestigo {
private class Main: Gtk.Application {
    public Main() {
        Object(application_id: "org.vala-apps.vestigo",
               flags: GLib.ApplicationFlags.FLAGS_NONE);
    }

    public override void startup() {
        base.startup();
        new Vestigo.Window().add_app_window(this);
    }

    public override void activate() {
        get_active_window().present();
    }

    private static int main (string[] args) {
        Vestigo.Main app = new Vestigo.Main();
        return app.run(args);
    }
}
}
