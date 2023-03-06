## Installation process
1. `git clone git@github.com:kallabs/infra.git kallabs`
2. Make sure `make` is installed.
3. Now we have to clone all related repos `cd kallabs && make clone`
4. Add `.env` and `mariadb_init.d/01-database.sql` files inside root folder `kallabs`.
5. Build docker images `docker-compose build`
6. Run containers `docker compose up`

## SSO api
By default it's ran in debug mode, from vscode we can connect to it using the following config:

```
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug SSO API",
            "type": "go",
            "request": "attach",
            "mode": "remote",
            "remotePath": "/usr/src",
            "port": 2346,
            "cwd": "${workspaceFolder}/sso/api/src",
            "host": "127.0.0.1"
        }
    ]
}
```

## Alembic
The tool is used to control SQL migrations, to apply them we can simply run:
```
# To apply migration simply run this:
make migra/apply

# To create new migration file:
make  migra/new msg="some comment"
```