from enum import Enum
from dataclasses import dataclass, field
from typing import List, Optional, Union
from generic.Frame import *
import os

class AnimFileVersion(Enum):
    NHL92 = 92
    NHL93 = 93
    NHL94 = 94
    NHL95 = 95
    NHL96 = 96
    NHL97 = 97
    NHL98 = 98
    UNKNOWN = 0

@dataclass
class AnimFileData:
    spa_list: Optional[bytes] = b''
    frame_spritedataoffsets: Optional[bytes] = b''
    frame_hotlist: Optional[bytes] = b''
    sprite_data: Optional[bytes] = b''
    sprite_tiles: Optional[bytes] = b''
    raw_anim_data: Optional[bytes] = b''

@dataclass
class AnimFile:
    fileversion: AnimFileVersion
    num_frames: Optional[int] = 0
    frames: Optional[List[Optional[Frame]]] = field(default_factory=list)
    data: Optional[AnimFileData] = None

    def load_data_from_version(self):
        version_map = {
            AnimFileVersion.NHL92: "92Tables",
            AnimFileVersion.NHL93: "93Tables",
            AnimFileVersion.NHL94: "94Tables",
            AnimFileVersion.NHL95: "95Tables",
            AnimFileVersion.NHL96: "96Tables",
            AnimFileVersion.NHL97: "97Tables",
            AnimFileVersion.NHL98: "98Tables",
        }

        directory = version_map.get(self.fileversion, None)
        if not directory:
            raise ValueError(f"Unsupported version: {self.fileversion}")

        base_path = os.path.join(os.path.dirname(__file__), directory)

        try:            
            self.data.spa_list=self._read_file(os.path.join(base_path, "SPAList.bin")),
            self.data.frame_spritedataoffsets=self._read_file(os.path.join(base_path, "FrmSprDataOff.bin")),
            self.data.frame_hotlist=self._read_file(os.path.join(base_path, "HotList.bin")),
            self.data.sprite_data=self._read_file(os.path.join(base_path, "SprData.bin")),
            self.data.sprite_tiles=self._read_file(os.path.join(base_path, "Spritetiles.bin"))
            
        except FileNotFoundError as e:
            raise FileNotFoundError(f"Missing file for version {self.fileversion}: {e}")

    @staticmethod
    def _read_file(filepath: str) -> bytes:
        with open(filepath, "rb") as file:
            return file.read()