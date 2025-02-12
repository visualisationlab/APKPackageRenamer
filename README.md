# APKPackageRenamer

Bulk rename the Package Name of already built APK's with this script.

## Install applications

**apktool**
Do not install with ``apt`` but follow [these](https://apktool.org/docs/install) instructions.

**zipalign**

**apksigner**

**keytool**

It might be that some of these applications come with Android studio e.g.

## Issues

I ran into an issue with keytool about not being able to understand some parts of the AndroidManifest
Fixed it by cleaning the framework directory
```
apktool empty-framework-dir --force
```
