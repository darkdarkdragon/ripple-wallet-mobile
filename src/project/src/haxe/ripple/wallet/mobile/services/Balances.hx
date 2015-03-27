package ripple.wallet.mobile.services;

import haxe.Timer;
import thx.core.Arrays;
import thx.promise.Promise;
import thx.core.Error;

import angular.service.RootScope;

import ripple.lib.RippleRestClient;

/**
 * ...
 * @author Ivan Tivonenko
 */
class Balances {

    public var balances(get, never): Array<BalanceData>;

    var scope: RootScope;
    var id: Id;
    var api: RippleRestClient;

    var currentRequest: Promise<Array<BalanceData>>;
    var _balances: Array<BalanceData>;
//    var _balancesSource: Array<{currency: String, counterparty: String, value: String}>;
    var addresses2names: Map<String, String>;
    var gotBalancesAt: Float = 0;

    public function new(scope: RootScope, id: Id) {
        this.scope = scope;
        this.id = id;
        this.scope.watch('loginStatus', onLogin);
        this.api = new RippleRestClient();
        this._balances = [];
        this.addresses2names = new Map();
    }

    function onLogin(v: Bool, v2: Bool) {
        trace('Balances::onLogin($v, $v2)');
        if (v) {
            this.getBalances();
        } else {
            this._balances = [];
        }
    }

    public function getBalances(): Promise<Array<BalanceData>> {
        trace('getBalances');
        if (!this.id.loginStatus) {
            return Promise.value([]);
        }
        if (this.currentRequest != null) return this.currentRequest;
        if (this._balances.length > 0 && Timer.stamp() - this.gotBalancesAt < 60) {
            return Promise.value( this._balances );
        }
        this.currentRequest = Promise.create(function(resolve : Array<BalanceData> -> Void, reject : Error -> Void) {
            api.balances(this.id.address).either(function(v) {
                trace(v);
                this.gotBalancesAt = Timer.stamp();
                this.currentRequest = null;
                this.processBalancesResult(v.balances);
                resolve(this._balances);
            }, function(e) {
                trace(e);
                this.currentRequest = null;
                this.scope.apply(function() {
                    this.scope.set('unfunded', e.message == 'actNotFound');
                });
                reject(e);
            });
        });
        return this.currentRequest;
    }

    function processBalancesResult(b: Array<{currency: String, counterparty: String, value: String}>) {
//        this._balancesSource = b;
//        this._balances = [];
        var cc = new Map<String, Int>();
        var toResolveAddresses = [];
        var toResolve = [];
        Lambda.iter(b, function(a) {
            if (cc.exists(a.currency)) {
                cc.set(a.currency, cc.get(a.currency) + 1);
            } else {
                cc.set(a.currency, 1);
            }
        });
        this._balances = Arrays.mapi(b, function(a, i) {
            var c = a.currency;
            if (cc.get(c) > 1) {
                // c = c + '.' + a.counterparty;
                if (this.addresses2names.exists(a.counterparty)) {
                    c = c + '.' + this.addresses2names.get(a.counterparty);
                } else {
                    toResolve.push(this.id.resolveAddress(a.counterparty));
                    toResolveAddresses.push(a.counterparty);
                }
            }
            return { currency: c, value: a.value };
        });
        if (toResolve.length > 0) {
            Promise.all(toResolve).success(function(names) {
                for (i in 0...names.length) {
                    this.addresses2names.set(toResolveAddresses[i], names[i]);
                }
                this.processBalancesResult(b);
            });
        }
        this.scope.broadcast('balancesUpdated');
    }

    inline function get_balances() {
        return this._balances;
    }


}

typedef BalanceData = {
    currency: String,
    value: String
}
