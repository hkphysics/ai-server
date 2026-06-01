import os
c.JupyterHub.ip = 'jupyter'
c.JupyterHub.hub_connect_ip = 'jupyter'
c.JupyterHub.bind_url = 'http://jupyter:8000/'
c.Authenticator.admin_users = os.environ['ADMIN_USERS'].split(',')
c.Authenticator.allowed_users = os.environ['ALLOWED_USERS'].split(',')
c.JupyterHub.authenticator_class = 'oauthenticator.google.LocalGoogleOAuthenticator'
c.LocalGoogleOAuthenticator.create_system_users=True
c.LocalGoogleOAuthenticator.client_id = os.environ['GOOGLE_CLIENT_ID']
c.LocalGoogleOAuthenticator.client_secret = os.environ['GOOGLE_CLIENT_SECRET']
c.LocalGoogleOAuthenticator.oauth_callback_url = os.environ['GOOGLE_OAUTH_CALLBACK_URL']
c.LocalGoogleOAuthenticator.auto_login = True
c.LocalGoogleOAuthenticator.add_user_cmd = ['useradd', '-m', '-c', '""', '-g', 'users', '-s', '/bin/bash', '--badname']
c.Cull.timeout = 21600
