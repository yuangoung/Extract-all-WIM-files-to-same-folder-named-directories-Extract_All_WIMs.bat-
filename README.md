# wim_batch_extractos.bat
This batch script scans a user-specified folder for all .wim files, then automatically extracts each one using image index 1. Each WIM file is extracted into a new folder with the same name as the WIM file, created in the same directory. After successful extraction, the script can optionally delete the original .wim files.


# wim_creator.bat
This batch script packs a user-specified folder and all of its contents into a .wim file. The generated WIM file is saved in the same parent directory as the source folder and uses the source folder name as the WIM filename.

Important: Run this script as Administrator. DISM capture operations may fail without administrator permissions.
