# How to build and run

```bash
docker compose up --build
```

Configure by editing `docker-compose.yml`.

# Upgrade

Before building the new image, some operation could be needed.

## Generate a template configuration file

This is if the new version of OpenRefine has a different `refine.ini` configuration file.

```bash
version="3.7.5"
curl -L "https://github.com/OpenRefine/OpenRefine/releases/download/${version}/openrefine-linux-${version}.tar.gz" |
    tar xz --wildcards '*/refine.ini' --strip-components 1
mv refine.ini refine.ini.template
```

The new `refine.ini.template` should still use the environmental variables as the previous one.
This requires editing the file manually by comparing it to the old version.
`git diff refine.ini.template` can be helpful.
