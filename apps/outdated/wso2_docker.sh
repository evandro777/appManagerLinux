#!/bin/bash

#Docker Latest version
docker run -it \
	-p 9443:9443 \
	-p 8243:8243 \
	-p 8280:8280 \
	wso2/wso2am

#Docker 2.6.0
docker run -it \
	-p 9443:9443 \
	-p 8243:8243 \
	-p 8280:8280 \
	wso2/wso2am:2.6.0