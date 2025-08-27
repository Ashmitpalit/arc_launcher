# Icon Pack Images

This directory contains preview images for different icon packs.

## Structure
- `material_preview.png` - Material Design icon pack preview
- `ios_preview.png` - iOS style icon pack preview  
- `rounded_preview.png` - Rounded icon pack preview
- `square_preview.png` - Square icon pack preview

## Adding Custom Icon Packs

To add a custom icon pack:

1. Create a new directory for your icon pack
2. Add preview images (recommended size: 200x200px)
3. Update the `IconPackService` to include your new pack
4. Add icon mappings for supported apps

## Icon Pack Format

Each icon pack should include:
- Preview image
- Icon mappings (package name -> icon path)
- Supported app list
- Metadata (name, description, author, version)

## Example Custom Icon Pack Structure

```
custom_pack/
├── preview.png
├── icons/
│   ├── com.whatsapp.png
│   ├── com.facebook.katana.png
│   └── com.instagram.android.png
└── metadata.json
```
