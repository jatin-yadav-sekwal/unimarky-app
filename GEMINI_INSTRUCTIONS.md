# UniMARKY Flutter — Phases 7-9 Implementation Guide for Gemini

> **Working Directory**: `d:\unmarky\apps\mobile`
> **Flutter SDK**: `d:\unmarky\flutter-sdk` (add `d:\unmarky\flutter-sdk\bin` to PATH)
> **Run analysis**: `dart analyze lib/` — must pass with 0 errors

---

## Architecture Rules (MUST FOLLOW)

1. **API calls**: Always use `ApiClient.instance` from `core/network/api_client.dart` (Dio + auth)
2. **State management**: `flutter_riverpod` — use `StateNotifier` for complex state, `setState` for simple screens
3. **Routing**: `go_router` — defined in `router/app_router.dart`
4. **Image upload**: `uploadImage()` from `core/utils/image_upload.dart` (Supabase Storage)
5. **Theme**: Use `Theme.of(context)` — colors, text styles. Use `colorScheme.primary`, `surface`, etc.
6. **No `withOpacity()`**: Use `withValues(alpha: 0.X)` instead (deprecated lint fix)
7. **Curly braces**: Always use `{}` in if/else/for blocks
8. **No unused imports**: Remove all unused imports before committing
9. **Auth provider**: `ref.watch(authProvider)` → `AuthState` with `user`, `isAuthenticated`, `onboardingCompleted`

---

## Existing Code Patterns to Copy

Look at these already-implemented screens for reference:
- **List screen**: `features/marketplace/screens/marketplace_screen.dart` (search, filters, grid, pagination, FAB)
- **Detail screen**: `features/marketplace/screens/marketplace_item_screen.dart` (image, details, actions)
- **Create form**: `features/marketplace/screens/create_listing_screen.dart` (form fields, image picker, API post)
- **Card widget**: `features/marketplace/widgets/marketplace_card.dart` (gradients, badges, onTap)
- **Model**: `features/marketplace/models/marketplace_item.dart` (fromJson, helper constants)

---

## Phase 7: Explore (Food + Housing + Study) — 15 files

### Overview
The bottom nav bar "Explore" tab (index 3) should open an explore hub with 3 sub-sections: Food, Housing, Study. Currently it goes to `/food` directly — change it to `/explore`.

### 7A: Explore Hub Screen (1 file)

#### [NEW] `features/explore/screens/explore_screen.dart`
- A tabbed screen with 3 tabs: **Food**, **Housing**, **Study**
- Use `DefaultTabController` with `TabBar` + `TabBarView`
- Each tab embeds the corresponding list widget
- Route: `/explore` (replace `/food` in bottom nav `_onItemTapped` case 3)

### 7B: Food Feature (5 files)

#### API Endpoints (base: `/api/food`)
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/` | GET | List restaurants. Query: `limit`, `offset` |
| `/:id` | GET | Restaurant detail |
| `/menu` | GET | List menu items. Query: `restaurantId`, `category` |
| `/menu-item/:id` | GET | Single menu item detail |

#### [NEW] `features/food/models/food_models.dart`
```dart
class Restaurant {
  final String id, name, location;
  final String? description, cuisine, tags, address, phone, timing, priceRange, imageUrl;
  final double rating;
  final int reviewCount;
  factory Restaurant.fromJson(Map<String, dynamic> json) => ...
}

class MenuItem {
  final String id, name, restaurantId;
  final String? description, category, imageUrl;
  final double price, rating;
  final int reviewCount;
  final bool isVeg, isAvailable;
  factory MenuItem.fromJson(Map<String, dynamic> json) => ...
}
```

#### [NEW] `features/food/widgets/restaurant_card.dart`
- Card showing: image, name, cuisine, rating stars, priceRange, location
- `onTap` → navigate to `/food/:id`

#### [NEW] `features/food/screens/food_list_screen.dart`
- Stateful widget (embedded in ExploreScreen tab, NOT a standalone scaffold)
- Fetches `GET /food?limit=20&offset=0`
- Shows list of `RestaurantCard` widgets
- Infinite scroll pagination

#### [NEW] `features/food/screens/restaurant_detail_screen.dart`
- Route: `/food/:id`
- Fetches `GET /food/:id` for restaurant info
- Fetches `GET /food/menu?restaurantId=:id` for menu items
- Shows: image, name, cuisine, timing, phone, address, rating
- Shows menu items grouped by category (Starters, Main Course, etc.)
- Each menu item shows: name, price, veg/non-veg badge, availability

#### [NEW] `features/food/widgets/menu_item_card.dart`
- Card for each menu item: name, price, veg indicator (green dot), description
- Compact list tile style

### 7C: Housing Feature (4 files)

#### API Endpoints (base: `/api/accommodation`)
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/` | GET | List accommodations. Query: `limit`, `offset`, `type` (PG/Hostel/Apartment) |
| `/:id` | GET | Accommodation detail (images JSON parsed) |

