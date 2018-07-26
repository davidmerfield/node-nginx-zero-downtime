Install NGINX, node, then run deploy.sh.

To do:
- check for long requests (e.g. file downloads, streams)
- check for child processes spawned by node.js, are those killed too?

Links:
- http://nginx.org/en/docs/http/ngx_http_upstream_module.html
- https://nodejs.org/api/http.html#http_server_close_callback
- http://blog.argteam.com/coding/hardening-node-js-for-production-part-3-zero-downtime-deployments-with-nginx/
