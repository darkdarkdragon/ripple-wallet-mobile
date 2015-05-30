package ripple.wallet.mobile.tabs;

import angular.service.RootScope;
import angular.service.Scope;
import angular.service.TypedScope;
import ripple.wallet.mobile.services.History;
import ripple.wallet.mobile.services.Id;

typedef TabHistoryScope = {
    > Scope,
                            noMore: Bool
                        }

/**
 * ...
 * @author Ivan Tivonenko
 */
class TabHistory {

    var id: Id;
    var rootScope: RootScope;
    var scope: TypedScope<TabHistoryScope>;
    var history: History;

    public function new(id: Id, rootScope: RootScope, scope: TypedScope<TabHistoryScope>, history: History) {
        this.id = id;
        this.rootScope = rootScope;
        this.scope = scope;
        this.history = history;
        this.setLoading(true);
        this.loadMore();
        this.scope.watch('loginStatus', onLogin);
    }

    public function loadMore() {
        this.setLoading(true);
        this.history.loadNext().success(function(v) {
            this.setLoading(false);
            this.scope.safeApply(function() {
                this.scope.noMore = !v;
            });
        });
    }

    function onLogin(v: Bool, v2: Bool) {
        if (v) {
            this.loadMore();
        }
    }

    function setLoading(v: Bool) {
        this.rootScope.safeApply(function() {
            this.rootScope.set('global_loading', v);
        });
    }

}
