import subprocess
import sys


def generate_app(app_name):
    python_bin = 'virtual_env/bin/python'
    process = subprocess.Popen([python_bin, 'build_from_templates.py', app_name])
    _, error = process.communicate()
    if error:
        print(error)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('Usage: ./run.py app-name')
        sys.exit(1)
    app_name = sys.argv[1]
    if len(app_name) == 0:
        print('App name must be a non-zero length string')
        sys.exit(1)
    generate_app(app_name)