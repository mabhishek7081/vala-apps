namespace Dlauncher
{
public class Cache: GLib.Object
{
    public void list_applications(GMenu.TreeDirectory? tree_root = null)
    {
        GMenu.TreeDirectory root;
        GMenu.Tree tree;

        if (tree_root == null)
        {
            tree = new GMenu.Tree("gnome-applications.menu", GMenu.TreeFlags.SORT_DISPLAY_NAME);
            try
            {
                tree.load_sync();
            }
            catch (Error e)
            {
                stderr.printf("Error: %s\n", e.message);
            }
            root = tree.get_root_directory();
        }
        else
        {
            root = tree_root;
        }

        var it = root.iter();
        GMenu.TreeItemType type;
        while ((type = it.next()) != GMenu.TreeItemType.INVALID)
        {
            if (type == GMenu.TreeItemType.DIRECTORY)
            {
                var dir = it.get_directory();
                list_applications(dir);
            }
            else if (type == GMenu.TreeItemType.ENTRY)
            {
                var appinfo = it.get_entry().get_app_info();
                string icon = appinfo.get_icon().to_string();
                string name = appinfo.get_name();
                string desc = appinfo.get_description();
                string cmd  = appinfo.get_commandline().replace("%F", "").replace("%U", "").replace("%f", "").replace("%u", "");

                var model = new Dlauncher.Model();
                
                var loop = new GLib.MainLoop();
                model.add_item_to_iconview.begin(icon, name, desc, cmd, (obj, res) =>
                {
                    model.add_item_to_iconview.end(res);
                    loop.quit();
                });
                loop.run();
            }
        }
    }
}
}
