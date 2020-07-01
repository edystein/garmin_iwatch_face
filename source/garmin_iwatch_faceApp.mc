using Toybox.Application;
using Toybox.System;

class garmin_iwatch_faceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new garmin_iwatch_faceView() ];
    }

	function onSettingsChanged() {
		System.println("onSettingsChanged 1");
//		var x = Application.getApp().getProperty("TimeHourColor");
//		System.println("x: " + x);

		var x = Application.getApp().getProperty("TimeHourColor");
		System.println("x: " + x);


		WatchUi.requestUpdate();
	}

}