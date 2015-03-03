package ripple.wallet.mobile.tabs;

import angular.service.Location;
import angular.service.Scope;
import angular.service.TypedScope;

/**
 * ...
 * @author Ivan Tivonenko
 */

typedef TabLoginScope = {
                            user: {
                                firstName : String,
                                lastName : String
                            }
                        }
class TabLogin {

    var location: Location;

    public function new(scope: TypedScope<TabLoginScope> , location: Location) {
        trace('TabLogin new');
        this.location = location;
        //scope.set("data", {username: 'Test user'} );
        scope.user = {
            firstName: 'Ivan',
            lastName: 'Hottabich'
        }
    }

    @:keep public function goBalance() {
        trace('BBBBBBBB');
        location.path('/balance');
    }

}
