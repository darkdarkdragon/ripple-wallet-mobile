package ripple.wallet.mobile.directives;

import angular.service.Filter;
import angular.service.Scope;

import ripple.wallet.mobile.services.Id;

/**
 * ...
 * @author Ivan Tivonenko
 */
class Formatters {

    public static function rmwPrettyIdentity(id: Id, filter: Filter) {
        return {
            restrict: 'A',
            transclude: false,
            scope: {
                identity: '=rmwPrettyIdentity'
            },
            template: '{{identity | rmwRippleName:{tilde:true} }}',
            link: function (scope: Scope, element, attr) {
                var address: String = scope.get('identity');
//                trace('identity = $address');
                if (!id.addressDontHaveName(address)) {
//                    trace('starting to resolve $address ...');
                    id.resolveAddress(address).success(function(name) {
//                        trace('$address resolved to $name');
                        var named = filter('rmwRippleName')(scope.get('identity'), { tilde:true } );
//                        trace('named: $named');
                        scope.safeApply(function() {
                            scope.set('identity', named);
                        });
                        //element.text(named);
                    });
                }
            }
        }
    }

    public static function rmwPrettyAmount(id: Id, filter: Filter) {
        return {
            restrict: 'A',
            transclude: false,
            scope: {
                amount: '=rmwPrettyAmount'
            },
            template: '<span class="value">{{amount | rmwAmount }}</span> ' +
                '<span class="currency" rmw-currency="amount"></span>',
            link: function (scope: Scope, element, attr) {
                /*
                var address: String = scope.get('amount');
                trace(address);
                if (!id.addressDontHaveName(address)) {
                    trace('resolving...');
                    id.resolveAddress(address).success(function(name) {
                        trace('resolved to $name');
                        var named = filter('rmwRippleName')(scope.get('identity'), { tilde:true } );
                        trace('named: $named');
                        scope.safeApply(function() {
                            scope.set('identity', named);
                        });
                        //element.text(named);
                    });
                }
                */
            }
        }
    }

    public static function rmwCurrency(id: Id, filter: Filter) {
        return {
            restrict: 'A',
            transclude: false,
            scope: {
                amount: '=rmwCurrency'
            },
            template: '{{ currency }}',
            link: function (scope: Scope, element, attr) {
                var amount: Dynamic = scope.get('amount');
                var currencyRes: String = '';
                if (Std.is(amount, String)) {
                    currencyRes = amount;
                } else if (Reflect.hasField(amount, 'currency')) {
                    var currency: String = Reflect.field(amount, 'currency');
                    currencyRes = currency;
                    if (Reflect.hasField(amount, 'issuer') && Reflect.field(amount, 'issuer') != null && Reflect.field(amount, 'issuer').length > 0) {
                        var issuer = Reflect.field(amount, 'issuer');
                        var issuerName = id.resolveAddressSync(issuer);
                        currencyRes = currency + '.' + issuerName;
                        if (issuerName == issuer && !id.addressDontHaveName(issuer)) {
                            id.resolveAddress(issuer).success(function(name) {
                                currencyRes = currency + '.' + name;
                                scope.safeApply(function() {
                                    scope.set('currency', currencyRes);
                                });
                            });
                        }
                    }
                } else {
                    currencyRes = Std.string(amount);
                }
                scope.safeApply(function() {
                    scope.set('currency', currencyRes);
                });
            }
        }
    }

    /**
     * Adds spacing around span tags.
     */
    public static function rmwSpanSpacing() {
        return {
            restrict: 'EA',
            compile: function (element, attr, linker) {
                element.find('> span').before(' ').after(' ');
            }
        };
    }
}
