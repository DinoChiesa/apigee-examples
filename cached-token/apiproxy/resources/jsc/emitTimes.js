var start, end, targetElapsed, totalElapsed;

start = context.getVariable('target.sent.start.timestamp');
end = context.getVariable('target.received.end.timestamp');
targetElapsed = Math.floor(end - start);
context.proxyResponse.headers['X-time-target-elapsed'] = targetElapsed;

start = context.getVariable('client.received.start.timestamp');
end = context.getVariable('system.timestamp');
totalElapsed = Math.floor(end - start);
context.proxyResponse.headers['X-time-total-elapsed'] = totalElapsed;
