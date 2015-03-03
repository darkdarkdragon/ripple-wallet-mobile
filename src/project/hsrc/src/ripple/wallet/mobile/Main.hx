package ripple.wallet.mobile;

import angular.Angular;
import angular.route.RouteProvider;
import angular.service.Scope;
import haxe.Json;
import js.Browser;
import js.Lib;
import ripple.wallet.mobile.internal.jade.Jade;

import ripple.wallet.mobile.tabs.TabLogin;
import ripple.wallet.mobile.tabs.TabBalances;

/**
 * ...
 * @author Ivan Tivonenko
 */

class Main {

	static var _appScope: Scope;

    static function appController(scope: Scope) {
//        trace("appController initialized");
//        scope.set("data", { appName : 'Wallet' } );
//        _appScope = scope;
    }

	static function startup() {
        trace("startup");

        Browser.document.addEventListener('deviceready', onDeviceReady, false);

//        trace(Jade.require('../../../../../src/jade/i.jade'));
        trace(Jade.require('i'));
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

    static function config(route: RouteProvider) {
        route.when('/', { templateUrl:'home.html', reloadOnSearch: false } );
        route.when('/login', {
//            controller: TabLogin.new,
            controller: 'TabLoginCtrl',
            controllerAs: 'login',
            template: Jade.require('login'),
            reloadOnSearch: false
        });
        var balanceCfg = {
            controller: 'TabBalanceCtrl',
            controllerAs: 'balance',
            template: Jade.require('balance'),
            reloadOnSearch: false
        };
        route.when('/balance', balanceCfg);
//        route.when('/', balanceCfg);
//        route.otherwise('/balance');
    }


	static function main() {
        @:keep untyped Browser.window.appClass = untyped ripple.wallet.mobile.Main;
        Browser.window.console.log('Hello!');
        var module =
            Angular.module("mobileWallet", ['ngRoute', 'mobile-angular-ui'])
            .config(config)
            // no need give the factory a name,
            // the link is created by the types
//            .factory(Config.new)
            .controller("AppController", appController)
            .controller("TabLoginCtrl", TabLogin.new)
            .controller("TabBalanceCtrl", TabBalances.new)
            .run(startup);
	}

}
