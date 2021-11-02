#!/bin/bash

# Random difficulty, Random Map, Random areas
DIFFICULTY=$(shuf -i 0-2 -n 1)
MAP_ID=$(shuf -i 0-4294967295 -n 1)
AREA_IDS=$(shuf -i 1-136 -n 5)

# Create session
SESSION_JSON=$(cat << EOF | curl --fail -d @- http://localhost:8080/sessions/ || s6-svscanctl -t /var/run/s6/services
{
  "difficulty" : $DIFFICULTY,
  "mapid" : $MAP_ID
}
EOF
)

# Isolate Session ID and test it
SESSION_ID=$(echo $SESSION_JSON | jq -r .id)
if [ -z $SESSION_ID ]; then
  s6-svscanctl -t /var/run/s6/services
fi

# Request data for the test areas
for AREA_ID in $AREA_IDS ; do
  # Pull the map data for this area
  AREA_JSON=$(curl -s --fail http://localhost:8080/sessions/$SESSION_ID/areas/$AREA_ID || s6-svscanctl -t /var/run/s6/services)

  # Isolate the level origin and test it
  LEVEL_ORIGIN=$(echo $AREA_JSON | jq -r ".levelOrigin")
  if [ -z $LEVEL_ORIGIN ]; then
    s6-svscanctl -t /var/run/s6/services
  fi
done

# Close session
curl -s --fail -X DELETE http://localhost:8080/sessions/$SESSION_ID || s6-svscanctl -t /var/run/s6/services
