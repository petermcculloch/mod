this.inlets = 2;
this.outlets = 2;

autowatch = 1;

var kv = {};
var priorities = {};
var default_priority = 0;
var ascending = 1; // Higher priority = load later
var arglist = [];
var values = []

var splits = ["@pre","@post"];

function init()
{
	var a = arrayfromargs(jsarguments.slice(1));
	var i = 0;
	var preIndex = a.indexOf("@pre");
	var postIndex = a.indexOf("@post");
	
	i = preIndex + 1;
	var preArray = [];
	// Record values until split occurs...
	while (i < a.length && splits.indexOf(a[i]) < 0)
	{
		preArray.push(a[i]);
		i++;
	}
	
	
	// preArray = preArray.reverse();
	
	i = 0;
	var priorityCounter = -preArray.length;
	var iMax = preArray.length;	
	while (i < iMax)
	{
		priorities[preArray[i]] = priorityCounter;
		priorityCounter++;
		i++;
	}
		
	i = postIndex + 1;
	priorityCounter = 1; // Count up from 1
	
	// Record values until split occurs...
	while (i < a.length && splits.indexOf(a[i]) < 0)
	{
		priorities[a[i]] = priorityCounter;
		i++;
		priorityCounter++;
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
	var i = inlet;
	if (i == 0) {
		arglist = a;
	} else { 
		if (a.length === 0 && messagename === "done") {
			// All set, now output
			values.sort(sortPriority);
			var i = 0;
			var iMax = values.length;
			for (i = 0; i < iMax; ++i)
			{
				outlet(1,values[i].key,values[i].val);
			}
			outlet(1,"done");
			outlet(0,arglist);
			values = [];
		} else {
			// Store values
			var p = priorities.hasOwnProperty(messagename) ? priorities[messagename] : default_priority;
			var record = {"key" : messagename, "val" : a, "priority" : p};
			values.push(record);
		}
	}	
}



	
