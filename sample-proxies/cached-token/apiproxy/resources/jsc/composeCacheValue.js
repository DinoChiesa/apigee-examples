// composeCacheValue.js
// ------------------------------------------------------------------
//
// Compose the value to be cached.  It's a string with multiple
// key/value pairs, each separate by colon.  Looks like this:
// key1=value1:key2=value2...  The cached value needs to contain all
// information that would be used by subsequent policies. In this case
// we need the client_id, and the myriad variables holding information
// about the quota.
//
// The side effect of this script is to simply set an additional variable.
//
//
// created: Mon Mar 24 21:09:34 2014
// last saved: <2014-April-18 10:47:12>

var delimiter1 =':', delimiter2 ='=',
    variableNames = ['apiproduct.developer.quota.interval',
                     'apiproduct.developer.quota.timeunit',
                     'apiproduct.developer.quota.limit',
                     'client_id'],
    elements = [],
    composed,
    key, value, i, L;

for (i=0, L=variableNames.length; i<L; i++) {
  key = variableNames[i];
  value = context.getVariable(key);
  elements.push([key, value].join(delimiter2));
}
composed = elements.join(delimiter1);
context.setVariable('composed_token_data', composed);
