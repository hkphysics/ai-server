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
if authenticator_class_env == "oauthenticator.github.LocalGitHubOAuthenticator":
    authenticator.scope = ["user:email"]

# --- Timeouts ---
c.Cull.timeout = 21600
c.Spawner.start_timeout = 120
c.Spawner.http_timeout = 120
c.OutputProcessor.use_outputs_service = True

openid_url = os.environ.get("OPENID_PROVIDER_URL")
c.JupyterHub.openid_connect_url = openid_url

# MCP Server
c.MCPExtensionApp.mcp_tools = [
    # File system operations (jupyter-ai-tools)
    "jupyter_ai_tools.toolkits.file_system:read",
    "jupyter_ai_tools.toolkits.file_system:write", 
    "jupyter_ai_tools.toolkits.file_system:edit",
    "jupyter_ai_tools.toolkits.file_system:ls",
    "jupyter_ai_tools.toolkits.file_system:glob",
    
    # Notebook operations (jupyter-ai-tools)
    "jupyter_ai_tools.toolkits.notebook:read_notebook",
    "jupyter_ai_tools.toolkits.notebook:edit_cell",
    "jupyter_ai_tools.toolkits.notebook:add_cell", 
    "jupyter_ai_tools.toolkits.notebook:delete_cell",
    "jupyter_ai_tools.toolkits.notebook:create_notebook",
    
    # Git operations (jupyter-ai-tools)
    "jupyter_ai_tools.toolkits.git:git_status",
    "jupyter_ai_tools.toolkits.git:git_add",
    "jupyter_ai_tools.toolkits.git:git_commit",
    "jupyter_ai_tools.toolkits.git:git_push",
    
    # JupyterLab operations (jupyterlab-commands-toolkit)
    "jupyterlab_commands_toolkit.tools:clear_all_outputs_in_notebook",
    "jupyterlab_commands_toolkit.tools:open_document",
    "jupyterlab_commands_toolkit.tools:open_markdown_file_in_preview_mode",
    "jupyterlab_commands_toolkit.tools:show_diff_of_current_notebook",
    
    # Utility functions  
    "os:getcwd",
    "json:dumps",
    "time:time",
    "platform:system",
]
