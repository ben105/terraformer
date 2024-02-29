import os
import shutil
import sys
from jinja2 import Environment


STATIC_FILES = (
    'Dockerfile',
    'go.sum',
)

TEMPLATE_FILES_AND_EXT = (
    ('auth', 'go'),
    ('server', 'go'),
    
    ('go', 'mod'),
)


def create_new_app_folder(app_name):
    new_folder = os.path.join('../apps', app_name)
    if os.path.exists(new_folder):
        raise FileExistsError
    os.makedirs(new_folder)


def build_from_templates(app_name):
    for (file, ext) in TEMPLATE_FILES_AND_EXT:
        env = Environment()
        template_file = open(os.path.join('../templates', f'{file}.jinja'))
        template = env.from_string(template_file.read())

        new_command_f = open(os.path.join('../apps/', app_name, f'{file}.{ext}'), 'w')
        new_command_f.write(
            template.render(
                app_name=app_name
            )
        )
        new_command_f.close()


def copy_static_files(app_name):
    dst = os.path.join('../apps', app_name)
    for file in STATIC_FILES:
        shutil.copy(os.path.join('../templates', file), dst)


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('Need to provide a single argument with an app name, e.g. cool-app')
        sys.exit(1)

    _, app_name = sys.argv

    create_new_app_folder(app_name)
    build_from_templates(app_name)
    copy_static_files(app_name)
