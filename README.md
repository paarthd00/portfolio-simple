# Static Site on Cloudflare Workers

A minimal template for hosting static files on Cloudflare Workers. Terraform manages the Worker, its custom domains, and the zone's HTTPS redirect. There is no build step or CI pipeline: Cloudflare serves the files in `site/` as-is.

## Requirements

- [Terraform](https://developer.hashicorp.com/terraform/install) 1.5 or later
- A Cloudflare account with your domain configured as an active zone
- A Cloudflare API token with permission to manage Workers scripts, custom domains, and the zone setting

## Set up your site

1. Replace the contents of `site/` with your own static site files. Keep the homepage at `site/index.html`.
2. Update canonical URLs, metadata, `robots.txt`, and `sitemap.xml` to use your domain.
3. Create a `.env` file in the repository root. It is gitignored; do not commit it.

   ```dotenv
   CLOUDFLARE_API_TOKEN=your-api-token
   TF_VAR_cloudflare_account_id=your-account-id
   TF_VAR_cloudflare_zone_id=your-zone-id
   TF_VAR_domain=example.com
   TF_VAR_worker_name=my-static-site
   ```

Terraform reads `TF_VAR_<variable_name>` environment variables as input variables. `domain` should be your apex domain; this configuration also attaches `www.<domain>` to the same Worker.

## Deploy

Initialize Terraform once:

```sh
terraform init
```

For convenience, define this function in your current Bash or Zsh session:

```sh
tfapply() (
  set -e
  set -a
  . ./.env
  set +a
  terraform apply -input=false "$@"
)
```

From the repository root, run:

```sh
tfapply
```

Terraform displays its plan and asks for confirmation. To skip the confirmation intentionally, use `tfapply -auto-approve`.

After initial setup, replace or edit files in `site/` and run `tfapply` again. Plain HTML, CSS, JavaScript, images, and other static assets need no separate build or CI step.

## Notes

- Terraform state is local by default and gitignored. Keep it safe; Terraform needs it to manage future changes.
- Keep `.env` and Terraform state out of version control.
- The `www` hostname must be available in the same Cloudflare zone as the apex domain.
