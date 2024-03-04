import os
import shutil
import sys
from glob import glob
from jinja2 import Environment


BOILER_PLATE = {
    'backend': {
        'static': (
            'Dockerfile',
            'go.sum',
            'auth.go',
        ),
        'templates': (
            ('go', 'mod'),
            ('server', 'go'),
        )
    },
    'frontend': {
        'static': (
            'Dockerfile',
            'index.html',
            'package.json',
            'public',
            'src',
            'tsconfig.json',
            'tsconfig.node.json',
            'vite.config.ts',
        ),
        'templates': (),
    },
}


def create_new_app_folder(app_name):
    new_folder = os.path.join('..', app_name)
    if os.path.exists(new_folder):
        raise FileExistsError
    os.makedirs(new_folder)
    os.makedirs(os.path.join(new_folder, 'backend'))
    os.makedirs(os.path.join(new_folder, 'frontend'))


def build_from_templates(app_name, layer):
    for (file, ext) in BOILER_PLATE[layer]['templates']:
        env = Environment()
        template_file = open(os.path.join('../templates', layer, f'{file}.jinja'))
        template = env.from_string(template_file.read())

        new_file = open(os.path.join('..', app_name, layer, f'{file}.{ext}'), 'w')
        new_file.write(
            template.render(
                app_name=app_name
            )
        )
        new_file.close()


def copy_static_files(app_name, layer):
    dst = os.path.join('..', app_name, layer)
    for file in BOILER_PLATE[layer]['static']:
        src = os.path.join('../templates', layer, file)
        if (os.path.isfile(src)):
            shutil.copy(src, dst)
        else:
            shutil.copytree(src, os.path.join(dst, file))


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('Need to provide a single argument with an app name, e.g. cool-app')
        sys.exit(1)

    _, app_name = sys.argv

    create_new_app_folder(app_name)
    build_from_templates(app_name, 'backend')
    copy_static_files(app_name, 'backend')
    build_from_templates(app_name, 'frontend')
    copy_static_files(app_name, 'frontend')
