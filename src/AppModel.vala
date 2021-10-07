/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Justin Haygood <jhaygood86@gmail.com>
 */

public class AppModel : Object {
    public string id { get; construct; }
    public string name { get; private set; }
    public string icon_theme { get; private set; }
    public string desktop_file_path { get; private set; }
    public bool is_appcenter { get; private set;}
    
    private AppModel (string id) {
        Object(id : id);
        
        load_app_data ();
    }
    
    private void load_app_data () {
        var path = Path.build_filename(
                    get_bundle_path(),
                    "files",
                    "share",
                    "appdata",
                    "%s.appdata.xml".printf(id));
                    
        var file = File.new_for_path(path);
        
        if (file.query_exists ()) {
            var app = new As.App ();
            app.parse_file(path, As.AppParseFlags.NONE);
            name = app.get_name (null);
        } else {
            name = id;
        }
        
        var origin_path = Path.build_filename(
                            get_flatpak_directory(),
                            "repo",
                            "refs",
                            "remotes",
                            "appcenter",
                            "app",
                            id);
                            
        var origin_dir = File.new_for_path(origin_path);
        
        is_appcenter = false;
        
        if (origin_dir.query_exists()){
            is_appcenter = true;
        }

        icon_theme = Path.build_filename (
                        get_bundle_path (),
                        "export",
                        "share",
                        "icons");

        desktop_file_path = Path.build_filename (
                                get_bundle_path (),
                                "export",
                                "share",
                                "applications",
                                id + ".desktop");
    }

    private string get_bundle_path () {
        var flatpak_directory = get_flatpak_directory ();
        
        return Path.build_filename(flatpak_directory,"app",id,"current","active");
    }
    
    private static string get_flatpak_directory () {
        var user_dir = Path.build_filename(Environment.get_home_dir(),".local","share");
        var flatpak_user_dir = Path.build_filename(user_dir,"flatpak");
        return flatpak_user_dir;
    }
    
    public static void populate_app_list_store (GLib.ListStore apps) {
        var flatpak_user_dir = get_flatpak_directory ();
        var flatpak_app_dir = Path.build_filename(flatpak_user_dir,"app");
        
        var flatpak_directory = File.new_for_path(flatpak_app_dir);

        if (flatpak_directory.query_exists ()) {
            var flatpak_directory_children_enumerator = flatpak_directory.enumerate_children("*",FileQueryInfoFlags.NONE, null);
            var info = flatpak_directory_children_enumerator.next_file(null);
            
            while (info != null) {
                var file = flatpak_directory_children_enumerator.get_child (info);
                var app_id = Path.get_basename(file.get_path());
                
                var app_model = new AppModel (app_id);
                
                var is_appcenter_app = GothamApp.is_running_on_elementary () && app_model.is_appcenter;
                
                if(!is_appcenter_app && app_model.is_app_valid ()) {
                    apps.append(app_model);
                }

                info = flatpak_directory_children_enumerator.next_file(null);
            }
        }
    }

    public bool is_app_valid () {
        var desktop_file = File.new_for_path (desktop_file_path);
        return desktop_file.query_exists ();
    }
}
