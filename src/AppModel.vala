/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Justin Haygood <jhaygood86@gmail.com>
 */

public class AppModel : Object {
    public string id { get; construct; }
    public string icon_theme { get; private set; }
    public string desktop_file_path { get; private set; }
    
    private string? _name;

    private AppModel (string id) {
        Object(id : id);
        
        load_app_data ();
    }
    
    public string name {
        get {
            if(_name == null) {
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
                    _name = app.get_name (null);
                } else {
                    _name = id;
                }
            }

            return _name;
        }
    }

    private void load_app_data () {
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
    
    public static async void populate_app_list_store (GLib.ListStore apps, CompareDataFunc<Object> compare_func) {
        var flatpak_user_dir = get_flatpak_directory ();
        var flatpak_app_dir = Path.build_filename(flatpak_user_dir,"app");
        
        var flatpak_directory = File.new_for_path(flatpak_app_dir);

        if (yield query_exists_async(flatpak_directory)) {
            var flatpak_directory_children_enumerator = yield flatpak_directory.enumerate_children_async(FileAttribute.STANDARD_NAME,FileQueryInfoFlags.NONE);
            
            FileInfo info;

            while ((info = flatpak_directory_children_enumerator.next_file (null)) != null) {
                var file = flatpak_directory_children_enumerator.get_child (info);
                var app_id = Path.get_basename(file.get_path());
                
                //print("[%lld] found app: %s\n", get_monotonic_time (), app_id);

                var app_model = new AppModel (app_id);
                
                var is_appcenter_app = GothamApp.is_running_on_elementary () && yield app_model.is_on_appcenter ();
                
                if(!is_appcenter_app && yield app_model.is_app_valid ()) {
                    apps.insert_sorted(app_model, compare_func);
                }
            }
        }
    }

    public async bool is_app_valid () {
        var desktop_file = File.new_for_path (desktop_file_path);
        return yield query_exists_async (desktop_file);
    }

    public async bool is_on_appcenter () {
        var origin_path = Path.build_filename(
                            get_flatpak_directory(),
                            "repo",
                            "refs",
                            "remotes",
                            "appcenter",
                            "app",
                            id);

        var origin_dir = File.new_for_path(origin_path);

        return yield query_exists_async (origin_dir);
    }

    private static async bool query_exists_async (File file) {

        try {
            var info = yield file.query_info_async (FileAttribute.STANDARD_TYPE, FileQueryInfoFlags.NONE);
            return info != null;
        } catch (Error e) {
            return false;
        }
    }
}
