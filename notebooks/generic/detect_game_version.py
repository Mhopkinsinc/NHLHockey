import sys
import os
from generic.AnimFile import AnimFileVersion, AnimFileData, AnimFile
from generic.logger import log_message

def identify_file_version(file_path):
    """
    Identifies the version of an .anim file or ROM based on its binary content.

    Parameters:
        file_path (str): Path to the animation file or ROM file.        

    Returns:
        AnimFile: An instance of AnimFile containing the identified version and data.
        If the file cannot be identified, an AnimFile with version UNKNOWN is returned.
        The data.raw_anim_data attribute of the AnimFile instance will contain the raw animation data if available.

    Raises:
        RuntimeError: If the file cannot be read or analyzed.
    """
    
    try:
        with open(file_path, 'rb') as f:
            
            # Check if it's an .anim file, which starts with 'AA'
            if f.read(2) == b'AA':
                f.seek(0)
                return create_anim_file(AnimFileVersion.NHL92, f.read())

            # Check bytes at offset 0x120 for .bin file (ROM)
            f.seek(0x120)
            offset_bytes = f.read(0xE)
            offset_text = offset_bytes.decode('utf-8', errors='replace').lower()

            # Map identifiers to versions
            version_map = {
                '93': AnimFileVersion.NHL93,
                '94': AnimFileVersion.NHL94,
                '95': AnimFileVersion.NHL95,
                '96': AnimFileVersion.NHL96,
                '97': AnimFileVersion.NHL97,
                '98': AnimFileVersion.NHL98,
                'nhl hockey': AnimFileVersion.NHL92
            }

            # Check for 'nhl' and specific version identifiers
            if 'nhl' in offset_text:
                for identifier, version in version_map.items():
                    if identifier in offset_text:
                        return create_anim_file(version)                        
            
            print("File does not match any known NHL version identifiers.")
            return create_anim_file(AnimFileVersion.UNKNOWN)

    except Exception as e:
        log_message(file_path, str(e))
        print(f"Error with file: {str(e)}")
        return create_anim_file(AnimFileVersion.UNKNOWN)
    
def create_anim_file(version, raw_data=None):
    """Helper function to create an AnimFile instance."""
    anim_file = AnimFile(version)
    anim_file.data = AnimFileData()
    if raw_data is not None:
        anim_file.data.raw_anim_data = raw_data
    else:
        anim_file.load_data_from_version()
    return anim_file