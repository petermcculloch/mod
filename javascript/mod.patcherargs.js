/**
*
*	mod.patcherargs.js - Peter McCulloch, 2016
*	
*   Mod.patcherargs.js allows you to reorder the attributes and arguments coming
*   out of patcherargs by specifying the order that attributes should appear 
*   relative to arguments.  This can be useful for objects that are configured by 
*   attributes where the order may be significant.  (For example: creating a buffer of 
*   a specific length, filling it with content, and then specifying a region to 
*   read from in it.)
*
*   There are four ordering positions any of which may be empty:
*   1. Pre - Before arguments are processed.  
*   2. Arguments 
*   3. Default attributes (attributes for which an order has not been specified)
*   4. Post - at the very end.

*   For @pre/@post, a list of attribute names is specified (without using @ for the names)
*   The attributes in each category will be ordered from first to last.  For 
*   example "@pre A B C" will process attribute A (if any), then attribute B (if any),
    then attribute C (if any).
*   
*	- The "done" message will always appear after everything (including arguments) has been processed.
*   - If you provide no arguments, the result will be arguments, then attributes because 
*     there are no @pre attributes specified.
*
*/

this.inlets = 2;
this.outlets = 2;

autowatch = 1;

var kv = {};
var priorities = {};
var defaultPriority = 1;
var argumentPriority = 0;
var ascending = 1; // Higher priority = load later
var values = [];

var splits = ["@pre","@post"];

var findAttributes = function(v)
{
	var res = {};
	var i = 0;
	var tmp = [];
	var found = false;
	var key = null;
	i = v.length - 1;
	while (i >= 0) 
	{
		if (splits.indexOf(v[i]) >= 0) // Is one of the specified keys
		{
			if (tmp.length > 0) {
				res[v[i].slice(1)] = tmp; // Strip off the @ sign
			}
			tmp = [];
		} else {
			tmp.unshift(v[i]);
		}
		i--;
	}
	if (tmp.length > 0) {
		res.arguments = tmp; // Anything left is the arguments
	}
	return res;
};

function init() 
{
	var a = arrayfromargs(jsarguments.slice(1));
	var res = findAttributes(a);
	var priorityCounter = argumentPriority-1;;
	var v = res["pre"];
	if (v !== undefined) 
	{
		while (v.length > 0) 
		{
			priorities[v.pop()] = priorityCounter;
			priorityCounter--;
		}
	}
	v = res["post"];
	if (v !== undefined) 
	{
		priorityCounter = defaultPriority+1; // Order is pre arguments otherAttr post
		
		while (v.length > 0) 
		{
			priorities[v.shift()] = priorityCounter;
			priorityCounter++;
		}
	}
}


	

init();


function sortPriority(a,b)
{
	var res = a.priority - b.priority;
	if (res === 0)
	{
		res = values.indexOf(b) - values.indexOf(a);
	}
	return res;
}

function anything()
{
	var a = arrayfromargs(arguments);
	var i = 0;
	if (inlet == 0) {
		// Store arguments
		var record = {"key" : "arguments", "val" : a, "priority" : argumentPriority};
		values.push(record);
	} else { 
		if (a.length === 0 && messagename === "done") {
			// All set, now output
			values.sort(sortPriority);
			var i = 0;
			var iMax = values.length;
			for (i = 0; i < iMax; ++i)
			{
				if (values[i].key === "arguments") {
					outlet(0, values[i].val);
				} else {
					outlet(1,values[i].key,values[i].val);
				}
			}
			outlet(1,"done"); // Done always arrives last.
			values = [];
		} else {
			// Store values
			var p = priorities.hasOwnProperty(messagename) ? priorities[messagename] : defaultPriority;
			var record = {"key" : messagename, "val" : a, "priority" : p};
			values.push(record);
		}
	}	
}

var testAttributes = function() {
	var test = ["@pre","buffer", "@post","samps","channel"];
	var res = findAttributes(test);
};

testAttributes.local = 1;
	
