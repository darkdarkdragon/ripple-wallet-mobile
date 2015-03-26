package ripple.wallet.mobile.services;

import angular.service.Location;
import angular.service.RootScope;
import haxe.Json;
import js.Browser;
import thx.core.UUID;
import thx.promise.Promise;
import thx.core.Error;

using StringTools;

import ripple.vaultclient.VaultClient;
import ripple.vaultclient.BlobObj;


/**
 * ...
 * @author Ivan Tivonenko
 */
class Id {

    public var loginStatus(get, never): Bool;
    public var username(get, never): String;

    var client: VaultClient;
    var scope: RootScope;

    var _isLoggedIn = false;
    var _username: String = '';

    public function new(scope: RootScope) {
        this.client = new VaultClient(Options.domain);
        this.scope = scope;
    }

    /**
     *
     * @return login status
     */
    public function init(): Promise<Bool> {
        trace('id::init');
        var ripple_auth = this.getStoredRippleAuth();
        if (ripple_auth != null) {
            return this.relogin().mapSuccess(function(b) {
                if (b == null) {
                    this.logout();
                }
                trace('id::init result is ${b != null}');
                return b != null;
            });
        }
        return Promise.value(false);
    }

    function getStoredRippleAuth(): RippleAuthSaved {
        var ripple_auth = this.getFromStorage('ripple_auth');
        if (ripple_auth != null) {
            var ripple_auth_d = null;
            try {
                ripple_auth_d = Json.parse(ripple_auth);
                if (ripple_auth_d.username == null ||
                    ripple_auth_d.url == null ||
                    ripple_auth_d.keys == null ||
                    ripple_auth_d.keys.id == null ||
                    ripple_auth_d.keys.crypt == null) {
                        ripple_auth_d = null;
                        throw 'bad';
                }
            } catch (e: Dynamic) {
                trace('error: ');
                trace(e);
                this.removeFromStorage('ripple_auth');
            }
            return ripple_auth_d;
        }
        return null;
    }

    public function logout() {
        this.removeFromStorage('ripple_auth');
        this.scope.apply(function() {
            this._username = '';
            this.scope.set('userBlob', {});
            this.scope.set('userCredentials', { username: '', account: '' } );
            this.scope.set('loginStatus', this.loginStatus);
        });
    }

    public function relogin(): Promise<BlobObj> {
        var ripple_auth = this.getStoredRippleAuth();
        if (ripple_auth != null) {
            return this.client.relogin(ripple_auth.url, ripple_auth.keys.id, ripple_auth.keys.crypt, this.getDeviceID(ripple_auth.username)).success(function(v) {
                this.scope.apply(function() {
                    trace('re-logged in! ${ripple_auth.username} ${v.data.account_id}');
                    this._isLoggedIn = true;
                    this._username = ripple_auth.username;
                    this.scope.set('userBlob', v);
                    this.scope.set('userCredentials', { username: this.username, account: v.data.account_id } );
                    this.scope.set('loginStatus', this.loginStatus);
                    var keys = {
                        id    : v.id,
                        crypt : v.key
                    };
                    this.storeLoginKeys(v.url, this.username, keys);
                    this.setDeviceID(username, v.deviceId);
                });
            });
        }
        return Promise.error(new Error('no auth data'));
    }

    public function login(username: String, password: String): Promise<BlobObj> {
        var deviceId = this.getDeviceID(username);
        if (deviceId == null) {
            deviceId = UUID.create();
        }

        return this.client.login(this.normalizeUsernameForInternals(username), password, deviceId).mapSuccess(function(v) {
            this.scope.apply(function() {
                trace('logged in!');
                trace(v);
                this._isLoggedIn = true;
                this._username = v.username;
                this.scope.set('userBlob', v.blob);
                this.scope.set('userCredentials', { username: this.username, account: v.blob.data.account_id } );
                this.scope.set('loginStatus', this.loginStatus);
                var keys = {
                    id    : v.blob.id,
                    crypt : v.blob.key
                };
                this.storeLoginKeys(v.blob.url, v.username, keys);
                this.setDeviceID(username, v.blob.deviceId);
            });
            return v.blob;
        });
    }

    function storeLoginKeys(url: String, username: String, keys: { id: String, crypt: String }) {
        this.setToStorage('ripple_auth', Json.stringify({url:url, username: username, keys: keys}));
    }

    function setToStorage(key: String, value: String): Bool {
        var storage = Browser.getLocalStorage();
        if (storage != null) {
            storage.setItem(key, value);

        }
        return false;
    }

    function getFromStorage(key: String): String {
        var storage = Browser.getLocalStorage();
        if (storage != null) {
            return storage.getItem(key);
        }
        return null;
    }

    function removeFromStorage(key: String): Bool {
        var storage = Browser.getLocalStorage();
        if (storage != null) {
            storage.removeItem(key);
            return true;
        }
        return false;
    }

    function setDeviceID(username: String, deviceId: String) {
        username = this.normalizeUsernameForInternals(username);
        this.setToStorage(username + '|device_id', deviceId);
    }

    function getDeviceID(username: String): String {
        username = this.normalizeUsernameForInternals(username);
        return getFromStorage(username + '|device_id');
    }

    /**
     * Reduce username to standardized form.
     *
     * This version is used in the login system and it's the version sent to
     * servers.
     */
    function normalizeUsernameForInternals(username: String) {
        // Strips whitespace at beginning and end.
        username = username.trim();

        // Remove hyphens
        username = username.replace('-', '');

        // All lowercase
        username = username.toLowerCase();

        return username;
    }

    inline function get_loginStatus(): Bool {
        return this._isLoggedIn;
    }

    inline function get_username(): String {
        return this._username;
    }

}

typedef RippleAuthSaved = {
    username: String,
    url: String,
    keys: {
        id: String,
        crypt: String
    }
}
