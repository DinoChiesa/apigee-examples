# Tools and scripts for doing Apigee things

This is a loose collection of tools and scripts for doing Apigee things. 


## loadEdgeKvm.sh

This tool loads a Key-Value Map in Apigee Edge with data. Provide the data in a text file with multiple lines, each line of the form KEY=VALUE.  Then invoke this script to generate the command to load the KVM, and optionally to run the generated command.

To avoid passing credentials on the command line, you can store credentials
in a file called .credentials. The contents should be like this: 
     apigeeuser=username"
     apigeepassword=password"

For example, suppose a file named settings.properties that has this content: 

    key1=value1
    key2=value2
    key3=value3
    key4=value4

Invoking the script like this: 

    bash ./loadEdgeKvm.sh -o deecee -s https://api.enterprise.apigee.com  \
          -f settings.properties -m gryphon -e test -t

Produces this output: 

    This is the command: 

    curl -X PUT -H content-type:application/json \
      https://api.enterprise.apigee.com/v1/o/deecee/e/test/keyvaluemaps/gryphon \
      -d '{ "entry" : [ { "name" : "key1" , "value" : "value1" },{ "name" : "key2" , "value" : "value2" },{ "name" : "key3" , "value" : "value3" },{ "name" : "key4" , "value" : "value4" } ], "name" : "gryphon" }'

