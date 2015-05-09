namespace Appearance
{
bool dark;
bool header;
string theme;
string icon;
string font;
string cursor;
string decoration;

Gtk.Settings gtk_settings;
Gtk.ComboBoxText button_dark;
Gtk.ComboBoxText button_header;
Gtk.ComboBoxText button_theme;
Gtk.ComboBoxText button_icon;
Gtk.FontButton   button_font;
Gtk.ComboBoxText button_cursor;
Gtk.ComboBoxText button_decoration;

public class Settings: GLib.Object
{
    public void get_current_values()
    {
        gtk_settings = Gtk.Settings.get_default();
        
        dark         = gtk_settings.gtk_application_prefer_dark_theme;
        header       = gtk_settings.gtk_dialogs_use_header;
        theme        = gtk_settings.gtk_theme_name;
        icon         = gtk_settings.gtk_icon_theme_name;
        font         = gtk_settings.gtk_font_name;
        cursor       = gtk_settings.gtk_cursor_theme_name;
        decoration   = gtk_settings.gtk_decoration_layout;
    }

    public void dark_changed()
    {
        gtk_settings.set("gtk-application-prefer-dark-theme", bool.parse(button_dark.get_active_id()));
        write_changes_gtk3();
    }

    public void header_changed()
    {
        gtk_settings.set("gtk-dialogs-use-header", bool.parse(button_header.get_active_id()));
        write_changes_gtk3();
    }

    public void theme_changed()
    {
        gtk_settings.set("gtk-theme-name", button_theme.get_active_text());
        write_changes_gtk3();
        write_changes_gtk2();
    }

    public void icon_changed()
    {
        gtk_settings.set("gtk-icon-theme-name", button_icon.get_active_text());
        write_changes_gtk3();
        write_changes_gtk2();
    }

    public void font_changed()
    {
        gtk_settings.set("gtk-font-name", button_font.get_font().to_string());
        write_changes_gtk3();
        write_changes_gtk2();
    }

    public void cursor_changed()
    {
        gtk_settings.set("gtk-cursor-theme-name", button_cursor.get_active_text());
        write_changes_gtk3();
        write_changes_gtk2();
    }

    public void decoration_changed()
    {
        gtk_settings.set("gtk-decoration-layout", button_decoration.get_active_id());
        write_changes_gtk3();
    }

    public void write_changes_gtk3()
    {
        try
        {
            // GTK3
            string gtk3file = GLib.Environment.get_user_config_dir() + "/gtk-3.0/settings.ini";
            string gtk3content =
"[Settings]
gtk-application-prefer-dark-theme=%s
gtk-dialogs-use-header=%s
gtk-theme-name=%s
gtk-icon-theme-name=%s
gtk-font-name=%s
gtk-cursor-theme-name=%s
gtk-decoration-layout=%s
".printf(
button_dark.get_active_id().to_string(),
button_header.get_active_id().to_string(),
button_theme.get_active_text(),
button_icon.get_active_text(),
button_font.get_font().to_string(),
button_cursor.get_active_text(),
button_decoration.get_active_id());

            FileUtils.set_contents(gtk3file, gtk3content);
        }
        catch (FileError e)
        {
            stderr.printf ("%s\n", e.message);
        }
    }

    public void write_changes_gtk2()
    {
        try
        {
            // GTK2
            string gtk2file = GLib.Environment.get_home_dir() + "/.gtkrc-2.0";
            string gtk2content = 
"gtk-theme-name='%s'
gtk-icon-theme-name='%s'
gtk-font-name='%s'
gtk-cursor-theme-name='%s'
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-toolbar-icon-size=GTK_ICON_SIZE_SMALL_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle='hintfull'
include '/root/.gtkrc-2.0.mine'
".printf(
button_theme.get_active_text(),
button_icon.get_active_text(),
button_font.get_font().to_string(),
button_cursor.get_active_text());

            FileUtils.set_contents(gtk2file, gtk2content);
        }
        catch (FileError e)
        {
            stderr.printf ("%s\n", e.message);
        }
    }

}
}
