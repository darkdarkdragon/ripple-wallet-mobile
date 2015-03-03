package ripple.wallet.mobile.internal.jade;

import haxe.io.Path;
import haxe.macro.Context;

/**
 * ...
 * @author Ivan Tivonenko
 */
class Jade {

    static var jadePath = 'src/jade';

    #if macro

    static inline function compileJade(path: String, templateName: String) {
        var status = Sys.command('jade', [path]);
        if (status != 0) {
            Context.error('error compiling ${templateName}', Context.currentPos());
        }
    }

    #end

    /**
     *
     * @param templateName without suffix
     */
    macro static public function require(templateName: String) {
        var htmlPath = jadePath + '/' + templateName + '.html';
        var path = jadePath + '/' + templateName + '.jade';
//        trace(path);

        if (sys.FileSystem.exists(path)) {
            if (sys.FileSystem.exists(htmlPath)) {
                // check if need compiling
                var htmlStat = sys.FileSystem.stat(htmlPath);
                var jadeStat = sys.FileSystem.stat(path);
                if (jadeStat.mtime.getTime() > htmlStat.mtime.getTime()) {
                    trace('compiling jade template $templateName');
                    compileJade(path, templateName);
                } else {
//                    trace('file is good');
                }
            } else {
                compileJade(path, templateName);
            }

            var m = Context.getLocalClass().get().module;
            Context.registerModuleDependency(m, path);
        } else {
            Context.error('file ${templateName} not found', Context.currentPos());
        }
        if (!sys.FileSystem.exists(htmlPath)) {
            Context.error('error compiling ${templateName} - no html found', Context.currentPos());
        }

		var content = sys.io.File.getContent(htmlPath);
//        trace(content);

        return macro $v{content};
    }

}
