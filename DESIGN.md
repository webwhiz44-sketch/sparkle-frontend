# Sparkle & Spill — App Design & Architecture

## Overview
Sparkle & Spill is a **women-only social platform** (verified via AWS Rekognition face liveness + gender check at signup). It has three distinct content types, a communities feature, and an anonymous confession feed.

---

## The 3 Content Types

### 1. Posts (short-form)
**What it is:** Photo/video with a short caption. Like an Instagram post.
**Create:** Main `+` FAB in bottom nav → `CreatePostScreen`
**Feed:** `PostFeedScreen` — full scrollable feed of all posts
**Home preview:** "Posts" section at the bottom of Home shows 3 most recent posts with "View all →"
**Backend:** `POST /api/posts`, `GET /api/posts` (paginated)
**Status:** ✅ Fully working — create, feed, like, comment, save, polls supported

---

### 2. Spill the Tea (anonymous gossip)
**What it is:** Short anonymous gossip/discussion post. No identity attached.
**Create:** "Spill" tab in bottom nav (water drop icon) → `SpillStoryScreen`
**Feed:** `SpillFeedScreen` — the Spill tab itself shows the feed
**Home:** "Spilling the Tea..." dark banner at the bottom of Home (currently hardcoded teaser, not linked)
**Backend:** `POST /api/anonymous-posts`, `GET /api/anonymous-posts` (paginated)
**Status:** ✅ Fully working — create with tags + optional photo, like, comment

---

### 3. Radiant Stories (long-form)
**What it is:** Long-form written stories — personal essays, experiences, narratives. Like a blog post or Medium article.
**Create:** ❌ Does NOT exist yet — needs a new "Write a Story" screen
**Feed:** ❌ Does NOT exist yet — needs a new Stories feed/list screen
**Detail view:** `StoryDetailScreen` exists but is 100% hardcoded mock data (no model, no postId, no API call)
**Home:** "Radiant Stories" section with silhouette cards + "View all →" currently navigates to `PostFeedScreen` — **WRONG**, should navigate to the Stories feed
**Home:** "Featured Story" card (`_buildFeaturedStoryCard`) is also hardcoded mock
**Backend:** ❌ No stories API exists yet — needs new endpoints

#### What needs to be built for Radiant Stories:
**Frontend:**
- `StoryModel` — data model (id, title, content, coverImageUrl, author, readTime, tags, likeCount, commentCount, createdAt)
- `StoryService` — API calls (create, getFeed, getById, like, unlike)
- `WriteStoryScreen` — create long story UI (title field, rich body text area, cover image picker, tags)
- `StoriesFeedScreen` — scrollable list of story cards (cover image, title, author, read time, tags)
- Rework `StoryDetailScreen` — accept a real `StoryModel`, load from API, show real comments
- Update Home "Radiant Stories" `View all →` to navigate to `StoriesFeedScreen`
- Update Home "Featured Story" card to show real latest story from API
- Add "Write a Story" entry point — either a button in `StoriesFeedScreen` or a dedicated tab/FAB

**Backend:**
- New `stories` table (id, author_id, title, content, cover_image_url, tags, like_count, comment_count, created_at)
- `GET /api/stories` — paginated feed
- `GET /api/stories/{id}` — single story
- `POST /api/stories` — create
- `POST /api/stories/{id}/like` + `DELETE /api/stories/{id}/like`
- `GET /api/stories/{id}/comments` + `POST /api/stories/{id}/comments`

---

## Navigation Structure

```
Bottom Nav:
  [Home]  [Communities]  [+ FAB]  [Spill]  [Me]

Home tab:       HomeScreen
Communities:    CommunitiesScreen → CommunityDetailScreen
+ FAB:          CreatePostScreen (creates a Post)
Spill tab:      SpillFeedScreen (Spill the Tea feed)
Me tab:         ProfileScreen (Stories | Saved | Clubs tabs)
```

**Missing entry point:** There is no tab or button to write a Radiant Story. Options:
- Add a "Write ✦" button inside `StoriesFeedScreen` (recommended — keeps it contextual)
- Or repurpose the `+` FAB to show a picker: Post / Story / Spill

---

## Home Screen Sections (current)

| Section | Widget | Data Source | Status |
|---|---|---|---|
| Hero banner | `_buildHeroBanner()` | Hardcoded | Mock — needs real CTA |
| Radiant Stories header + silhouettes | `_buildRadiantStoriesHeader()` + silhouettes | Hardcoded | Should link to Stories feed |
| Member Spotlight card | `_buildMemberSpotlightCard()` | Hardcoded | Mock — not from API |
| Featured Story card | `_buildFeaturedStoryCard()` | Hardcoded | Should show latest Radiant Story |
| Daily Prompt card | `_buildDailyPromptCard()` | Hardcoded | Mock |
| Posts section | `_buildPostsSectionHeader()` + `_buildApiPostCard()` | `PostService.getFeed()` | ✅ Real data |
| Spilling the Tea banner | `_buildSpillingTeaBanner()` | Hardcoded | Should link to Spill feed |

---

## Screen Inventory

| Screen | File | Status |
|---|---|---|
| Login | `login_screen.dart` | ✅ Working |
| Signup | `signup_screen.dart` | ✅ Working |
| Face Verification | `face_verification_screen.dart` | ✅ Working |
| Home | `home_screen.dart` | Partially real — see table above |
| Post Feed | `post_feed_screen.dart` | ✅ Working |
| Create Post | `create_post_screen.dart` | ✅ Working |
| Spill Feed | `spill_feed_screen.dart` | ✅ Working |
| Spill Story (create) | `spill_story_screen.dart` | ✅ Working |
| Story Detail | `story_detail_screen.dart` | ❌ 100% mock — needs real model + API |
| Stories Feed | — | ❌ Doesn't exist |
| Write Story | — | ❌ Doesn't exist |
| Communities | `communities_screen.dart` | ✅ Working |
| Community Detail | `community_detail_screen.dart` | ✅ Working |
| Comments | `comments_screen.dart` | ✅ Working |
| Profile | `profile_screen.dart` | ✅ Working (Saved + Clubs now real data) |
| Edit Profile | `edit_profile_screen.dart` | ✅ Working |
| Settings | `settings_screen.dart` | Exists |
| Notifications | `notifications_screen.dart` | Exists |
| Main Shell | `main_shell.dart` | ✅ Working |

---

## Color Palette
- Primary pink: `#BE1373`
- Accent pink: `#EC407A`
- Light pink bg: `#FFF0F5`
- Light border: `#FFB6C1`
- Dark bg (Spill): `#1A0A12`
- Text dark: `#1A1A1A`
- Text grey: `#888888`

## Fonts
- Headlines: `GoogleFonts.playfairDisplay` (serif, editorial feel)
- Cursive/branding: `GoogleFonts.dancingScript`
- Body: default Flutter sans-serif

---

## Dev Priority Order (agreed)
1. ✅ High priority buttons — done
2. ✅ Medium priority buttons — done
3. ✅ Saved posts + My Communities (backend + frontend) — done
4. 🔲 **Radiant Stories — full feature** (next up)
   - Backend: stories table + CRUD endpoints
   - Frontend: StoryModel, StoryService, WriteStoryScreen, StoriesFeedScreen, real StoryDetailScreen
