# FromThePage-Podman

Run FromThePage in a Podman (or Docker) container.

Based on [Ryan F. Baumann's docker_fromthepage][df] and derivatives,
this only works with MySQL and starts a development server.

[df]: https://github.com/ryanfb/docker_fromthepage

## Building

There are several build arguments for the Containerfile:

- `REPO`: git repository to clone (default: `https://github.com/benwbrum/fromthepage.git`)
- `FTP_VERSION`: tag or branch to checkout from the git repository (default: `development`)
- `BUNDLER_VERSION`: Bundler version to install (default: `2.4.22`)

Some of these arguments are related.
For example, older versions of FromThePage may need an older version of Bundler.

## Running

Because of the custom database.yml configuration file, FromThePage will read
the database connection information from environment variables.
It should be possible to store this information in Docker or Podman secrets,
but it did not work in our situation, so we resort to storing everything in
`local.env`.

Add the database connection information and other values to `local.env`.
You can use the `local.env.template` file as a starter.

If you want to migrate an existing installation, load a database dump into MySQL
before starting the FromThePage container.
See the section *Initializing a fresh instance* in the 
[MySQL Docker documentation](https://hub.docker.com/_/mysql/).
You can put your data in the `data/` directory.

After loading the existing data, start the FromThePage container.
Depending on the version you are coming from and the size of your database,
running migrations may take a while.

### Reverse proxy

If you run this application behind a reverse proxy, make sure that the proxy
sets the request header `X-Forwarded-Proto: https`, so that the application
understands that the request was made using HTTPS.
It is important that `https` is in lowercase.
