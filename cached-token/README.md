# Cached Token Proxy

This provides an Apigee Edge proxy.  

This proxy shows a pattern for caching an oauthv2 token, 
and then re-use the cached values for enforcing a quota, 
in subsequent requests. 

## Why?

Why would you want to cache a token in a proxy?  The reason is that
verifying a token requires a call to Cassandra, aacross the network.
This is normally "pretty fast" but when you are eeking out every last
drop of performance, you look for ways to avoid network communication.
This pattern allows avoidance.

## Is this Difficult?

No, it's not difficult. In the simplest case, you need only to store an
entry into a cache using the token as the key.  Then, on subsequent API
invocations, see if that entry exists. Just do a cache lookup using the
token as the key.  The value does not matter. Pretty simple.

Even that simple case, though, takes 3 policies and some conditions. So I wanted to show it. 

## Anything Else? 

Yes, there's one other twist: when enforcing a Quota with a cached
token, you need the metadata associated to the token, to evaluate the
quota. This means you cannot simply store "anything" in the cache. You
need to store the quota-related metadata. That's really 4 different data items. 

This policy bundle shows how to assemble all those items into a string
for cache population, and how to dis-assemble the cached string upon
cache retrieval. It does this with Javascript callouts. 





