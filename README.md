# Catalyst Merged Mining

- `sh get-docker.sh`
- `apt-get install docker-compose`

- `docker volume create xun-blockchain`
- `docker volume create catalyst-blockchain`
- `docker volume create xun-wallet`
- `docker volume create catalyst-wallet`
- `docker volume create xun-cx-db`


- `/var/lib/docker/volumes/`

- checkout the AWS branch - for AWS final configs.

- Read https://github.com/catalystdevelopment/catalyst-pool-docker as a starting poing.

AWS SETTINGS:
- region=us-east-1
- assign ip
- assign EBS 28GB
- configure firewall - open ports

SSL
- Use https://github.com/n8tb1t/docker-repository/tree/master/compose/aws/ssl-proxy.
