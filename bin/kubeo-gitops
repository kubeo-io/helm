#!/usr/bin/env python3
#

# python3 -m venv .venv
# source .venv/bin/activate
# pip3 install pyyaml setuptools

#
# GitOps release operator
#

import argparse
from distutils.command.config import config
import yaml
from pathlib import Path
import os
import subprocess
import io
import re
from pathlib import PurePath
import pprint

helm = 'helm'
git = '/usr/bin/git'
kubectl = 'kubectl'

releases = {}

parser = argparse.ArgumentParser(description='GitOps release operator.')
parser.add_argument('-t', dest='test', action='store_true', help='Test execution. Do not perform helm operations.')
parser.add_argument('--git-scan', dest='gitScan', help='Scan for git repository (or any of the parent directories), looking for changed or added files.')
parser.add_argument('-r', dest='manual', help='Ignore git scan and process a specific release directory. Use this to manually process a release without git changes.')
args = parser.parse_args()

def echo_test(text):
    if args.test:
        print('TEST: ' + text)

#
# Execute a process or rollback process in case of failure
#
def run_shell(execute, workdir, rollback = None):

    if args.test:
        echo_test('Executing: ' + str(execute))
        return

    execRun = subprocess.run(execute, 
            cwd=workdir)

    if execRun.returncode != 0:
        print('Shell execution error: Exit code = ' + str(execRun.returncode))

        if rollback is not None:
            print('  Rollback previous command')
            execRollback = subprocess.run(rollback, 
                cwd=workdir, 
                capture_output=True)

def get_release_from_cache(workdir):
    if workdir in releases:
        return releases[workdir]
    else:
        config = load_release(workdir)
        if config:
            releases[workdir] = config
            return config
        return None

# Load release from workdir, looking for release.yaml or release.yml
def load_release(workdir):
    echo_test('Loading release from directory: ' + str(workdir))

    #If wordir is directory, look for release.yaml or release.yml 
    if workdir is None:
        workdir = os.getcwd()
    elif not os.path.isdir(workdir):
        print('Error: Workdir is not a directory: ' + str(workdir))
        return None
    
    filename = ''
    if os.path.isfile(os.path.join(workdir, 'release.yml')):
        filename = 'release.yml'
    elif os.path.isfile(os.path.join(workdir, 'release.yaml')):
        filename = 'release.yaml'
    else:
        echo_test('No release filename found at: ' + str(workdir))
        return None
    
    p = Path(workdir, filename)
    config = None
    if p.resolve().is_file():
        try:
            config = yaml.safe_load(p.read_text())
            if 'helm' in config:
                print('      -> Release found: Type = Helm release' + ', Name: ' + config['helm']['name'])
                return config
            if 'kubectl' in config:
                print('      -> Release found: Type = Kubectl manifest')
                return config

        except Exception as e:
            print(f'Exception while parsing file {p.resolve().as_posix()}: {e}')
            return None

    #Was a valid yml file but no helm or kubectl section found
    return None

def read_file(filename, gitOperation):
    file = PurePath(filename)
    relese = get_release_from_cache(file.parent)
    if relese:
        print('  ('+ gitOperation +') ' + filename + ', processing...')
    else:
        print('  ('+ gitOperation +') ' + filename + ', no release found in directory, skipping...')

