using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;


function getDate(){
	var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
	var dateString = Lang.format(
	    "$1$ $2$",
	    [
	        today.day_of_week,
	        today.day,
	    ]
	);
	return dateString;
}

class garmin_iwatch_faceView extends WatchUi.WatchFace {
	var params = {
		"batt_status"=> {"high"=> 70, "low"=> 30, "x"=> .43, "y"=> .05},
		"floors_climbed" => {"x"=> .8, "y"=> .45},
		"bluetooth" => {"x"=> .7, "y"=> .15} 
		};
    var myBitmap;
    var bitmapbBattStatus;
    var bitmapIcons;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
		// set battery    
	    myBitmap = WatchUi.loadResource(Rez.Drawables.BatteryMed);
	    bitmapbBattStatus = {
	    	"low"=> WatchUi.loadResource(Rez.Drawables.BatteryLow), 
	    	"med"=> WatchUi.loadResource(Rez.Drawables.BatteryMed), 
	    	"high"=> WatchUi.loadResource(Rez.Drawables.BatteryHigh)
	    	};

	    bitmapIcons = {
	    	"floors_climbed"=> WatchUi.loadResource(Rez.Drawables.FloorsClimbed),
	    	"bluetooth"=> WatchUi.loadResource(Rez.Drawables.Bluetooth) 
	    	};
	    
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
//        // Get and show the current time
//        var clockTime = System.getClockTime();
//        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
//        var view = View.findDrawableById("TimeLabel");
//        view.setText(timeString);

//		System.println( "Hello Monkey C!" );
        // Get and show Hour
        var clockTime = System.getClockTime();


        var timeString = Lang.format("$1$", [clockTime.hour]);
        var view = View.findDrawableById("TimeLabelHour");
        view.setText(timeString);

        timeString = Lang.format("$1$", [clockTime.min.format("%02d")]);
        view = View.findDrawableById("TimeLabelMin");
        view.setText(timeString);

		// update date
        view = View.findDrawableById("Date");
        view.setText(getDate());

		// update floors climbed
        var floorsClimbed = Toybox.ActivityMonitor.getInfo().floorsClimbed ;
        view = View.findDrawableById("FloorsClimbedNum");
        view.setText(floorsClimbed.toString());
        
		// Move bar
		var steps = Toybox.ActivityMonitor.getInfo().steps;
		System.println( steps);        
        
		var moveBar = Toybox.ActivityMonitor.getInfo().moveBarLevel ;
		System.println( moveBar );        

//		setBatteryDisplay();

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
		// draw battery status
		var battery = System.getSystemStats().battery;
		try{
			var x =  params["batt_status"]["x"] * dc.getWidth();
			var y =  params["batt_status"]["y"] * dc.getHeight();
			if (battery > params["batt_status"]["high"]){
				dc.drawBitmap(x, y, bitmapbBattStatus["high"]);
			} else if (battery < params["batt_status"]["low"]){
				dc.drawBitmap(x, y, bitmapbBattStatus["low"]);
			} else{
				dc.drawBitmap(x, y, bitmapbBattStatus["med"]);
			}        
		} catch (e instanceof Lang.Exception) {
		    System.println(e.getErrorMessage());
		    System.println(battery);
		}

		// draw bluetooth connection
		var mySettings = System.getDeviceSettings();
		if (mySettings.phoneConnected) {
			dc.drawBitmap(params["bluetooth"]["x"] * dc.getWidth(), 
				params["bluetooth"]["y"] * dc.getHeight(), 
				bitmapIcons["bluetooth"]
				);
		}

		// draw battery floors climbed
		dc.drawBitmap(params["floors_climbed"]["x"] * dc.getWidth(), 
			params["floors_climbed"]["y"] * dc.getHeight(), 
			bitmapIcons["floors_climbed"]
			);
//		dc.drawBitmap(30, 120, myBitmap);
		return;
    }

	private function setBatteryDisplay() {
    	var battery = System.getSystemStats().battery;				
		var batteryDisplay = View.findDrawableById("BatteryDisplay");      
		batteryDisplay.setText(battery.format("%d")+"%");	
    	}
    
    
    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }


}

