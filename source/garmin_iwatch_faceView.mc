using Toybox.Application as App;
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;

// Global vars
var UPDATE_INTERVAL_MIN = 1;
//<device family="round-240x240" grouping="Watches/Wearables" id="fr935" name="Forerunner® 935" part_number="006-B2691-00">
var dateX = 120;
var dateY = 36;
var timeHourX = 120;
var timeHourY = 75;
var colorHour = Graphics.COLOR_WHITE; 
var timeMinX = 120;
var timeMinY= 145;
var timeSecX = 175;
var timeSecY= 174;

var dailyStatX = 200;
var dailyStatY = 127;
var moveAlertX = 120;
var moveAlertY= 205;







function drawStat(stat, dc, settings, bitmapIcons){
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
}






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
		stat_str = " " + Toybox.ActivityMonitor.getInfo().floorsClimbed.toString();
//		System.println("floors " + stat_str); 
	}
	
	if (stat_type.equals("steps")){
		var steps = Toybox.ActivityMonitor.getInfo().steps;
		if ((steps < 10000) && (steps > 0)){
			stat_str = (Toybox.ActivityMonitor.getInfo().steps / 1000.0).format("%.1f") + "/" + (Toybox.ActivityMonitor.getInfo().stepGoal / 1000.0).format("%d");
		} else {
			stat_str = (Toybox.ActivityMonitor.getInfo().steps / 1000).format("%d") + "/" + (Toybox.ActivityMonitor.getInfo().stepGoal / 1000).format("%d");
		}
		
//		stat_str = Toybox.ActivityMonitor.getInfo().steps / 1000 + " / " + Toybox.ActivityMonitor.getInfo().stepGoal / 1000;
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
		"daily_monitor_currently_displayed" => {"indx" => 0, "last_update_min" => 0, "update_interval_min" => UPDATE_INTERVAL_MIN}
		};
    var myBitmap;
    var bitmapbBattStatus;
    var bitmapIcons;

    function initialize() {
        WatchFace.initialize();
    }


	function initDevice(settings){
		// detect device
		////////////////////////
		var deviceSettings = System.getDeviceSettings();
		var partNumber = deviceSettings.partNumber;
		// device part numbers come from ${SDKROOT}/bin/devices.xml

		var device = "---";
		if ("006-B2691-00".equals(partNumber)) {
			// <device family="round-240x240" grouping="Watches/Wearables" id="fr935" name="Forerunner® 935" part_number="006-B2691-00">
			device = "fr935";
		} else if ("006-B3113-00".equals(partNumber)){
			// <device family="round-240x240" grouping="Watches/Wearables" id="fr945" name="Forerunner® 945" part_number="006-B3113-00">
			device = "fr945";
		} else if ("006-B3076-00".equals(partNumber)){
			// <device family="round-240x240" grouping="Watches/Wearables" id="fr245" name="Forerunner® 245" part_number="006-B3076-00">
			device = "fr245";
		} else if ("006-B2431-00".equals(partNumber)){
			// <device family="semiround-215x180" grouping="Watches/Wearables" id="fr235" name="Forerunner® 235" part_number="006-B2431-00">
			device = "fr235";
		} 
		System.println( "Device: " + device );
		
		
		// set layout
		////////////////////////////////
		// fr935 is default
				
		if ("fr245".equals(device) || "fr945".equals(device)){
			timeHourY = 55;
			timeMinY= 125;
			timeSecX= 180;
			timeSecY= 172;
			var view = View.findDrawableById("TimeLabelHour");
			view.setLocation(timeHourX, timeHourY);
			view = View.findDrawableById("TimeLabelMin");
			view.setLocation(timeMinX, timeMinY);
			view = View.findDrawableById("TimeLabelSec");
			view.setLocation(timeSecX, timeSecY);
			
		} 
		else if ("fr235".equals(device)){
			// <device family="semiround-215x180" grouping="Watches/Wearables" id="fr235" name="Forerunner® 235" part_number="006-B2431-00">
			System.println( "!!!!!!!!!!!!!!!!!! Handle 235 layout !!!!!!!!!!!!!!!!!!");
			timeHourX = 100;
			timeHourY = 40;
			timeMinX= 100;
			timeMinY= 80;
			timeSecX= 100;
			timeSecY= 100;
			var view = View.findDrawableById("TimeLabelHour");
			view.setLocation(timeHourX, timeHourY);
			view.setFont(Graphics.FONT_SYSTEM_NUMBER_THAI_HOT   );

			view = View.findDrawableById("TimeLabelMin");
			view.setLocation(timeMinX, timeMinY);
			view.setFont(Graphics.FONT_SYSTEM_NUMBER_THAI_HOT   );

			view = View.findDrawableById("TimeLabelSec");
			view.setLocation(timeSecX, timeSecY);
		} 
	
		
		// init daily statistics
		////////////////////////////
		var lActivities = ["floorsClimbed", "steps", "calories"];
		if ("fr935".equals(device) || "fr945".equals(device)){
			settings["daily_monitor"] = ["floorsClimbed", "steps", "calories"];
		} else{
			settings["daily_monitor"] = ["steps", "calories"];
		} 
	
		var clockTime = System.getClockTime();
		settings["daily_monitor_currently_displayed"] = {"indx" => 0, "last_update_min" => clockTime.min, "update_interval_min" => UPDATE_INTERVAL_MIN};
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
//		System.println( "Hello Monkey C!" );
//        // Get and show the current time
//        var clockTime = System.getClockTime();
//        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
//        var view = View.findDrawableById("TimeLabel");
//        view.setText(timeString);

		// init device
		//////////////////////////
		if (0 == settings["daily_monitor"].size()){
			initDevice(settings);
		}
		

        // Get and show Hour
		//////////////////////////
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$", [clockTime.hour]);
        

        var view = View.findDrawableById("TimeLabelHour");
        view.setText(timeString);
        view.setColor(App.getApp().getProperty("TimeHourColor"));
//        view.setY(timeHourY);


        timeString = Lang.format("$1$", [clockTime.min.format("%02d")]);
        view = View.findDrawableById("TimeLabelMin");
        view.setText(timeString);
        view.setColor(App.getApp().getProperty("TimeMinColor"));

		var secString = ""; 
		if (1 == App.getApp().getProperty("DisplaySeconds")){
			secString = Lang.format("$1$", [clockTime.sec.format("%02d")]);
		}         
        view = View.findDrawableById("TimeLabelSec");
        view.setText(secString);
        view.setColor(App.getApp().getProperty("TimeMinColor"));
		
//		var dispSeconds = App.getApp().getProperty("DisplaySeconds");
//		System.println("dispSeconds : " + dispSeconds + ", dispSeconds  == 1: " + (dispSeconds  == 1));
        
        
        
        

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
        view.setColor(App.getApp().getProperty("MoveAlertColor"));
//		System.println( moveString.substring(0, moveBar) );        


		//		setBatteryDisplay();
		//////////////////////////////////////////		
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
		// draw battery status
		var battery = System.getSystemStats().battery;
		var dispBatStatus = App.getApp().getProperty("AlwaysDisplayBatteryLevel");
//		System.println( "dispBatStatus: " + dispBatStatus + ", (1 == dispBatStatus): " + (1 == dispBatStatus) );
		if (battery < settings["batt_status"]["low"]){
			dispBatStatus = 1;
		}
        view = View.findDrawableById("BatteryLevel");
        view.setText("");
		if (1 == dispBatStatus){
			try{
				var x =  settings["batt_status"]["x"] * dc.getWidth();
				var y =  settings["batt_status"]["y"] * dc.getHeight();
				if (battery > settings["batt_status"]["high"]){
				// high
					dc.drawBitmap(x, y, bitmapbBattStatus["high"]);
				} else if (battery < settings["batt_status"]["low"]){
				// low
					dc.drawBitmap(x, y, bitmapbBattStatus["low"]);
					view.setText(battery.format("%2d") + "%");
				} else{
				// med
					dc.drawBitmap(x, y, bitmapbBattStatus["med"]);
				}        
			} catch (e instanceof Lang.Exception) {
			    System.println(e.getErrorMessage());
			    System.println(battery);
			}
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
		
		
		var deviceSettings = System.getDeviceSettings();
		// device part numbers come from ${SDKROOT}/bin/devices.xml
		var partNumber = deviceSettings.partNumber;
//		// device part numbers come from ${SDKROOT}/bin/devices.xml
//		var partNumber = deviceSettings.partNumber;
//		if ("006-B2156-00".equals(partNumber)) {
//		// fr630
//		}
//		else if ("006-B2431-00".equals(partNumber) ||
//		"006-B2396-00".equals(partNumber) ||
//		"006-B2397-00".equals(partNumber) ||
//		"006-B2516-00".equals(partNumber)) {
//		// fr235
//		}
//		// and so on

		
		var stat = settings["daily_monitor"][settings["daily_monitor_currently_displayed"]["indx"]];
        view = View.findDrawableById("DailyStat");
        view.setText(dailyStatGetText(stat));
 
 

		// daily stat draw
		///////////////////////////
		drawStat(stat, dc, settings, bitmapIcons);				

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

