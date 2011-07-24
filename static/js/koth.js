
var KOTH = {};

(function($, A) {

    // http://twitter.com/#!/ericflo/status/10598118215122944
    $.ajaxSetup({cache: false});

    $(document).ready(function() {
        A.init_login();
        if( !Auth.getUser(A.get_user_callback) ) {
            A.not_logged_in();
        }
    });


    $.extend(true, A, {

        init_login: function() {
            $("#login-form").submit(function() {
                A.login( $(this) );
            });
        },

        get_user_callback: function(user, status, xhr) {
            if( status == "success" ) {
                if (user) {
                    A.logged_in(user);
                } else {
                    A.not_logged_in();
                }
            }
        },

        logged_in: function(user) {
            $("#login-form-wrapper").hide();
            $("#welcome").text(user.profile.first);
            $("#not-logged-in").hide();
            $("#logged-in").show();
            $("#landing-wrapper").hide();
            $("#koth-wrapper").show();
        },

        not_logged_in: function() {
            $("#welcome").empty();
            $("#not-logged-in").show();
            $("#logged-in").hide();
            $("#landing-wrapper").show();
            $("#koth-wrapper").hide();
        },

        toggle_login: function() {
            $("#login-form-wrapper").toggle();
        },

        toggle_register: function() {
            $("#register-form-wrapper").toggle();
        },

        login: function(form) {
            $("#login-button").hide();
            var str = form.serialize();
            $.ajax({
                type: "POST",
                url: "/api/login",
                data: str,
                dataType: "json",
                success: A.get_user_callback,
                error: function(xhr, status, error) {
                    var msg = "";
                    if( xhr && xhr.status ) {
                        switch( xhr.status ) {
                        case 403:
                            msg = "Username or password is incorrect.";
                            break;
                        case 502:
                        default:
                            msg = "There was an error on the server while logging in.";
                        }
                    }
                    $("#login-error").text(msg);
                }
            });
            $("#login-button").show();
        },

        logout: function() {
            Auth.clearCookies();
            window.location = "/";
        }

    });

})(jQuery, KOTH);
