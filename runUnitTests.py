# -*- coding: utf-8 -*-
"""
Created on Mon Aug 14 09:49:13 2017

@author: vmg
"""

from pathlib import Path
import buildingspy.development.regressiontest as r
import shutil
import time

def copy_folder_overwrite(src_folder: Path, dst_base_folder: Path):
    src_folder = src_folder.resolve()
    dst_folder = dst_base_folder.resolve() / src_folder.name

    # Delete the target folder if it exists
    if dst_folder.exists():
        print(f"Deleting existing folder: {dst_folder}")
        shutil.rmtree(dst_folder)

    # Copy the source folder to the target location
    print(f"Copying {src_folder} to {dst_folder}")
    shutil.copytree(src_folder, dst_folder)

    print("Copy complete.")
    
 

    
rt = r.Tester(check_html=False)#,tool="dymola")
LibPath  = Path(r'..\TRANSFORM-Library\TRANSFORM')
ResPath = Path(r'..\TRANSFORM-Library-ReferenceResults')

copy_folder_overwrite(ResPath / 'ReferenceResults', LibPath / 'Resources')
copy_folder_overwrite(ResPath / 'Scripts', LibPath / 'Resources')

start_time = time.time()

rt.showGUI(False)
rt.setLibraryRoot(LibPath.resolve().as_posix())
rt.setNumberOfThreads(8)
#rt.TestSinglePackage('Media.Solids.Examples.Hastelloy_N_Haynes', SinglePack=True)
rt.run()

end_time = time.time()
print(f"Elapsed time: {end_time - start_time:.4f} seconds")