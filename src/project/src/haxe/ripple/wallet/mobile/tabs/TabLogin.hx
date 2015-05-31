package ripple.wallet.mobile.tabs;

import angular.route.Route;
import angular.service.Location;
import angular.service.Scope;
import angular.service.Timeout;
import angular.service.TypedScope;
import haxe.Timer;
import ripple.wallet.mobile.services.Id;

/**
 * ...
 * @author Ivan Tivonenko
 */

typedef Message = {
    backend: String,
    message: String
}

typedef TabLoginScope = {
    > Scope,
                            user: {
                                firstName : String,
                                lastName : String
                            },
                            username: String,
                            password: String,
                            verifying: String,
                            status: String,
                            backendMessages: Array<Message>,
                            ajax_loading: Bool
                        }

class TabLogin {

    var location: Location;
    var scope: TypedScope<TabLoginScope>;
    var route: Route;
    var timeout: Timeout;
    var id: Id;

    public function new(scope: TypedScope<TabLoginScope>, location: Location, route: Route, id: Id, timeout: Timeout) {
        trace('TabLogin new');
        this.location = location;
        this.scope = scope;
        this.route = route;
        this.timeout = timeout;
        this.id = id;
        trace(this.route.routes);
        trace(this.route.current);
        //scope.set("data", {username: 'Test user'} );
        scope.user = {
            firstName: 'Ivan',
            lastName: 'Hottabich'
        }
//        scope.ajax_loading = true;
    }

//    @:keep public function goBalance() {
//        trace('BBBBBBBB');
//        location.path('/balance');
//    }

    @:keep public function submitForm() {
        trace('submitForm!!! ${scope.username} ${scope.password}');
//        trace(this.route.routes);
//        trace(this.route.current);
//        this.route.updateParams({ d: 2 });
        this.scope.status = '';
        this.scope.backendMessages = [];
        this.scope.ajax_loading = true;

        this.id.login(this.scope.username, this.scope.password).either(function(blob) {
            trace('----- blob:');
            trace(blob);
            this.scope.apply(function() {
                this.scope.ajax_loading = false;
                this.scope.status = 'Login successful.';
                this.timeout.timeout(function() {
                    this.location.path('/');
                }, 300);
            });
        }, function(e) {
            trace('----- error:');
            trace(e);
            this.scope.apply(function() {
                this.scope.ajax_loading = false;
                this.scope.status = 'Login error.';
                this.scope.backendMessages = [
                    {
                        backend: 'error:',
                        message: Std.string(e)
                    }
                ];
            });
        });
        /*
        Timer.delay(function() {
            this.scope.apply(function() {
                this.scope.ajax_loading = false;
                this.scope.status = 'Got bad result.';
                this.scope.backendMessages = [
                    {
                        backend: 'from backend!',
                        message: 'got message'
                    }
                ];
            });
        }, 3000);
        */
    }

}
