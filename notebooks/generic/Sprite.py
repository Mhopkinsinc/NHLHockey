from dataclasses import dataclass
from typing import List, Optional
from generic.Tile import *

@dataclass
class Sprite:
    id: Optional[int] = None
    y_pos: Optional[int] = None
    x_pos: Optional[int] = None
    size_tab: Optional[int] = None
    tile_id: Optional[int] = None
    priority: Optional[int] = None
    vflip: Optional[int] = None
    hflip: Optional[int] = None
    width: Optional[int] = None
    height: Optional[int] = None
    pixel_width: Optional[int] = None
    pixel_height: Optional[int] = None
    palette_id: Optional[int] = None
    tiles: Optional[List[Tile]] = None
    data: Optional[bytes] = None