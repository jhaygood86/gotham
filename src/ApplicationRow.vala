/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Justin Haygood <jhaygood86@gmail.com>
 */

public class ApplicationRow : Gtk.ListBoxRow {
    public AppModel app { get; construct; }
    
    private Gtk.Switch dark_mode_switch;

    public ApplicationRow (AppModel app) {
        Object (app: app);
    }
    
    construct {
        hexpand = true;
        margin = 10;
        margin_right = 20;
        margin_left = 20;
        
        var app_id = app.id;
        var app_name = app.name;
        
        var appinfo = new GLib.DesktopAppInfo (app_id + ".desktop");

        Gtk.Image image;
        
        if (appinfo != null && appinfo.get_icon () != null) {
            image = new Gtk.Image.from_gicon (appinfo.get_icon (), Gtk.IconSize.DND);
        } else {
            image = new Gtk.Image.from_icon_name ("application-default-icon", Gtk.IconSize.DND);
        }

        image.pixel_size = 32;

        var title_label = new Gtk.Label (app_name) {
            ellipsize = Pango.EllipsizeMode.END,
            valign = Gtk.Align.END,
            xalign = 0
        };
        
        title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

        dark_mode_switch = new Gtk.Switch() {
            valign = Gtk.Align.CENTER,
            halign = Gtk.Align.END
        };
        
        var grid = new Gtk.Grid () {
            column_spacing = 6,
        };
        
        grid.attach (image, 0, 0, 1, 2);
        grid.attach (title_label, 1, 0);
        
        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        
        box.pack_start (grid);
        box.pack_end (dark_mode_switch);

        add (box);
        
        var overrides = new KeyFile ();
        
        var user_data_dir = Environment.get_user_data_dir();
        var path = Path.build_filename(user_data_dir,"flatpak","overrides",app.id);
        
        var file = File.new_for_path (path);
        
        dark_mode_switch.active = false;
        
        if (file.query_exists()){
            overrides.load_from_file(path, KeyFileFlags.NONE);
        
            if (overrides.has_group("Environment") && overrides.has_key("Environment","GTK_THEME")) {
                var selected_theme = overrides.get_string("Environment","GTK_THEME");

                print("theme: %s",selected_theme);

                if (selected_theme == "Adwaita:dark" || selected_theme == "Adwaita-dark") {
                    dark_mode_switch.active = true;
                }
                
            }
        
        }
        

        activate.connect (() => {
            dark_mode_switch.activate ();
        });
        
        dark_mode_switch.notify["active"].connect(() => {
           if(dark_mode_switch.active) {
               overrides.set_string ("Environment", "GTK_THEME", "Adwaita-dark");
               overrides.set_string ("Environment", "QT_STYLE_OVERRIDE", "Adwaita-Dark");
           } else {
               if (overrides.has_group("Environment") && overrides.has_key("Environment","GTK_THEME")) {
                   overrides.remove_key("Environment","GTK_THEME");
               }

               if (overrides.has_group("Environment") && overrides.has_key("Environment","QT_STYLE_OVERRIDE")) {
                   overrides.remove_key("Environment","QT_STYLE_OVERRIDE");
               }
           }
           
           overrides.save_to_file(path);
        });
    }
}
