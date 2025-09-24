# QX Toolbox for 3ds Max 🎨

A collection of powerful, time-saving scripts for 3ds Max artists, originally developed in 2011 and updated in 2014. These scripts were designed to streamline common tasks in architectural visualization and 3D rendering workflows.

## 🚀 Key Features

The QX Toolbox is a comprehensive set of utilities neatly organized into a single, intuitive floater. It includes:

### V-Ray Render Presets & Optimization 💡

This powerful suite of tools helps you manage render settings and optimize your scene for both speed and quality.

* **V-Ray Render Check**: This diagnostic and optimization tool automatically checks your current V-Ray settings and alerts you to common issues that could affect render quality or time. It provides recommendations and one-click solutions to quickly fix problems.
    * **Render Elements Manager**: Review, add, or remove V-Ray Render Elements from a clean, easy-to-use interface.
    * **Quality Check**: Scans your scene for potential issues with **Image Sampler**, **Color Mapping**, **GI settings**, and **System** parameters, highlighting values that may not be optimal for a final render.
    * **Output Validation**: Confirms that your **render output size** and **file-saving settings** are correctly configured.
    * **One-Click Optimization**: Apply recommended settings for high-quality production renders with a single button press.
* **V-Ray Render Switch**: A simplified version of the Render Check tool that provides quick access to core GI and DMC settings. It allows you to quickly switch between **Low** and **Medium** render quality presets for both the GI and DMC sections, streamlining your workflow for test renders and final output.

### Asset & Scene Management

* **V-Ray Material Check**: This tool helps you check and modify V-Ray material parameters across your entire scene.
    * **Find & Select**: Quickly find materials that meet specific criteria (e.g., V-Ray materials with low reflection subdivs or bitmap textures with incorrect blur settings). The tool can automatically load these materials into your Material Editor slots for easy inspection.
    * **Set All**: Apply specific parameter values (e.g., set reflection subdivs to 8) to all materials of a certain type in your scene with a single click.
* **Distributed Rendering**: Manage your V-Ray Distributed Rendering settings with ease. Get a real-time status check on all available servers and assign specific idle servers to your render job.
* **Channel Setting & Render Elements**: Easily assign G-buffer channels to objects using a palette of 45 pre-defined colors. A one-click function automatically creates **MultiMatteElement** render passes for the first 15 G-Buffer channels, ready for compositing.
* **Asset Relinking**: Effortlessly **relink missing maps and V-Ray proxies**. The script intelligently searches specified folders and their subdirectories to find and re-path lost assets.

### General Utilities

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

## 🖼️ Screenshots

A visual guide to the toolbox's main floater and its various functions.

* **General Utilities**: A screenshot showing the main floater with scene maintenance tools.
  [toolbox.png]
* **V-Ray Material Check**: A screenshot of the material management tool, showing how to check and apply specific parameters to materials.
  [toolbox_vray_material.png]
* **Channel Setting**: A screenshot of the color-coded channel assignment tool and its render elements features.
  [toolbox_channel.png]

## 🛠️ Installation

1.  Download the repository as a ZIP file.
2.  Unzip the contents to a folder on your computer.
3.  Open 3ds Max.
4.  Drag and drop the `qx_toolbox.mcr` file into the 3ds Max viewport.
5.  A dialog will pop up, confirming the installation.
6.  To launch the script, go to **Customize** > **Customize User Interface**.
7.  In the "Toolbars" tab, under the "Category" dropdown, find **"QX_Toolbox"**.
8.  Drag the **"QX_Toolbox"** action onto a toolbar in your UI. You can also assign a keyboard shortcut or a quad menu item if you prefer.

## 💡 Notes

* **V-Ray Compatibility**: This toolbox was initially built for V-Ray 1.5, 2.0, and 3.0. The render presets may behave differently with newer versions of V-Ray, but the majority of the tools, particularly those for object management and transformation, work perfectly across 3ds Max 2014 through 2025.
* **Undos**: All operations are undoable via the standard **Ctrl+Z** hotkey, so feel free to experiment without worry.
* **File Paths**: Some internal paths are hardcoded for `ms*` files. Ensure all files (`.mse`) from the toolbox are in the same folder as the main `.mcr` file.

Feel free to open an issue or pull request if you find any bugs or have suggestions for improvements. Happy rendering!
