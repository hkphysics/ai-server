import os
import sys

# --- Base configuration ---
c.JupyterHub.ip = "0.0.0.0"
c.JupyterHub.hub_ip = "0.0.0.0"
c.JupyterHub.hub_connect_ip = "jupyter"
c.JupyterHub.bind_url = "http://jupyter:8000/"

# --- User management ---
def _get_env_list(name: str, default: list | None = None) -> list:
    """Parse a comma-separated env var into a list, with a fallback default."""
    raw = os.environ.get(name, "")
    if not raw and default is not None:
        return default
    if not raw:
        return []
    return [u.strip() for u in raw.split(",") if u.strip()]

admin_users = _get_env_list("ADMIN_USERS", ["admin"])
allowed_users = _get_env_list("ALLOWED_USERS", [])

c.Authenticator.admin_users = admin_users
c.Authenticator.allowed_users = allowed_users

# --- Dynamic authenticator ---
authenticator_class_env = os.environ.get(
    "JUPYTERHUB_AUTHENTICATOR_CLASS",
    "oauthenticator.github.LocalGitHubOAuthenticator",
)
c.JupyterHub.authenticator_class = authenticator_class_env

# Resolve the authenticator class and apply shared OAuth settings
authenticator = getattr(c, authenticator_class_env.split(".")[-1])

authenticator.create_system_users = True
authenticator.client_id = os.environ.get("OAUTH_CLIENT_ID", "")
authenticator.client_secret = os.environ.get("OAUTH_CLIENT_SECRET", "")
authenticator.oauth_callback_url = os.environ.get("OAUTH_CALLBACK_URL", "")
authenticator.auto_login = True
authenticator.add_user_cmd = ["/usr/sbin/jupyterhub-add-user"]
authenticator.username_claim = "email"
authenticator.scope = ["user:email"]

# --- Timeouts ---
c.Cull.timeout = 21600
c.Spawner.start_timeout = 120
c.Spawner.http_timeout = 60
c.OutputProcessor.use_outputs_service = True

openid_url = os.environ.get("OPENID_PROVIDER_URL")
c.JupyterHub.openid_connect_url = openid_url
