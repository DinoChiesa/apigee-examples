// extractValuesFromCachedItem.js
// ------------------------------------------------------------------
//
// Extract the values of interest from the item that was cached, and set
// the appropriate context variables. The cached value is a string,
// composed of multiple elements like this: key1=value1:key2=value2 The
// result of this callout is that context variables key1 and key2 get
// the values value1 and value2 respectively.
//
// created: Mon Mar 24 21:09:34 2014
// last saved: <2014-April-18 10:48:28>

var delimiter1 = ':', delimiter2 = '=',
    composedValue = context.getVariable('accessToken_cache') + '', //coerce to string
    parts = composedValue.split(delimiter1),
    kvpair,
    i, L;

// re-populate these variables from the cached item.
if (parts.length > 0) {
  for (i=0, L=parts.length; i<L; i++) {
    kvpair = parts[i].split(delimiter2);
    if (kvpair.length == 2) {
      context.setVariable(kvpair[0], kvpair[1]);
    }
  }
}
