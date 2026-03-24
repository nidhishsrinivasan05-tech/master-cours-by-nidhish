import unittest
from utils.helpers import greet, add

class TestHelpers(unittest.TestCase):
    def test_greet(self):
        self.assertEqual(greet("Nidhish"), "Hello, Nidhish!")

    def test_add(self):
        self.assertEqual(add(4, 5), 9)

if __name__ == "__main__":
    unittest.main()
