# fromthepage-podman
Run FromThePage in a Podman container

## Running

If you want to migrate an existing installation, load a database dump into MySQL
before starting the FromThePage container.
See the section *Initializing a fresh instance* in the 
[MySQL Docker documentation](https://hub.docker.com/_/mysql/).
You can put your data in the `data/` directory.

After loading the existing data, start the FromThePage container.
Depending on the version you are coming from and the size of your database,
running migrations may take a while.
