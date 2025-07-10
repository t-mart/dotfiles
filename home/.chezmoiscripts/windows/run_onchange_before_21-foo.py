import os
import json

# print all os.environ variables in json

print(json.dumps(dict(os.environ), indent=2))

import sys
sys.exit(1)