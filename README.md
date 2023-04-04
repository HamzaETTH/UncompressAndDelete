# Uncompress and Delete

This repository contains a Windows Batch script, a registry file, and an icon file to easily uncompress and delete archive files with a right-click context menu.

## Features

- Uncompress and delete archive files (ZIP, RAR, TAR) with a right-click context menu.

- Supports 7-Zip (x86/x64), WinRAR (x86/x64), TAR (available as of Windows 10 build 17063 by default) , and built-in VBS command for ZIP files.

- Automatically creates an output directory for extracted files based on the archive name

- Comes with a registry file for easy context menu integration.

- Includes an extract icon for the context menu.

  

## Usage

Clone or download this repository to your local machine.

**Update the paths to the uncompress_and_delete.bat script and uncompress_and_delete.ico icon in the uncompress_and_delete.reg file. Make sure to use double backslashes (\\) as path separators.**

Double-click on the uncompress_and_delete.reg file to merge it with your Windows Registry. This will add the "Uncompress and delete" option to the context menu for ZIP, RAR, and TAR files.

Right-click on an archive file (ZIP, RAR, or TAR) and select the "Uncompress and delete" option to extract the contents and delete the archive file.
