var exec = require('cordova/exec');

var StarMicronicsAirCash = function() {};
var errorObjFunc = function(cb) {
	return function(message) {
		return cb(new Error(message));
	};
};

StarMicronicsAirCash.prototype.isOnline = function(
	drawerPortName,
	drawerPortSetting,
	successCallback,
	errorCallback
) {
	return exec(successCallback,
		errorObjFunc(errorCallback),
		'CDVStarMicronicsAirCash',
		'isOnline', [
			drawerPortName,
			drawerPortSetting
		]
	);
};

StarMicronicsAirCash.prototype.isOpen = function(
	drawerPortName,
	drawerPortSetting,
	successCallback,
	errorCallback
) {
	return exec(successCallback,
		errorObjFunc(errorCallback),
		'CDVStarMicronicsAirCash',
		'isOpen', [
			drawerPortName,
			drawerPortSetting
		]
	);
};

StarMicronicsAirCash.prototype.openCashDrawer = function(
	drawerPortName,
	drawerPortSetting,
	drawerNumber,
	successCallback,
	errorCallback
) {
	return exec(successCallback,
		errorObjFunc(errorCallback),
		'CDVStarMicronicsAirCash',
		'openCashDrawer', [
			drawerPortName,
			drawerPortSetting,
			drawerNumber
		]
	);
};

module.exports = new StarMicronicsAirCash();
