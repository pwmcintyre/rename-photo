# Move-Photo
A script for renaming photos in a sortable way (using EXIF data and some handy parameters) so you can combine all of your holiday snaps in one folder even though they were taken by 5 different devices.

## To use:

Import module:
```PowerShell
Import-Module C:\Users\peter\move.ps1
```

Make destination
```PowerShell
mkdir ./dest
```

Run
```PowerShell
ls ./source | Move-Photo -destination ./dest
```
