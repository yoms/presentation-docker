class: center, middle

# Docker

---
# Sommaire

1. Principe général de docker
2. Le dockerfile
3. Déploiement d'un docker compose

---
class: center, middle
# PRINCIPE GÉNÉRAL DE DOCKER
---
# DOCKER – CARACTÉRISTIQUES
- Agnostique sur le contenu ;
- Agnostique sur le transporteur ;
- Isolation ;
- Automatisation ;
- Cycle de vie proche du logiciel (Repose sur git).
---
# DOCKER - CONTENEUR

![conteneur-vm](/conteneur-vm.png)

---
# DOCKER – POURQUOI ?
- Faciliter le déploiement des systèmes complexes ;
- S’abstraire des problèmes de dépendances inter-applications ;
- Réduire l’impact de la virtualisation sur les performances ;
- Faciliter la gestion de version des conteneurs d'application (VM/Container).

---
# MISE EN PRATIQUE

![docker-function](/docker-function.png)

---
# MISE EN PRATIQUE

Recherche d'une image :
```sh
docker search httpd
```
---
# MISE EN PRATIQUE

Lancement d’un conteneur :

```sh
docker run -p 80:80 --name httpd httpd
```

```sh
sudo iptables --list
```

---
# MISE EN PRATIQUE
Inspection des dockers lancés sur la machine :


```sh
 docker ps
```

Inspection d’un docker lancé sur la machine :


```sh
 docker inspect httpd
```
---

# MISE EN PRATIQUE
Arrêter un docker :

```sh
 docker stop httpd
```

Relancer un docker arrêté :

```sh
 docker start httpd
```
---

# MISE EN PRATIQUE

Lancement en mode interactif :


```sh
 docker run -it ubuntu /bin/bash
```
---

# MISE EN PRATIQUE

Partage de port :


```sh
 docker run --rm --name httpd httpd
```
--

```sh
 docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' httpd
```
--

```sh
 docker run --rm -p 8080:80 --rm --name httpd httpd
```
---

# MISE EN PRATIQUE

Partage de volume :


```sh
 echo 'delair.ai' > /tmp/index.html
 docker run --rm -v /tmp/index.html:/usr/local/apache2/htdocs/index.html -p 80:80 --rm --name httpd httpd
```

```sh
docker inspect httpd | jq '.[].HostConfig.Binds'
```

--
Mode détaché :


```sh
 docker run -d -p 80:80 --name httpd httpd
```
---
# CYCLE DE VIE D’UN CONTENEUR DOCKER

- docker ps : affiche les dockers en cours d'exécution ;
- docker logs : affiche les logs d'un conteneur ;
- docker inspect : afficher la description d'un conteneur ;
- docker events : liste tous les évènements venant des conteneurs ;
- docker port : affiche le port public d'un conteneur ;
- docker top : affiche les processus tournant dans le conteneur ;
- docker stats : affiche l'utilisation des ressources d'un conteneur ;
- docker diff : affiche les changements du conteneur depuis son lancement.
---

# CYCLE DE VIE D’UN CONTENEUR DOCKER

![docker-life](/docker-life.png)

---
# APPLICATION MULTI-CONTENEUR
Afin de faciliter le déploiement de conteneurs interconnectés docker permet de créer des liens entre eux.

Ce lien permet d’ajouter une règle dans le ficher host du docker lié.
---
# MISE EN PRATIQUE
Lancement du docker de données :

```sh
 docker run -d --name redis redis
```
--
Lancement de l’interface web connectée au docker de données :


```sh
 docker run --rm --name node --link redis:redis -p 8080:8080 ghormiere/node
```

