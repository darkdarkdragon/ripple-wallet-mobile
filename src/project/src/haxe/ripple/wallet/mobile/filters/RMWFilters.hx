package ripple.wallet.mobile.filters;

import ripple.wallet.mobile.services.Id;

/**
 *
 * (c) 2015 Ivan Tivonenko
 * @author Ivan Tivonenko
 */
class RMWFilters {

    public static function rmwAmount(id: Id) {
        return function(x: Dynamic, ?options: { showCurrency: Bool} ): String {
//            trace('rmwAmount($x)');
//            if (Std.is(x, String)) {
//                trace('is string');
//            }
//            trace(Type.typeof(x));
            var res = '';
            var showCurrency = options != null && options.showCurrency ? true : false;
            switch (Type.typeof(x)) {
                case TObject:
                    var cur = x.currency;
                    if (x.issuer != null && x.issuer.length > 0) {
                        cur = cur + '.' + id.resolveAddressSync(x.issuer);
                    }
                    return showCurrency ? x.value + ' ' + cur : x.value;
                default:
                    res = Std.string(x);
            }
            return res;
        }
    }

    public static function rmwRippleName(id: Id) {
        return function(address: String, ?options: { tilde: Bool }): String {
//            trace('rmwRippleName($address)');
//            if (Std.is(address, String)) {
//                trace('is string');
//            }
//            trace(Type.typeof(address));
            var res = id.resolveAddressSync(address);
            if (options != null && options.tilde && res != address) {
                res = '~' + res;
            }
//            trace('res: $res');
            return res;
        }
//        untyped f.$stateful = true;
//        return f;
    }

}
