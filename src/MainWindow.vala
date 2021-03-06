/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Justin Haygood <jhaygood86@gmail.com>
 */

public class Gotham.MainWindow : Hdy.ApplicationWindow {
    public MainWindow (Gtk.Application application) {
            Object (
                application: application,
                icon_name: "com.github.jhaygood86.gotham",
                title: _("Gotham")
            );
    }
    
    static construct {
        Hdy.init ();
    }

    Hdy.HeaderBar header_bar;
    Gtk.Grid grid;
    GLib.ListStore app_list_store;

    construct {
        height_request = 800;
        width_request = 600;
    
        header_bar = new Hdy.HeaderBar () {
            show_close_button = true,
            title = _("Gotham"),
            has_subtitle = false,
            hexpand = true,
            halign = Gtk.Align.FILL
        };

        unowned Gtk.StyleContext header_bar_context = header_bar.get_style_context ();
        header_bar_context.add_class (Gtk.STYLE_CLASS_FLAT);
        header_bar_context.add_class ("default-decoration");

        grid = new Gtk.Grid ();
        
        var title_label = new Gtk.Label(_("Force Dark Mode"));
        title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);
        title_label.margin_top = 10;
        
        Gtk.Label subtitle_label;

        if(GothamApp.is_running_on_elementary ()) {
            subtitle_label = new Gtk.Label(_("Showing Non-Curated Apps Only"));
            subtitle_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            subtitle_label.margin_top = 10;
        }
        
        var disclaimer_label = new Gtk.Label(_("Not every app supports forcing dark mode"));

        var window_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        window_box.add(header_bar);
        window_box.add(title_label);

        if (GothamApp.is_running_on_elementary ()) {
            window_box.add(subtitle_label);
        }

        window_box.add(disclaimer_label);
        window_box.add(grid);

        child = window_box;

        grid.visible = true;
        
        var placeholder_title = new Gtk.Label (_("Loading Available Flatpak Applications")) {
            xalign = 0
        };
        
        placeholder_title.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

        var placeholder_description = new Gtk.Label (_("Apps whose style can be adjusted will appear here")) {
            wrap = true,
            xalign = 0
        };

        var placeholder = new Gtk.Grid () {
            margin = 12,
            row_spacing = 3,
            valign = Gtk.Align.CENTER,
            hexpand = true
        };
        
        placeholder.attach (placeholder_title, 0, 0);
        placeholder.attach (placeholder_description, 0, 1);
        placeholder.show_all ();
        
        app_list_store = new GLib.ListStore(typeof(AppModel));

        var app_list = new Gtk.ListBox ();
        app_list.vexpand = true;
        app_list.selection_mode = Gtk.SelectionMode.NONE;
        app_list.set_placeholder (placeholder);

        app_list.bind_model (app_list_store, (item) => {
            return new ApplicationRow((AppModel)item);
        });
        
        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.add (app_list);

        var frame = new Gtk.Frame (null);
        frame.add (scrolled_window);
        frame.width_request = 300;
        frame.margin = 20;
        
        grid.attach (frame, 0, 0, 1, 1);
        
        AppModel.populate_app_list_store.begin (app_list_store, (CompareDataFunc<Object>)sort_func);

    }
    
    [CCode (instance_pos = -1)]
    private int sort_func (AppModel row1, AppModel row2) {
        return row1.name.collate(row2.name);
    }
}

