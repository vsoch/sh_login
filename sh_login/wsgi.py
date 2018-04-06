from sh_login.server import app
import os

if __name__ == "__main__":
    port = int(os.environ.get('SH_LOGIN_FLASK_PORT', 5000))
    app.run(port=port)
