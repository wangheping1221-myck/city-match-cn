# RedNote Live Maker MVP

## Goal

Build a small iOS-native MVP that turns static photos or short videos into real Apple Live Photos, saved directly to the user's Photos library. The app should validate whether a creator-focused Live Photo tool can find demand in the US and Canada, especially among RedNote/Xiaohongshu creators, overseas Chinese users, sellers, travel creators, and local service marketers.

This should not start as a generic "video to live wallpaper" clone. That space is already crowded by intoLive, VideoToLive, and many wallpaper apps. The first version should own a narrower promise:

> Make social-post-ready Live Photos from ordinary photos or clips.

## Target users

1. RedNote/Xiaohongshu creators in the US and Canada.
2. Overseas Chinese small businesses and service sellers.
3. Real estate, travel, beauty, food, and lifestyle creators who want motion inside image-style posts.
4. Users who want a simple no-subscription tool for turning videos/photos into Live Photos.

## Positioning

Working name:

- RedNote Live Maker
- LivePost Maker
- Live Cover Maker
- Motion Live Maker

Recommended first positioning:

> Turn photos and videos into Live Photos for RedNote, social posts, and iPhone albums.

Avoid leading with "wallpaper" only. Wallpaper is a large but crowded market. "Creator/social post Live Photo" is more differentiated.

## MVP feature scope

### 1. Video to Live Photo

Required:

- Pick a video from Photos or Files.
- Trim to 1.5s, 2s, 3s, or 5s.
- Select a key photo frame.
- Export a valid Live Photo.
- Save directly to Photos.

Nice later:

- Reverse / bounce / loop.
- Speed control.
- Mute / keep audio toggle.
- Batch conversion.

### 2. Photo to Live Photo

Required:

- Pick a static image.
- Generate a short motion clip from the image.
- Motion presets:
  - Slow zoom in.
  - Slow zoom out.
  - Gentle pan left.
  - Gentle pan right.
  - Breath / subtle pulse.
- Save directly to Photos as a Live Photo.

This is the most important differentiator because many competitors focus on existing video input.

### 3. Social presets

Required:

- 3:4 RedNote card.
- 1:1 square.
- 9:16 story/reel.

Later:

- Product photo preset.
- Travel preset.
- Food preset.
- Real estate preset.
- Before/after preset.

### 4. Export and save

Required:

- Ask for Photos add-only permission.
- Save the generated Live Photo to the user's library with `PHAssetCreationRequest`.
- Show success screen with instructions:
  - Open Photos.
  - Press and hold to preview.
  - Open RedNote/Xiaohongshu and select the Live Photo from the album.

### 5. Monetization test

Recommended first pricing:

- Free: limited exports, e.g. 3 exports.
- Lifetime unlock: USD 4.99 or 9.99.
- Optional one-export unlock: USD 1.99.

Avoid starting with aggressive weekly subscriptions. Competitors use subscriptions, but a simple trusted utility can differentiate with no-subscription messaging.

## App Store listing draft

### App name options

- RedNote Live Maker
- LivePost Maker
- Video to Live Photo Maker
- Live Cover Maker

If Apple review objects to "RedNote" as trademark/platform naming, use `LivePost Maker` publicly and mention supported workflows in screenshots/copy.

### Subtitle

Photo & video to Live Photos

Alternative:

Live Photos for social posts

### Promotional text

Turn photos and videos into real iPhone Live Photos. Add gentle motion to static images, trim short clips, choose a cover frame, and save directly to Photos for RedNote, social posts, wallpapers, and memories.

### Description

Create real Live Photos from ordinary photos and videos.

LivePost Maker helps creators turn static images and short clips into motion-ready Live Photos that save directly to the iPhone Photos app.

Key features:

- Convert videos into Live Photos.
- Turn static photos into subtle motion Live Photos.
- Choose a key photo frame.
- Trim clips for clean 1.5s, 2s, 3s, or 5s exports.
- Use social-friendly formats like 3:4, 1:1, and 9:16.
- Save directly to Photos.
- Works offline for local photo/video conversion.

Perfect for:

- RedNote/Xiaohongshu posts.
- Product photos.
- Travel memories.
- Food and lifestyle posts.
- iPhone Live Photo albums.
- Dynamic wallpapers.

No complicated file export. Pick, animate, save, and post.

### Keywords

live photo,video to live,live wallpaper,rednote,xiaohongshu,photo animator,motion photo,live maker,video wallpaper,photo to video,creator tools

## Validation plan

### What to validate first

1. Can users understand "photo to Live Photo" immediately?
2. Do RedNote/Xiaohongshu creators care enough to download a separate app?
3. Does direct Photos saving work reliably across recent iOS versions?
4. Does no-subscription positioning improve conversion?
5. Are users more interested in video-to-Live or static-photo-to-Live?

### Early success signals

- Users complete an export without help.
- Users open Photos and see the LIVE badge.
- Users publish the result to RedNote/Xiaohongshu.
- Users ask for more templates rather than basic converter fixes.
- At least some users pay for lifetime unlock after free exports.

### Risks

- US/Canada App Store keyword competition is mature.
- RedNote creator demand may be smaller than China mainland demand.
- Live Photos are less widely used on non-Apple social platforms.
- App review may require clear privacy and Photos permission explanations.
- Native media export edge cases can be time-consuming.

## Recommendation

Proceed only as a focused MVP:

- Do build: static photo to motion Live Photo + video to Live Photo + direct Photos save.
- Do not build: a full video editor, AI generator, wallpaper library, template marketplace, or subscription-heavy app at first.

The sharpest wedge is:

> One-tap social Live Photos from static images.

