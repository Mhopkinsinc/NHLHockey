from dataclasses import dataclass
from typing import List
from .Frame import Frame

@dataclass
class Animation:
    name: str
    frames: List[Frame] = None
