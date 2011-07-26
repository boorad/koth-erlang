//= require "contrib/base64"

var Auth = {};

(function($) {

    var Cache = {};

    Cache.exists = function(f, input) {
        return f.cachedInput === input;
    };
    Cache.get = function(f) {
        return f.cachedOutput;
    };
    Cache.clear = function(f) {
        f.cachedInput = null;
        f.cachedOutput = null;
    };
    Cache.set = function(f, input, output) {
        f.cachedInput = input;
        f.cachedOutput = output;
        return output;
    };

    Auth.getCookie = function() {
        if (Cache.exists(this, document.cookie)) return Cache.get(this);

        var cookies = document.cookie.split(';');
        for (var i in cookies) {
            var bits = cookies[i].split('=');
            if ($.trim(bits[0]) == 'AuthSession') {
                return Cache.set(this, document.cookie, bits[1]);
            }
        }
        return null;
    };

    Auth.setUsernum = function(user) {
        // cache the usernum
        Cache.set(Auth.getUsernum, Auth.getCookie(), user);
    };

    Auth.getUsernum = function() {
        if (Cache.exists(this, Auth.getCookie())) return Cache.get(this);
        var cookie = Auth.getCookie();
        if (cookie) {
            var parts = Base64.decode(cookie).split(':');
            var u = parts[0];
            //console.log("parts:", parts);
            return Cache.set(this, Auth.getCookie(), u);
        } else {
            return null;
        }
    };

    Auth.getUser = function(callback) {
        var usernum = Auth.getUsernum();
        if( !usernum ) return null;
        var url = "/api/user/" + usernum;
        $.get(url, '', callback, "koth");
        return usernum; // something not null
    };

    Auth.clearCookies = function() {
        Cache.clear(Auth.getCookie);
        Cache.clear(Auth.getUsernum);
        document.cookie = 'AuthSession=;expires=Thu, 01-Jan-70 00:00:01 GMT';
    };

})(jQuery);
