# Catalyst Merged Mining

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

## WWW

The site is in `WWW` folder, it's better to host it on some free static server, to save traffic.

# Catalyst pool troubleshooting protocol

> It is always better to use SSH  for docker interactions because it uses less traffic, but for quickly taking a look at what's going on and review some logs we have the Docker Management User Interface (Portainer).

- [http://3.13.173.213:9000](http://3.13.173.213:9000)

> At first, it all looks a bit scary, and too much hassle, but once you get into docker, it will save you lots of time and headake! 

> Before starting any work it's extremely important to be inside `catalyst-merged-mining` folder!

All the pool related data is inside `/catalyst` folder.

- `sudo su`
- `cd /catalyst/catalyst-merged-mining`
- `docker-compose logs --tail=30 pool_xun pool_catalyst`
- `htop` - to monitor the system resources usage.

> All of the persistent data is here `per/var/lib/docker/volumes` - We can copy it to some other location once each 2-3 days... just in case. currently the block-chain backups are at `/catalyst/backups`

- You need to backup the wallet files, just download the files to your home PC. and Also, there is a backup functions inside the console wallets on the server, to save the seed data, etc. Also, backup the pool config files at `/catalyst/catalyst-merged-mining`:
`catalyst.config.json`
`xun.config.json`

## Trubleshooting

> WARNING! All the services are meant to be running us a single instance.
So you can't spawn another container with let's say RPC-Service, it can break the whole system. So in order to fix, tweak things, we will stop/restart/interact with each service one by one.

**Case One**

- Descripton: Somthing wrong with the payment system. 
- Error `daemon {"code":-32700,"data":{"application_code":9},"message":"Wrong amount"}`
- Let's check it out:
- The payments are done by the pool so we will need to check the `pool_catalyst` service.
- `docker-compose stop pool_catalyst` - safely stop the service, so it will finish all the stuff it's doing and won't corrupt any data.
- `docker rm -f pool_catalyst` - we can easily remove the service containers because all the important data is persistent inside the `Docker Volumes`, And this way we are sure, we are starting a new container, that won't conflict.
- WARNING - at this point, the catalyst pool service is down, and we need to restart it ASAP, so the pool will continue to function properly.
- `docker-compose run --rm --service-ports pool_catalyst` - we, start the service in visual mode, to see what's going on.
- WoW, it looks OK, the payment went through this time.
- Conclusion: Because each time the wallet sends a payment it is also locking some amount, and the wallet was brand new with 0 balance, it didn't have time to accumulate enough coins, to send almost 99% of its balance. with time the balance will get bigger from pools fee, and this problem will be resolved by itself. On each restart, the pool tries to make the due payments, and this time the available balance was enough, to make the transaction.
- Now, we are kind of happy... so lets stop the console output with `Ctrl-C` and restart the service as a deamon:
- `docker-compose up -d pool_catalyst`

======================================

- After a while, I see that the problem still exists. So I decided to increase the maturity depth to 60 blocks, this way the coins won't be credited to miners pool account until 60 blocks have been passed, so the payment will be less than the unlocked wallet balance.
- The config file is inside the catalyst_pool container. I can change it locally and then, stop the service, recompile the container, and start it again.  But I decided to login inside the running container and change it live.
- `docker exec -it pool_catalyst bash`
- vi `config.json`
- Change the maturity requirement to from 40 to 60
- `close vim` -> exit the running service `exit`
- restart the service `docker-compose restart pool_catalyst`


## Pool Setup

- `git clone https://github.com/catalystdevelopment/catalyst-merged-mining.git`
- `git checkout AWS`

- `cd ./catalyst-merged-mining.git`

- Execute `docker ps` to list the running containers
- Currently, only `Portainer` is running - it's ok.

## Catalyst

### Cat Daemon

- Start Catalyst daemon in a visual mod. to see if it's doing ok.
- `docker-compose run --rm --service-ports catalyst_deamon`
- We only need to do it once, after I see that it's ok.
- Close it with `Ctrl-C`
- Launch it as a `daemon`
- `docker-compose up -d catalyst_deamon`

### Cat Wallet

- Create the wallet
- `docker-compose run --rm catalyst_wallet`
- Check if it's synced. 
- We can chack the status with: `press: 1->enter->press: 22->enter.`
- We can use that command later to check the wallet balance, etc.

### Cat RPC
 
- Start Catalyst `RPC-SERVICE` in a visual mod. to see if it's doing ok.
- `docker-compose run --rm --service-ports catalyst_rpc_service`
- If it's running OK. Launch it as a `daemon`
- `docker-compose up -d catalyst_rpc_service`

## XUN

### Xun Daemon

- Start Catalyst daemon in a visual mod. to see if it's doing ok.
- `docker-compose run --rm --service-ports xun_deamon`
- We only need to do it once, after we see that it's ok.
- Close it with `Ctrl-C`
- Launch it as a `daemon`
- `docker-compose up -d xun_deamon`


### Xun Wallet

- Create the wallet
- `docker-compose run --rm xun_wallet`
- Check if it's synced. 
- We can use that command later to check the wallet balance, etc.

### Xun RPC
 
- Start Xun `RPC-SERVICE` in a visual mod. to see if it's doing ok.
- `docker-compose run --rm --service-ports xun_rpc_service`
- If it's running OK. Launch it as a `daemon`
- `docker-compose up -d xun_rpc_service`

## Pool

- Start redis `docker-compose up -d redis`
- Compile the pool's base image:
- `docker-compose build --force-rm pool`
- The pools are using it to save some space.
- Edit the pool config files:
  - `catalyst.config.json`
  - `xun.config.json`


- Start the xun pool in test mode.
- `docker-compose run --rm --service-ports pool_xun` 
- If it's ok, start it as a deamon:
- `docker-compose up -d pool_xun`
- Start the Catalyst pool:
- `docker-compose up -d pool_catalyst`

## Misc

> Once all the services are running as daemons. We can't launch them in visual/test mode, this can break the whole thing! 

- So the best way to monitor the logs is:
- Only pools: `docker-compose logs --tail=20 pool_xun pool_catalyst`
- All the services: `docker-compose logs --tail=20`
- No errors - WoW!

**Clear pool and docker logs once a day!**

- `docker exec pool_catalyst sh -c "rm ./logs/*.log"`
- `docker exec pool_xun sh -c "rm ./logs/*.log"`
- `truncate -s 0 /var/lib/docker/containers/*/*-json.log`

**Web Access**

- I configured the security groups. Take a peek.
- Now we can access:
- `http://3.13.173.213:8407/stats` - Catalyst stats
- `http://3.13.173.213:8408/stats` - Xun stats

**SSL**
- `https://alpha.cryptocatalyst.net/cat/stats`
- `https://alpha.cryptocatalyst.net/xun/stats`

**Mining**

- To start mining:
- 3.13.173.213:4442
- 3.13.173.213:4443
- 3.13.173.213:4444

**Catalyst Node (deamon)**

- The `node` exposed at:
- 3.13.173.213:17291
- You can test it at http://3.13.173.213:17291/json_rpc
- It can be used as remote wallet endpoint or anything else related to `catalystd`

