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

        var desktop_file = new KeyFile ();
        desktop_file.load_from_file (app.desktop_file_path, KeyFileFlags.NONE);

        var user_dir = Path.build_filename(Environment.get_home_dir(),".local","share");
        var flatpak_dir = Path.build_filename(user_dir,"flatpak");
        var path = Path.build_filename(flatpak_dir,"overrides",app.id);

        var icon_theme = Gtk.IconTheme.get_default ();
        icon_theme.append_search_path (app.icon_theme);

        Gtk.Image image;
        
        var icon_name = desktop_file.get_string ("Desktop Entry","Icon");

        var icon_pixbuf = icon_theme.load_icon (icon_name, 32, Gtk.IconLookupFlags.FORCE_SIZE);

        image = new Gtk.Image.from_pixbuf (icon_pixbuf);

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
        
        var file = File.new_for_path (path);
        
        dark_mode_switch.active = false;
        
        if (file.query_exists()){
            overrides.load_from_file(path, KeyFileFlags.NONE);
        
            if (overrides.has_group("Environment") && overrides.has_key("Environment","GTK_THEME")) {
                var selected_theme = overrides.get_string("Environment","GTK_THEME");

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

        show_all ();
    }
}
