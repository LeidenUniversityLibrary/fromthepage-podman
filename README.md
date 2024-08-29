# FromThePage-Podman

Run FromThePage in a Podman (or Docker) container.

Based on [Ryan F. Baumann's docker_fromthepage][df] and derivatives,
this only works with MySQL and starts a development server.

[df]: https://github.com/ryanfb/docker_fromthepage

## Building

There are several build arguments for the Containerfile:

- `VARIANT`: Ruby version to use (this is a tag for Microsoft's Ruby devcontainer)
  (default: `2.7`)
- `REPO`: git repository to clone (default: `https://github.com/benwbrum/fromthepage.git`)
- `FTP_VERSION`: tag or branch to checkout from the git repository (default: `development`)
- `BUNDLER_VERSION`: Bundler version to install (default: `2.4.22`)

Some of these arguments are related.
For example, older versions of FromThePage may need an older version of Bundler.

## Running

If you want to migrate an existing installation, load a database dump into MySQL
before starting the FromThePage container.
See the section *Initializing a fresh instance* in the 
[MySQL Docker documentation](https://hub.docker.com/_/mysql/).
You can put your data in the `data/` directory.

After loading the existing data, start the FromThePage container.
Depending on the version you are coming from and the size of your database,
running migrations may take a while.
