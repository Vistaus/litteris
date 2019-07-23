public class Litteris.PenpalView : Gtk.ScrolledWindow {
    public Litteris.Window main_window {get; construct;}
    public Litteris.Penpal loaded_penpal {get; set;}
    private Gtk.Box box_sent_dates;
    private Gtk.Box box_received_dates;

    public PenpalView (Litteris.Window main_window) {
        Object (
            main_window: main_window
        );
    }

    construct {
        load_penpal ();

        /* header */
        var label_name = new Gtk.Label ("<b>"+loaded_penpal.name+"</b>");
            label_name.halign = Gtk.Align.START;
            label_name.use_markup = true;
            label_name.margin_start = 12;
            label_name.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

        var label_nickname = new Gtk.Label (loaded_penpal.nickname);
            label_nickname.halign = Gtk.Align.START;
            label_nickname.margin_start = 20;
            label_nickname.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

        var box_names = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            box_names.halign = Gtk.Align.FILL;
            box_names.hexpand = true;
            box_names.pack_start (label_name);
            box_names.pack_start (label_nickname);

        var emoji_flag = new Gtk.Label (loaded_penpal.country_emoji);
            emoji_flag.valign = Gtk.Align.START;
            emoji_flag.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);

        var icon_sent = new Gtk.Image.from_icon_name ("mail-send", Gtk.IconSize.LARGE_TOOLBAR);
            icon_sent.halign = Gtk.Align.START;

        var icon_sent_label = new Gtk.Label (loaded_penpal.mail_sent.size.to_string ());
            icon_sent_label.halign = Gtk.Align.END;
            icon_sent_label.get_style_context ().add_class (Granite.STYLE_CLASS_WELCOME);

        var icon_received = new Gtk.Image.from_icon_name ("mail-read", Gtk.IconSize.LARGE_TOOLBAR);
            icon_received.halign = Gtk.Align.START;

        var icon_received_label = new Gtk.Label (loaded_penpal.mail_received.size.to_string ());
            icon_received_label.halign = Gtk.Align.END;
            icon_received_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

        var grid_icons = new Gtk.Grid ();
            grid_icons.hexpand = false;
            grid_icons.height_request = 60;
            grid_icons.width_request = 80;
            grid_icons.column_homogeneous = true;
            grid_icons.row_homogeneous = true;
            grid_icons.row_spacing = 6;
            grid_icons.column_spacing = 6;
            grid_icons.attach (icon_sent_label, 0, 0);
            grid_icons.attach (icon_sent, 1, 0);
            grid_icons.attach (icon_received_label, 0, 1);
            grid_icons.attach (icon_received, 1, 1);

        var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            header_box.hexpand = true;
            header_box.homogeneous = false;
            header_box.halign = Gtk.Align.FILL;
            header_box.pack_start (emoji_flag, false, false);
            header_box.pack_start (box_names, true, true);
            header_box.pack_end (grid_icons, false, false);

        /* penpal info */
        var label_notes = new Gtk.Label ("<b>Notes : </b>");
            label_notes.use_markup = true;
            label_notes.halign = Gtk.Align.START;

        var label_notes_content = new Gtk.Label (loaded_penpal.notes);
            label_notes_content.wrap = true;
            label_notes_content.halign = Gtk.Align.START;
            label_notes_content.valign = Gtk.Align.START;
            label_notes_content.justify = Gtk.Justification.FILL;
            label_notes_content.margin_start = 16;
            label_notes_content.selectable = true;

        var label_address = new Gtk.Label ("<b>Address : </b>");
            label_address.use_markup = true;
            label_address.halign = Gtk.Align.START;

        var label_address_content = new Gtk.Label (loaded_penpal.address);
            label_address_content.label += "\n\n%s\n".printf (loaded_penpal.country_name);
            label_address_content.wrap = true;
            label_address_content.halign = Gtk.Align.START;
            label_address_content.valign = Gtk.Align.START;
            label_address_content.justify = Gtk.Justification.FILL;
            label_address_content.margin_start = 16;
            label_address_content.selectable = true;

        var icon_mail_sent = new Gtk.Image.from_icon_name ("mail-send", Gtk.IconSize.LARGE_TOOLBAR);
        var label_sent = new Gtk.Label ("<b>Sent :</b>");
            label_sent.use_markup = true;
            label_sent.halign = Gtk.Align.START;

        var box_sent = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            box_sent.pack_start (icon_mail_sent, false, false);
            box_sent.pack_start (label_sent, false, false);

        var icon_mail_received = new Gtk.Image.from_icon_name ("mail-read", Gtk.IconSize.LARGE_TOOLBAR);
        var label_received = new Gtk.Label ("<b>Received :</b>");
            label_received.use_markup = true;
            label_received.halign = Gtk.Align.START;

        var box_received = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            box_received.pack_start (icon_mail_received, false, false);
            box_received.pack_start (label_received, false, false);

        box_sent_dates = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        box_sent_dates.homogeneous = false;
        box_sent_dates.margin_start = 24;
        load_dates ();

        box_received_dates = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        box_received_dates.homogeneous = false;
        box_received_dates.margin_start = 24;
        load_dates (false);

        var content_grid = new Gtk.Grid ();
            content_grid.column_spacing = 24;
            content_grid.column_homogeneous = true;
            content_grid.row_spacing = 6;
            content_grid.row_homogeneous = false;
            content_grid.attach (label_address, 0, 0);
            content_grid.attach (label_address_content, 0, 1);
            content_grid.attach (label_notes, 1, 0);
            content_grid.attach (label_notes_content, 1, 1);
            content_grid.attach (box_sent, 0, 2);
            content_grid.attach (box_sent_dates, 0, 3);
            content_grid.attach (box_received, 1, 2);
            content_grid.attach (box_received_dates, 1, 3);

        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL,12);
            main_box.margin = 24;
            main_box.pack_start (header_box, false, false);
            main_box.pack_start (separator, false, false);
            main_box.pack_start (content_grid, false, false);

        add (main_box);
    }

    public void load_penpal () {
        var new_loaded_penpal = new Litteris.Penpal (main_window.list_panel.active_penpal);
        set_property ("loaded-penpal", new_loaded_penpal);
    }

    public void load_dates (bool sent = true) {
        var dates_list = sent ? loaded_penpal.mail_sent : loaded_penpal.mail_received;
        var dates_years = sent ? loaded_penpal.mail_sent_years : loaded_penpal.mail_received_years;
        var dates_box = sent ? box_sent_dates : box_received_dates;

        foreach (var year in dates_years) {
            var label_year = new Gtk.Expander ("<b>%i</b>".printf (year));
                label_year.expanded = true;
                label_year.use_markup = true;
                label_year.margin = 3;

            var flowbox_year = new Gtk.FlowBox ();
                flowbox_year.homogeneous = true;
                flowbox_year.row_spacing = 3;

            label_year.add (flowbox_year);
            foreach (var mail_date in dates_list) {
                var date = new DateTime.from_unix_utc (mail_date.date);

                if (date.get_year () == year) {
                    var button_date = new Gtk.Button ();
                        button_date.label = date.format ("%d/%m/%Y");
                        button_date.relief = Gtk.ReliefStyle.NONE;
                        button_date.halign = Gtk.Align.START;
                        button_date.always_show_image = true;
                        button_date.image_position = Gtk.PositionType.LEFT;
                    var button_date_icon = new Gtk.Image.from_icon_name
                                           ("emblem-mail", Gtk.IconSize.SMALL_TOOLBAR);
                    if (mail_date.mail_type == Litteris.MailDate.MailType.POSTCARD) {
                        button_date_icon = new Gtk.Image.from_icon_name
                                           ("image-x-generic", Gtk.IconSize.SMALL_TOOLBAR);
                    }
                    button_date.set_image (button_date_icon);
                    flowbox_year.add (button_date);
                }
            }

            dates_box.pack_start (label_year, false, false);
        }
    }

}
