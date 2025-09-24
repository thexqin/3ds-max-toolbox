# QX Toolbox for 3ds Max 🎨

A collection of powerful, time-saving scripts for 3ds Max artists, originally developed in 2011 and updated in 2014. These scripts were designed to streamline common tasks in architectural visualization and 3D rendering workflows.

---

## 🚀 Key Features

The QX Toolbox is a comprehensive set of utilities neatly organized into a single, intuitive floater. It includes:

* **V-Ray Render Presets**: Quickly set up **Low** or **Medium** quality V-Ray rendering presets with a single click. No more digging through complex settings.
* **Object & Glass Passes**: Generate render passes for objects, glass, or shadows with a single click, automating a tedious post-production task.
* **Asset Management**: Effortlessly **relink missing maps and V-Ray proxies**. The script intelligently searches specified folders and their subdirectories to find and re-path lost assets.
* **Randomized Transformations**: Inject organic variation into your scenes. Randomly **rotate, move, and scale selected objects** to add a touch of realism to large-scale scenes like forests or gravel piles.
* **Object Painting**: Paint objects onto a target surface with customizable rotation, scale, and density. Perfect for scattering rocks, trees, or other props.
* **Selection & Renaming Tools**:
    * **Select by Attribute**: Select objects based on a variety of properties (e.g., material, G-buffer channel, visibility).
    * **Random Selection**: Randomly select a percentage of objects from your current selection.
    * **Rename**: Quickly rename selected objects with options for creating unique names.
* **Utilities & Maintenance**:
    * **Purge Scene**: Clean up your scene by deleting empty layers and resetting a variety of miscellaneous settings.
    * **Lock/Unlock Transforms**: Easily lock or unlock an object's transformations to prevent accidental edits.
    * **Overscan**: Adjust the render frame while preserving your camera's perspective, a handy feature for composition.

---

## 🛠️ Installation

1.  Download the repository as a ZIP file.
2.  Unzip the contents to a folder on your computer.
3.  Open 3ds Max.
4.  Drag and drop the `qx_toolbox.mcr` file into the 3ds Max viewport.
5.  A dialog will pop up, confirming the installation.
6.  To launch the script, go to **Customize** > **Customize User Interface**.
7.  In the "Toolbars" tab, under the "Category" dropdown, find **"QX_Toolbox"**.
8.  Drag the **"QX_Toolbox"** action onto a toolbar in your UI. You can also assign a keyboard shortcut or a quad menu item if you prefer.

---

## 💡 Notes

* **V-Ray Compatibility**: This toolbox was initially built for V-Ray 1.5, 2.0, and 3.0. The render presets may behave differently with newer versions of V-Ray, but the majority of the tools, particularly those for object management and transformation, work perfectly across 3ds Max 2014 through 2025.
* **Undos**: All operations are undoable via the standard **Ctrl+Z** hotkey, so feel free to experiment without worry.
* **File Paths**: Some internal paths are hardcoded for `ms*` files. Ensure all files (`.mse`) from the toolbox are in the same folder as the main `.mcr` file.

Feel free to open an issue or pull request if you find any bugs or have suggestions for improvements. Happy rendering!
