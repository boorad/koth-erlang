
var KOTH = {};

(function($, A) {

    $.ajaxSetup({
        cache: false, // http://twitter.com/#!/ericflo/status/10598118215122944
        accepts: {
            "koth"   : "application/koth-v1+json",
            "erlauth": "application/erlauth-v1+json"
        },
        converters: {
            "text koth"   : jQuery.parseJSON,
            "text erlauth": jQuery.parseJSON
        }
    });

    $(document).ready(function() {
        A.init_forms();
        if( !Auth.getUser(A.get_user_callback) ) {
            A.not_logged_in();
        }
        $("#msg").ajaxError(function(e, req, settings) {
            if( settings.url.substr(0,10) == "/api/user/" ) {
                A.not_logged_in();
            } else {

            }
        });
        A.handle_hash();
    });


    $.extend(true, A, {

        init_forms: function() {
            $("#login-form").submit(function() {
                A.login( $(this) );
            });
            $("#register-form").submit(function() {
                A.fill_register_profile( $(this) );
                A.register( $(this) );
            }).validate({
                rules: {
                    register_password1: "required",
                    register_password2: {
                        equalTo: "#register_password1"
                    }
                }
            });
        },

        get_user_callback: function(user, status, xhr) {
            if( status == "success" ) {
                if (user) {
                    A.logged_in(user);
                } else {
                    A.not_logged_in();
                }
            } else {
                A.not_logged_in();
            }
        },

        handle_hash: function() {
            var hash = location.hash;
            if( hash == "#register" ) {
                $("#register-wrapper").show();
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
            Auth.clearCookies();
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
            $("#register-wrapper").toggle();
            $("#register-form").show();
            $("#register-success").hide();
        },

        login: function(form) {
            $("#login-button").hide();
            var str = form.serialize();
            $.ajax({
                type: "POST",
                url: "/api/login",
                data: str,
                dataType: "erlauth",
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
        },

        // to be erlauth-compliant and have a register_profile field in form
        fill_register_profile: function(form) {
            var first = $("#register_first").val();
            var last = $("#register_last").val();
            var timezone = $("#register_timezone").val();
            $("#register_profile").val(JSON.stringify({
                first: first,
                last: last,
                timezone: timezone
            }));
        },

        register: function(form) {
            $("#register-button").hide();
            var str = form.serialize();
            $.ajax({
                type: "POST",
                url: "/api/register",
                data: str,
                dataType: "erlauth",
                success: A.register_callback,
                error: function(xhr, status, error) {
                    var msg = "";
                    if( xhr && xhr.status ) {
                        switch( xhr.status ) {
                        case 409:
                            msg = "Username already exists.";
                            break;
                        case 502:
                        default:
                            msg = "There was an error on the server while " +
                                "registering.";
                        }
                    }
                    $("#register-error").text(msg);
                }
            });
            $("#register-button").show();
        },

        register_callback: function(user, status, xhr) {
            $("#register-error").text("");
            $("#register-form").hide();
            $("#register-success").show();
        }

    });

})(jQuery, KOTH);