#### [NEW] `features/housing/models/accommodation_model.dart`
```dart
class Accommodation {
  final String id, name, type, location;
  final String? description, address, phone, amenities, rentRange, contact;
  final double? minPrice, maxPrice, rating;
  final int reviewCount;
  final List<String> images;
  factory Accommodation.fromJson(Map<String, dynamic> json) => ...
}

const accommodationTypes = ['All', 'PG', 'Hostel', 'Apartment'];
```

#### [NEW] `features/housing/widgets/accommodation_card.dart`
- Card: first image or placeholder, name, type badge (PG/Hostel/Apartment), rentRange, rating, location
- `onTap` → navigate to `/housing/:id`

#### [NEW] `features/housing/screens/housing_list_screen.dart`
- Embedded tab (no scaffold)
- Type filter chips: All, PG, Hostel, Apartment
- Fetches `GET /accommodation?type=X&limit=20&offset=0`
- Grid/list of AccommodationCard

#### [NEW] `features/housing/screens/accommodation_detail_screen.dart`
- Route: `/housing/:id`
- Fetches `GET /accommodation/:id`
- Image carousel (PageView with dots indicator)
- Details: name, type, description, amenities list, rent range, phone, address, contact
- Copy phone to clipboard action

### 7D: Study Feature (4 files)

#### API Endpoints (base: `/api/study`)
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/departments` | GET | Returns `{ departments: [...], years: [...], categories: [...] }` |
| `/` | GET | List materials. Required: `department`, `year`. Optional: `category` |

#### [NEW] `features/study/models/study_models.dart`
```dart
class StudyMaterial {
  final String id, department, year, subjectName, category, title;
  final String? description, fileUrl, uploadedBy, uploaderName;
  final DateTime? createdAt;
  factory StudyMaterial.fromJson(Map<String, dynamic> json) => ...
}

const categoryLabels = {
  'previous_year_papers': 'Previous Year Papers',
  'notes': 'Notes',
  'sessional_exams': 'Sessional Exams',
  'assignments': 'Assignments',
  'syllabus': 'Syllabus',
  'reference_books': 'Reference Books',
};
```

#### [NEW] `features/study/widgets/study_material_card.dart`
- Card: title, subject, category badge, uploader name, date
- `onTap` → open fileUrl (copy to clipboard or use url_launcher if available)

#### [NEW] `features/study/screens/study_list_screen.dart`
- Embedded tab (no scaffold)
- Step 1: User selects department from dropdown
- Step 2: User selects year from dropdown
- Then fetches `GET /study?department=X&year=Y`
- Optional category filter chips
- Shows list of StudyMaterialCard

#### [NEW] `features/study/screens/upload_material_screen.dart`
- Route: `/study/upload` (only for superuser/userX roles)
- Form: department dropdown, year dropdown, subject name, category dropdown, title, description, file URL
- POST to `/study`
- NOTE: Fetch `/study/departments` to populate dropdowns dynamically

### 7E: Router Updates
In `router/app_router.dart`:
1. Add import for ExploreScreen
2. Replace `/food` route → ExploreScreen
3. Replace `/food/:id` route → RestaurantDetailScreen
4. Replace `/housing` route → remove (accessed via explore tab)
5. Replace `/housing/:id` route → AccommodationDetailScreen
6. Replace `/study` route → remove (accessed via explore tab)
7. Add `/study/upload` route
8. Change `_onItemTapped` case 3 → `context.go('/explore')`
9. Update `_calculateSelectedIndex` to include `/explore`

---

## Phase 8: Admin & Role Management (5 files)

### 8A: Role Request Feature (2 files)

#### API Endpoints (base: `/api/role-requests`)
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/` | POST | Submit role upgrade request. Body: `{ reason: string }` |
| `/mine` | GET | Get user's own requests |
| `/` | GET | List all pending requests (userX only). Query: `status` |
| `/:id` | PATCH | Approve/reject request (userX only). Body: `{ status: "approved"/"rejected" }` |

#### [NEW] `features/admin/screens/request_role_screen.dart`
- Route: `/request-role`
- If user role is "normal": show form to submit reason (min 10 chars) → POST `/role-requests`
- Also show existing requests from GET `/role-requests/mine` with status badges
- If user role is "superuser": show "You're already a superuser" message

