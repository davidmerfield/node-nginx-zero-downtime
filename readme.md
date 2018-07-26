###### Goals

Essentially we are trying to deploy changes to a node.js application running behind NGINX without dropping any requests. Here are some subgoals:

1. Do not adjust anything with NGINX. This means we don't have to mess around with ```sudo```
2. 


###### Set up

After cloning the repository, make sure the script is executable:

```bash
chmod +x deploy.sh
```

Then call the deployment script, passing all the ports you have set aside to run node.js processes on. Make sure these match the ports specified in upstream servers for nginx.conf.

```
./deploy.sh 8890 8891 8892 8893
```

###### How it works

1. Start new code

  The deployment script requires a list of ports to run the node application on. It will use half of these ports during normal use.

  The script first works out which of the list of ports are available for the new code. It then attempts to start the new code, passing an available port as an environment variable. It is up to the node.js application to actually listen on that port.

2. Check new code is healthy

3. Kill old code

4. Check old code is dead





To do:
- check for long requests (e.g. file downloads, streams)
- check for child processes spawned by node.js, are those killed too?
- work out what to do for a 'bad deploy' with error in code

Links:
- http://nginx.org/en/docs/http/ngx_http_upstream_module.html
- https://nodejs.org/api/http.html#http_server_close_callback
- http://blog.argteam.com/coding/hardening-node-js-for-production-part-3-zero-downtime-deployments-with-nginx/
