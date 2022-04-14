
import json
import os.path


def load_parameter(key):
    file_path = os.path.join(os.path.dirname(__file__), "parameters.json")
    with open(file_path, 'r') as f:
        data = json.load(f)
        return data[key]
