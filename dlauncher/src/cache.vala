namespace Dlauncher {
public class Cache: GLib.Object {
    public void list_applications() {
        try {
            string dd = "/usr/share/applications/";
            string n;
            var d = Dir.open(dd);
            while ((n = d.read_name()) != null) {
                string icon;
                string name;
                string desc;
                string cmd;
                string nodisplay = "";
                if (n.contains(".desktop")) {
                    var keyfile = new GLib.KeyFile();
                    try {
                        keyfile.load_from_file(dd + n, GLib.KeyFileFlags.NONE);
                    } catch (GLib.Error e) {
                        error("%s\n", e.message);
                    }
                    try {
                        icon = keyfile.get_string ("Desktop Entry", "Icon");
                    } catch (GLib.Error e) {
                        error("%s %s\n", n, e.message);
                    }
                    try {
                        name = keyfile.get_string ("Desktop Entry", "Name");
                    } catch (GLib.Error e) {
                        error("%s %s\n", n, e.message);
                    }
                    try {
                        desc = keyfile.get_string ("Desktop Entry", "Comment");
                    } catch (GLib.Error e) {
                        desc = "";
                        //error("%s\n", e.message);
                    }
                    try {
                        cmd = keyfile.get_string ("Desktop Entry", "Exec");
                        cmd = cmd.replace("%F", "").replace("%f", "").replace("%U", "").replace("%u",
                                "");
                    } catch (GLib.Error e) {
                        error("%s %s\n", n, e.message);
                    }
                    try {
                        nodisplay = keyfile.get_string ("Desktop Entry", "NoDisplay");
                    } catch (GLib.Error e) {
                        nodisplay = "";
                        //error("%s\n", e.message);
                    }
                    if (nodisplay != "true") {
                        var model = new Dlauncher.Model();
                        model.add_item_to_iconview(icon, name, desc, cmd);
                    }
                }
            }
        } catch (GLib.Error e) {
            error("%s\n", e.message);
        }
    }
}
}
