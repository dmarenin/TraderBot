"""
Package setup.
"""

from os.path import join, dirname
from configparser import ConfigParser
from setuptools import setup, find_packages
from pkg_resources import parse_requirements


def package_metadata():
    """Package metadata."""
    meta = ConfigParser()
    meta.read(join('qlua', 'conf', 'meta.ini'))
    return meta['default']


def install_requires(filename):
    """Return list of requirements."""
    with open(filename, 'r') as file:
        return [str(i) for i in parse_requirements(file)]


META = package_metadata()
setup(
    name=META['name'],
    version=META['version'],
    author=META['author'],
    author_email=META['email'],
    url=META['url'],
    project_urls={
        'Bug Tracker': 'https://gitlab.com/abrosimov.a.a/qlua/-/issues',
        'Documentation': 'https://gitlab.com/abrosimov.a.a/qlua/-/wikis/home',
        'Source Code': 'https://gitlab.com/abrosimov.a.a/qlua',
    },
    packages=find_packages(),
    include_package_data=True,
    description=META['description'],
    long_description=open(join(dirname(__file__), 'README.md')).read(),
    long_description_content_type='text/markdown',
    classifiers=[
        'Development Status :: 4 - Beta',
        'Topic :: Communications',
        'Topic :: Office/Business :: Financial',
        'Topic :: Software Development :: Libraries :: Python Modules',
        'Operating System :: OS Independent',
        'Programming Language :: Python :: 3 :: Only',
        'License :: OSI Approved :: Apache Software License',
    ],
    keywords=[
        'quik-lua-rpc',
        'quik',
        'arqa',
        'trading',
        'protobuf',
        'zeromq',
    ],
    license='Apache Software License',
    python_requires='>=3.6.0',
    install_requires=install_requires('requirements.txt'),
    setup_requires=['pytest-runner'],
    tests_require=install_requires('requirements-test.txt'),
    entry_points={
        'console_scripts': [
            'qlua = qlua.__main__:main',
        ]
    },
)
