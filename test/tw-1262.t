#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-

import sys
import os
import unittest
import string
# Ensure python finds the local simpletap module
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from basetest import Task, TestCase


@unittest.skip("WaitingFor TW-1262")
class TestBug1262(TestCase):
    @classmethod
    def setUpClass(cls):
        cls.t = Task()

        command = ("add", "Buy oranges")
        cls.t(command)

        command = ("add", "Buy apples")
        cls.t(command)

        cls.DEPS = ("1", "2")
        command = ("add", "dep:" + ",".join(cls.DEPS), "Make fruit salad!")
        cls.t(command)

    def test_dependency_contains_matches_ID(self):
        """dep.contains matches task IDs"""
        for char in self.DEPS:
            self.t(("list", "dep.contains:{0}".format(char)))

    def test_dependency_contains_not_matches_other(self):
        """dep.contains matches other characters not present in ID nor UUID"""
        for char in set(string.letters).difference(string.hexdigits):
            self.t.runError(("list", "dep.contains:{0}".format(char)))

    def test_dependency_contains_not_UUID(self):
        """dep.contains matches characters in the tasks' UUIDs"""
        # Get the UUID of the task with description "Buy"
        command = ("uuid", "Buy")
        code, out, err = self.t(command)

        # Get only characters that show up in the UUID
        uuid = {chr for chr in out.splitlines()[0] if chr in string.hexdigits}

        for char in uuid:
            if char not in self.DEPS:
                self.t.runError(("list", "dep.contains:{0}".format(char)))


if __name__ == "__main__":
    from simpletap import TAPTestRunner
    unittest.main(testRunner=TAPTestRunner())

# vim: ai sts=4 et sw=4
