# cordova-plugin-star-micronics-air-cash

Cordova Plugin that Supports Common Tasks for the StarMicronics AirCash Cash Drawer.

## Installation

    cordova plugin add cordova-plugin-star-micronics-air-cash

## Supported Platforms

- Android
- iOS

## Usage

Get the plugin like this:

`var drawer = $window.cordova.plugins.starMicronicsAirCash`

Now you can call the following functions:

	drawer.isOnline(
		drawerPortName,
		drawerPortSetting,
		successCallback,
		errorCallback
	);

	drawer.isOpen(
		drawerPortName,
		drawerPortSetting,
		successCallback,
		errorCallback
	);

	drawer.openCashDrawer(
		drawerPortName,
		drawerPortSetting,
		drawerNumber,
		successCallback,
		errorCallback
	);


The drawerPortName will be in the format of `TCP:192.168.1.123` and the port setting can be an empty String.