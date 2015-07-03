package ripple.wallet.mobile;

import angular.Angular;
import angular.route.RouteProvider;
import angular.service.RootScope;
import angular.service.Scope;
import haxe.Json;
import js.Browser;
import js.Lib;
import ripple.wallet.mobile.directives.Effects;
import ripple.wallet.mobile.directives.Formatters;
import ripple.wallet.mobile.filters.RMWFilters;
import ripple.wallet.mobile.internal.jade.Jade;
import ripple.wallet.mobile.services.Balances;
import ripple.wallet.mobile.services.History;
import ripple.wallet.mobile.services.Id;
import ripple.wallet.mobile.tabs.TabObserve;
import ripple.wallet.mobile.utils.StorageUtils;

import ripple.wallet.mobile.tabs.TabHistory;
import ripple.wallet.mobile.tabs.TabLogin;
import ripple.wallet.mobile.tabs.TabBalances;

/**
 * ...
 * @author Ivan Tivonenko
 */

@:injectionName("$ionicPlatform")
extern class IonicPlatform {
    function ready(x: Void -> Void): Void;
}

@:injectionName("$stateProvider")
extern class StateProvider {
    function state(name: String, x2: Dynamic): StateProvider ;
}

@:injectionName("$urlRouterProvider")
extern class UrlRouterProvider {
    function otherwise(url: String): Void;
}




class Main {

	static var _appScope: Scope;

    static function appController(scope: Scope) {
//        trace("appController initialized");
//        scope.set("data", { appName : 'Wallet' } );
//        _appScope = scope;
    }

	static function startup(id: Id, scope: RootScope, ionicPlatform: IonicPlatform) {
        trace("startup");

        Browser.document.addEventListener('deviceready', onDeviceReady, false);

//        trace(Jade.require('../../../../../src/jade/i.jade'));
        trace(Jade.require('i'));
        id.init();
        scope.safeApply(function() {
            scope.set('logout', function() {
                id.logout();
                Browser.window.setTimeout(function() {
                    Browser.location.reload();
                }, 100);
            });

            var observed = StorageUtils.getFromStorage('observed');
            if (observed == null) {
                observed = { };
            }
            scope.set('observed', observed);
        });

        ionicPlatform.ready(function() {
            // Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
            // for form inputs)
            if (untyped Browser.window.cordova && untyped Browser.window.cordova.plugins.Keyboard) {
                untyped cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true);
            }
            if (untyped Browser.window.StatusBar) {
                // org.apache.cordova.statusbar required
//                StatusBar.styleDefault();
            }
      });

    }

    // result contains any message sent from the plugin call
    static function successHandler(result) {
        trace('pushNotification Callback Success! Result = ' + result);
    }

    static function errorHandler(error) {
        trace('pushNotification callback errorHandler ' + error);
    }

    static function onDeviceReady(e: Dynamic) {
        trace('onDeviceReady');
        Main.receivedEvent('deviceready', e);

        var pushNotification: Dynamic = untyped Browser.window.plugins.pushNotification;
        if (pushNotification) {
            pushNotification.register(successHandler, errorHandler,{'senderID': '295830929128', 'ecb': 'appClass.onNotificationGCM'});
        } else {
            trace('Error: pushNotification plugin not available');
        }
        var device: Dynamic = untyped Browser.window.device;
        if (device) {
            trace('manufacturer: ' + device.manufacturer);
            trace('platform: ' + device.platform);
            trace('model: ' + device.model);
            trace('version: ' + device.version);
        }
        trace('onDeviceReady end');
    }

    static function onNotificationGCM(e: Dynamic) {
        trace('onNotificationGCM ' + Std.string(e));
        if (e) {
            trace(Json.stringify(e));
        }
        var w = Browser.window;
        switch( e.event ) {
            case 'registered':
                if ( e.regid.length > 0 ) {
                    w.console.log("Regid " + e.regid);
                    //alert('registration id = '+e.regid);
                }

            case 'message':
                // this is the actual push notification. its format depends on the data model from the push server
                w.console.log('message = ' + e.message+' msgcnt = ' + e.msgcnt);
                if (_appScope != null) {
                    _appScope.apply(function() {
                        var mess = 'empty';
                        if (e.payload && e.payload.payment) {
                            var p = e.payload.payment;
                            mess = 'got ${p.amountHuman} from ${p.account}';
                        }
                        _appScope.set("message", mess);
                    });
                } else {
                    trace('_appScope is null!');
                }

            case 'error':
                w.console.log('GCM error = ' + e.msg);

            default:
                w.console.log('An unknown GCM event has occurred');
                w.console.log(e);
        }
    }

    static function receivedEvent(id: String, e: Dynamic) {
        trace('Received Event: ' + id);
        return;
        //Main.receivedEvent('deviceready');
        var document = Browser.document;
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        trace('Received Event: ' + id);
    }