#### [NEW] `features/admin/screens/admin_panel_screen.dart`
- Route: `/admin`
- Only visible to userX role
- Tab 1: **Pending Requests** — list from GET `/role-requests?status=pending`
  - Each card shows: user name, department, university, reason
  - Approve/Reject buttons → PATCH `/role-requests/:id`
- Tab 2: **Reviewed** — list from GET `/role-requests?status=approved` and `status=rejected`

### 8B: Superuser Dashboard (2 files)

#### [NEW] `features/admin/screens/superuser_screen.dart`
- Route: `/superuser`
- Shows superuser-specific actions:
  - "My Food Listings" → shows restaurants from GET `/food/my-listings`
  - "My Accommodations" → shows accommodations from GET `/accommodation/my-listings`
  - "My Study Materials" → shows materials from GET `/study/mine`
- Each section has Add/Edit/Delete capabilities
- Uses existing CRUD endpoints

#### [NEW] `features/admin/widgets/superuser_listing_card.dart`
- Generic card for superuser listings with Edit/Delete buttons
- Edit → navigate to edit screen or show dialog
- Delete → confirmation dialog → DELETE endpoint

### 8C: Profile Enhancement (1 file)

#### [MODIFY] `features/profile/screens/profile_screen.dart`
- Add role badge (normal / superuser / userX)
- Add "Request Role Upgrade" button (for normal users) → navigate to `/request-role`
- Add "Superuser Dashboard" button (for superuser role) → navigate to `/superuser`
- Add "Admin Panel" button (for userX role) → navigate to `/admin`

---

## Phase 9: Polish & Integration (3 files)

### 9A: Profile Edit Screen (1 file)

#### [NEW] `features/profile/screens/edit_profile_screen.dart`
- Route: `/profile/edit`
- Fetches current profile from auth state
- Form: full name, mobile number, department fields
- PATCH `/profiles/me` to update
- Navigate back after save

### 9B: My Content Screen (1 file)

#### [NEW] `features/profile/screens/my_content_screen.dart`
- Route: `/my-content`
- Tabs: My Posts, My Listings (marketplace), My Reports (lost & found)
- Fetches user-specific content from existing API endpoints
- Each item shows edit/delete options

### 9C: Router Final Updates (1 file)

#### [MODIFY] `router/app_router.dart`
- Wire all remaining placeholder routes:
  - `/profile/edit` → EditProfileScreen
  - `/request-role` → RequestRoleScreen
  - `/admin` → AdminPanelScreen
  - `/superuser` → SuperuserScreen
  - `/my-content` → MyContentScreen
- Remove `_PlaceholderScreen` class if no more placeholders remain

---

## Verification Checklist

After implementing each phase:
1. Run `dart analyze lib/` — must show **0 errors, 0 warnings**
2. Check all imports are used
3. Check no `withOpacity()` calls — use `withValues(alpha:)` instead
4. Check all if/else have curly braces
5. Check models have proper `fromJson` factories
6. Check API calls use `ApiClient.instance.get/post/patch/delete`
7. Check navigation uses `context.go()` or `context.push()`

---

## File Summary

| Phase | Feature | Files | Count |
|-------|---------|-------|-------|
| 7A | Explore Hub | explore_screen.dart | 1 |
| 7B | Food | food_models.dart, restaurant_card.dart, food_list_screen.dart, restaurant_detail_screen.dart, menu_item_card.dart | 5 |
| 7C | Housing | accommodation_model.dart, accommodation_card.dart, housing_list_screen.dart, accommodation_detail_screen.dart | 4 |
| 7D | Study | study_models.dart, study_material_card.dart, study_list_screen.dart, upload_material_screen.dart | 4 |
| 7E | Router | app_router.dart (modify) | 1 |
| 8A | Role Requests | request_role_screen.dart, admin_panel_screen.dart | 2 |
| 8B | Superuser | superuser_screen.dart, superuser_listing_card.dart | 2 |
| 8C | Profile | profile_screen.dart (modify) | 1 |
| 9A | Profile Edit | edit_profile_screen.dart | 1 |
| 9B | My Content | my_content_screen.dart | 1 |
| 9C | Router | app_router.dart (modify) | 1 |
| **Total** | | | **23 changes** |

---

## Error Handling Pattern

Use this consistent pattern in all screens:

```dart
try {
  setState(() => _isLoading = true);
  final data = await ApiClient.instance.get('/endpoint');
  setState(() {
    _items = (data['items'] as List? ?? []).map((e) => Model.fromJson(e)).toList();
    _isLoading = false;
  });
} catch (e) {
  if (mounted) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load: $e'), backgroundColor: Colors.red),
    );
  }
}
```

Always check `mounted` before calling `setState` in async callbacks. Always show user-friendly error messages via SnackBar.
