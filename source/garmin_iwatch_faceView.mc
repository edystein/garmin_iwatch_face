using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;

var UPDATE_INTERVAL_MIN = 1;

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


function dailyMonitorGetActivities(lAllActivities){
	// get a list of activities supprted by watch
	var val = 0;
	var lActivities = [];
	// floors climbed
	try {
    	val = Toybox.ActivityMonitor.getInfo().floorsClimbed ;
    	lActivities.add("floorsClimbed"); 
	} catch (e instanceof Lang.Exception) {
    	System.println(e.getErrorMessage());
	}

	// steps
	try {
    	val = Toybox.ActivityMonitor.getInfo().steps;
    	lActivities.add("steps") ;
	} catch (e instanceof Lang.Exception) {
    System.println(e.getErrorMessage());
	}

	// calories
	try {
    	val = Toybox.ActivityMonitor.getInfo().calories;
    	lActivities.add("calories"); 
	} catch (e instanceof Lang.Exception) {
    	System.println(e.getErrorMessage());
	}
	
	System.println("Supported activites: " + lActivities + "n activities: " +  lActivities.size());
	return lActivities;	
}


function dailyStatGetText(stat_type){
	var stat_str = "no stat";

	if (stat_type.equals("floorsClimbed")){
		stat_str = Toybox.ActivityMonitor.getInfo().floorsClimbed.toString();
//		System.println("floors " + stat_str); 
	}
	
	if (stat_type.equals("steps")){
		stat_str = (Toybox.ActivityMonitor.getInfo().steps / 1000.0).format("%.1f") + "/" + (Toybox.ActivityMonitor.getInfo().stepGoal / 1000.0).format("%.1f");
		stat_str = Toybox.ActivityMonitor.getInfo().steps / 1000 + " / " + Toybox.ActivityMonitor.getInfo().stepGoal / 1000;
//		System.println("steps " + stat_str);
	}

	if (stat_type.equals("calories")){
		stat_str = Toybox.ActivityMonitor.getInfo().calories.toString();
//		System.println("calories " + stat_str);
	}
	
	return stat_str;
}



class garmin_iwatch_faceView extends WatchUi.WatchFace {
	var settings = {
		"batt_status"=> {"high"=> 70, "low"=> 30, "x"=> .43, "y"=> .05},
		"floors_climbed" => {"x"=> .8, "y"=> .40},
		"bluetooth" => {"x"=> .7, "y"=> .15},
		 "daily_monitor" => [],
		 "daily_monitor_options" => ["steps", "floors", "calories", "active_min"],
		 "daily_monitor_currently_displayed" => {"indx" => 0, "last_update_min" => 0, "update_interval_min" => UPDATE_INTERVAL_MIN}
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
	    	"steps"=> WatchUi.loadResource(Rez.Drawables.Steps),
	    	"calories"=> WatchUi.loadResource(Rez.Drawables.Calories),
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
		//////////////////////////////////////////		
        view = View.findDrawableById("Date");
        view.setText(getDate());

		// Move bar
		//////////////////////////////////////////		
		var moveBar = Toybox.ActivityMonitor.getInfo().moveBarLevel ;
		var moveString = "MOVE!";
        view = View.findDrawableById("moveAlert");
        view.setText(moveString.substring(0, moveBar) );
//		System.println( moveString.substring(0, moveBar) );        


		//		setBatteryDisplay();
		//////////////////////////////////////////		
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
		// draw battery status
		var battery = System.getSystemStats().battery;
		try{
			var x =  settings["batt_status"]["x"] * dc.getWidth();
			var y =  settings["batt_status"]["y"] * dc.getHeight();
			if (battery > settings["batt_status"]["high"]){
				dc.drawBitmap(x, y, bitmapbBattStatus["high"]);
			} else if (battery < settings["batt_status"]["low"]){
				dc.drawBitmap(x, y, bitmapbBattStatus["low"]);
			} else{
				dc.drawBitmap(x, y, bitmapbBattStatus["med"]);
			}        
		} catch (e instanceof Lang.Exception) {
		    System.println(e.getErrorMessage());
		    System.println(battery);
		}

		// draw bluetooth connection
		//////////////////////////////////////////		
		var mySettings = System.getDeviceSettings();
		if (mySettings.phoneConnected) {
			dc.drawBitmap(settings["bluetooth"]["x"] * dc.getWidth(), 
				settings["bluetooth"]["y"] * dc.getHeight(), 
				bitmapIcons["bluetooth"]
				);
		}

		// daily monitor
		///////////////////////////
		if (0 == settings["daily_monitor"].size()){
			settings["daily_monitor"] = dailyMonitorGetActivities(settings["daily_monitor_options"]);
			settings["daily_monitor_currently_displayed"] = {"indx" => 0, "last_update_min" => clockTime.min, "update_interval_min" => UPDATE_INTERVAL_MIN};			
		}
		var time_stat_change = (settings["daily_monitor_currently_displayed"]["last_update_min"] +  settings["daily_monitor_currently_displayed"]["update_interval_min"]) % 60;
		if (time_stat_change == clockTime.min){
			settings["daily_monitor_currently_displayed"] = {
				"indx" => (settings["daily_monitor_currently_displayed"]["indx"] + 1) % settings["daily_monitor"].size(), 
				"last_update_min" => clockTime.min, 
				"update_interval_min" => UPDATE_INTERVAL_MIN
			};
		}
		// daily stat string		
		///////////////////////////
//		System.println( settings["daily_monitor_currently_displayed"]);
//		System.println( "settings[daily_monitor]: " + settings["daily_monitor"] + ", settings[daily_monitor_currently_displayed][indx]: " + settings["daily_monitor_currently_displayed"]["indx"]);
//		System.println( "Debug: " + settings["daily_monitor"][settings["daily_monitor_currently_displayed"]["indx"]]);
		
		var stat = settings["daily_monitor"][settings["daily_monitor_currently_displayed"]["indx"]];
        view = View.findDrawableById("DailyStat");
        view.setText(dailyStatGetText(stat));

		// daily stat draw
		///////////////////////////
				
		// draw floors climbed
		if (stat.equals("floorsClimbed")){
			dc.drawBitmap(settings["floors_climbed"]["x"] * dc.getWidth(), 
				settings["floors_climbed"]["y"] * dc.getHeight(), 
				bitmapIcons["floors_climbed"]
				);
		}
		// draw steps
		if (stat.equals("steps")){
			dc.drawBitmap(settings["floors_climbed"]["x"] * dc.getWidth(), 
				settings["floors_climbed"]["y"] * dc.getHeight(), 
				bitmapIcons["steps"]
				);
		}
		// caloreis
		if (stat.equals("calories")){
			dc.drawBitmap(settings["floors_climbed"]["x"] * dc.getWidth(), 
				settings["floors_climbed"]["y"] * dc.getHeight(), 
				bitmapIcons["calories"]
				);
		}


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