#
# Process the Helm release
#
def process_helm_release(config, workdir):

    print("Helm GitOps operator process release ======================== Starting")
    print("")
    print("")

    if 'repository' in config['helm']:
        for repo in config['helm']['repository']:
            print (' Installing repository: name = ' + repo['name'] + ', path = ' + repo['path'])
            
            run_shell([helm, 'repo', 'add', repo['name'], repo['path']], workdir)
            run_shell([helm, 'repo', 'update', repo['name']], workdir)

    if 'helm' in config:

        helm_callback = [helm]
        release = config['helm']

        if 'operation' not in release:
            print('Error: Operation is mandatory.')
            exit(1)

        if release['operation'] == 'upgrade':
            helm_callback.extend([
                'upgrade',
                '-i'
            ])
        else:
            print('Error: Operation ' + release['operation'] + ' not known.')
            exit(1)

        if release['namespace']:
            helm_callback.extend([
                '--create-namespace',
                '-n',
                release['namespace']
            ])

        if 'name' in release:
            helm_callback.append(release['name'])
        else:
            print('Error: Release name is mandatory.')
            exit(1)

        if 'chart' in release:
            helm_callback.append(release['chart'])
        else:
            print('Error: Chart name is mandatory.')
            exit(1)

        if 'version' in release:
            helm_callback.append('--version')
            helm_callback.append(release['version'])

        if 'values' in release:

            helm_callback.append('-f')
            canonicalValuesFilename = ''
            if release['values'].startswith('/'):
                canonicalValuesFilename = release['values']
            else:
                canonicalValuesFilename = Path(
                    workdir,
                    release['values']).resolve()

            helm_callback.append(canonicalValuesFilename)
        
        if 'overrides' in release:
            for override in release['overrides']:
                if 'name' in override and 'value' in override:
                    helm_callback.append('--set')
                    helm_callback.append(override['name'] + '=' + str(override['value']))
                else:
                    print('Error: Override must contain name and value.')
                    exit(1)

        #print('Executing Helm command at ' + str(workdir) + ' =  ' + str(helm_callback))
        run_shell(helm_callback, workdir)
        print("")
        print("")
        print("Helm GitOps operator process release ======================== Finished")
        print("")
        print("")

def process_kubectl_release(config, workdir):

    print("Kubectl GitOps operator process release ======================== Starting")
    print("")
    print("")

    if 'kubectl' in config:

        kubectl_callback = [kubectl]

        release = config['kubectl']

        if 'operation' not in release:
            print('Error: Operation is mandatory.')
            exit(1)

        if release['operation'] == 'apply':
            kubectl_callback.append('apply')
        else:
            print('Error: Operation ' + release['operation'] + ' not known.')
            exit(1)

        if 'namespace' in release:
            kubectl_callback.extend([
                '-n',
                release['namespace']
            ])

        if 'manifests' in release:
            for manifest in release['manifests']:
                kubectl_callback.append("-f")
                kubectl_callback.append(manifest)

        run_shell(kubectl_callback, workdir)
        print("")
        print("")
        print("Kubectl GitOps operator process release ======================== Finished")
        print("")
        print("")   

#
# Main file controll logic
#

if args.manual is not None:
    # If manual is specified, we ignore git scan and process the specific release directory
    workdir = args.manual
    print('Processing manual release at: ' + workdir)
    config = load_release(workdir)
    if config:
        releases[workdir] = config
        if 'helm' in config:
            process_helm_release(config, workdir)
        if 'kubectl' in config:
            process_kubectl_release(config, workdir)
    else:
        print('No release found in directory: ' + workdir)
    exit(0) 

if args.gitScan is not None:
    if os.path.isdir(args.gitScan):

        gitResult = subprocess.run([git, 'status', '-s'], 
            cwd=args.gitScan, 
            capture_output=True)

        if gitResult.returncode == 0:
            changeLog = subprocess.run([git, 'log', '--name-status', '--oneline', '-1', '--no-color'], 
                cwd=args.gitScan, 
                stdout=subprocess.PIPE,
                text=True)

            if gitResult.returncode == 0:

                buf = io.StringIO(changeLog.stdout)
                line = buf.readline()
                while line:

                    if re.match(r'^[0-9a-z]{7}', line.strip()):
                        commit = line.split(' ', 1)[0]
                        print('Found commit id: ' + commit)

                    elif re.match(r'^M...', line.strip()):
                        filename = re.split(r'^M.', line.strip(), maxsplit=2)[1]
                        read_file(filename, 'M')

                    elif re.match(r'^A...', line.strip()):
                        filename = re.split(r'^A.', line.strip(), maxsplit=2)[1]
                        read_file(filename, 'A')

                    elif re.match(r'^R...', line.strip()):
                        filename = re.split(r'^R.', line.strip(), maxsplit=2)[1]
                        filename = filename.split('\t')[2]
                        read_file(filename, 'R')
                    
                    line = buf.readline()

# pprint.pprint(releases)

if releases:
    print('Releases found: ' + str(len(releases)))
    print('-----------------')
    for workdir, config in releases.items():

        if 'helm' in config:
            process_helm_release(config, workdir)
        
        if 'kubectl' in config:
            process_kubectl_release(config, workdir)
else:
    print('No GitOps releases found. Nothing to do.')