from dataclasses import dataclass
from typing import Optional
from generic.Sprite import *

@dataclass
class Frame:
    id: Optional[int] = None
    sprstratt: Optional[int] = None
    sprstrhot: Optional[int] = None
    x_hot: Optional[int] = None
    y_hot: Optional[int] = None
    num_sprites: Optional[int] = None
    sprites: Optional[list[Sprite]] = None
    frame_data: Optional[bytes] = None