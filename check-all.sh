 #!/bin/bash
        
for i in *.json
do
    city=${i%.json}
    echo $city
    ./check-api-searches.coffee $city
    sleep 20
done
