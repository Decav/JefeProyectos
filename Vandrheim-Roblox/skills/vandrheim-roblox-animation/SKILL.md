---
name: vandrheim-roblox-animation
description: Create and validate usable Roblox character animations for Vandrheim RPG in Studio, especially for custom Motor6D rigs authored from JSON. Use for enemy and character animation work; this workflow does not require Moon Animator.
---

# Vandrheim Roblox Animation

Use this skill to create animation clips for the exact rig in the open Vandrheim place. The validated workflow authors motion in JSON, creates Roblox `KeyframeSequence` instances directly in Studio with Luau, stores them in the model's `AnimSaves`, and checks that an `Animator` can play them. Moon Animator is not part of this workflow; use it only if the user explicitly asks for it.

The JSON is the editable authoring source. The `KeyframeSequence` in Studio is the clip that can be previewed and used by Roblox. Registering a sequence with `KeyframeSequenceProvider` for a temporary preview does not publish it as a Roblox asset.

## Inspect the exact rig first

- Resolve the model by its full path in the current Studio DataModel. Confirm the exact model name and parent before creating anything; do not assume a similarly named preview, source, or revision model is the target.
- Enumerate every `Motor6D` under that model and record its `Name`, `Part0`, and `Part1`. Custom rigs can differ from standard R15. Drive only joints that actually exist, and use the rig's actual joint limits and validated biomechanical guidance.
- Inspect the model's `AnimSaves` and `ServerStorage.RBX_ANIMSAVES` branch. Follow the project's current naming and storage pattern, preserving all existing clips.
- Record the current camera type and subject for comparison. Do not assign to `Workspace.CurrentCamera`, and capture the existing view without `camera_position` or `look_at_position` arguments.

## Author the motion

- Choose timing and poses for the requested intent and the character's weight. Do not copy another rig's frame count, angles, intensity, or pacing as fixed defaults.
- Save a JSON source under `Assets/Animations/` using a descriptive, versioned name. Include `animation_name`, `description`, `total_frames`, `fps`, `intensity`, and `keyframes`.
- Each joint entry has `joint`, `frame`, `rotation` (`x`, `y`, `z` in degrees), and `position` (`x`, `y`, `z`). Keep joint names exact and use numeric values. Include a complete pose at frame 0. For looped locomotion, add an explicit final pose that matches frame 0 so the cycle closes cleanly.
- Animate all joints that contribute to the movement, including secondary joints such as elbows and knees on custom rigs. Keep the frame order and joint order stable. Use the project's biomechanical guide for pose logic, then validate the pose on the actual model.

## Build and store the KeyframeSequence

Use Studio's `execute_luau` to decode the JSON and create a `KeyframeSequence` with one `Keyframe` per authored frame. Set each keyframe's `Time` to `frame / fps`. Convert degree rotations to radians when composing its `CFrame`:

```lua
CFrame.new(position.x, position.y, position.z)
    * CFrame.Angles(math.rad(rotation.x), math.rad(rotation.y), math.rad(rotation.z))
```

Build a nested `Pose` hierarchy that follows the rig's part connections. The pose name must match the corresponding `Motor6D.Part1.Name`, not necessarily the Motor6D's own name. For example, a `RootJoint` from `HumanoidRootPart` to `TorsoCore` is represented by a `TorsoCore` pose beneath an identity `HumanoidRootPart` pose. Nest forearms and lower legs beneath their upper-limb poses according to the actual `Part0`/`Part1` chain.

Set `KeyframeSequence.Loop` and `Priority` to fit the clip: locomotion cycles use `Movement` and loop; attacks and one-shot expressions use `Action` and do not loop unless requested. Give both saved copies the same descriptive name. Store the sequence under:

- `ServerStorage.RBX_ANIMSAVES.<model name>`
- `<model>.AnimSaves`

When regenerating a clip, replace only the sequence with that exact name in those locations. Do not delete or overwrite other animations.

## Validate playback and appearance

- Check the JSON parses, every required joint is present once per complete pose, and the final loop pose matches the first. Check the stored clips' keyframe counts, duration, loop flag, priority, and pose tree in both save locations.
- When the model has an `Animator`, validate runtime playback by registering the `KeyframeSequence` temporarily with `KeyframeSequenceProvider`, creating a temporary `Animation`, loading it through the model's `Animator`, and playing the track. Confirm `AnimationTrack.Length`, `IsPlaying`, and non-neutral `Motor6D.Transform` values on the intended joints. Stop the track and remove the temporary `Animation` afterward. Runtime preview registration is not a substitute for saving the `KeyframeSequence`.
- Visually inspect representative poses on the target model. If the Play viewport cannot show the target, an Edit-time static pose can be previewed by temporarily applying each pose `CFrame` to its Motor6D `C0`. First preserve every original `C0` at full precision and each `Transform`; after capture, restore them exactly, remove temporary attributes, and verify the model returns to its baseline. Do not rely on changing the camera to frame the model.
- After any Play preview, return Studio to Edit mode. Confirm the target model is back in its original pose, no preview tracks or temporary instances remain, and the camera type and subject match their recorded values.

## Report the result

State the exact target model and saved sequence paths, the clip duration and priority, and whether the runtime track and visual pose were checked. Link the JSON source. Say plainly if the clip was only staged in Studio and has not been uploaded or published.

