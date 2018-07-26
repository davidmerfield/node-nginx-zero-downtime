# You should specify twice as many ports as you
# have CPUs on your machine. The script will 
# start processes equal to half the number of ports
# Make sure your NGINX configuration has these ports.
PORTS=(8890 8891 8892 8893)

UNUSED_PORTS=()
USED_PORTS=()
EXISTING_PIDS=()

# First we determine which of the ports are in use
# and if so, which processes are bound to them and
# which ports are not in use and available for this deployment
for port in "${PORTS[@]}"
do
  # Sourced this command to check a particular port here:
  # https://unix.stackexchange.com/questions/149419/how-to-check-whether-a-particular-port-is-open-on-a-machine-from-a-shell-script
  # lsof = list open files
  # -i selects the listing of files any  of  whose  Internet  address
  # -P inhibits the conversion of port numbers to port names for net-
  # work files.  Inhibiting the conversion may  make  lsof  run  a
  # little faster.  It is also useful when port name lookup is not
  # working properly.
  # -sTCP:LISTEN will list only network files with TCP state LISTEN
  # -t specifies terse output
  pid=$(lsof -Pi :$port -sTCP:LISTEN -t)
  if [ $pid ]; then
    EXISTING_PIDS+=($pid)
    USED_PORTS+=($port)
  else 
    UNUSED_PORTS+=($port)
  fi
done

# If there are no free ports available then we must
# exit the script now and show an error message.
if [ ${#UNUSED_PORTS[@]} -eq 0 ]; then
  echo "Error: No free ports to bind new processes to"
  exit 1
fi

# Run the new processes on the available ports
for port in "${UNUSED_PORTS[@]}"
do
  
  # This is where the application should probably
  # decide how to set itself up when passed a 
  # working directory. For now we'll write it here
  depdir=$(date +%s)-$port
  mkdir -p data/$depdir/app
  cp -R app data/$depdir/
  export APP_PORT=$port
  node data/$depdir/app >> data/log &
  
  echo "Started new process on port $port with pid $!"
  NEW_PROCESS_COUNT=$((NEW_PROCESS_COUNT+1))

  # We keep track of the number of new processes to 
  # ensure that we don't start more than half the number 
  # of total ports. This ensures we have free ports for our
  # next deployment.
  if (( NEW_PROCESS_COUNT >= ${#PORTS[@]}/2 )); then
    break
  fi

done

# There will be no existing processes the first
# time the deploy script is run.
if [ ${#EXISTING_PIDS[@]} -eq 0 ]; then
  echo "Warning: no existing processes to kill"
  exit 0
fi

# I'm not sure what timeout this should be, but for
# now it is as long as the fail_timeout directive in
# nginx.conf which specifies how long NGINX will cache
# the information that a given upstream server is 
# unavailable. I should do more research.
echo "Waiting for NGINX's fail_timeout to expire for previously unused ports now running our new deployment"
sleep 6s
echo "Waiting is over!"

# kill old EXISTING_PIDS
for activepid in "${EXISTING_PIDS[@]}"
do 
  echo "Killing old process with pid $activepid"
  kill $activepid
  # Wait for the process to close
  # This script is sourced from here:
  # https://stackoverflow.com/questions/1058047/wait-for-any-process-to-finish
  lsof -p $activepid +r 1 &>/dev/null
  echo "Killed old process with pid $activepid"
done

echo "Deploy completed successfully!"

# remove old code?
exit 0