package ripple.wallet.mobile.directives;
import angular.service.Scope;

/**
 * ...
 * @author Ivan Tivonenko
 */
class Effects {

    /**
     * Slide box up or down
     * Usage: div(rmw-slide="entry.show")
     */
    public static function rmwSlide() {
        return {
            restrict: 'A',
            link: function(scope: Scope, element: Dynamic, attrs) {
                scope.watch(attrs.rmwSlide, function(value, oldValue) {
                    // don't animate on initialization
                    if (value == oldValue) {
                        if (value) {
                            element.css('maxHeight', '');
                        } else {
                            element.css({
                                maxHeight: 0,
                                overflow: 'hidden'
                            });
                        }
                        return;
                    }
                    if (value) {
                        element.css('maxHeight', '');
                        var height = element.height();
                        element.stop().animate(
                            {maxHeight: height},
                            350,
                            function () {
                                // remove maxHeight and overflow after animation completes
                                element.css('maxHeight', '');
                                element.css('overflow', '');
                            }
                        );
                    } else {
                        element.css({
                            maxHeight: element.height(),
                            overflow: 'hidden'
                        });
                        element.stop().animate(
                            {maxHeight: 0},
                            350
                        );
                    }
              });
            }
        }
    }

}
