package ripple.wallet.mobile.tabs;

import angular.service.Scope;
import angular.service.TypedScope;
import haxe.Json;

import ripple.wallet.mobile.services.Id;
import ripple.wallet.mobile.services.Balances;


typedef TabBalancesScope = {
    > Scope,
                            resp: String,
                            unfunded: Bool,
                            balances: Array<{currency: String, value: String}>
                        }

/**
 * ...
 * @author Ivan Tivonenko
 */
class TabBalances {

    var scope: TypedScope<TabBalancesScope>;
    var id: Id;
    var balances: Balances;

    public function new(scope: TypedScope<TabBalancesScope>, id: Id, balances: Balances) {
        trace('TabBalances new');
        this.scope = scope;
        this.id = id;
        this.balances = balances;
        if (this.balances.balances.length > 0) {
            this.updateBalances();
        }
        this.scope.on('balancesUpdated', this.updateBalances);

//        this.scope.watch('loginStatus', onLogin);
//        if (this.id.loginStatus) {
//            this.onLogin(true, false);
//        }

    }


    function updateBalances() {
        this.scope.safeApply(function() {
            this.scope.resp = '';
            this.scope.balances = this.balances.balances;
        });
    }

/*
    function onLogin(v: Bool, v2: Bool) {
        if (v) {
            this.balances.getBalances().either(function(b) {
                this.scope.apply(function() {
                    this.scope.resp = '';
                    this.scope.balances = b;
                });
            }, function(e) {
                this.scope.apply(function() {
                    this.scope.resp = '';
                    this.scope.balances = [];
                });
            });
        } else {
            this.scope.apply(function() {
                this.scope.resp = '';
                this.scope.balances = [];
            });
        }
    }
*/

//    public function test1() {
//        trace('test 2');
//        var api = new RippleRestClient();
//        api.balances(this.id.address).either(function(v) {
//            trace(v);
//            this.scope.apply(function() {
////                this.scope.resp = Json.stringify(v);
//                this.scope.resp = '';
//                this.scope.balances = v.balances;
//            });
//        }, function(e) {
//            trace(e);
//            this.scope.apply(function() {
//                this.scope.unfunded = e.message == 'actNotFound';
//                this.scope.resp = Std.string(e);
//            });
//        });
//    }

}
