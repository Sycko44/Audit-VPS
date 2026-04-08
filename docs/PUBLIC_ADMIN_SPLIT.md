# Public / Admin Split

## Goal

Separate the public interface from the administrator interface.

- `pulseo.me` = public dialogue only
- `admin.pulseo.me` = administrator session and internal tools

## Security rule

The admin host must not be exposed as a public feature surface.

Initial protection level:
- Nginx Basic Auth
- dedicated host: `admin.pulseo.me`

## Included files

- `ops/nginx/pulseo.me.conf`
- `ops/nginx/create_admin_htpasswd.sh`

## Recommended mapping

- `pulseo.me` -> public app on `127.0.0.1:7860`
- `admin.pulseo.me` -> admin app on `127.0.0.1:8000`
- `www.pulseo.me` -> redirect to `pulseo.me`

## Deployment steps

1. Create the admin password file:

```bash
bash ops/nginx/create_admin_htpasswd.sh admin /etc/nginx/.htpasswd_pulseo_admin
```

2. Install the Nginx config:

```bash
sudo cp ops/nginx/pulseo.me.conf /etc/nginx/sites-available/pulseo.me
sudo ln -sf /etc/nginx/sites-available/pulseo.me /etc/nginx/sites-enabled/pulseo.me
sudo nginx -t
sudo systemctl reload nginx
```

3. Verify:

```bash
curl -I https://pulseo.me
curl -I https://www.pulseo.me
curl -I https://admin.pulseo.me
```

Expected behavior:
- `pulseo.me` serves the public dialogue
- `www.pulseo.me` redirects to `pulseo.me`
- `admin.pulseo.me` asks for authentication
