###### Set up

```bash
chmod +x deploy.sh
./deploy.sh
```

###### How it works

1. Start new code

  The deployment script requires a list of ports to run the node application on. It will use half of these ports during normal use.

  The script first works out which of the list of ports are available for the new code. It then attempts to start the new code, passing an available port as an environment variable. It is up to the node.js application to actually listen on that port.

2. Check new code is healthy

3. Kill old code

4. Check old code is dead




Goals for this:
- Deploy new code safely as unpriviledged user
- Do not adjust anything with NGINX

To do:
- check for long requests (e.g. file downloads, streams)
- check for child processes spawned by node.js, are those killed too?
- work out what to do for a 'bad deploy' with error in code

Links:
- http://nginx.org/en/docs/http/ngx_http_upstream_module.html
- https://nodejs.org/api/http.html#http_server_close_callback
- http://blog.argteam.com/coding/hardening-node-js-for-production-part-3-zero-downtime-deployments-with-nginx/
