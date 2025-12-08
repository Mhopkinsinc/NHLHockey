from dataclasses import dataclass


@dataclass
class Tile:
    ID: int    
    data: bytes

   # Tile Size Lookup Table
    SIZE_TABLE = {
        0x0: {"tiles": 1, "dimensions": (1, 1), "value": 0x01},
        0x1: {"tiles": 2, "dimensions": (1, 2), "value": 0x02},
        0x2: {"tiles": 3, "dimensions": (1, 3), "value": 0x03},
        0x3: {"tiles": 4, "dimensions": (1, 4), "value": 0x04},
        0x4: {"tiles": 2, "dimensions": (2, 1), "value": 0x02},
        0x5: {"tiles": 4, "dimensions": (2, 2), "value": 0x04},
        0x6: {"tiles": 6, "dimensions": (2, 3), "value": 0x06},
        0x7: {"tiles": 8, "dimensions": (2, 4), "value": 0x08},
        0x8: {"tiles": 3, "dimensions": (3, 1), "value": 0x03},
        0x9: {"tiles": 6, "dimensions": (3, 2), "value": 0x06},
        0xA: {"tiles": 9, "dimensions": (3, 3), "value": 0x09},
        0xB: {"tiles": 12, "dimensions": (3, 4), "value": 0x0C},
        0xC: {"tiles": 4, "dimensions": (4, 1), "value": 0x04},
        0xD: {"tiles": 8, "dimensions": (4, 2), "value": 0x08},
        0xE: {"tiles": 12, "dimensions": (4, 3), "value": 0x0C},
        0xF: {"tiles": 16, "dimensions": (4, 4), "value": 0x10}
    }

    def __init__(self, ID: int = 0, data: bytes = b""):
        self.ID = ID
        self.data = data