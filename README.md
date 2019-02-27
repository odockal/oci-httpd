# oci-httpd - containerized httpd app
Simple pre-configured containerized httpd app that should ease testing of proxy setup and other network configurations.

## Project file structure
	./
	Dockerfile
    conf.d/
    	50_logging.conf
    html/
    	index.html
    keys/
    generate_ss_keys.sh
    LICENSE
    README.md
    	
## Build an container image from Dockerfile
    docker build -f Dockerfile --rm -t oci-httpd:latest .

## Run the container

    docker run -dit --name run-c-httpd -p 1234:80 c-httpd

## Check running web server

    curl -Is http://localhost:1234

Should return HTTP 200 status code. Now is your Apache web server running in container. 
