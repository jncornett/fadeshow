$(function() {
    // Refresh web page every X seconds to get any new code updates
    setTimeout(function() {
        location.reload(true);
    }, 10000);

    $("body").click(function() {
        var el = $(".container");
        console.log("clicked");
        if ( el.fadeshow("started") ) {
            console.log("stopping");
            el.fadeshow("stop");
        } else {
            console.log("starting");
            el.fadeshow("start");
        }
    });

    $(".container").fadeshow({
        start: false,
        nextCallback: "shuffle",
        width: 500,
        fit: "stretch",
        interval: 1000,
        align: "center"
    });
});