//    static function config(route: RouteProvider) {
    static function config(stateProvider: StateProvider, urlRouterProvider: UrlRouterProvider) {
        stateProvider
            .state('app', {
                url: "/app",
                'abstract': true,
                templateUrl: "templates/menu.html",
                controller: 'AppController'
            })
            .state('app.history', {
                url: "/history",
                views: {
                    'menuContent': {
//                        templateUrl: "templates/tabs/history.html",
                        template: Jade.require('tabs/history'),
                        controllerAs: 'history',
                        controller: 'TabHistoryCtrl'
                    }
                }
            })
            .state('app.balance', {
                url: "/balance",
                views: {
                    'menuContent': {
                        controller: 'TabBalanceCtrl',
                        controllerAs: 'balance',
                        template: Jade.require('tabs/balance'),
                    }
                }
            })
            .state('app.observe', {
                url: "/observe",
                views: {
                    'menuContent': {
                        controller: 'TabObserveCtrl',
                        controllerAs: 'observe',
                        template: Jade.require('tabs/observe'),
                    }
                }
            })
            .state('app.login', {
                url: "/login",
                views: {
                    'menuContent': {
//                        templateUrl: "templates/playlist.html",
                        template: Jade.require('tabs/login'),
                        controller: 'TabLoginCtrl'
                    }
                }
            });
        // if none of the above states are matched, use this as the fallback
        urlRouterProvider.otherwise('/app/balance');

        /*
        var route: RouteProvider = null;
        route.when('/', { templateUrl:'home.html', reloadOnSearch: false } );
        route.when('/login', {
//            controller: TabLogin.new,
            controller: 'TabLoginCtrl',
            controllerAs: 'login',
            template: Jade.require('tabs/login'),
            reloadOnSearch: false
        });
        route.when('/history', {
//            controller: TabLogin.new,
            controller: 'TabHistoryCtrl',
            controllerAs: 'history',
            template: Jade.require('tabs/history'),
            reloadOnSearch: false
        });
        route.when('/observe', {
//            controller: TabLogin.new,
            controller: 'TabObserveCtrl',
            controllerAs: 'observe',
            template: Jade.require('tabs/observe'),
            reloadOnSearch: false
        });
        var balanceCfg = {
            controller: 'TabBalanceCtrl',
            controllerAs: 'balance',
            template: Jade.require('tabs/balance'),
            reloadOnSearch: false
        };
        route.when('/balance', balanceCfg);
//        route.when('/', balanceCfg);
//        route.otherwise('/balance');
        */
    }


	static function main() {
        @:keep untyped Browser.window.appClass = untyped ripple.wallet.mobile.Main;
        Browser.window.console.log('Hello!');
        var module =
//            Angular.module("mobileWallet", ['ngRoute', 'mobile-angular-ui'])
            Angular.module("mobileWallet", ['ionic'])
            .config(config)
            // no need give the factory a name,
            // the link is created by the types
//            .factory(Config.new)
            .factory(Id.new)
            .factory(Balances.new)
            .factory(History.new)
            .filter('rmwAmount', RMWFilters.rmwAmount)
            .filter('rmwRippleName', RMWFilters.rmwRippleName)
            .directive('rmwPrettyIdentity', Formatters.rmwPrettyIdentity)
            .directive('rmwPrettyAmount', Formatters.rmwPrettyAmount)
            .directive('rmwCurrency', Formatters.rmwCurrency)
            .directive('rmwSpanSpacing', Formatters.rmwSpanSpacing)
            .directive('rmwSlide', Effects.rmwSlide)
            .controller("AppController", appController)
            .controller("TabLoginCtrl", TabLogin.new)
            .controller("TabBalanceCtrl", TabBalances.new)
            .controller("TabHistoryCtrl", TabHistory.new)
            .controller("TabObserveCtrl", TabObserve.new)
            .run(startup);
	}

}
