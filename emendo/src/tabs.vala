namespace Emendo {
public class Tabs: GLib.Object {
    public string get_path_at_tab(int pos) {
        string path = files[pos];
        return path;
    }

    public Gtk.SourceView get_sourceview_at_tab(int pos) {
        var scrolled = (Gtk.ScrolledWindow) notebook.get_nth_page(pos);
        var view = (Gtk.SourceView) scrolled.get_child();
        return view;
    }

    public Gtk.Label get_label_at_tab(int pos) {
        var scrolled = (Gtk.ScrolledWindow) notebook.get_nth_page(pos);
        var grid = (Gtk.Grid) notebook.get_tab_label(scrolled);
        var label = (Gtk.Label) grid.get_child_at(0, 0);
        return label;
    }

    public string get_current_path() {
        string path = files[notebook.get_current_page()];
        return path;
    }

    public Gtk.SourceView get_current_sourceview() {
        var scrolled = (Gtk.ScrolledWindow) notebook.get_nth_page(
                           notebook.get_current_page());
        var view = (Gtk.SourceView) scrolled.get_child();
        return view;
    }

    public Gtk.Label get_current_label() {
        var scrolled = (Gtk.ScrolledWindow) notebook.get_nth_page(
                           notebook.get_current_page());
        var grid = (Gtk.Grid) notebook.get_tab_label(scrolled);
        var label = (Gtk.Label) grid.get_child_at(0, 0);
        return label;
    }

    public void check_notebook_for_file_name(string path) {
        if (files.contains(path) == true) {
            int i;
            for (i = 0; i < files.size; i++) {
                if (files[i] == path) {
                    var scrolled = (Gtk.ScrolledWindow) notebook.get_nth_page(i);
                    var nbook = new Emendo.NBook();
                    nbook.destroy_tab(scrolled, path);
                    print("debug: removed tab number %d with: %s\n", i, path);
                }
            }
        }
    }
}
}
