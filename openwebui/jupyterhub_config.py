import os
c.JupyterHub.ip = '0.0.0.0'
c.JupyterHub.hub_ip = '0.0.0.0'
c.JupyterHub.hub_connect_ip = 'jupyter'
c.JupyterHub.bind_url = 'http://jupyter:8000/'
c.Authenticator.admin_users = os.environ['ADMIN_USERS'].split(',')
c.Authenticator.allowed_users = os.environ['ALLOWED_USERS'].split(',')


authenticator_class_env = os.environ['JUPYTERHUB_AUTHENTICATOR_CLASS']
authenticator = getattr(c, authenticator_class_env.split('.')[-1])

# Configure the authenticator dynamically
c.JupyterHub.authenticator_class = authenticator_class_env
authenticator.create_system_users = True
authenticator.client_id = os.environ['OAUTH_CLIENT_ID']
authenticator.client_secret = os.environ['OAUTH_CLIENT_SECRET']
authenticator.oauth_callback_url = os.environ['OAUTH_CALLBACK_URL']
authenticator.auto_login = True
authenticator.add_user_cmd = ['/usr/sbin/jupyterhub-add-user']

c.Cull.timeout = 21600
c.Spawner.start_timeout = 120
c.Spawner.http_timeout = 60
c.OutputProcessor.use_outputs_service = True

