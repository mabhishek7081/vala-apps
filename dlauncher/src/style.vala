namespace Dlauncher
{
public class Style: GLib.Object
{
    public void load_css()
    {
        var css_stuff = """
                        *
                        {
                        -GtkRange-slider-width:        10px;
                        -GtkRange-trough-border:       4px;
                        -GtkRange-arrow-scaling:       0px;
                        -GtkRange-stepper-size:        0px;
                        border-radius:                 5px;

                        background-color:              #F7F7F7;
                        color:                         #363636;
                    }

                        *:selected:focus
                        {
                        background-color: #D9D9D9;
                        border-color:     #D9D9D9;
                        color:            #363636;
                        border-radius:    0px;
                    }                

                        .scrollbar.trough
                        {
                        background-color: #F7F7F7;
                    }

                        .scrollbar.slider
                        {
                        background-color: #BBBBBB;
                        border-color:     #BBBBBB;
                        border-width:     1px;
                        border-radius:    2px;
                    }

                        .scrollbar.slider.vertical:hover
                        {
                        background-color: #9B9B9B;
                        border-color:     #9B9B9B;
                    }

                        .scrollbar.slider.vertical:active
                        {
                        background-color: #9B9B9B;
                        border-color:     #9B9B9B;
                    }
                        """;
        var provider = new Gtk.CssProvider();
        try
        {
            provider.load_from_data(css_stuff, css_stuff.length);
            Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }
        catch (Error e)
        {
            stderr.printf ("Error: %s\n", e.message);
        }
    }
}
}
