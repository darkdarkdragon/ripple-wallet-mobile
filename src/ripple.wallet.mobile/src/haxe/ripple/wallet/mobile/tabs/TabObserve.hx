package ripple.wallet.mobile.tabs;

import angular.service.TypedScope;
import angular.service.Scope;
import angular.service.RootScope;
import ripple.wallet.mobile.services.Id;

//typedef Observe {
//    account: String;
//}
//
typedef TabObserveScope = {
    > Scope,
                            noMore: Bool,
                            observed: Array<String>
                        }

/**
 * ...
 * @author Ivan Tivonenko
 */
class TabObserve {

    var id: Id;
    var scope: TypedScope<TabObserveScope>;
    var rootScope: RootScope;

    public function new(id: Id, scope: TypedScope<TabObserveScope>, rootScope: RootScope) {
        this.id = id;
        this.scope = scope;
        this.rootScope = rootScope;
        this.scope.observed = ['rFFdfdaaxS', 'ddd', 'fff'];

    }

}
