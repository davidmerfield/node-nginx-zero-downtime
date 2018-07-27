#### Goals

We want to deploy changes to a node.js application running behind NGINX without dropping any requests. 

Here are some additional requirements:

1. Deployment of changes to node.js application should not requireme any adjustments to NGINX. This means we don't have to mess around with ```sudo```

2. Deployment should verify new code starts and runs. This means we don't kill old processes before 

3. Long connections, like those for [Server-sent events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events), should be killed and reset on the client.

#### Set up

After cloning the repository, make sure the script is executable:

```bash
chmod +x deploy.sh
```

Then call the deployment script, passing all the ports you have set aside to run node.js processes on. Make sure these match the ports specified in upstream servers for nginx.conf.

```
./deploy.sh 8890 8891 8892 8893
```

#### How it works

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
