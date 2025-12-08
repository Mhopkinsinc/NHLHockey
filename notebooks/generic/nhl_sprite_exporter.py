import sys
import os
from generic.detect_game_version import identify_file_version
from generic.AnimFile import *

def main(file_path=None):
    # Check if a file path is provided as a command line argument
    if file_path or len(sys.argv) > 1:
        file_path = file_path or sys.argv[1]
        anim_file = identify_file_version(file_path)         # Returns an AnimFile
        print(anim_file.data.raw_anim_data)
    else:
        print("Invalid file was provided.")

# left off here need to set the number of frames based on the file version. Get from 93/94 tables
def set_num_frames(anim_file):
    """
    Sets the number of frames in the AnimFile instance.
    
    Parameters:
        anim_file (AnimFile): The AnimFile instance to update.
    """
    if anim_file.fileversion == AnimFileVersion.NHL92:
        anim_file.num_frames = int.from_bytes(anim_file.data.raw_anim_data[0x02:0x04], byteorder='big') + 1 # 0 based
    elif anim_file.fileversion == AnimFileVersion.NHL93:
        anim_file.num_frames = 0x1F
    elif anim_file.fileversion == AnimFileVersion.NHL94:
        anim_file.num_frames = 0x1F    
    else:
        anim_file.num_frames = 0x1F
    print(f"Number of frames set to: {anim_file.num_frames}")

if __name__ == "__main__":
    main()
    input("Press Enter to exit...")