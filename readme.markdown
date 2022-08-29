scalar-docker
-------------

A Docker container for [scalar]. Uses a submodule to track the code upstream
and copies files found in `patches/` on top of the application, saving us from
having to maintain a fork _and_ a submodule. 

[scalar]: https://github.com/anvc/scalar

## Try it locally

```bash
git clone --recursive https://git.lafayette.edu/dss/scalar-docker
cd scalar-docker
docker compose up -d --build
```

Visit localhost:4000 to browse the installation. Uses mysql:8 image for the DB backend.
