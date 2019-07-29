public class Litteris.PenpalStatusBar : Gtk.Box {
    public Litteris.PenpalView penpal_view {get; set;}
    private Granite.Widgets.DatePicker new_mail_date;
    private Granite.Widgets.ModeButton new_mail_mailtype;
    private Granite.Widgets.ModeButton new_mail_direction;
    private Gtk.Button button_confirm;
    private Gtk.Button button_destroy;
    private Gtk.Button button_cancel;
    private Litteris.Utils utils;
    public bool edit_mode {get; set;}

    public PenpalStatusBar (Litteris.PenpalView penpal_view) {
        Object (
            orientation: Gtk.Orientation.HORIZONTAL,
            spacing: 8,
            homogeneous: false,
            margin: 8,
            penpal_view: penpal_view
        );
    }

    construct {
        utils = new Litteris.Utils ();

        set_property ("edit-mode", false);
        load_status_bar ();

        notify["edit-mode"].connect (() => {
            if (edit_mode == false) {
                load_status_bar ();
            }
        });
    }

    public void load_status_bar () {
        utils.remove_box_children (this);

        var button_new_date = new Gtk.Button.with_label ("Register Mail");
            button_new_date.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            button_new_date.clicked.connect (register_mail);

        pack_end (button_new_date, false, false);
        show_all ();

        if (edit_mode != false) {
            set_property ("edit-mode", false);
        }
    }

    private void register_mail () {
        utils.remove_box_children (this);
        load_edit_mode ();

        button_confirm.clicked.connect (() => {
            on_confirm_clicked ();
        });
    }

    public void edit_mail (Litteris.MailDate edit_date) {
        utils.remove_box_children (this);
        load_edit_mode (false);

        new_mail_date.date = new DateTime.from_unix_utc (edit_date.date);
        new_mail_mailtype.selected = edit_date.mail_type;
        new_mail_direction.selected = edit_date.direction;

        button_confirm.clicked.connect (() => {
            on_confirm_clicked (false, edit_date.rowid);
        });

        button_destroy.clicked.connect (() => {
            on_destroy_clicked (edit_date);
        });
    }

    private void load_edit_mode (bool new_mail = true) {
        set_property ("edit-mode", true);
        new_mail_date = new Granite.Widgets.DatePicker ();

        new_mail_mailtype = new Granite.Widgets.ModeButton ();
        new_mail_mailtype.append_icon ("emblem-mail", Gtk.IconSize.BUTTON);
        new_mail_mailtype.append_icon ("image-x-generic", Gtk.IconSize.BUTTON);

        new_mail_direction = new Granite.Widgets.ModeButton ();
        new_mail_direction.append_text ("Received");
        new_mail_direction.append_text ("Sent");

        button_confirm = new Gtk.Button ();
        button_confirm.label = new_mail ? "Add Mail" : "Save Changes";
        button_confirm.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        button_cancel = new Gtk.Button.with_label ("Discard Changes");
        button_cancel.clicked.connect (load_status_bar);

        button_destroy = new Gtk.Button.with_label ("Remove Mail");
        button_destroy.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

        var spacer = new Gtk.Grid ();
        var spacer_2 = new Gtk.Grid ();

        pack_start (spacer, true, true);
        pack_start (new_mail_mailtype, false, false);
        pack_start (new_mail_date, false, false);
        pack_start (new_mail_direction, false, false);
        pack_start (spacer_2, true, true);
        pack_end (button_confirm, false, false);
        if (!new_mail) {
            pack_end (button_destroy, false, false);
        }
        pack_end (button_cancel, false, false);

        show_all ();
    }

    private void on_confirm_clicked (bool new_mail = true, string rowid = "") {
        if (new_mail_mailtype.selected == -1 || new_mail_direction.selected == -1) {
            penpal_view.notifications.title = "Please select Letter/Postcard and Received/Sent";
            penpal_view.notifications.send_notification ();
        } else {
            string query = "";
            var insert_date = new_mail_date.date.to_unix ().to_string ();
            if (new_mail) {
                query = """INSERT INTO dates (date, penpal, type, direction)
                                VALUES ('"""+ insert_date +"""',
                                """+ penpal_view.loaded_penpal.rowid +""",
                                """+ new_mail_mailtype.selected.to_string () +""",
                                """+ new_mail_direction.selected.to_string () +""")""";
            } else {
                query = """UPDATE dates
                                SET date = '"""+ insert_date +"""',
                                penpal = """+ penpal_view.loaded_penpal.rowid +""",
                                type = """+ new_mail_mailtype.selected.to_string () +""",
                                direction = """+ new_mail_direction.selected.to_string () +"""
                                WHERE rowid = """+ rowid +""";""";
            }

            var exec_query = Application.database.exec_query (query);

            if (exec_query) {
                penpal_view.loaded_penpal.load_dates ();
                penpal_view.get_all_dates ();
                penpal_view.notifications.title = new_mail ? "Mail Registered" : "Changes Saved";
                penpal_view.notifications.send_notification ();
                load_status_bar ();
            } else {
                penpal_view.notifications.title = "Something went wrong...";
                penpal_view.notifications.send_notification ();
            }
        }
    }

    private void on_destroy_clicked (Litteris.MailDate edit_date) {
        var query = "DELETE FROM dates WHERE rowid = " + edit_date.rowid + ";";

        var delete_mail_mailtype = (edit_date.mail_type == Litteris.MailDate.MailType.LETTER) ? "Letter" : "Postcard";
        var delete_mail_date = new DateTime.from_unix_utc (edit_date.date).format ("%x");
        var dialog_title = "Remove " + delete_mail_mailtype + " from " + delete_mail_date + "?";

        var dialog = new Granite.MessageDialog.with_image_from_icon_name (
                                dialog_title,
                                "This will delete this date from the database permanently!",
                                "edit-delete",
                                Gtk.ButtonsType.CANCEL);

        var delete_confirm = new Gtk.Button.with_label ("Remove Mail");
            delete_confirm.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

        dialog.add_action_widget (delete_confirm, Gtk.ResponseType.ACCEPT);
        dialog.transient_for = penpal_view.main_window;
        dialog.show_all ();

        if (dialog.run () == Gtk.ResponseType.ACCEPT) {
            var exec_query = Application.database.exec_query (query);

            if (exec_query) {
                penpal_view.loaded_penpal.load_dates ();
                penpal_view.get_all_dates ();
                penpal_view.notifications.title = "Mail removed with success!";
                penpal_view.notifications.send_notification ();
                load_status_bar ();
            } else {
                penpal_view.notifications.title = "Something went wrong...";
                penpal_view.notifications.send_notification ();
            }
        }

        dialog.destroy ();
    }

}
