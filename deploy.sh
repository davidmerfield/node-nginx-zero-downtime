PORTS=(8890 8891 8892 8893)
CONCURRENT_PROCESSES=$((${#PORTS[@]}/2))

NEW_DEPLOYMENT_ID=$(date +%s)

FREEPORTS=()
CLOSEDPORTS=()
PIDS=()

for port in "${PORTS[@]}"
do
  pid=$(lsof -Pi :$port -sTCP:LISTEN -t)
  if [ $pid ]; then
    PIDS+=($pid)
    CLOSEDPORTS+=($port)
  else 
    FREEPORTS+=($port)
  fi
done

if [ ${#FREEPORTS[@]} -eq 0 ]; then
  echo "Error: No free ports to bind new processes to"
  exit 1
fi

# run the new code
for freeport in "${FREEPORTS[@]}"
do
  
  if (( active_processes >= CONCURRENT_PROCESSES )); then
    echo "max concurrent reached!"
    continue
  fi

  # copy code to new directory
  depdir=$NEW_DEPLOYMENT_ID-$freeport
  mkdir -p data/$depdir/app
  cp -R app data/$depdir/
  
  # run new app
  export APP_PORT=$freeport
  node data/$depdir/app >> data/log &
  active_processes=$((active_processes+1))
  echo "Started new process on port $freeport with pid $!"

done


if [ ${#PIDS[@]} -eq 0 ]; then
  echo "Warning: no existing processes to kill"
  exit 0
fi

# verify it works
echo "Waiting for full length of timeout"
sleep 5s
echo "Waiting is over!"

# kill old pids
for activepid in "${PIDS[@]}"
do 
  echo "Killing old process with pid $activepid"
  kill $activepid
done

# remove old code?

exit 0