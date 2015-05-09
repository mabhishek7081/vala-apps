namespace Emendo
{
public class Find: Gtk.Dialog
{
    private Gtk.Entry entry;
    private Gtk.SourceSearchContext context;
    private Gtk.Popover popover;

    public void show_dialog()
    {
        if (notebook.get_n_pages() == 0)
            return;

        entry = new Gtk.Entry();
        entry.set_size_request(200, 30);

        var button_up = new Gtk.Button.from_icon_name("go-up-symbolic",     Gtk.IconSize.BUTTON);
        button_up.set_size_request(30, 30);

        var button_down = new Gtk.Button.from_icon_name("go-down-symbolic", Gtk.IconSize.BUTTON);
        button_down.set_size_request(30, 30);

        var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        box.pack_start(button_up);
        box.pack_start(button_down);
        box.get_style_context().add_class("linked");
        box.valign = Gtk.Align.CENTER;

        var image_close = new Gtk.Image();
        image_close.set_from_icon_name("window-close-symbolic",  Gtk.IconSize.BUTTON);
        image_close.set_padding(1, 8);

        var eventbox = new Gtk.EventBox();
        eventbox.set_events(Gdk.EventMask.BUTTON_RELEASE_MASK);
        eventbox.add(image_close);

        var grid = new Gtk.Grid();
        grid.attach(entry,    0, 0, 1, 1);
        grid.attach(box,      1, 0, 1, 1);
        grid.attach(eventbox, 2, 0, 1, 1);
        grid.set_border_width(3);
        grid.set_column_spacing(2);
        grid.show_all();

        popover = new Gtk.Popover(button_find);
        popover.add(grid);
        popover.set_modal(false);
        popover.set_visible(true);

        // signals
        entry.changed.connect(forward_on_changed);
        entry.activate.connect(forward);
        button_down.clicked.connect(forward);
        button_up.clicked.connect(backward);
        eventbox.button_release_event.connect(on_close_clicked);

        popover.hide.connect(on_popover_hide);

        entry_start_text();
    }

    // Set entry text from selection
    private void entry_start_text()
    {
        Gtk.TextIter sel_st;
        Gtk.TextIter sel_end;

        var tabs = new Emendo.Tabs();
        var view = tabs.get_current_sourceview();
        var buffer = (Gtk.SourceBuffer) view.get_buffer();
        buffer.get_selection_bounds(out sel_st, out sel_end);

        string sel_text = buffer.get_text(sel_st, sel_end, true);

        entry.grab_focus();
        entry.set_text(sel_text);
        entry.select_region(0, 0);
        entry.set_position(-1);
    }

    // Search forward on entry changed
    private void forward_on_changed()
    {
        Gtk.TextIter sel_st;
        Gtk.TextIter sel_end;
        Gtk.TextIter match_st;
        Gtk.TextIter match_end;

        var tabs = new Emendo.Tabs();
        var view = tabs.get_current_sourceview();
        var buffer = (Gtk.SourceBuffer) view.get_buffer();
        buffer.get_selection_bounds(out sel_st, out sel_end);

        var settings = new Gtk.SourceSearchSettings();
        context = new Gtk.SourceSearchContext(buffer, settings);

        settings.set_search_text(entry.get_text());
        context.set_highlight(true);

        bool found = context.forward(sel_st, out match_st, out match_end);
        if (found == true)
        {
            buffer.select_range(match_st, match_end);
            view.scroll_to_iter(match_st, 0.10, false, 0, 0);
            on_found_entry_color();
        }
        else
        {
            on_not_found_entry_color();
        }
    }

    // Search forward
    private void forward()
    {
        Gtk.TextIter sel_st;
        Gtk.TextIter sel_end;
        Gtk.TextIter match_st;
        Gtk.TextIter match_end;

        var tabs = new Emendo.Tabs();
        var view = tabs.get_current_sourceview();
        var buffer = (Gtk.SourceBuffer) view.get_buffer();
        buffer.get_selection_bounds(out sel_st, out sel_end);

        var settings = new Gtk.SourceSearchSettings();
        context = new Gtk.SourceSearchContext(buffer, settings);

        settings.set_search_text(entry.get_text());

        bool found = context.forward(sel_end, out match_st, out match_end);
        if (found == true)
        {
            buffer.select_range(match_st, match_end);
            view.scroll_to_iter(match_st, 0.10, false, 0, 0);
            on_found_entry_color();
        }
        else
        {
            on_not_found_entry_color();
        }
    }

    // Search backward
    private void backward()
    {
        Gtk.TextIter sel_st;
        Gtk.TextIter sel_end;
        Gtk.TextIter match_st;
        Gtk.TextIter match_end;

        var tabs = new Emendo.Tabs();
        var view = tabs.get_current_sourceview();
        var buffer = (Gtk.SourceBuffer) view.get_buffer();
        buffer.get_selection_bounds(out sel_st, out sel_end);

        var settings = new Gtk.SourceSearchSettings();
        context = new Gtk.SourceSearchContext(buffer, settings);

        settings.set_search_text(entry.get_text());

        bool found = context.backward(sel_st, out match_st, out match_end);
        if (found == true)
        {
            buffer.select_range(match_st, match_end);
            view.scroll_to_iter(match_st, 0.10, false, 0, 0);
            on_found_entry_color();
        }
        else
        {
            on_not_found_entry_color();
        }
    }

    // Change entry color
    private void on_found_entry_color()
    {
        var rgba = Gdk.RGBA();
        rgba.parse("#000000");
        entry.override_color(Gtk.StateFlags.NORMAL, rgba);
    }

    private void on_not_found_entry_color()
    {
        var rgba = Gdk.RGBA();
        rgba.parse("#FF6666");
        entry.override_color(Gtk.StateFlags.NORMAL, rgba);
    }

    // Hide Popover
    private bool on_close_clicked()
    {
        popover.hide();
        return false;
    }

    // On popover hide
    private void on_popover_hide()
    {
        var tabs = new Emendo.Tabs();
        var view = tabs.get_current_sourceview();
        view.grab_focus();

        if (entry.get_text_length() > 0)
            context.set_highlight(false);
    }

}
}
