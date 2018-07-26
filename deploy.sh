set -e

NEW_DEPLOYMENT_ID=$(date +%s)

FIRST_PORT=8899
SECOND_PORT=8890

if [ -e data/active.deployment ]
then 
  echo "There is an active deployment"
  OLD_DEPLOYMENT_ID=$(cat data/active.deployment)
  OLD_DEPLOYMENT_PID=$(cat data/active.pid)
  OLD_DEPLOYMENT_PORT=$(cat data/active.port)
else 
  echo "There is no active deployment"
fi


# copy code to new directory
mkdir -p data/$NEW_DEPLOYMENT_ID/app
cp -R app data/$NEW_DEPLOYMENT_ID/



# check if there is an existing deployment running
if [ $OLD_DEPLOYMENT_ID ]; then
  mv data/active.pid data/old.pid
  mv data/active.port data/old.port
  mv data/active.deployment data/old.deployment
else
  echo "No deployment running"
fi

if [ "$OLD_DEPLOYMENT_PORT" == "$FIRST_PORT" ]; then
  NEW_DEPLOYMENT_PORT=$SECOND_PORT
else
  NEW_DEPLOYMENT_PORT=$FIRST_PORT
fi

# run the new code
export APP_PORT=$NEW_DEPLOYMENT_PORT 
node data/$NEW_DEPLOYMENT_ID/app &

echo $! > data/active.pid
echo $NEW_DEPLOYMENT_PORT > data/active.port
echo $NEW_DEPLOYMENT_ID > data/active.deployment

# verify it works
# We must wait longer than the fail_timeout directive
# in the upstream block for the proxy in nginx.conf
echo "Waiting 10 seconds..."
sleep 10
echo "Done!"
curl localhost:$NEW_DEPLOYMENT_PORT

# send kill signal to old code processes
# remove old code?
if [ $OLD_DEPLOYMENT_ID ]; then
  echo "Killing $OLD_DEPLOYMENT_PID"
  rm -rf data/$OLD_DEPLOYMENT_ID
  kill $OLD_DEPLOYMENT_PID
else 
  echo "Not killing $OLD_DEPLOYMENT_ID"  
fi

exit 0