[localhost:8080](http://localhost:8080)

```sh
docker exec -it node cat /etc/hosts
```

---
# APPLICATION MULTI-CONTENEUR
Le docker volume permet de partager un volume contenu par un docker vers d'autres dockers.

Cela permet par exemple de monter un dossier partagé par plusieurs applications.

---
# MISE EN PRATIQUE

Lancement du docker de données :


```sh
 docker run -d --name redis redis
```
--

Création d’un volume de données docker :

```sh
 docker volume create node-volume
```
--

Lancement de l’interface web connectée au docker de données et montant un volume de données :

```sh
 docker run --rm --name node -v node-volume:/tmp --link redis:redis -p 8080:8080 ghormiere/node
```

[localhost:8080](http://localhost:8080/folder)

```sh
docker run -it --rm -v node-volume:/tmp ubuntu bash
```

---
# PRINCIPE GÉNÉRAL DE DOCKER GESTION DES IMAGES

- docker images : liste toutes les images ;
- docker import : crée une image à partir d'une tarball ;
- docker build : crée une image à partir d'un Dockerfile ;
- docker commit : crée une image à partir d'un conteneur ;
- docker rmi : supprime une image ;
- docker load : charge une image à partir d'un fichier tar ;
- docker save : sauvegarde une image à partir d'un fichier tar.
---
# GESTION DES IMAGES

Fonctionnement du commit dans docker
- [1] docker run -it --rm --name ubuntu ubuntu /bin/bash
- [1] apt-get update && apt-get install vim
- [2] docker commit --message "Ubuntu with vim" ubuntu ghormiere/ubuntu
- [1] docker run -it --rm --name ubuntu ghormiere/ubuntu /bin/bash
- [2] docker ps
- [2] docker inspect ubuntu

---
class: center, middle

# LE DOCKERFILE

---
# QU’ES AQUÒ ?
Le Dockerfile est un formalisme permettant d’automatiser la construction d’un docker.

---
# EXEMPLE
```Dockerfile
FROM ubuntu

MAINTAINER guillaume.hormiere@delair.aero

RUN apt-get update && apt-get -y install vim
```
---

# CONSTRUCTION DE L’IMAGE


```sh
 docker build -t ghormiere/ubuntu .
```

---
class: split-50

# PROCESSUS DE CONSTRUCTION DE L’IMAGE
.column[
    ![docker-layer](/docker-layer.png)
]

.column[

```Dockerfile
FROM ubuntu
MAINTAINER gh@d.a
RUN apt-get update && \
    apt-get -y install vim
ADD hellodocker.sh /hellodocker.sh
ENTRYPOINT ["/bin/bash"]
CMD ["/hellodocker.sh"]
```

```sh
docker build -t test .
```

```sh
dive test
docker history test
```
]

---

# INSTRUCTIONS

- FROM : définit à partir de quelle image on travaille, la plus commune est Ubuntu ;
- MAINTAINER : information permettant de savoir qui maintient le Dockerfile ;
- RUN : permet de lancer une commande [!] le dossier courant est redéfini à chaque appel de cette commande [!] ;
- COPY : permet d'ajouter un fichier du dossier courant du Dockerfile dans l'image docker ;
- ADD : permet d'ajouter un fichier ou une URL dans l'image Docker [!] si le fichier est un tar il sera automatiquement extrait [!] ;
- CMD : permet de définir la commande par défaut de l'image Docker. Quand la commande CMD est utilisée avec la commande ENTRYPOINT la commande CMD sera l'argument par défaut passé à l'ENTRYPOINT ;
---
# INSTRUCTIONS - 2
- ENTRYPOINT : permet de définir la commande exécutée lors du lancement de l'image docker ;
- EXPOSE : permet aux applications du docker d'écouter sur ce port et à l'hôte d'accéder à ce port ;
- ENV : permet de définir une variable d'environnement ;
- VOLUME : permet de définir un volume où les données persistantes peuvent être stockées ;
- USER : permet de spécifier l'utilisateur (nom ou UID) qui exécute les commandes RUN, CMD et ENTRYPOINT lors de la construction de l'image docker ;
- WORKDIR : Permet de définir le dossier dans lequel les commandes RUN, CMD, ENTRYPOINT, COPY et ADD vont êtres appelées.
- HEALTHCHECK : Permet de définir une commande pour voir si le docker tourne toujours correctement.
---
# BONNES PRATIQUES
- Utiliser une .dockerignore afin d'ignorer les fichiers inutiles autours du Dockerfile, lors de la création de l'image le docker-engine charge tous les fichiers/dossiers qui se trouvent dans le répertoire de travail ;
- N'installer que le nécessaire afin de réduire au maximum la taille de votre image ;
- Dans le meilleur des mondes, on ne devrait faire tourner qu'un seul processus par Docker ;
- Minimiser le nombre de layer de l'image Docker afin de réduire la taille de l'image et son temps de chargement;
- Une image Docker doit être aussi éphémère que possible. Elle doit pouvoir être remplacée et reconstruite le plus facilement possible. Aka : Le Dockerfile doit être autosuffisant.
---
class: center, middle

# DOCKER COMPOSE
---
# DOCKER COMPOSE – QU’ES AQUÒ ?
Docker compose permet de décrire une infrastructure ainsi que les connexions entre les Dockers. La description de l'infrastructure se fait via un fichier YAML.
---
# DOCKER-COMPOSE FILE – EXEMPLE
```yaml
version: "3.4"

networks:
  network-local:
volumes:
  data:
services:
    node:
        build: node/
        ports:
            - 8080:8080
        networks:
            - network-local
        links:
            - redis
        volumes: 
            - data:/tmp

    redis:
        image: redis
        networks:
            - network-local
        ports:
            - "6379"
```
---
# OU SONT MES DONNEES ?
```sh
docker volume inspect compose_data
sudo ls /var/lib/docker/volumes/compose_data/_data
sudo cat /var/lib/docker/volumes/compose_data/_data/package.json
```
---
# COMMANDE DOCKER-COMPOSE

- build : chemin du répertoire contenant le Dockerfile à construire ;
- image : permet de définir l'image du docker lancé ;
- links : permet de définir un lien entre les Dockers ;
- ports : même fonctionnement que -p 80:80 ;
- volumes_from : monte le volume à partir d'un autre service ou d'un autre conteneur ;
- volumes : même fonctionnement que -v /tmp:/tmp ;
- expose : permet d'exposer un port du Docker en surchargeant sa configuration ;
- environment : permet de définir des variables d'environnement.
- Mais aussi : command, cgroup_parent, container_name, devices, dns, dns_search, dockerfile, env_file, extends, external_links, extra_hosts, labels, log_driver, log_opt, net, pid, security_opt, limits, volumes, volume_driver, cap_add, cap_drop, cpu_shares, cpuset, domainname, ntrypoint, hostname, ipc, mac_address, mem_limit, memswap_limit, privileged, read_only, estart, stdin_open, tty, user, working_dir
---

# DOCKER COMPOSE – A SAVOIR
- Les Dockers sont tous lancés en même temps. On ne peut pas attendre qu’une base de données soit lancée pour exécuter le site web qui en dépend ;
- La commande docker-compose manage l’ensemble des Docker présents dans le fichier YAML.
---

class: center, middle
# The end...
---