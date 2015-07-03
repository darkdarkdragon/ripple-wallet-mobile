package ripple.wallet.mobile.services;

import haxe.Timer;
import js.Browser;
import thx.AnonymousMap;
import thx.Arrays;
import thx.Maps;
import thx.promise.Promise;
import thx.Error;

import angular.service.RootScope;

import ripple.lib.RippleRestClient;

using thx.Arrays;
using thx.Iterators;

/**
 * ...
 * @author Ivan Tivonenko
 */
class Balances {

    public var balances(get, never): UserBalances;
    // user address to balances
    public var othersBalances(get, never): Map<String, UserBalances>;

    var scope: RootScope;
    var id: Id;
    var api: RippleRestClient;

//    var currentRequest: Promise<Array<BalanceData>>;
    var _balances: UserBalances;
    var _othersBalances: Map<String, UserBalances>;
//    var _balancesSource: Array<{currency: String, counterparty: String, value: String}>;
//    var addresses2names: Map<String, String>;
    var gotBalancesAt: Float = 0;

    public function new(scope: RootScope, id: Id) {
        this.scope = scope;
        this.id = id;
        this.scope.watch('loginStatus', onLogin);
        this.api = new RippleRestClient();
        this._balances = { XRP: { value: '0', currency: 'XRP', issuer: ''},  Other: {} };
        this._othersBalances = new Map();
        this.setBalancesToScope();
    }

    function onLogin(v: Bool, v2: Bool) {
        trace('Balances::onLogin($v, $v2)');
        if (v) {
            this.load();
        } else {
            this._balances = { XRP: { value: '0', currency: 'XRP', issuer: ''},  Other: {} };
            this.setBalancesToScope();
        }
    }

    public function load() {
        if (this.id.loginStatus) {
            this.loadOther(this.id.address, true);
        }
    }

    public function loadOther(address: String, ?isMain = false) {
        this.setLoading(true);
        this.api.balances(address).either(function(v) {
            this.setLoading(false);
            trace(v);
            this.gotBalancesAt = Timer.stamp();
            var processed = this.processBalancesResult(v.balances);
            if (isMain) {
                this._balances = processed;
            } else {
                this._othersBalances.set(address, processed);
            }
            this.setBalancesToScope();
        }, function(e) {
            this.setLoading(false);
            trace(e);
            this.scope.apply(function() {
                this.scope.set('unfunded', e.message == 'actNotFound');
            });
        });
    }

    function setBalancesToScope() {
        var othersDyn = Maps.mapToObject(this._othersBalances);
        this.scope.safeApply(function() {
            trace('------------------');
            Browser.console.log(this._balances);
            this.scope.set('balances', this._balances);
            this.scope.set('othersBalances', othersDyn);
        });
    }

    function setLoading(v: Bool) {
        this.scope.safeApply(function() {
            this.scope.set('global_loading', v);
        });
    }

    function processBalancesResult(b: Array<{currency: String, counterparty: String, value: String}>) {
        var processed = { XRP: { value: '0', currency: 'XRP', issuer: '' },  Other: { } };
        Lambda.iter(b, function(a) {
            if (a.currency == 'XRP') {
                processed.XRP.value = a.value;
            } else {
                if (!Reflect.hasField(processed.Other, a.currency)) {
                    Reflect.setField(processed.Other, a.currency, { total: { value: '0', currency: a.currency, issuer: '' }, components: {} });
                }
                var entry = Reflect.field(processed.Other, a.currency);
                Reflect.setField(entry.components, a.counterparty, { value: a.value, currency: a.currency, issuer: a.counterparty });
                entry.total.value = Std.string( Iterators.reduce((new AnonymousMap(entry.components)).iterator(), function(a: Float, b) {
                    return a + Std.parseFloat(b.value);
                }, 0.));
            }
        });
        return processed;
    }


/*
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
*/

    inline function get_balances() {
        return this._balances;
    }

    inline function get_othersBalances() {
        return this._othersBalances;
    }

}

typedef UserBalances = {
    XRP: AmountData,
    // map of currency code to array of AmountData
    Other: Dynamic
}

typedef BalanceData = {
    currency: String,
    value: String
}
