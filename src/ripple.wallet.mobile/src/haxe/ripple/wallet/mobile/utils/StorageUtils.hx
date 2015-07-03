package ripple.wallet.mobile.utils;

import haxe.Json;
import js.Browser;

/**
 * ...
 * @author Ivan Tivonenko
 */
class StorageUtils {

    public static function setToStorage(key: String, value: Dynamic): Bool {
        var storage = Browser.getLocalStorage();
        if (storage != null) {
            storage.setItem(key, Json.stringify(value));
            return true;
        }
        return false;
    }

    public static function getFromStorage(key: String): Dynamic {
        var res = null;
        var storage = Browser.getLocalStorage();
        if (storage != null) {
            var s = storage.getItem(key);
            try {
                res = Json.parse(s);
            } catch (e: Dynamic) {
            }
        }
        return res;
    }

    public static function removeFromStorage(key: String): Bool {
        var storage = Browser.getLocalStorage();
        if (storage != null) {
            storage.removeItem(key);
            return true;
        }
        return false;
    }

}
