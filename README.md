## Building

Assume you already have docker installed.

```shell
git clone https://github.com/Jamesits/docker-recursive-dns-resolver.git
cd docker-resursive-dns-resolver
docker build --tag recursive-caching-dns:latest .
```

## Running

You need to mount a config folder (as provided in `config` folder of this repo) to `/config` in container.

```shell
docker run -v `pwd`/config:/config -p 53:53/udp -p 53:53/tcp -p 80:80/tcp -it recursive-caching-dns:latest
```