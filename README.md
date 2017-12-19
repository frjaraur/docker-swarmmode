# Quick 4 nodes Docker Swarm Mode Cluster using Vagrant and Virtualbox#

##This repository will create a working swarm mode cluster for quick deploying, demo and testing of your service and applications. ##

Basic Usage:

1. Download or clone this respository
 1. Install Vagrant
 2. Install Virtualbox

2. Execute **make create** to create a new environment (you can use **make recreate** as well).

3. This will create nodes defined in **config.yml** and will create the swarm cluster for you (using docker swarm mode). 
It defaults to for nodes:

  * swarmnode1 - manager
  * swarmnode2 - manager
  * swarmnode3 - manager
  * swarmnode4 - worker

4. Connect to nodes using vagrant as usual (**vagrant ssh swarmnode1**).

5. When you have finnished all your tests, 
you can execute **make stop** to stop all nodes or **make destroy** to destroy your environment
(__**it will delete all nodes and temporary space**__).

## Notes ##

* Deployment will create 3 interfaces on everynode
 * vagrant internal communication (**internal**)
 * internal docker network with ips configured in **config.yml** (**internal**)
 * bridged interface for connecting to your network using dhcp (**external**)

* **make recreate** will destroy your environment and temporary space and create a new one.

* **config.yml** will let you configure your environment 
(for example adding more nodes, **docker engine version to use and mode**, changing default roles, node ips, domain, etc..)

* If you execut vagrant up for each node, you will have the following options:
  *  **--engine-version** - You can choose between 'experimental', 'test' and 'current' versions and deployment will download
  the required version using its url.
  * **--engine-mode** - Will let you choose between 'default' or 'experimental'.
  * If none of these options is used, deployment will use **config.yml** values.
