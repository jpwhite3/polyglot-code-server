import unittest
import subprocess
import tempfile
import shlex
import time
import os
import sys
from pathlib import Path


class CommandException(Exception):
    pass


class GitServer:
    def __init__(self):
        self.basedir = tempfile.TemporaryDirectory()
        self.process = None
        self._initialize_repo()

    def __enter__(self):
        self.start()
        return self

    def __exit__(self, type, value, traceback):
        self.stop()
        self.basedir.cleanup()

    def _run_command(self, command_str: str):
        command_args = shlex.split(command_str)
        return subprocess.run(
            command_args,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            cwd=self.basedir.name,
        )

    def _initialize_repo(self):
        commands = [
            "git init",
            'git commit --allow-empty -m "initial commit"',
            "git config receive.denyCurrentBranch updateInstead",
        ]
        for command in commands:
            result = self._run_command(command)
            if result.returncode > 0:
                raise CommandException(result.stdout.decode("utf-8"))

    def start(self):
        cmd_str = f"git daemon --base-path={self.basedir.name} --export-all --enable=receive-pack --reuseaddr --informative-errors --verbose"
        cmd_args = shlex.split(cmd_str)
        if self.process is None:
            self.process = subprocess.Popen(cmd_args)
            time.sleep(1)

    def stop(self):
        if self.process is not None:
            self.process.terminate()
            time.sleep(1)


class TestGitSyncpoint(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.gitsvr = GitServer()
        cls.gitsvr.start()
        commands = [
            "git checkout main",
            'git commit --allow-empty -m "commit #1 on main"',
            'git commit --allow-empty -m "commit #2 on main"',
            'git commit --allow-empty -m "commit #3 on main"',
            "git branch syncpoint-01",
            'git commit --allow-empty -m "commit #4 on main"',
            'git commit --allow-empty -m "commit #5 on main"',
            'git commit --allow-empty -m "commit #6 on main"',
            "git checkout syncpoint-01",
            'git commit --allow-empty -m "commit #1 on syncpoint-01"',
            'git commit --allow-empty -m "commit #2 on syncpoint-01"',
            "git branch syncpoint-02",
            "git checkout syncpoint-02",
            'git commit --allow-empty -m "commit #1 on syncpoint-02"',
            'git commit --allow-empty -m "commit #2 on syncpoint-02"',
            "git branch syncpoint-03",
            "git checkout syncpoint-03",
            'git commit --allow-empty -m "commit #1 on syncpoint-03"',
            "git checkout main",
        ]
        for cmd_str in commands:
            command_args = shlex.split(cmd_str)
            subprocess.run(
                command_args, stdout=subprocess.PIPE, cwd=cls.gitsvr.basedir.name
            )

    @classmethod
    def tearDownClass(cls):
        cls.gitsvr.stop()

    def setUp(self):
        self.remote_repo_dir = self.__class__.gitsvr.basedir.name
        self.working_dir = tempfile.TemporaryDirectory()
        self.local_repo_dir = os.path.join(self.working_dir.name, "localhost")
        command_args = shlex.split(f"git clone git://localhost/ {self.local_repo_dir}")
        p = subprocess.run(
            command_args, stdout=subprocess.PIPE, cwd=self.working_dir.name
        )
        print(p.stdout.decode("utf-8"))
        os.chdir(self.local_repo_dir)

    def tearDown(self):
        self.working_dir.cleanup()

    def test_everything_end_to_end(self):
        # test_repo_is_cwd
        self.assertTrue(os.getcwd().endswith(self.local_repo_dir))

        # test_print_history
        command_args = shlex.split("git log --all --oneline --graph --decorate")
        p = subprocess.run(command_args, stdout=subprocess.PIPE)
        expected = "(HEAD -> main, origin/main, origin/HEAD) commit #6 on main"
        actual = p.stdout.decode("utf-8")
        self.assertIn(expected, actual)

        # test_sync_to_branches
        scripts_dir = Path(__file__).parent.parent
        cmd_path = scripts_dir.joinpath("lvlup-git-sync")
        interpreter = sys.executable
        command_args = shlex.split(f"{interpreter} {str(cmd_path)} syncpoint-01")
        subprocess.run(command_args, stdout=subprocess.PIPE)

        # test_print_history
        command_args = shlex.split("git log --all --oneline --graph --decorate")
        p = subprocess.run(command_args, stdout=subprocess.PIPE)
        expected = "(HEAD -> main, origin/main, origin/HEAD) commit #2 on syncpoint-01"
        actual = p.stdout.decode("utf-8")
        self.assertIn(expected, actual)
