---
name: roblox-r15-body-skins
description: Create and validate Roblox R15 classic shirt and pants textures for Vandrheim, preserving the project's UV layout and previewing them on an isolated R15 rig. Use for body-skin artwork, not 3D accessories or gameplay integration.
metadata:
  short-description: Create fitted R15 body-skin textures
---

# Vandrheim R15 body-skin workflow

Use this skill for clothing painted onto Roblox R15 body parts through classic Shirt and Pants templates. The deliverable is a pair of UV-aligned PNGs and, when authorized, a preview on a test rig—not separate armor meshes or game integration.

## Scope and references

1. Read the assigned HU, ASSETS_POLICY.md, the relevant set notes, and the matching class UV templates under Assets/Clothing/EST-07/.
2. Follow the user's current slot decision if older HU text conflicts. The established Hunter convention is: chest/torso and gloves/arms are painted into the shirt map; pants/greaves are painted into the pants map. Helmet, shoulders, and weapons remain separate models. Do not turn body-skin slots into accessories.
3. Use approved item icons as visual references for palette and motifs. This workflow does not generate icons unless separately requested.
4. Preserve approved source templates and prior approved PNGs. Create a new, clearly versioned candidate instead of overwriting them.

## Construct the texture maps

1. Work with two distinct maps: classic shirt (torso and arms) and classic pants (legs). Use the exact class/project R15 template for each; do not redraw or rearrange its UV islands.
2. Paint or generate the design in the template's UV layout. A raster-generation tool may help create the artwork, but it must not be trusted to preserve UV boundaries, scale, or alpha. Reapply the canonical template alpha mask after artwork generation. If using ImageGen for the artwork, follow the available imagegen skill as well.
3. Keep details on the correct islands: torso front/back/side faces, mirrored left/right arm faces, and corresponding leg faces. Check seams and front/back continuity in UV space. Put gloves and greaves into those clothing maps, not separate 3D pieces.
4. For this project's current body-skin maps, export PNG RGBA at 585×559 px. Outside-template pixels must be transparent; inside pixels must retain the exact alpha values of the corresponding mask. Do not resize to the 512×512 icon format.
5. On this project's current arm/leg masks, the fourth side face is a separate island; do not locate it by continuing a regular x + col*64 sequence. Locate each island from the canonical mask. In the current template, the fourth right-side face begins at x=215 and the fourth left-side face at x=503; these coordinates are template-specific, so recheck them if the mask changes. Extend paint and gradients through the mask's antialiased edge pixels, then let the canonical alpha mask trim the overpaint instead of leaving boundary pixels uncovered. This correction passed a clean R15 Studio preview reviewed from front, back, and side on the Vandrheim Traveler Starter v3.
6. Use stable, versioned names such as <class>_<tier>_classic_shirt_r15_vN.png and <class>_<tier>_classic_pants_r15_vN.png in the assigned isolated asset area.

## Verify and preview

- Programmatically compare width, height, and every alpha pixel against the matching source mask. Reject or remask any file with shifted islands, changed alpha, or opaque background outside the template.
- Inspect the flattened maps at full size before upload: all clothing should be on intended faces, no details should spill between UV islands, and left/right mirrored faces should read correctly.
- Only upload the PNGs to Roblox when the user has authorized that external asset operation. Record the returned asset IDs; never invent or reuse IDs from a different variant.
- On a clean cloned R15 rig in an isolated Workspace.ModelTest preview, add a Shirt and Pants and set ShirtTemplate and PantsTemplate to the corresponding uploaded IDs. Do not change the source rig or production assets.
- Review front, back, and side views in Studio for UV seams, clipping, and readability at avatar scale. If Studio capture fails, report that visual QA is pending; do not imply approval.
- Keep preview metadata honest: design-only until the user approves the visuals, and not integrated unless a separate authorized dev workflow does that.

## Boundaries and handoff

- Keep generated PNGs, helper scripts, and rigs in the assigned temporary/design area. Do not edit existing project files, source masks, approved assets, canonical HUs, configs, registries, runtime code, or production ReplicatedStorage.
- Do not integrate the clothing into the product. Hand off the two PNG paths, dimensions/mask validation, Roblox asset IDs if uploaded, Studio preview path, and known limitations for the developer/user to review.
- Do not claim that a specific drawing or generation tool was used unless the task record or artifact metadata confirms it.
