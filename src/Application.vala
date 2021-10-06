/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Justin Haygood <jhaygood86@gmail.com>
 */

public class GothamApp : Gtk.Application {
    public GothamApp () {
        Object (
            application_id: "io.github.jhaygood86.gotham",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }
    
    private static bool? _is_on_elementary;

    protected override void activate () {
        init_theme ();

        weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_default ();
        default_theme.add_resource_path ("/io/github/jhaygood86/gotham/");
    
        var main_window = new Gotham.MainWindow (this);
        
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });
        
        main_window.show_all ();
        
        var css_provider = new Gtk.CssProvider ();
        css_provider.load_from_resource ("/io/github/jhaygood86/gotham/application.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    }
    
    private void init_theme () {
         GLib.Value value = GLib.Value (GLib.Type.STRING);
         Gtk.Settings.get_default ().get_property ("gtk-theme-name", ref value);
         if (!value.get_string ().has_prefix ("io.elementary.")) {
             Gtk.Settings.get_default ().set_property ("gtk-icon-theme-name", "elementary");
             Gtk.Settings.get_default ().set_property ("gtk-theme-name", "io.elementary.stylesheet.blueberry");
         }
    }

    public static bool is_running_on_elementary () {

        if (_is_on_elementary == null ) {
            var os_id = Environment.get_os_info ("ID");
            print("Running On OS: %s\n",os_id);
            _is_on_elementary = os_id == "elementary";
        }

        return _is_on_elementary;
    }

    public static int main (string[] args) {
        return new GothamApp ().run (args);
    }

}
